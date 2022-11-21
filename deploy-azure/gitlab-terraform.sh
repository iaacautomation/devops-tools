#!/bin/sh -e

# Helpers
terraform_is_at_least() {
  [ "${1}" = "$(terraform -version | awk -v min="${1}" '/^Terraform v/{ sub(/^v/, "", $2); print min; print $2 }' | sort -V | head -n1)" ]
  return $?
}

if [ "${DEBUG_OUTPUT}" = "true" ]; then
    set -x
fi

TF_PLAN_CACHE="${TF_PLAN_CACHE:-plan.cache}"
TF_PLAN_JSON="${TF_PLAN_JSON:-plan.json}"

JQ_PLAN='
  (
    [.resource_changes[]?.change.actions?] | flatten
  ) | {
    "create":(map(select(.=="create")) | length),
    "update":(map(select(.=="update")) | length),
    "delete":(map(select(.=="delete")) | length)
  }
'

# If TF_USERNAME is unset then default to GITLAB_USER_LOGIN
TF_USERNAME="${TF_USERNAME:-${GITLAB_USER_LOGIN}}"

# If TF_PASSWORD is unset then default to gitlab-ci-token/CI_JOB_TOKEN
if [ -z "${TF_PASSWORD}" ]; then
  TF_USERNAME="gitlab-ci-token"
  TF_PASSWORD="${CI_JOB_TOKEN}"
fi

# If TF_ADDRESS is unset but TF_STATE_NAME is provided, then default to GitLab backend in current project
if [ -n "${TF_STATE_NAME}" ]; then
  TF_ADDRESS="${TF_ADDRESS:-${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/terraform/state/${TF_STATE_NAME}}"
fi

# If TF_ROOT is set then use the -chdir option
if [ -n "${TF_ROOT}" ]; then
  abs_tf_root=$(cd "${CI_PROJECT_DIR}"; realpath "${TF_ROOT}")

  TF_CHDIR_OPT="-chdir=${abs_tf_root}"
fi

# Set variables for the HTTP backend to default to TF_* values
export TF_HTTP_ADDRESS="${TF_HTTP_ADDRESS:-${TF_ADDRESS}}"
export TF_HTTP_LOCK_ADDRESS="${TF_HTTP_LOCK_ADDRESS:-${TF_ADDRESS}/lock}"
export TF_HTTP_LOCK_METHOD="${TF_HTTP_LOCK_METHOD:-POST}"
export TF_HTTP_UNLOCK_ADDRESS="${TF_HTTP_UNLOCK_ADDRESS:-${TF_ADDRESS}/lock}"
export TF_HTTP_UNLOCK_METHOD="${TF_HTTP_UNLOCK_METHOD:-DELETE}"
export TF_HTTP_USERNAME="${TF_HTTP_USERNAME:-${TF_USERNAME}}"
export TF_HTTP_PASSWORD="${TF_HTTP_PASSWORD:-${TF_PASSWORD}}"
export TF_HTTP_RETRY_WAIT_MIN="${TF_HTTP_RETRY_WAIT_MIN:-5}"

# Expose Gitlab specific variables to terraform since no -tf-var is available
# Usable in the .tf file as variable "CI_JOB_ID" { type = string } etc
export TF_VAR_CI_JOB_ID="${TF_VAR_CI_JOB_ID:-${CI_JOB_ID}}"
export TF_VAR_CI_COMMIT_SHA="${TF_VAR_CI_COMMIT_SHA:-${CI_COMMIT_SHA}}"
export TF_VAR_CI_JOB_STAGE="${TF_VAR_CI_JOB_STAGE:-${CI_JOB_STAGE}}"
export TF_VAR_CI_PROJECT_ID="${TF_VAR_CI_PROJECT_ID:-${CI_PROJECT_ID}}"
export TF_VAR_CI_PROJECT_NAME="${TF_VAR_CI_PROJECT_NAME:-${CI_PROJECT_NAME}}"
export TF_VAR_CI_PROJECT_NAMESPACE="${TF_VAR_CI_PROJECT_NAMESPACE:-${CI_PROJECT_NAMESPACE}}"
export TF_VAR_CI_PROJECT_PATH="${TF_VAR_CI_PROJECT_PATH:-${CI_PROJECT_PATH}}"
export TF_VAR_CI_PROJECT_URL="${TF_VAR_CI_PROJECT_URL:-${CI_PROJECT_URL}}"

# Use terraform automation mode (will remove some verbose unneeded messages)
export TF_IN_AUTOMATION=true

# Set a Terraform CLI Configuration File
export TF_CLI_CONFIG_FILE="${TF_CLI_CONFIG_FILE:-$HOME/.terraformrc}"

# Authenticate to private registry
if terraform_is_at_least 1.2.0; then
  # From Terraform 1.2.0 and later, we can use TF_TOKEN_your_domain_name to authenticate to registry.
  # The credential environment variable has the following requirements:
  # - Domain names containing non-ASCII characters are converted to their punycode equivalent with an ACE prefix
  # - Periods are encoded as underscores
  # - Hyphens are encoded as double underscores
  # For more info, see https://www.terraform.io/cli/config/config-file#environment-variable-credentials
  if [ "${CI_SERVER_PROTOCOL}" = "https" ] && [ -n "${CI_SERVER_HOST}" ]; then
    tf_token_var_name=TF_TOKEN_$(idn2 "${CI_SERVER_HOST}" | sed 's/\./_/g' | sed 's/-/__/g')
    export "${tf_token_var_name}"="${CI_JOB_TOKEN}"
  fi
else
  # If we have a version older than 1.2.0, we use the credentials file.
  # This authentication method can be safely deleted when we'll remove support for Terraform 1.0 and 1.1
  if [ ! -f "${TF_CLI_CONFIG_FILE}" ] && [ "${CI_SERVER_PROTOCOL}" = "https" ] && [ -n "${CI_SERVER_HOST}" ] && [ -n "${CI_SERVER_PORT}" ]; then
  cat << EOF > "${TF_CLI_CONFIG_FILE}"
credentials "${CI_SERVER_HOST}:${CI_SERVER_PORT}" {
token = "${CI_JOB_TOKEN}"
}
EOF
  fi
fi

init() {
  # We want to allow word splitting here for TF_INIT_FLAGS
  # shellcheck disable=SC2086
  terraform "${TF_CHDIR_OPT}" init "${@}" -input=false -reconfigure ${TF_INIT_FLAGS}
}

case "${1}" in
  "apply")
    init
    terraform "${TF_CHDIR_OPT}" "${@}" -input=false "${TF_PLAN_CACHE}"
  ;;
  "destroy")
    init
    terraform "${TF_CHDIR_OPT}" "${@}" -auto-approve
  ;;
  "fmt")
    terraform "${TF_CHDIR_OPT}" "${@}" -check -diff -recursive
  ;;
  "init")
    # shift argument list „one to the left“ to not call 'terraform init init'
    shift
    init "${@}"
  ;;
  "plan")
    init
    terraform "${TF_CHDIR_OPT}" "${@}" -input=false -out="${TF_PLAN_CACHE}"
  ;;
  "plan-json")
    terraform "${TF_CHDIR_OPT}" show -json "${TF_PLAN_CACHE}" | \
      jq -r "${JQ_PLAN}" \
      > "${TF_PLAN_JSON}"
  ;;
  "validate")
    init -backend=false
    terraform "${TF_CHDIR_OPT}" "${@}"
  ;;
  *)
    terraform "${@}"
  ;;
esac
