# OSCAR EMR Database Initialization

This directory contains SQL files for initializing the OSCAR EMR database with BC-specific configuration.

## Files (Loaded in Order)

1. **01-init-schema.sql** - Database initialization metadata
2. **02-oscarinit.sql** - Core OSCAR schema (423KB)
3. **03-oscarinit-bc.sql** - BC-specific schema additions (211KB)
4. **04-oscardata-bc.sql** - BC diagnostic codes and initial data (2.7MB)
5. **05-integration-schema.sql** - Integration tables (RingCentral, Ocean, Labs)
6. **06-bc-billing-codes.sql** - 17,700+ BC MSP billing codes (4.3MB)
7. **07-bc-pharmacies.sql** - BC pharmacy directory (145KB)

**Total Size:** ~7.7MB

## Initialization Process

MySQL Docker container automatically executes SQL files in `/docker-entrypoint-initdb.d` alphabetically.

Files are processed only on **first run** when database is empty.

## Schema Components

### Core Tables (02-oscarinit.sql)
- Provider accounts and security
- Patient demographics
- Appointments and scheduling
- Clinical notes (eChart)
- Prescriptions (RX3)
- Billing and invoicing
- Document management
- Lab results
- Consultations

### BC-Specific (03-oscarinit-bc.sql, 04-oscardata-bc.sql)
- BC Teleplan billing configuration
- BC MSP service codes
- BC diagnostic codes (ICD-10)
- BC-specific forms and templates

### Integration Schema (05-integration-schema.sql)
```sql
- system_config          # Global system settings
- integration_config     # API credentials (RingCentral, Ocean, Labs)
- fax_queue, fax_log     # RingCentral fax management
- sms_queue, sms_log     # SMS appointment reminders
- ocean_referrals        # OceanMD eReferral tracking
- lab_downloads          # BC lab auto-download tracking
- portal_users           # Patient portal accounts
- portal_messages        # Secure messaging
- appointment_reminders  # Automated SMS/email reminders
- audit_log              # Security audit trail
```

### BC Reference Data
- **17,700+ MSP billing codes** (06) - Complete fee schedule
- **BC pharmacies** (07) - Province-wide pharmacy directory
- **BC specialists** (optional, not included - 4.1MB) - Professional directory

## Schema Version Tracking

The `schema_version` table tracks database migrations:

```sql
CREATE TABLE schema_version (
    version VARCHAR(50) PRIMARY KEY,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    description TEXT
);
```

Current version: **1.0.0** (Initial BC deployment)

## Database Requirements

- **MySQL/MariaDB 5.7+** or MariaDB 10.5+
- **Character Set:** utf8mb4
- **Collation:** utf8mb4_unicode_ci
- **Storage Engine:** InnoDB
- **Minimum Disk:** 2GB for database + 10GB for documents

## Environment Variables

Set in `.env` file:

```bash
MYSQL_DATABASE=oscar_mcmaster
MYSQL_USER=oscar
MYSQL_PASSWORD=<strong_password>
MYSQL_ROOT_PASSWORD=<strong_password>
```

## First-Time Setup

1. Start database: `docker compose up -d db`
2. Wait for initialization (check logs): `docker compose logs -f db`
3. Look for: "MySQL init process done. Ready for start up."
4. Start OSCAR: `docker compose up -d oscar`

## Adding Custom Data

To add clinic-specific data:

1. Create `08-custom-data.sql` in this directory
2. Add your SQL (providers, clinic settings, etc.)
3. Restart database (first time only): `docker compose restart db`

## Backup & Restore

**Backup:**
```bash
docker compose exec db mysqldump -u root -p oscar_mcmaster > backup.sql
```

**Restore:**
```bash
docker compose exec -T db mysql -u root -p oscar_mcmaster < backup.sql
```

Or use the automated backup service (see deployment/backup/).

## Troubleshooting

**"Table already exists" errors:**
- SQL files only run on first initialization
- To reinitialize: `docker compose down -v` (⚠️ destroys data!)

**Schema changes not applied:**
- SQL files don't auto-update existing databases
- Use Flyway migrations (deployment/migrations/) for updates

**Character encoding issues:**
- Ensure utf8mb4 is used throughout
- Check: `SHOW VARIABLES LIKE 'character_set%';`

## Next Steps

After database initialization:
1. Complete Setup Wizard at http://localhost:8568
2. Configure integrations (RingCentral, OceanMD, BC Labs)
3. Create provider accounts
4. Import patient data (if migrating)

## Support

For schema questions, see:
- OSCAR Documentation: https://oscargalaxy.org/
- BC OpenOSP: https://github.com/open-osp/Open-O
- Integration Guide: ../ARCHITECTURE.md
