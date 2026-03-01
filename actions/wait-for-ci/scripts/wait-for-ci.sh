#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# Used to colorize output
RED='\e[0;31m'
GREEN='\e[0;32m'
YELLOW='\e[0;33m'
BLUE='\e[0;34m'
PURPLE='\e[0;35m'
CYAN='\e[0;36m'
LIGHT_GREEN='\e[0;92m'
LIGHT_CYAN='\e[0;96m'
RESET='\e[0m'

script_path=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")

get_checks_status() {
  local commit_sha=$1
  local repo=$2

  readarray -t commit_checks < <(
    gh api "/repos/${repo}/commits/${commit_sha}/check-runs" \
      --paginate \
      --jq '.check_runs[] | {
        name: .name,
        bucket: (.conclusion // .status),
        link: .html_url
      }'
  )

  check_runs=("${commit_checks[@]}")
}

is_excluded() {
  local name=$1
  local exclude_patterns=$2

  IFS=',' read -r -a patterns_array <<<"${exclude_patterns}"
  for pattern in "${patterns_array[@]}"; do
    if [[ -n "${pattern}" && "${name}" =~ ${pattern} ]]; then
      return 0
    fi
  done
  return 1
}

get_combined_status() {
  local commit_sha=$1
  local fail_fast=$2
  local exclude_patterns=$3
  local self_job_name=$4
  local repository=$5
  local pending_checks=0
  local failed_checks=0

  printf "\n${PURPLE}Checking CI status for commit${RESET} '%s'.\n" "${commit_sha}"
  get_checks_status "${commit_sha}" "${repository}"

  for check in "${check_runs[@]}"; do
    name=$(jq -r '.name' <<<"${check}")
    status=$(jq -r '.bucket' <<<"${check}")
    status_icon="✅"
    if [ "${status}" == "fail" ] || [ "${status}" == "cancel" ] || [ "${status}" == "timed_out" ] || [ "${status}" == "failure" ] || [ "${status}" == "cancelled" ] || [ "${status}" == "failed" ]; then
      status_icon="❌"
    fi
    if [ "${status}" == "pending" ] || [ "${status}" == "in_progress" ] || [ "${status}" == "queued" ]; then
      status_icon="⏳"
    fi
    printf "${BLUE}%s Check:${RESET} %s\n" "${status_icon}" "${name}"

    if [ "${name}" == "${self_job_name}" ]; then
      printf " -->${CYAN} Skipping self job '%s'...${RESET}\n" "${name}"
      continue
    fi

    if is_excluded "${name}" "${exclude_patterns}"; then
      printf " -->${YELLOW} Skipping check '%s' as it matches an exclude pattern...${RESET}\n" "${name}"
      continue
    fi

    if [ "${status}" == "fail" ] || [ "${status}" == "cancel" ] || [ "${status}" == "timed_out" ] || [ "${status}" == "failure" ] || [ "${status}" == "cancelled" ] || [ "${status}" == "failed" ]; then
      failed_checks=$((failed_checks + 1))
      if [ "${fail_fast}" == "true" ]; then
        break
      fi
    fi
    if [ "${status}" == "pending" ] || [ "${status}" == "in_progress" ] || [ "${status}" == "queued" ]; then
      pending_checks=$((pending_checks + 1))
    fi
  done

  if [ "${failed_checks}" -gt 0 ]; then
    combined_status="fail"
  elif [ "${pending_checks}" -gt 0 ]; then
    combined_status="pending"
  else
    combined_status="success"
  fi
}

# Usage & argument parsing
# ------------------------
display_usage() {
	cat <<-EOF
Script that waits for CI to complete successfully on a given pull request or merge queue. It first waits for 10 seconds 
before starting to poll. It will time out after a given time (default: 30 minutes).

Requirements:
- GitHub CLI (gh)
- jq
- GITHUB_TOKEN env var to be set with a token that has repo access.

		USAGE:
		  $(basename "${script_path}") [OPTIONS]

		OPTIONS:
		  -h    Display usage information

		  -c    Commit SHA to check
		  -r    Repository name (e.g. "owner/repo")
      -j    Self job name, as it is defined at the workflow level (to exclude from checks)
      -t    Time out in minutes (default: 30)
      -i    Polling interval in seconds (default: 10)
      -f    Fail fast if the pull request has a failure status (default: true)
      -e    Comma-separated list of job name patterns to ignore (supports regex) (default: "")
	EOF
}

commit_sha=
repository=
self_job_name=
time_out_in_minutes=30
polling_interval_in_seconds=10
fail_fast="true"
exclude_job_patterns=""
while getopts 'hc:r:j:t:i:f:e:' opt; do
  case "${opt}" in
  c)
    commit_sha="${OPTARG}"
    ;;
  r)
    repository="${OPTARG}"
    ;;
  j)
    self_job_name="${OPTARG}"
    ;;
  t)
    time_out_in_minutes="${OPTARG}"
    ;;
  i)
    polling_interval_in_seconds="${OPTARG}"
    ;;
  f)
    fail_fast="${OPTARG}"
    ;;
  e)
    exclude_job_patterns="${OPTARG}"
    ;;
  h)
    display_usage
    exit 0
    ;;
  esac
