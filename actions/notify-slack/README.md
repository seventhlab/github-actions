# Notify Slack

A GitHub Action that reports a **failed** workflow run to a Slack incoming webhook. It is built for
`workflow_run` listeners: point it at the workflows whose failures matter, and it stays silent for
everything else.

## Description

The action reads a workflow run and its jobs from the GitHub API, and posts a compact Block Kit
message naming the repository, the workflow, the job that failed, the branch, the commit subject and
who triggered it, linked to the run.

It posts only when the run concluded `failure`, `timed_out` or `startup_failure`. A `cancelled` run
is almost always a human superseding a deploy, and `skipped` is a held job — neither is news, so
neither is reported. `startup_failure` is in the list because that is what a malformed workflow
edit produces, and it is the change most likely to need reporting.

The conclusion comes from the `workflow_run` payload when there is one, and from the API otherwise.
The payload has to win: clicking *Re-run failed jobs* resets the run's API conclusion to `null`, so
reading the API alone would report nothing for the failure that just happened. Falling back to the
API is what lets a past run be replayed by id — the only rehearsal available, since `workflow_run`
only fires for workflow files on the default branch and so cannot be exercised from a pull request.

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `webhookUrl` | Slack incoming webhook URL. A webhook is bound to one channel when it is created, so it cannot post anywhere else. | Yes | - |
| `runId` | The workflow run to report. Leave unset under `workflow_run`; set it to replay a past run. | No | the run that raised the event |
| `githubToken` | Token used to read the run and its jobs. | No | `${{ github.token }}` |

## Requirements

- `permissions: actions: read` on the calling job. Nothing else — the action never reads the code and
  does not check out the repository.
- GitHub CLI (`gh`), `jq` and `curl` are used internally (pre-installed on GitHub-hosted runners).

## Usage Example

```yaml
---
name: Notify

on:
  workflow_run:
    workflows: [Pipeline, Deploy]
    types: [completed]

permissions:
  actions: read

jobs:
  slack:
    if: ${{ github.event.workflow_run.conclusion != 'success' }}
    runs-on: ubuntu-latest
    steps:
      - name: Report the failure
        uses: seventhlab/github-actions/actions/notify-slack@v1.6.0
        with:
          webhookUrl: ${{ secrets.SLACK_DEPLOY_FAILURES_WEBHOOK }}
```

### Replaying a past run

`workflow_run` cannot fire from a branch, so add a dispatch input to rehearse the message against a
run that really failed:

```yaml
on:
  workflow_dispatch:
    inputs:
      run_id:
        description: A workflow run id to report
        required: true
        type: string
# …
        with:
          webhookUrl: ${{ secrets.SLACK_DEPLOY_FAILURES_WEBHOOK }}
          runId: ${{ inputs.run_id }}
```

```bash
gh run list --repo OWNER/REPO --workflow Pipeline --status failure --limit 5 --json databaseId
gh workflow run notify.yml --repo OWNER/REPO -f run_id=<id>
```

## Behavior

1. **Resolve**: reads the run named by `runId`, or by the `workflow_run` event that triggered the job
2. **Filter**: exits quietly unless the conclusion is `failure` or `timed_out`
3. **Attribute**: lists the jobs in that run whose own conclusion is `failure`
4. **Post**: sends one Block Kit message, with a `text` fallback for notifications and screen readers

Values reach the script through the environment rather than being interpolated into the shell, so a
branch name or commit subject containing `$(…)` cannot execute on the runner. Text is HTML-escaped
for Slack mrkdwn, so a `<` in a commit subject does not swallow the rest of the line.

## Exit Codes

- `0`: the message was delivered, or the run did not warrant one
- `1`: a required input was missing, the run could not be read, or Slack rejected the post

A missing `webhookUrl` is fatal rather than a skip: a notifier that silently does nothing is the
failure mode worth designing against.
