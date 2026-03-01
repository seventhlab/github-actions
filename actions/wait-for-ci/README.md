# Wait for CI

A GitHub Action that waits for all CI checks to complete on a given commit before proceeding.
This is particularly useful for merge queues, pull requests, or any workflow where you need to
ensure all checks have passed before continuing with subsequent steps.

## Description

This action polls the GitHub API to monitor the status of all CI checks associated with a specific commit SHA. It will:

- Wait for all CI jobs to complete (success, failure, or cancellation)
- Automatically exclude itself from the checks being monitored
- Support custom job exclusion patterns using regex
- Provide configurable timeout and polling intervals
- Optionally fail fast when any job fails, or wait for all jobs to complete

The action is ideal for scenarios where you need to:

- Synchronize workflows that depend on other CI checks
- Implement custom merge queue logic
- Create deployment gates based on CI status
- Coordinate complex multi-workflow pipelines

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `commitSha` | The commit SHA to wait for CI checks to complete | Yes | - |
| `jobName` | The name of the job running this action, exactly as it appears in the workflow file (e.g., "Wait for CI"). This job will be automatically excluded from monitoring. | Yes | - |
| `excludeJobPatterns` | Comma-separated list of job name patterns to ignore. Supports regex patterns for flexible matching. | No | `""` |
| `timeOutInMinutes` | Maximum time to wait for CI checks to complete, in minutes. Valid range: 1-240 (4 hours). | No | `30` |
| `pollingIntervalInSeconds` | How often to check the CI status, in seconds. Valid range: 5-300 (5 minutes). | No | `10` |
| `failFast` | Whether to fail immediately when any job fails (`true`) or wait for all jobs to complete (`false`). | No | `true` |

## Requirements

- `GITHUB_TOKEN` environment variable with `repo` access (typically `${{ secrets.GITHUB_TOKEN }}`)
- GitHub CLI (`gh`) and `jq` are used internally (pre-installed on GitHub-hosted runners)

## Usage Example

```yaml
---
name: Wait for CI
on:
  pull_request:
    branches: [ main ]
  merge_group:
    types: [checks_requested]

jobs:
  wait-for-ci:
    runs-on: ubuntu-latest
    steps:
      - name: Wait for CI
        uses: seventhlab/github-actions/actions/wait-for-ci@v1.0.0
        with:
          commitSha: ${{ github.event.pull_request.head.sha || github.event.merge_group.head_sha }}
          jobName: "Wait for CI"
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Advanced Example with Job Exclusions

```yaml
---
name: Wait for CI
on:
  pull_request:
    branches: [ main ]

jobs:
  wait-for-ci:
    runs-on: ubuntu-latest
    steps:
      - name: Wait for CI
        uses: seventhlab/github-actions/actions/wait-for-ci@v1.0.0
        with:
          commitSha: ${{ github.event.pull_request.head.sha }}
          jobName: "wait-for-ci"
          excludeJobPatterns: "^lint-.*,.*-docs$"
          timeOutInMinutes: 60
          pollingIntervalInSeconds: 15
          failFast: false
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Behavior

1. **Initial Wait**: The action waits 10 seconds after starting to allow CI jobs to initialize
2. **Polling**: Checks the status of all CI checks at the configured interval
3. **Self-Exclusion**: Automatically excludes the job running this action from monitoring
4. **Pattern Exclusion**: Skips any jobs matching the patterns in `excludeJobPatterns`
5. **Status Determination**:
   - **Success**: All non-excluded checks have completed successfully
   - **Failure**: At least one check has failed, been cancelled, or timed out
   - **Pending**: At least one check is still running
6. **Timeout**: Fails if the maximum wait time is exceeded
7. **Fail Fast**: If enabled, exits immediately when any check fails; otherwise waits for all checks to complete

## Exit Codes

- `0`: All CI checks passed successfully
- `1`: One or more CI checks failed, were cancelled, or the timeout was reached
- `2`: Invalid configuration or missing required arguments
