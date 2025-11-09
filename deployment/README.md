# NextScript OSCAR EMR - Docker Deployment

Production-ready OSCAR EMR for British Columbia clinics. Self-configuring with web-based setup wizard.

## 🚀 Quick Start (3 commands)

```bash
cd deployment
chmod +x deploy.sh
./deploy.sh
```

That's it! The script will:
1. Generate secure random passwords
2. Create `.env` configuration file
3. Build and start all containers

## 📋 What Gets Deployed

- **OSCAR EMR** - BC-specific with Teleplan billing
- **MariaDB 10.5** - Database with automatic schema initialization
- **DrugRef** - Canadian drug reference database
- **Setup Wizard** - Web-based first-run configuration
- **Integration Services** - RingCentral, OceanMD, BC Labs
- **Backup Service** - Automated daily backups with optional S3

## 🔧 First-Time Setup

After running `./deploy.sh`, wait 2-3 minutes for services to start, then:

### 1. Complete Setup Wizard

Visit: **http://localhost:8568**

Configure:
- Clinic details (name, address, contact)
- BC Teleplan billing (payee number, group, location)
- RingCentral (fax & SMS credentials)
- OceanMD (Site ID, API key)
- Lab integration (Excelleris/LifeLabs SFTP)

### 2. Access OSCAR

Visit: **http://localhost:8567/oscar**

Default credentials:
- Username: `oscardoc`
- Password: `mac2002`
- PIN: `1117`

**⚠️ IMPORTANT**: Change these credentials immediately after first login!

