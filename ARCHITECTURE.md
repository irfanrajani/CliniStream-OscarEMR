# OSCAR EMR - System Architecture

## Table of Contents
1. [System Overview](#system-overview)
2. [Architecture Diagram](#architecture-diagram)
3. [Service Components](#service-components)
4. [Data Flow](#data-flow)
5. [Integration Points](#integration-points)
6. [Security Architecture](#security-architecture)
7. [Deployment Architecture](#deployment-architecture)
8. [Database Schema](#database-schema)
9. [API Specifications](#api-specifications)
10. [Scalability & Performance](#scalability--performance)

---

## System Overview

OSCAR EMR is a comprehensive Electronic Medical Record system designed for BC (British Columbia) healthcare clinics. This deployment is production-ready, secure, and fully dockerized with automated integrations.

### Key Features
- **BC-Ready**: MSP billing, Teleplan, BC lab systems
- **Integrated Fax/SMS**: RingCentral for secure communication
- **eReferrals**: OceanMD integration for specialist referrals
- **Lab Auto-Download**: Excelleris/LifeLabs SFTP integration
- **Patient Portal**: Secure online access (future)
- **Automated Backups**: Database + documents with S3 support
- **Setup Wizard**: One-time configuration for easy deployment

### Technology Stack
- **Application**: Java 8, Apache Tomcat 9.0, Spring 4.3
- **Database**: MariaDB 10.5 (MySQL-compatible)
- **Integration Layer**: Python 3.11 Flask, Node.js 18
- **Frontend**: JSP, React 18 (Setup Wizard)
- **Deployment**: Docker, Docker Compose, GitHub Container Registry

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Client Layer                             │
├─────────────────────────────────────────────────────────────┤
│  Web Browser                                                │
│  ├─ Setup Wizard (React)      :8568                        │
│  ├─ OSCAR EMR (JSP)           :8567/oscar                  │
│  └─ Admin Settings (JSP)      :8567/oscar/admin           │
└─────────────────────────────────────────────────────────────┘
                          ↓ HTTP/HTTPS
┌─────────────────────────────────────────────────────────────┐
│              Application Layer (Docker)                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────┐  ┌──────────────────┐               │
│  │  Setup Wizard    │  │  OSCAR EMR       │               │
│  │  (Node.js)       │  │  (Tomcat)        │               │
│  │  Port: 3000      │  │  Port: 8080      │               │
│  │  User: nodejs    │  │  User: oscar     │               │
│  └──────────────────┘  └──────────────────┘               │
│           ↓                     ↓                           │
│  ┌──────────────────────────────────────┐                  │
│  │  Integration Service (Python)        │                  │
│  │  - RingCentral (Fax/SMS)            │                  │
│  │  - OceanMD (eReferral)              │                  │
│  │  - BC Labs (SFTP)                   │                  │
│  │  Port: 8080                         │                  │
│  │  User: integrations                 │                  │
│  └──────────────────────────────────────┘                  │
│           ↓                     ↓                           │
│  ┌──────────────────┐  ┌──────────────────┐               │
│  │  Backup Service  │  │  MariaDB 10.5    │               │
│  │  (Python)        │  │  Port: 3306      │               │
│  │  User: backup    │  │  Volume: db-data │               │
│  └──────────────────┘  └──────────────────┘               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                          ↓ External APIs
┌─────────────────────────────────────────────────────────────┐
│              External Integrations                          │
├─────────────────────────────────────────────────────────────┤
│  • RingCentral API (OAuth)   - Fax & SMS                   │
│  • OceanMD API (API Key)     - eReferral platform          │
│  • Excelleris SFTP           - BC lab results              │
│  • LifeLabs SFTP             - BC lab results              │
│  • AWS S3 (optional)         - Backup storage              │
└─────────────────────────────────────────────────────────────┘
```

---

## Service Components

### 1. OSCAR EMR Service
**Purpose**: Core EMR application

**Container**: `oscar-emr`
**Image**: `ghcr.io/irfanrajani/clinistream-oscaremr/oscar:latest`
**Port**: 8080 (internal) → 8567 (external)
**User**: oscar (UID 1000)

**Responsibilities**:
- Patient demographics & charts
- Appointment scheduling
- Clinical documentation (eChart)
- Prescriptions (RX3)
- Billing (BC MSP, Teleplan)
- Document management
- Provider accounts & security
- Lab result viewing
- Consultation management

**Key Directories**:
- `/var/lib/OscarDocument` - Patient documents & attachments
- `/etc/oscar` - Configuration files
- `/usr/local/tomcat/webapps/oscar.war` - Application

**Environment Variables**:
```bash
MYSQL_HOST=db
MYSQL_DATABASE=oscar_mcmaster
MYSQL_USER=oscar
MYSQL_PASSWORD=<from .env>
CLINIC_NAME=<clinic name>
TZ=America/Vancouver
CATALINA_OPTS=-Xms512m -Xmx2048m
```

**Health Check**: HTTP GET `/oscar/` every 60s

---

### 2. Setup Wizard Service
**Purpose**: First-time configuration UI

**Container**: `oscar-wizard`
**Image**: `ghcr.io/irfanrajani/clinistream-oscaremr/setup-wizard:latest`
**Port**: 3000 (internal) → 8568 (external)
**User**: nodejs (UID 1001)

**Responsibilities**:
- Clinic details collection
- BC Teleplan billing configuration
- RingCentral credentials setup
- OceanMD API key configuration
- BC lab provider SFTP settings
- Provider account creation
- Initial database population

**Configuration Flow**:
1. **Step 1**: Clinic Details (name, address, contacts, BC MSP info)
2. **Step 2**: Billing Config (MSP payee, group, location, Teleplan)
3. **Step 3**: RingCentral (client ID, secret, username, extension)
4. **Step 4**: OceanMD (site ID, API key, webhook URL)
5. **Step 5**: BC Labs (SFTP credentials for Excelleris/LifeLabs)
6. **Step 6**: Completion (summary, create admin account)

**API Endpoints**:
- `POST /api/config/clinic` - Save clinic details
- `POST /api/config/billing` - Save billing config
- `POST /api/config/ringcentral` - Save RC credentials
- `POST /api/config/ocean` - Save Ocean config
- `POST /api/config/labs` - Save lab SFTP settings
- `POST /api/test/ringcentral` - Test RC connection
- `POST /api/test/ocean` - Test Ocean API
- `POST /api/test/labs` - Test SFTP connection
- `GET /health` - Health check

---

### 3. Integration Service
**Purpose**: External API integrations

**Container**: `oscar-integrations`
**Image**: `ghcr.io/irfanrajani/clinistream-oscaremr/integrations:latest`
**Port**: 8080 (internal)
**User**: integrations (UID 1001)

**Responsibilities**:
#### RingCentral Integration
- **Fax Sending**: Queue-based fax transmission
- **Fax Receiving**: Webhook handler, auto-save to OSCAR documents
- **SMS Sending**: Appointment reminders, notifications
- **Delivery Tracking**: Status updates, retry logic

#### OceanMD Integration
- **eReferral Submission**: Create referrals from OSCAR
- **Status Polling**: Track referral acceptance/decline
- **Response Handling**: Update OSCAR with specialist responses
- **Webhook Processing**: Real-time status updates

#### BC Labs Integration
- **SFTP Auto-Download**: Daily scheduled downloads
- **HL7 Parsing**: Parse lab result messages (HL7 v2.x)
- **Patient Matching**: Demographics-based matching
- **Result Import**: Auto-create documents in OSCAR
- **Error Handling**: Retry failed downloads, log errors

**Technology**: Python 3.11, Flask, paramiko (SFTP), ringcentral-sdk

**Configuration**: Loaded from `integration_config` database table

**Logs**: `/var/log/integrations/`

---

### 4. Backup Service
**Purpose**: Automated backups

**Container**: `oscar-backup`
**Image**: `ghcr.io/irfanrajani/clinistream-oscaremr/backup:latest`
**User**: backup (UID 1001)

**Responsibilities**:
- **Database Backup**: mysqldump daily
- **Document Backup**: rsync `/var/lib/OscarDocument`
- **S3 Upload**: Optional cloud backup
- **Encryption**: GPG encryption (optional)
- **Retention**: Configurable (default: 30 days)
- **Monitoring**: Failed backup alerts

**Backup Schedule** (cron): `0 2 * * *` (2 AM daily)

**Backup Locations**:
- Local: `/backups/db/` and `/backups/documents/`
- S3: `s3://${S3_BUCKET}/oscar-backups/`

**Restore**: `restore.sh <backup-date>`

---

### 5. Database Service
**Purpose**: Data persistence

**Container**: `oscar-db`
**Image**: `mariadb:10.5`
**Port**: 3306 (internal only)

**Initialization**: SQL files in `/docker-entrypoint-initdb.d` (deployment/sql/)

**Databases**:
- `oscar_mcmaster` - Main OSCAR database

**Key Tables** (300+ tables):
#### Core OSCAR
- `provider` - Healthcare providers
- `demographic` - Patients
- `appointment` - Scheduling
- `casemgmt_note` - Clinical notes
- `drugs` - Prescriptions
- `billing` - Invoices
- `document` - Attachments
- `ctl_document` - Lab results

#### Integration Tables
- `system_config` - Global settings
- `integration_config` - API credentials
- `fax_queue`, `fax_log`
- `sms_queue`, `sms_log`
- `ocean_referrals`
- `lab_downloads`
- `audit_log`

**Volumes**: `db-data` (persistent)

---

## Data Flow

### Patient Encounter Flow
```
1. Patient arrives → Front desk books appointment
2. Appointment created in OSCAR → SMS reminder sent (RingCentral)
3. Provider opens eChart → Views patient history
4. Provider documents encounter → Saves clinical notes
5. Provider orders labs → Requisition created
6. Labs processed at LifeLabs → Results uploaded to SFTP
7. Integration service downloads → Parses HL7 → Imports to OSCAR
8. Provider reviews results → Documents interpretation
9. Provider creates referral → Submits via OceanMD
10. Specialist accepts → OceanMD webhook → Updates OSCAR
11. Provider submits billing → Teleplan file generated
```

### Fax Workflow (RingCentral)
```
OSCAR → Integration Service → RingCentral API

1. User clicks "Send Fax" in OSCAR
2. Document selected, fax number entered
3. OSCAR creates entry in fax_queue table
4. Integration service polls fax_queue (every 30s)
5. Sends fax via RingCentral API
6. Updates fax_log with delivery status
7. Retry on failure (3 attempts)
```

### eReferral Workflow (OceanMD)
```
OSCAR → Integration Service → OceanMD API

1. Provider creates referral in OSCAR
2. Integration service submits to OceanMD
3. Creates entry in ocean_referrals table
4. Ocean sends to specialist office
5. Specialist responds (accept/decline)
6. OceanMD webhook notifies integration service
7. Updates ocean_referrals status
8. Provider sees status in OSCAR
```

### Lab Auto-Download (BC Labs)
```
Lab SFTP → Integration Service → OSCAR

1. Cron triggers daily download (2 AM)
2. Connects to Excelleris/LifeLabs SFTP
3. Downloads new HL7 files
4. Parses HL7 messages
5. Matches patient by PHN/demographics
6. Creates document in OSCAR (ctl_document table)
7. Saves PDF to /var/lib/OscarDocument
8. Logs download in lab_downloads table
```

---

## Integration Points

### RingCentral API
**Type**: REST API with OAuth 1.0
**Base URL**: `https://platform.ringcentral.com`
**Authentication**: Client ID/Secret + Username/Extension/Password

**Endpoints Used**:
- `POST /restapi/oauth/token` - Get access token
- `POST /restapi/v1.0/account/~/extension/~/fax` - Send fax
- `GET /restapi/v1.0/account/~/extension/~/message-store` - List messages
- `POST /restapi/v1.0/account/~/extension/~/sms` - Send SMS

**Webhooks**:
- Inbound fax notification → `POST /integrations/ringcentral/webhook`

**Configuration** (integration_config table):
- `ringcentral.client_id`
- `ringcentral.client_secret`
- `ringcentral.username`
- `ringcentral.extension`
- `ringcentral.password`

---

### OceanMD API
**Type**: REST API with API Key
**Base URL**: `https://ocean.cognisantmd.com/api`
**Authentication**: `X-API-Key` header

**Endpoints Used**:
- `POST /v1/referrals` - Create eReferral
- `GET /v1/referrals/{id}` - Get referral status
- `GET /v1/referrals` - List referrals

**Webhooks**:
- Referral status change → `POST /integrations/ocean/webhook`

**Configuration** (integration_config table):
- `ocean.site_id`
- `ocean.api_key`
- `ocean.webhook_url`

---

### BC Labs SFTP
**Type**: SFTP file transfer
**Protocols**: HL7 v2.x (ORU^R01)

**Excelleris**:
- Host: `<provided by Excelleris>`
- Port: 22
- Auth: SSH key or username/password

**LifeLabs**:
- Host: `<provided by LifeLabs>`
- Port: 22
- Auth: SSH key or username/password

**File Format**: `.hl7` files with HL7 v2.x messages

**Configuration** (integration_config table):
- `labs.excelleris.host`
- `labs.excelleris.port`
- `labs.excelleris.username`
- `labs.excelleris.password` (encrypted)
- `labs.lifelabs.host`
- `labs.lifelabs.port`
- `labs.lifelabs.username`
- `labs.lifelabs.password` (encrypted)

---

## Security Architecture

### Authentication & Authorization
- **Provider Login**: Username + PIN (4-digit)
- **Session Management**: Server-side sessions (30-minute timeout)
- **Role-Based Access**: Provider, admin, receptionist roles
- **Password Policy**: Complexity requirements, 90-day expiration

### Data Security
- **Database Encryption**: MySQL encryption at rest (optional)
- **Backup Encryption**: GPG encryption with public key
- **SSL/TLS**: HTTPS for all external access
- **API Credentials**: Encrypted in integration_config table
- **PHI Protection**: Audit logging for all patient data access

### Network Security
- **Docker Network**: Isolated bridge network (172.20.0.0/16)
- **Port Exposure**: Only 8567 and 8568 exposed externally
- **Internal Communication**: Services communicate via Docker network
- **No Root Users**: All containers run as non-root (UIDs 1000-1001)

### Audit Logging
- **Patient Access**: All demographic/chart views logged
- **Data Changes**: Create/update/delete operations
- **Failed Logins**: Track brute-force attempts
- **Integration Activity**: API calls, fax sends, eReferrals

**Audit Log Table**:
```sql
CREATE TABLE audit_log (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    provider_no VARCHAR(10),
    action VARCHAR(50),  -- VIEW, CREATE, UPDATE, DELETE
    resource VARCHAR(100),  -- DEMOGRAPHIC, NOTE, BILLING
    resource_id VARCHAR(50),
    ip_address VARCHAR(45),
    details TEXT
);
```

### Compliance
- **HIPAA**: PHI protection, audit trails, encryption
- **PIPEDA** (Canada): Personal information protection
- **BC Privacy Act**: Provincial requirements
- **Data Retention**: Configurable retention policies

---

## Deployment Architecture

### Docker Compose Services
```yaml
services:
  db:           # MariaDB 10.5
  oscar:        # OSCAR EMR (Tomcat)
  setup-wizard: # React app (profile: setup)
  integrations: # Python Flask (RingCentral, Ocean, Labs)
  backup:       # Automated backups (profile: backup)
```

### Volumes
- `db-data`: Database persistence (MySQL data directory)
- `oscar-documents`: Patient documents & attachments
- `oscar-config`: OSCAR configuration files
- `integration-logs`: Integration service logs
- `backup-data`: Backup storage

### Networks
- `oscar-network`: Bridge network (172.20.0.0/16)

### Ports
- `8567`: OSCAR EMR (HTTP)
- `8568`: Setup Wizard (HTTP, first-run only)

### Environment Configuration
**File**: `deployment/.env`

**Required Variables**:
```bash
MYSQL_ROOT_PASSWORD=<strong_password>
MYSQL_PASSWORD=<strong_password>
MYSQL_DATABASE=oscar_mcmaster
MYSQL_USER=oscar
CLINIC_NAME=Your Clinic Name
```

**Optional Variables**:
```bash
TZ=America/Vancouver
OSCAR_MAX_MEMORY=2048m
BACKUP_SCHEDULE=0 2 * * *
S3_BACKUP_ENABLED=false
```

### Deployment Steps
1. Clone repository
2. Copy `.env.example` to `.env` and configure
3. `docker compose pull` - Pull pre-built images
4. `docker compose --profile setup up -d` - Start with wizard
5. Complete setup at `http://localhost:8568`
6. Access OSCAR at `http://localhost:8567/oscar`

---

## Database Schema

### Schema Statistics
- **Total Tables**: 300+
- **Total Size**: ~100MB (empty) + data
- **Character Set**: utf8mb4
- **Collation**: utf8mb4_unicode_ci
- **Engine**: InnoDB

### Key Table Groups

#### Demographic Tables
- `demographic` - Patient master record
- `demographicArchive` - Change history
- `demographicExt` - Extended fields
- `demographicContact` - Emergency contacts

#### Clinical Tables
- `casemgmt_note` - Progress notes (eChart)
- `eChart` - Note organization
- `drugs` - Current medications
- `allergies` - Patient allergies
- `preventions` - Immunizations, screening
- `measurementMap`, `measurements` - Vitals
- `dxresearch` - Diagnoses (ICD codes)

#### Scheduling Tables
- `appointment` - Appointments
- `appointmentArchive` - Historical
- `scheduletemplate` - Provider schedules
- `scheduletemplatecodetypes` - Time slots

#### Billing Tables
- `billing` - Invoices
- `billingservice` - Line items
- `ctl_billingservice` - Service codes
- `billingreferral` - Referral tracking

#### Document Tables
- `document` - Uploaded documents
- `ctl_document` - Lab results, reports
- `documentDescriptionTemplate` - Templates

#### Integration Tables (New)
- `system_config` - Global settings
- `integration_config` - API credentials (encrypted)
- `fax_queue`, `fax_log` - Fax management
- `sms_queue`, `sms_log` - SMS tracking
- `ocean_referrals` - eReferral tracking
- `lab_downloads` - Lab import log
- `portal_users` - Patient portal accounts
- `appointment_reminders` - Reminder queue
- `audit_log` - Security audit trail

### Relationships
- `provider` (1) → (N) `demographic` (via provider_no)
- `demographic` (1) → (N) `casemgmt_note`
- `demographic` (1) → (N) `drugs`
- `demographic` (1) → (N) `allergies`
- `demographic` (1) → (N) `appointment`
- `provider` (1) → (N) `appointment`

### Indexes
- Primary keys on all tables (id, demographic_no, provider_no, etc.)
- Foreign key indexes for relationships
- Performance indexes on common query fields (last_name, phone, chart_no)

---

## API Specifications

### OSCAR Internal APIs (JSP-based)
OSCAR uses JSP pages for most operations, not RESTful APIs. Key endpoints:

**Demographics**:
- `/demographic/demographiccontrol.jsp?action=add` - Create patient
- `/demographic/demographiccontrol.jsp?action=update` - Update patient
- `/demographic/demographicsearch2apptresults.jsp` - Search patients

**Appointments**:
- `/appointment/appointmentcontrol.jsp?action=add` - Book appointment
- `/appointment/appointmentcontrol.jsp?action=view` - View schedule

**Clinical**:
- `/casemgmt/forward.jsp?action=view` - View eChart
- `/casemgmt/NoteAction.do` - Create/update notes
- `/oscarRx/choosePatient.do` - Prescriptions

**Billing**:
- `/billing/billingview.do` - View invoice
- `/billing/save.do` - Submit billing

### Integration Service APIs (REST)

**Base URL**: `http://integrations:8080`

#### RingCentral Endpoints
```
POST /integrations/ringcentral/fax/send
Request:
{
  "demographic_no": "123",
  "fax_number": "+16045551234",
  "document_id": "456",
  "cover_page": "To: Dr. Smith\nFrom: Dr. Johnson\nPages: 3"
}
Response: {"status": "queued", "fax_id": "789"}

GET /integrations/ringcentral/fax/status/:fax_id
Response: {"status": "sent", "sent_at": "2024-11-12T10:30:00Z"}

POST /integrations/ringcentral/sms/send
Request:
{
  "phone": "+16045551234",
  "message": "Appointment reminder: Tomorrow at 2 PM"
}
Response: {"status": "sent", "sms_id": "890"}
```

#### OceanMD Endpoints
```
POST /integrations/ocean/referral/create
Request:
{
  "demographic_no": "123",
  "specialty": "Cardiology",
  "reason": "Chest pain investigation",
  "urgency": "routine",
  "notes": "Patient complains of intermittent chest discomfort..."
}
Response: {"status": "submitted", "ocean_referral_id": "abc123"}

GET /integrations/ocean/referral/:ocean_referral_id
Response: {
  "status": "accepted",
  "specialist": "Dr. Jane Smith",
  "appointment_date": "2024-12-15"
}
```

#### BC Labs Endpoints
```
POST /integrations/labs/download/trigger
Response: {"status": "download_started", "job_id": "def456"}

GET /integrations/labs/download/status/:job_id
Response: {
  "status": "completed",
  "files_downloaded": 15,
  "patients_matched": 14,
  "errors": 1
}

GET /integrations/labs/download/history
Response: [
  {"date": "2024-11-12", "files": 15, "status": "success"},
  {"date": "2024-11-11", "files": 22, "status": "success"}
]
```

#### Health Check
```
GET /health
Response: {"status": "healthy", "services": {
  "ringcentral": "connected",
  "ocean": "connected",
  "labs_excelleris": "connected",
  "labs_lifelabs": "connected"
}}
```

---

## Scalability & Performance

### Current Capacity
- **Users**: 10-50 providers (single instance)
- **Patients**: 10,000-50,000 active patients
- **Appointments**: 100-500 per day
- **Database**: 10-50GB typical
- **Documents**: 100GB-1TB

### Performance Optimization

#### Database
- **Connection Pooling**: HikariCP (10-50 connections)
- **Query Caching**: MySQL query cache
- **Indexes**: Optimized for common queries
- **Partitioning**: Consider for large tables (casemgmt_note, appointment)

#### Application
- **Java Heap**: 512MB min, 2GB max (configurable via OSCAR_MAX_MEMORY)
- **Session Management**: Server-side, 30-minute timeout
- **Static Assets**: Served by Tomcat (could add Nginx caching)

#### Integration Service
- **Queue Processing**: 10 concurrent workers
- **Retry Logic**: Exponential backoff (2s, 4s, 8s, 16s, 32s)
- **Rate Limiting**: Respect API limits (RingCentral: 10 req/s)

### Scaling Options

#### Vertical Scaling (Single Server)
- Increase Docker container memory limits
- Add more CPU cores
- Faster SSD storage
- Up to 100 providers, 100,000 patients

#### Horizontal Scaling (Multi-Server)
**Load Balancer** → Multiple OSCAR instances → Shared Database

**Requirements**:
- Session persistence (sticky sessions or Redis)
- Shared document storage (NFS or S3)
- Database replication (master-slave)

**Estimated Capacity**: 200+ providers, 500,000+ patients

---

## Monitoring & Maintenance

### Health Checks
All services have health check endpoints:
- **OSCAR**: `http://oscar:8080/oscar/`
- **Setup Wizard**: `http://setup-wizard:3000/health`
- **Integrations**: `http://integrations:8080/health`
- **Database**: `mysqladmin ping`

**Docker Compose** automatically restarts unhealthy services.

### Logs
- **OSCAR**: `/usr/local/tomcat/logs/catalina.out`
- **Integrations**: `/var/log/integrations/app.log`
- **Database**: `/var/log/mysql/error.log`

**Access logs**:
```bash
docker compose logs -f oscar
docker compose logs -f integrations
docker compose logs -f db
```

### Backups
- **Automated**: Daily at 2 AM (configurable)
- **Retention**: 30 days default
- **Storage**: Local + S3 (optional)
- **Restore**: `./backup/restore.sh <backup-date>`

### Updates
1. Pull latest images: `docker compose pull`
2. Stop services: `docker compose down`
3. Start services: `docker compose up -d`
4. Verify health: `docker compose ps`

---

## Troubleshooting

### Common Issues

**"Database connection failed"**
- Check `MYSQL_PASSWORD` in `.env`
- Verify database is running: `docker compose ps db`
- Check logs: `docker compose logs db`

**"Fax not sending"**
- Verify RingCentral credentials in Admin Settings
- Check integration service logs: `docker compose logs integrations`
- Test connection: Admin → Integrations → Test RingCentral

**"Lab results not importing"**
- Verify SFTP credentials
- Check lab download log: Admin → Labs → Download History
- Manually trigger: Admin → Labs → Download Now

**"Slow performance"**
- Check memory usage: `docker stats`
- Increase OSCAR_MAX_MEMORY in `.env`
- Optimize database: `ANALYZE TABLE` on large tables

### Support Resources
- **OSCAR Documentation**: https://oscargalaxy.org/
- **BC OpenOSP GitHub**: https://github.com/open-osp/Open-O
- **RingCentral Docs**: https://developers.ringcentral.com/
- **OceanMD Support**: support@cognisantmd.com
- **This Repository**: Issues and discussions

---

## Development

### Local Development Setup
1. Clone repository
2. Build images locally: `docker compose build`
3. Start services: `docker compose up -d`
4. Access OSCAR: http://localhost:8567/oscar

### Code Structure
```
CliniStream-OscarEMR/
├── open-o-source/          # OSCAR source code (Java)
├── deployment/
│   ├── docker-compose.yml  # Orchestration
│   ├── oscar/              # OSCAR Dockerfile & config
│   ├── setup-wizard/       # React wizard app
│   ├── integrations/       # Python Flask integration service
│   ├── backup/             # Backup scripts
│   └── sql/                # Database initialization
└── docs/                   # Documentation
```

### Making Changes
1. Create feature branch: `git checkout -b feature/my-feature`
2. Make changes, test locally
3. Commit: `git commit -m "Description"`
4. Push: `git push origin feature/my-feature`
5. Create pull request

### Testing
- **Unit Tests**: `mvn test` (OSCAR Java code)
- **Integration Tests**: `pytest` (Integration service)
- **E2E Tests**: Manual testing checklist (see TESTING.md)

---

## License & Credits

**OSCAR EMR**: GPL v3
**OpenOSP (BC Fork)**: GPL v3
**This Deployment**: Maintained by CliniStream/NextScript

**Credits**:
- OSCAR McMaster Team - Original OSCAR development
- OpenOSP Community - BC-specific enhancements
- RingCentral - Fax/SMS APIs
- CognisantMD - OceanMD eReferral platform

---

*Last Updated: November 2024*
*Version: 1.0.0*
