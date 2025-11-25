# Release Setup

This document explains how to set up the release workflow for this repository.

## Problem

The default `GITHUB_TOKEN` provided by GitHub Actions may not have sufficient permissions to create releases, especially if:
- Branch protection rules are enabled on `main`
- The repository has strict security settings
- You're in an organization with specific permission requirements

## Solution: Personal Access Token (PAT)

The release workflow is configured to use a Personal Access Token (PAT) named `GH_PAT` as a fallback.

### Creating a PAT

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
   - Or visit: https://github.com/settings/tokens

2. Click "Generate new token" → "Generate new token (classic)"

3. Configure the token:
   - **Note**: `github-actions-release` (or any descriptive name)
   - **Expiration**: Choose an appropriate expiration (90 days, 1 year, or no expiration)
   - **Scopes**: Select the following:
     - ✅ `repo` (Full control of private repositories)
       - This includes: `repo:status`, `repo_deployment`, `public_repo`, `repo:invite`, `security_events`
     - ✅ `write:packages` (if you plan to publish packages)
     - ✅ `workflow` (Update GitHub Action workflows)

4. Click "Generate token"

5. **Copy the token immediately** (you won't be able to see it again!)

### Adding the PAT to Repository Secrets

1. Go to your repository on GitHub

2. Navigate to: Settings → Secrets and variables → Actions

3. Click "New repository secret"

4. Create the secret:
   - **Name**: `GH_PAT`
   - **Secret**: Paste the token you generated
   - Click "Add secret"

### Verification

Once the `GH_PAT` secret is added:

1. The next push to `main` will trigger the release workflow
2. It will use `GH_PAT` instead of the default `GITHUB_TOKEN`
3. Releases should be created successfully

### Fallback Behavior

The workflow is configured with a fallback:
```yaml
token: ${{ secrets.GH_PAT || secrets.GITHUB_TOKEN }}
```

This means:
- If `GH_PAT` exists, it will be used
- If `GH_PAT` doesn't exist, it falls back to `GITHUB_TOKEN`
- This ensures the workflow doesn't break if the PAT is not configured

## Alternative: Fine-grained Personal Access Token

If you prefer to use fine-grained tokens (beta feature):

1. Go to: Settings → Developer settings → Personal access tokens → Fine-grained tokens

2. Click "Generate new token"

3. Configure:
   - **Token name**: `github-actions-release`
   - **Expiration**: Choose expiration
   - **Repository access**: Only select repositories → Choose `github-actions`
   - **Permissions**:
     - Repository permissions:
       - ✅ Contents: Read and write
       - ✅ Issues: Read and write
       - ✅ Pull requests: Read and write
       - ✅ Metadata: Read-only (automatically selected)

4. Generate and add to secrets as described above

## Troubleshooting

### "author_id does not have push access"

This error means the token doesn't have push permissions. Verify:
- The PAT has the `repo` scope
- The PAT hasn't expired
- The PAT is properly added to repository secrets
- The secret name is exactly `GH_PAT`

### "Resource not accessible by integration"

This error typically means:
- The workflow permissions are insufficient
- Try adding the PAT as described above

### Checking Workflow Logs

To debug:
1. Go to Actions tab in your repository
2. Click on the failed "Release" workflow
3. Expand the "Run semantic-release" step
4. Check the error message for more details

## Security Notes

- 🔒 Keep your PAT secure and never commit it to the repository
- 🔄 Set an expiration date and rotate tokens regularly
- 👥 For organization repositories, ensure the PAT owner has appropriate permissions
- 📝 Document when tokens need to be renewed
