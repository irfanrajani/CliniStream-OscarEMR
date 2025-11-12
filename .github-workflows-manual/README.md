# GitHub Actions Workflow - Manual Setup Required

GitHub App cannot automatically create workflow files due to permission restrictions.

## How to Add This Workflow

1. **Copy the workflow file**:
   ```bash
   cp .github-workflows-manual/WORKFLOW-TO-ADD-MANUALLY.yml .github/workflows/build-and-deploy.yml
   ```

2. **Commit and push via git directly** (not through Claude):
   ```bash
   git add .github/workflows/build-and-deploy.yml
   git commit -m "Add GitHub Actions workflow for automated builds"
   git push
   ```

3. **Or add via GitHub Web Interface**:
   - Go to your repository on GitHub
   - Navigate to `.github/workflows/`
   - Click "Add file" → "Create new file"
   - Name it `build-and-deploy.yml`
   - Copy contents from `WORKFLOW-TO-ADD-MANUALLY.yml`
   - Commit directly to the branch

## What This Workflow Does

- **Builds OSCAR WAR**: Compiles from `open-o-source` using Maven
- **Fixes pom.xml**: Removes SourceForge repos, adds Spring versions
- **Builds Docker Images**: Creates production-ready containers
- **Pushes to ghcr.io**: GitHub Container Registry for easy deployment
- **Tests Deployment**: Verifies everything works

## After Adding

The workflow will run on:
- Push to `main` or feature branches
- Pull requests to `main`
- Manual trigger via GitHub Actions tab

Images will be available at:
- `ghcr.io/irfanrajani/clinistream-oscaremr/oscar:latest`
- `ghcr.io/irfanrajani/clinistream-oscaremr/setup-wizard:latest`
- `ghcr.io/irfanrajani/clinistream-oscaremr/integrations:latest`
- `ghcr.io/irfanrajani/clinistream-oscaremr/backup:latest`

## First Time Setup

1. Ensure GitHub Actions is enabled in repository settings
2. Add workflow file (follow steps above)
3. Push code to trigger build
4. Wait for build to complete (~10-15 minutes first time)
5. Pull images: `docker compose pull`
6. Deploy: `docker compose up -d`