done

if [[ -z "${commit_sha}" ]]; then
  printf "\n${RED}Error: Missing required argument -> 'commit_sha'.${RESET}\n" >&2
  display_usage >&2
  exit 2
fi
# validate commit_sha format (7-40 hex characters for short/full SHA)
if ! [[ "${commit_sha}" =~ ^[0-9a-f]{7,40}$ ]]; then
  printf "\n${RED}Error: Invalid commit SHA format.${RESET} Must be a valid git commit hash (7-40 hexadecimal characters).\n" >&2
  display_usage >&2
  exit 2
fi
if [[ -z "${repository}" ]]; then
  printf "\n${RED}Error: Missing required argument -> 'repository'.${RESET}\n" >&2
  display_usage >&2
  exit 2
fi
if [[ -z "${self_job_name}" ]]; then
  printf "\n${RED}Error: Missing required argument -> 'self_job_name'.${RESET}\n" >&2
  display_usage >&2
  exit 2
fi
# convert timeout to seconds
time_out_in_seconds=$((time_out_in_minutes * 60))
# timeout should be a positive integer from 1 to 240 (4 hours)
if (( time_out_in_minutes < 1 || time_out_in_minutes > 240 )); then
  printf "\n${RED}Error: Invalid timeout value.${RESET} Must be between 1 and 240 minutes (4 hours).\n" >&2
  exit 2
fi
# polling interval should be a positive integer from 5 to 300 (5 minutes)
if (( polling_interval_in_seconds < 5 || polling_interval_in_seconds > 300 )); then
  printf "\n${RED}Error: Invalid polling interval value.${RESET} Must be between 5 and 300 seconds (5 minutes).\n" >&2
  exit 2
fi
# fail_fast should be either true or false
if ! [[ "${fail_fast}" =~ ^(true|false)$ ]]; then
  printf "\n${RED}Error: Invalid fail fast value.${RESET} Must be either 'true' or 'false'.\n" >&2
  exit 2
fi

# record start time
start_time=$(date +%s)

printf "\n${PURPLE}Waiting 10 seconds for CI jobs to start on commit${RESET} '%s'.\n" "${commit_sha}"
sleep 10

printf "\n${PURPLE}Excluding self job name:${RESET} '%s'\n" "${self_job_name}"

printf "\n${PURPLE}Polling every${RESET} %s${PURPLE} seconds for a maximum of${RESET} %s${PURPLE} minutes...${RESET}\n" "${polling_interval_in_seconds}" "${time_out_in_minutes}"

check_runs=()
get_checks_status "${commit_sha}" "${repository}"

if [ "${#check_runs[@]}" -eq 0 ]; then
  printf "\n${YELLOW}Warning: No CI checks found for commit '%s'.${RESET}\n" "${commit_sha}" >&2
  exit 0
fi

printf "\n${PURPLE}Found${RESET} %s${PURPLE} CI checks for commit${RESET} '%s'.${RESET}\n" "${#check_runs[@]}" "${commit_sha}"
for check in "${check_runs[@]}"; do
  name=$(jq -r '.name' <<<"${check}")
  printf " -->${CYAN} Check:${RESET} %s\n" "${name}"
done

get_combined_status "${commit_sha}" "${fail_fast}" "${exclude_job_patterns}" "${self_job_name}" "${repository}"
while [ "${combined_status}" == "pending" ]; do
  printf "\n${YELLOW}CI is still pending...${RESET}\n\n"

  # check if timeout has been reached
  current_time=$(date +%s)
  elapsed_time=$((current_time - start_time))
  if (( elapsed_time >= time_out_in_seconds )); then
    printf "\n${RED}Error: Timeout reached after %s minutes.${RESET}\n" "${time_out_in_minutes}" >&2
    exit 1
  fi

  sleep "${polling_interval_in_seconds}"
  get_combined_status "${commit_sha}" "${fail_fast}" "${exclude_job_patterns}" "${self_job_name}" "${repository}"
done

if [ "${combined_status}" == "success" ]; then
  printf "\n${GREEN}All CI checks passed successfully!${RESET}\n"
  exit 0
else
  printf "\n${RED}Error: Some CI checks failed or were canceled.${RESET}\n" >&2
  # find failed checks and print them
  for check in "${check_runs[@]}"; do
    name=$(jq -r '.name' <<<"${check}")
    status=$(jq -r '.bucket' <<<"${check}")
    url=$(jq -r '.url' <<<"${check}")
    if [ "${status}" == "fail" ] || [ "${status}" == "cancel" ]; then
      if is_excluded "${name}" "${exclude_job_patterns}"; then
        continue
      fi
      printf " -->${RED} Check${RESET} '%s'${RED} failed with status${RESET} '%s'${RED} - url ${RESET} %s\n" "${name}" "${status}" "${url}"
    fi
  done
  exit 1
fi
