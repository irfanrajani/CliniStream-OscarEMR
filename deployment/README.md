# NextScript OSCAR EMR - Self-Configuring Deployment

## Quick Start (QNAP Deployment)

### 1. One-Command Deployment

```bash
docker-compose up -d
```

That's it! The system will:
- Start all services
- Create databases
- Launch setup wizard at http://your-qnap:3000

### 2. Complete First-Run Setup

Visit **http://your-qnap-ip:3000** and configure:

1. **Clinic Details**
   - Clinic name (default: NextScript)
   - Address, phone, email
   - Timezone (default: America/Vancouver)

2. **BC Teleplan Billing**
   - Billing location (Victoria)
   - Payee number
   - Group number
   - Provider billing numbers

3. **RingCentral Integration**
   - API credentials
   - Fax number
   - SMS number
   - Auto-configuration of fax/SMS services

4. **OceanMD eReferral**
   - Site ID
   - API key
   - Auto-configuration for specialist referrals

5. **Lab Integration**
   - PathNet/LifeLabs credentials (via Expedius)
   - Lab provider selection
   - Result routing preferences

6. **Administrator Account**
   - Primary admin username
   - Secure password
   - Email for alerts

### 3. Access OSCAR EMR

After setup completes:
- **OSCAR EMR:** http://your-qnap-ip:8080/oscar
- **Settings:** http://your-qnap-ip:8080/oscar/admin/settings

All integrations (fax, SMS, labs, eReferral) are configurable in Settings at any time.

---

## Services

| Service | Port | Purpose |
|---------|------|---------|
| oscar | 8080, 8443 | Main EMR application |
| setup-wizard | 3000 | First-run configuration (auto-stops after setup) |
| db | 3306 (internal) | MariaDB database |
| expedius | 8081 | Lab auto-downloader |
| drugref | 8080 (internal) | Drug reference database |
| integrations | - | RingCentral, Ocean, SMS services |
| backup | - | Automated backups |

---

## Configuration Files

All configuration is stored in the database and editable via Settings UI.

**First-run only:** Create `.env` from `.env.example`

```bash
cp .env.example .env
# Edit .env and set random passwords
```

---

## Backup & Restore

### Automatic Backups
- Daily at 2 AM (configurable via `BACKUP_SCHEDULE`)
- Stored in Docker volume `backup-data`
- Optional S3 upload (set `S3_BACKUP_BUCKET`)

### Manual Backup
```bash
docker-compose exec backup /backup.sh manual
```

### Restore from Backup
```bash
docker-compose exec backup /restore.sh /backups/backup-YYYY-MM-DD.tar.gz
```

---

## Updating

```bash
docker-compose pull
docker-compose up -d
```

All data persists in Docker volumes.

---

## Reconfiguring Integrations

Don't edit config files. Use the Settings UI:

1. Login to OSCAR as admin
2. Go to **Administration → NextScript Settings**
3. Edit any integration:
   - RingCentral credentials
   - Ocean API keys
   - Lab provider settings
   - Billing configuration
   - Clinic details

Changes apply immediately (no restart required).

---

## Support

For issues, check logs:

```bash
# OSCAR logs
docker-compose logs oscar

# Integration logs
docker-compose logs integrations

# Database logs
docker-compose logs db
```

---

## Architecture

```
┌─────────────────────────────────────┐
│  First-Run Setup Wizard (Port 3000) │ ← Configure everything here
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  OSCAR EMR (Port 8080/8443)        │
│  ┌─────────────────────────────┐   │
│  │ Settings UI                  │   │ ← Reconfigure anytime
│  │ - Clinic details             │   │
│  │ - Integrations               │   │
│  │ - Billing                    │   │
│  │ - Labs                       │   │
│  └─────────────────────────────┘   │
└──────────────┬──────────────────────┘
               │
    ┌──────────┼──────────┐
    │          │          │
    ▼          ▼          ▼
┌────────┐ ┌────────┐ ┌────────────┐
│RingCent│ │ Ocean  │ │ Expedius   │
│Fax/SMS │ │eReferral│ │BC Labs     │
└────────┘ └────────┘ └────────────┘
```

No hardcoded config. Everything database-driven and hot-reloadable.
