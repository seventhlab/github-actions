#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# Used to colorize output
GREEN='\e[0;32m'
YELLOW='\e[0;33m'
RESET='\e[0m'

# Fatal rather than a skip: a notifier that silently does nothing is the failure to design against.
: "${WEBHOOK_URL:?no webhook URL — the organization secret did not reach this repository}"
: "${REPOSITORY:?no repository}"
: "${RUN_ID:?no run id — this action needs a workflow_run event or an explicit runId}"

run=$(gh api "repos/${REPOSITORY}/actions/runs/${RUN_ID}")

# The event's conclusion wins over the API's. Clicking "Re-run failed jobs" resets the run to
# `null` in the API, and the notifier would report nothing for the failure that just happened.
conclusion="${CONCLUSION:-}"
if [ -z "${conclusion}" ]; then
  conclusion=$(jq -r '.conclusion' <<<"${run}")
fi

# `startup_failure` is the one a bad pipeline edit produces, so it has to be in here. `cancelled` is
# a human superseding a deploy and `skipped` is a held job — neither is news.
case "${conclusion}" in
  failure | timed_out | startup_failure) ;;
  *)
    printf "${GREEN}Run %s concluded '%s' — nothing to report.${RESET}\n" "${RUN_ID}" "${conclusion}"
    exit 0
    ;;
esac

failed_jobs=$(
  gh api "repos/${REPOSITORY}/actions/runs/${RUN_ID}/jobs?per_page=100" \
    --jq '[.jobs[] | select(.conclusion == "failure") | .name] | join(", ")'
)

# One `jq` over the whole run object: a `--arg "$(jq …)"` per field discards each substitution's
# exit status under errexit, and renders a JSON null as the string "null".
payload=$(
  jq -n \
    --argjson run "${run}" \
    --arg repository "${REPOSITORY}" \
    --arg jobs "${failed_jobs}" \
    '
    def slack_escape: gsub("&"; "&amp;") | gsub("<"; "&lt;") | gsub(">"; "&gt;");
    def or_unknown: if . == null or . == "" then "unknown" else . end;

    ($repository | slack_escape)              as $repo
    | ($run.name | or_unknown | slack_escape) as $workflow
    | ($run.head_branch | or_unknown | slack_escape) as $branch
    | ($run.actor.login | or_unknown | slack_escape) as $actor
    | ($run.display_title | or_unknown | slack_escape) as $commit
    | ($jobs | or_unknown | slack_escape)     as $failed
    | ($run.html_url | or_unknown)            as $url
    | {
        text: "\($repo) — \($workflow) failed on \($branch)",
        blocks: [
          {
            type: "section",
            text: {
              type: "mrkdwn",
              text: ":rotating_light: <\($url)|*\($repo)* — \($workflow) failed>"
            }
          },
          {
            type: "section",
            fields: [
              { type: "mrkdwn", text: "*Failed job*\n\($failed)" },
              { type: "mrkdwn", text: "*Branch*\n\($branch)" },
              { type: "mrkdwn", text: "*Triggered by*\n\($actor)" },
              { type: "mrkdwn", text: "*Commit*\n\($commit)" }
            ]
          }
        ]
      }'
)

printf "${YELLOW}Reporting run %s to Slack.${RESET}\n" "${RUN_ID}"

# `--fail-with-body` keeps the non-zero exit AND prints Slack's reason; plain `--fail` leaves you a
# bare status code, and `invalid_blocks` is only in the body. `--max-time` so a black-holed
# connection does not hold a runner for the six-hour job default.
curl --silent --show-error --fail-with-body --max-time 30 \
  --header 'Content-Type: application/json' \
  --data "${payload}" \
  "${WEBHOOK_URL}"

printf "\n${GREEN}Reported.${RESET}\n"
