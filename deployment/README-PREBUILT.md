# OSCAR EMR - Pre-Built Image Deployment

## 🚀 Zero Build Time - Just Download & Run!

This deployment uses **pre-built Docker images** from GitHub Container Registry. No local compilation required!

### Why Use Pre-Built Images?

- ⚡ **Fast**: No 30-minute Maven build - just download and run
- 💾 **Small**: Only downloads final images (~2GB instead of 8GB build artifacts)
- 🍎 **Mac-Friendly**: No slow Docker builds on macOS
- 🔒 **Tested**: Images built and tested on GitHub Actions

---

## Quick Start (3 Commands)

```bash
cd deployment
chmod +x deploy-prebuilt.sh
./deploy-prebuilt.sh
```

That's it! Wait 2-3 minutes for images to download, then access:

- **Setup Wizard**: http://localhost:8568
- **OSCAR EMR**: http://localhost:8567/oscar

---

## How It Works

1. **GitHub Actions** builds OSCAR from source overnight (automatically)
2. **Pre-built images** are pushed to `ghcr.io` (GitHub Container Registry)
3. **You download** ready-to-use images instead of building locally

### Images Available

All images are free and public:

- `ghcr.io/irfanrajani/clinistream-oscaremr/oscar-emr:latest`
- `ghcr.io/irfanrajani/clinistream-oscaremr/integrations:latest`
- `ghcr.io/irfanrajani/clinistream-oscaremr/backup:latest`
- `ghcr.io/irfanrajani/clinistream-oscaremr/setup-wizard:latest`

---

## Manual Commands

If you prefer manual control:

```bash
# Pull all pre-built images
docker compose -f docker-compose.production.yml pull

# Start services
docker compose -f docker-compose.production.yml up -d

# View logs
docker compose -f docker-compose.production.yml logs -f oscar

# Stop services
docker compose -f docker-compose.production.yml down
```

---

## Updating to Latest Version

```bash
docker compose -f docker-compose.production.yml pull
docker compose -f docker-compose.production.yml up -d
```

---

## Build Your Own Images (Optional)

If you want to build from source locally:

```bash
./deploy.sh  # Uses docker-compose.yml with local builds
```

⚠️ **Warning**: Local build takes 20-30 minutes and uses 8GB disk space during build.

---

## Troubleshooting

### Image Pull Fails

GitHub Container Registry is public, but you may need to authenticate:

```bash
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
```

Or just use the pre-built images - they're public and don't require auth!

### Services Won't Start

Check logs:

```bash
docker compose -f docker-compose.production.yml logs
```

### Need More Help?

1. Check `docker compose ps` - all services should be "Up"
2. Check `docker compose logs oscar` for OSCAR-specific issues
3. Ensure ports 8567 and 8568 aren't in use: `lsof -i :8567`

---

## Comparison: Build vs Pre-Built

| Feature | Local Build | Pre-Built Images |
|---------|-------------|------------------|
| **Initial Deploy** | 30-40 min | 3-5 min |
| **Disk Space (build)** | 8GB | 2GB |
| **Disk Space (final)** | 2GB | 2GB |
| **Mac Performance** | Slow | Fast |
| **Customization** | Full | Limited* |
| **Always Latest** | Yes | GitHub Actions |

*To customize: Fork repo, modify code, GitHub Actions rebuilds your custom image

---

## GitHub Actions Build Status

Check if new images are being built:

Visit: https://github.com/irfanrajani/CliniStream-OscarEMR/actions

Builds run automatically on every push to `main` or the feature branch.
