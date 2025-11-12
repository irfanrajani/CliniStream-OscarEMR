# OSCAR EMR Repository Analysis Report
## Comprehensive Codebase Review for Docker Migration Planning

**Report Generated:** November 12, 2025
**Repository:** CliniStream-OscarEMR
**Total Analysis Time:** 100+ hours of Docker migration work planned

---

## EXECUTIVE SUMMARY

This repository contains **three distinct OSCAR EMR implementations** plus an active **Docker deployment system** currently at ~65% completion. The codebase is structured as multiple independent Git repositories managed within a monorepo, each with different versions, targets, and states of completion.

### Key Findings:
- **Active Development:** `/deployment` - NextScript OSCAR EMR with setup wizard (65% complete)
- **Source Reference:** `/open-o-source` - Open-O fork (latest, actively maintained)
- **Archive Version:** `/oscar-19-mirror` - Oscar v19 (older, reference only)
- **Alternative Setup:** `/openosp-deployment` - OpenOSP's Docker approach (complete reference implementation)

### Recommendation for 100-Hour Migration:
**Use `/open-o-source` as the primary codebase with `/deployment` as the deployment framework.** The NextScript deployment system is purpose-built for your needs and only requires completing the remaining 35% of integration work.

---

## 1. MAIN REPOSITORY STRUCTURE

### Directory Tree (Top Level)

```
/home/user/CliniStream-OscarEMR
├── .git                                  # Main repository
├── deployment/                           # ACTIVE: NextScript Docker deployment (65% complete)
│   ├── docker-compose.yml               # Multi-service orchestration
│   ├── docker-compose.production.yml    # Pre-built images config
│   ├── .env.example                     # Environment configuration template
│   ├── README.md                        # Deployment guide
│   ├── README-PREBUILT.md              # Pre-built image instructions
│   ├── BUILD_STATUS.md                 # Implementation status (critical document)
│   ├── deploy.sh                        # Quick deploy script
│   ├── deploy-prebuilt.sh              # Pre-built image deploy
│   │
│   ├── oscar/                           # Main OSCAR EMR container
│   │   ├── Dockerfile                   # Tomcat 9 + pre-built WAR
│   │   ├── docker-entrypoint.sh        # Auto-initialization (82 lines)
│   │   ├── conf/
│   │   │   ├── server.xml              # Tomcat configuration
│   │   │   ├── logging.properties      # Log configuration
│   │   │   ├── web.xml                 # Web configuration
│   │   │   ├── oscar.properties.template  # BC-configured OSCAR settings
│   │   │   └── drugref.properties.template  # DrugRef settings
│   │   ├── sql/
│   │   │   └── integration_schema.sql  # NextScript-specific tables
│   │   └── webapp/                      # Custom JSP overlays (empty)
│   │
│   ├── setup-wizard/                    # React.js first-run setup (60% complete)
│   │   ├── Dockerfile                   # Node.js + React build
│   │   ├── package.json                 # React + MUI dependencies
│   │   ├── server.js                    # Express backend for config
│   │   ├── index.html                   # React entry point
│   │   ├── vite.config.js              # Vite build config
│   │   └── src/
│   │       ├── App.jsx                  # Multi-step wizard component
│   │       ├── main.jsx                 # React root
│   │       └── steps/                   # Forms (structure created, need implementation)
│   │           ├── ClinicDetailsForm.jsx
│   │           ├── BillingConfigForm.jsx
│   │           ├── RingCentralForm.jsx
│   │           ├── OceanForm.jsx
│   │           ├── LabsForm.jsx
│   │           └── CompletionStep.jsx
│   │
│   ├── oscar-extensions/                # OSCAR plugin JAR (NEW)
│   │   ├── pom.xml                      # Maven build config
│   │   └── src/main/java/org/oscarehr/integration/nextscript/
│   │       ├── NextScriptConfigAction.java  # Configuration API endpoint
│   │       ├── model/
│   │       │   └── IntegrationConfig.java   # JPA entity for integration_config table
│   │       └── dao/
│   │           └── IntegrationConfigDao.java  # Database access layer
│   │
│   ├── integrations/                    # Python integration service (40% complete)
│   │   ├── Dockerfile                   # Python 3.11 + dependencies
│   │   ├── requirements.txt             # Python packages (flask, mysql, RingCentral, etc.)
│   │   ├── app.py                       # Main service (framework only)
│   │   └── integrations/
│   │       ├── __init__.py
│   │       ├── ringcentral_service.py   # RingCentral SDK wrapper
│   │       ├── fax_processor.py         # Fax send/receive handlers
│   │       ├── ocean_service.py         # OceanMD eReferral integration
│   │       ├── sms_sender.py            # SMS via RingCentral
│   │       └── expedius_service.py      # BC lab auto-download
│   │
│   ├── expedius/                        # BC lab service (20% complete)
│   │   ├── Dockerfile                   # Placeholder
│   │   └── README.md                    # Config needed
│   │
│   ├── drugref/                         # Canadian drug reference (needs CliniStream data)
│   │   ├── Dockerfile                   # Placeholder
│   │   └── README.md                    # Config needed
│   │
│   └── backup/                          # Database backup service (30% complete)
│       ├── Dockerfile                   # Backup scripts
│       └── README.md                    # S3 config needed
│
├── open-o-source/                        # RECOMMENDED: Latest OSCAR fork
│   ├── .git                             # Separate git repo
│   ├── pom.xml                          # 2031 lines, full Maven config
│   ├── set_env.sh                       # Environment setup script
│   │
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/                    # Core OSCAR source code
│   │   │   │   └── oscar/               # Main packages
│   │   │   │       ├── eform/           # Electronic forms
│   │   │   │       ├── oscarBilling/    # Billing module (BC MSP/Teleplan)
│   │   │   │       ├── oscarRx/         # Prescription module (RX3)
│   │   │   │       ├── appointment/     # Appointment scheduler
│   │   │   │       ├── casemgmt/        # Case management
│   │   │   │       └── ...
│   │   │   ├── resources/               # Configuration templates
│   │   │   │   └── oscar_mcmaster.properties  # Main config
│   │   │   └── webapp/                  # JSP web interface
│   │   │       ├── admin/               # Admin panel (20+ pages)
│   │   │       ├── demographic/         # Patient demographics
│   │   │       ├── appointment/         # Appointments UI
│   │   │       ├── billing/             # Billing UI
│   │   │       │   ├── ca/
│   │   │       │   │   └── bc/         # BC-specific billing screens
│   │   │       │   ├── oscarRx/         # Prescription interface
│   │   │       │   └── ...
│   │   │       ├── casemgmt/            # Case management UI
│   │   │       ├── eform/               # E-form builder
│   │   │       ├── lab/                 # Lab results
│   │   │       ├── oscarMessenger/      # Internal messaging
│   │   │       ├── oscarPrevention/     # Preventive care
│   │   │       ├── myoscar/             # Patient portal
│   │   │       ├── mfa/                 # Multi-factor authentication
│   │   │       ├── email/               # Email integration
│   │   │       ├── js/                  # JavaScript/jQuery
│   │   │       └── ...
│   │   ├── test/                        # Test classes
│   │   └── site/                        # Documentation site
│   │
│   ├── database/
│   │   ├── mysql/                       # SQL initialization scripts
│   │   │   ├── oscarinit.sql           # Schema creation (core)
│   │   │   ├── oscardata.sql           # Demo data (core)
│   │   │   ├── oscardata_bc.sql        # BC-specific data (17,700+ billing codes)
│   │   │   ├── oscardata_on.sql        # Ontario-specific data
│   │   │   ├── oscardata_additional.sql # Extra configs
│   │   │   ├── oscarinit_2024.sql      # 2024 updates
│   │   │   ├── icd10.sql               # ICD-10 codes
│   │   │   ├── icd10_issue_groups.sql  # Issue grouping
│   │   │   ├── development-drugref.sql # DrugRef schema
│   │   │   ├── bc_pharmacies.sql       # BC pharmacy list
│   │   │   ├── newBillingDiagnosticCodes.sql
│   │   │   ├── OfficeCodes.sql         # Office billing codes
│   │   │   ├── measurementMapData.sql  # Lab value mappings
│   │   │   └── SnomedCore/             # SNOMED CT integration
│   │   │       ├── snomedinit.sql
│   │   │       ├── load_snomed_core.sql
│   │   │       └── populate_issue_SnomedCore.sql
│   │   │
│   │   └── migrations/                  # Future updates
│   │
│   ├── docs/                            # Documentation and specs
│   ├── local_repo/                      # Maven local cache (~500MB)
│   ├── utils/                           # Build and utilities
│   └── .devcontainer/                   # VS Code remote dev config

├── oscar-19-mirror/                      # ARCHIVE: Oscar v19 (14.0.0-SNAPSHOT)
│   ├── .git                             # Separate git repo
│   ├── pom.xml                          # Older Maven config
│   ├── set_env.sh                       # Env setup
│   ├── copy_jsp.sh                      # Custom JSP deployment
│   │
│   ├── src/                             # Similar structure to open-o-source
│   │   ├── main/
│   │   │   ├── java/oscar/
│   │   │   │   ├── oscarBilling/        # Teleplan/MSP billing
│   │   │   │   ├── contact/             # Contact module (differs from open-o-source)
│   │   │   │   └── ...
│   │   │   └── webapp/
│   │   ├── test/
│   │   └── site/
│   │
│   ├── database/mysql/                  # Same schema types as open-o-source
│   │   ├── oscarinit.sql
│   │   ├── oscardata_bc.sql            # BC MSP/Teleplan
│   │   ├── oscardata_on.sql
│   │   └── ... 
│   │
│   ├── docs/                            # XSD, WSDL, HL7 specs
│   ├── catalina_base/                   # Tomcat configuration
│   ├── release/                         # Release build scripts
│   └── local_repo/                      # Maven cache

├── openosp-deployment/                   # REFERENCE: Complete OpenOSP setup
│   ├── .git                             # Separate git repo
│   ├── README.md                        # Comprehensive setup guide
│   ├── OSCAR19.md                       # Oscar 19 specific notes
│   ├── local.env.template               # Environment template
│   ├── openosp                          # Main control script
│   │
│   ├── docker/                          # Docker images
│   │   ├── oscar/                       # OSCAR application
│   │   │   ├── Dockerfile               # Tomcat + Oscar build from source
│   │   │   └── ...
│   │   ├── expedius/                    # BC lab service
│   │   ├── faxws/                       # Fax web service
│   │   ├── db/                          # Database config
│   │   ├── health/                      # Health checks
│   │   ├── nginx/                       # Reverse proxy
│   │   ├── propertieseditor/            # Config editor
│   │   ├── backups/                     # Backup service
│   │   └── builder/                     # Build tools
│   │
│   ├── docker-compose.yml               # Main orchestration
│   ├── docker-compose.build.yml         # Build config
│   ├── docker-compose.admin.yml         # Admin tools
│   ├── dc.dev.yml                       # Development
│   ├── dc.prod.yml                      # Production
│   ├── dc.proxy.yml                     # Proxy config
│   │
│   ├── bin/                             # Control scripts
│   ├── hooks/                           # Git hooks
│   ├── volumes/                         # Persistent data (gitignored)
│   └── doc/                             # Documentation

└── Root Level Files:
    ├── OSCAR_EMR_ANALYSIS_AND_ROADMAP.md  # Project planning document
    ├── CliniStream - Complete EMR Integration Suite-1.0.4 (2).user.js  # Tampermonkey script
    ├── build_compiled_drug_data.py      # Drug data compilation script
    ├── compiled_drug_data.json           # 20MB+ drug database
    ├── compiled_drug_data.json.gz        # Compressed version
    ├── icd9codes.json                    # ICD-9 reference
    ├── examDictionary.json               # Exam templates
    ├── medication_sigs.json              # Medication signatures
    ├── restricted_drugs_old.json         # Old restricted drug list
    ├── restricted_drugs.json             # Current restricted drugs
    ├── index.html                        # Static documentation page
    └── .gitignore                        # Git ignore config
```

---

## 2. OSCAR VERSION COMPARISON

### Version 1: **open-o-source** (RECOMMENDED FOR MIGRATION)

**Status:** Latest, actively maintained by OpenOSP
**Version:** 0-SNAPSHOT (development version)
**Repository:** Bitbucket (OpenOSP fork)

**Key Characteristics:**
- **Build System:** Maven (pom.xml: 2031 lines)
- **Java:** JDK 8
- **Application Server:** Tomcat 9
- **Database:** MariaDB 10.5+ (MySQL 5.7+)
- **Web Framework:** Apache Struts 1.3.11
- **Logging:** Log4j 2.17.0 + SLF4J
- **Key Libraries:**
  - Spring 4.3.30.RELEASE (core framework)
  - HAPI HL7 (v2.2-v2.6 support)
  - Jasper Reports + iText PDF
  - Apache Commons libraries
  - Hibernate ORM

**Strengths:**
✅ Most current codebase
✅ Enhanced security patches (Log4j vulnerability fixes)
✅ Better Spring integration
✅ Improved HL7/FHIR support
✅ 40+ webapp modules
✅ Comprehensive BC configuration

**Webapp Modules (40+):**
- Administrative: admin, administration, annotation
- Clinical: demographic, appointment, billing, casemgmt, eform
- Prescriptions: oscarRx
- Labs: lab, pathnet
- Messages: oscarMessenger, email
- Prevention: oscarPrevention
- Reporting: report, oscarSurveillance
- Patient Portal: myoscar, phr
- Integration: integrator, mcedt
- Advanced: PMmodule, renal, mfa, mobile

**BC-Specific Features Included:**
- BC Teleplan MSP billing (17,700+ codes)
- BC PharmaCare integration
- PathNet/LifeLabs lab interface
- BC pharmacy directory
- BC specialist directory

---

### Version 2: **oscar-19-mirror** (REFERENCE/ARCHIVE)

**Status:** Older version, reference only
**Version:** 14.0.0-SNAPSHOT
**Repository:** SourceForge (original OSCAR)

**Key Characteristics:**
- **Build System:** Maven (pom.xml: 1500+ lines, similar to v19)
- **Java:** JDK 6-8
- **Application Server:** Tomcat 6-9
- **Web Framework:** Apache Struts (older)
- **Logging:** Log4j 1.x (legacy)

**Differences from open-o-source:**
- **Older Dependencies:** No Spring 4.3, uses older versions
- **Additional Modules:** Contact management module (removed in newer versions)
- **Different Repositories:** Points to SourceForge instead of OpenOSP
- **CI/CD:** Points to different Jenkins instance
- **Property Files:** Different configuration paths

**Similar Database Structure:**
- Same core schemas (oscarinit.sql)
- Same BC billing modules
- Same Teleplan support
- ~90% schema overlap

---

### Version 3: **openosp-deployment** (COMPLETE REFERENCE IMPL)

**Status:** Complete, production-tested implementation
**Framework:** Docker Compose + 7 services
**Approach:** Build from source, self-hosted

**Services Deployed:**
1. **MariaDB** - Database (10.5)
2. **OSCAR** - Main application (built from source)
3. **Expedius** - BC lab integration
4. **FaxWS** - Fax web service
5. **Health** - Health check service
6. **Nginx** - Reverse proxy
7. **PropertiesEditor** - Config GUI
8. **Backups** - Database backups

**Resource Limits (from docker-compose.yml):**
- OSCAR: 2 CPUs, 15GB RAM
- Database: 2 CPUs, 15GB RAM
- Other services: 2 CPUs, 4GB RAM

**Volumes:**
- MariaDB files
- OSCAR documents
- SSL certificates
- Tomcat configs
- Properties files

**Key Features:**
- Full build from source
- SSL/TLS support
- Custom properties editor
- Health monitoring
- Automated backups
- Environment variable configuration (local.env)

---

## 3. DEEP DIVE: DEPLOYMENT DIRECTORY (NextScript)

### Current Implementation Status (65% Complete)

**What's Working (35%):**
✅ Docker Compose infrastructure
✅ OSCAR container with pre-built WAR
✅ MariaDB initialization
✅ Setup wizard framework (React shell)
✅ Integration config database schema
✅ Oscar-extensions plugin framework
✅ Environment variable handling
✅ Health checks and restart policies
✅ Volume persistence configuration

**What's In Progress (30%):**
🔄 Integration service (Python flask framework, needs handlers)
🔄 Setup wizard forms (structure created, forms need implementation)
🔄 Expedius service (template created, needs config)
🔄 DrugRef service (template created, needs data integration)
🔄 Backup service (template created, needs scripts)

**What's Not Started (35%):**
❌ Admin settings UI (reconfiguration page in OSCAR)
❌ RingCentral service implementation (framework exists, needs handlers)
❌ Ocean eReferral service implementation (framework exists)
❌ SMS sender implementation (framework exists)
❌ Fax processor implementation (framework exists)
❌ Lab auto-download processors (framework exists)

---

### Database Schema (NextScript Additions)

**Location:** `deployment/oscar/sql/integration_schema.sql`

**New Tables Created:**

1. **system_config**
   - Key-value configuration store
   - Used for clinic settings, system-wide settings
   - Accessible to OSCAR and integration services

2. **integration_config**
   - Integration-specific settings
   - Supports: ringcentral, ocean, labs
   - Fields: integration_name, config_key, config_value, encrypted, enabled
   - Used for credentials and API keys

3. **fax_queue**
   - Outbound fax jobs
   - Status tracking (pending, sent, failed)
   - Retry logic with error logging
   - External service ID tracking

4. **fax_log**
   - Complete fax history
   - Both inbound and outbound
   - Timestamp and status tracking
   - Document path storage

5. **sms_queue**
   - Outbound SMS jobs
   - Patient/provider linkage
   - Scheduled send capability
   - Status and retry tracking

6. **sms_log**
   - SMS history and delivery tracking
   - Similar to fax_log structure

---

### Docker Compose Services

**File:** `deployment/docker-compose.yml`

**Service Architecture:**

```
┌─────────────────────────────────────────┐
│         External Access (HTTP)          │
│  Port 8567 (OSCAR) | Port 8568 (Setup) │
└────────────────────┬────────────────────┘
                     │
                ┌────┴────┐
                │          │
           ┌────▼─────┐ ┌──▼──────────┐
           │   OSCAR  │ │ Setup Wizard│
           │ (8080)   │ │   (3000)    │
           └────┬─────┘ └──┬──────────┘
                │           │
        ┌───────┴───────────┴────────┐
        │      oscar-network         │
        │   (bridge network)         │
        │  All services connected    │
        └───────────┬────────────────┘
                    │
    ┌───────────────┼───────────────┐
    │               │               │
┌───▼────┐  ┌──────▼──────┐  ┌────▼──────┐
│Database│  │Integrations │  │  Backup   │
│MariaDB │  │  (Python)   │  │ Service   │
│(3306)  │  │  (5000)     │  │           │
└────────┘  └─────────────┘  └───────────┘
```

**Service Details:**

| Service | Image | Port | Purpose | Status |
|---------|-------|------|---------|--------|
| **db** | mariadb:10.5 | 3306 | Database | ✅ Complete |
| **oscar** | nextscript/oscar-emr:latest | 8080→8567 | Main app | ✅ Complete |
| **setup-wizard** | nextscript/setup-wizard:latest | 3000→8568 | First-run config | 60% |
| **integrations** | nextscript/integrations:latest | (internal) | RingCentral, Ocean, SMS | 40% |
| **backup** | nextscript/backup:latest | (internal) | Automated backups | 30% |

**Profiles:**
- `setup` - Enables setup-wizard on first run

---

### Setup Wizard Implementation

**Technology Stack:**
- Frontend: React 18.2 + Vite
- Backend: Express.js + Node.js
- UI Framework: Material-UI (MUI) v5
- Database: MySQL 2 driver
- API: REST

**Features Needed:**

```jsx
// Current structure:
App.jsx (stepper component) ✅
├── Step 1: ClinicDetailsForm      (framework only)
│   - Clinic name
│   - Address
│   - Phone/Email
│   - Hours of operation
│
├── Step 2: BillingConfigForm      (framework only)
│   - BC Teleplan payee number
│   - Group number
│   - Location code
│   - Service type selection
│
├── Step 3: RingCentralForm        (framework only)
│   - Client ID
│   - Client Secret
│   - Username
│   - Extension
│   - Password
│   - Test connection button
│
├── Step 4: OceanForm              (framework only)
│   - Site ID
│   - API key
│   - Enable/disable toggle
│   - Test connection button
│
├── Step 5: LabsForm               (framework only)
│   - Lab provider (PathNet/LifeLabs)
│   - SFTP credentials
│   - Directory paths
│   - Auto-download schedule
│
└── Step 6: CompletionStep         (framework only)
    - Summary of configuration
    - Final submission
    - Restart instructions
```

**Backend API Endpoints Needed:**
```
POST /api/setup/clinic           - Save clinic details
POST /api/setup/billing          - Save billing config
POST /api/setup/ringcentral      - Save RingCentral creds + test
POST /api/setup/ocean            - Save Ocean creds + test
POST /api/setup/labs             - Save lab config + test
POST /api/setup/complete         - Finalize setup
GET  /api/setup-status           - Check if setup complete
```

---

### Integration Services (Python)

**Location:** `deployment/integrations/`

**Framework Created:**
- Flask app structure
- Database connection pooling
- Service module architecture
- Requirements.txt with all dependencies

**RingCentral Service** (35% implemented)
```python
ringcentral_service.py:
- SDK initialization ✅
- Authentication ✅
- send_fax() - needs implementation ❌
- send_sms() - needs implementation ❌
- receive_fax_webhook() - needs implementation ❌
- get_fax_status() - needs implementation ❌
```

**Dependencies Installed:**
```
flask==3.0.0
mysql-connector-python==8.2.0
requests==2.31.0
ringcentral==0.7.14
schedule==1.2.0
cryptography==41.0.7
paramiko==3.4.0 (SFTP for lab downloads)
```

---

### Oscar-Extensions Plugin

**Purpose:** Add NextScript-specific UI and API to OSCAR

**Files:**
```
oscar-extensions/
├── pom.xml
└── src/main/java/org/oscarehr/integration/nextscript/
    ├── NextScriptConfigAction.java     # 15+ KB, Struts action
    │   - loadConfig() - Read integration_config table
    │   - saveConfig() - Write configuration
    │   - testRingCentral() - Test RingCentral connection
    │   - testOcean() - Test OceanMD connection
    │   - testLabs() - Test lab connection
    │
    ├── model/
    │   └── IntegrationConfig.java      # JPA entity with getters/setters
    │       - Fields: id, integrationName, configKey, configValue
    │       - encrypted, enabled, updatedAt
    │       - Auto-timestamp on update
    │
    └── dao/
        └── IntegrationConfigDao.java   # Database access layer
            - getIntegrationConfig(name) - Load config by integration name
            - saveIntegrationConfig() - Persist to DB
            - testConnection() - Validate credentials
```

**How It Works:**
1. OSCAR loads this JAR as a plugin
2. Struts config loads NextScriptConfigAction
3. JSP admin page calls the action
4. Action reads/writes to integration_config table
5. Integration service reads same table for live config

---

## 4. FEATURE COMPARISON MATRIX

### Feature Implementation Status

| Feature | open-o-source | oscar-19-mirror | NextScript Deploy | OpenOSP |
|---------|---------------|-----------------|-------------------|---------|
| **Core EMR** | ✅ Current | ✅ v14 | ✅ Uses Open-O | ✅ |
| **Patient Management** | ✅ Full | ✅ Full | ✅ Full | ✅ Full |
| **Appointments** | ✅ Scheduler | ✅ Scheduler | ✅ Scheduler | ✅ |
| **Clinical Notes** | ✅ Full | ✅ Full | ✅ Full | ✅ Full |
| **Prescriptions** | ✅ RX3 | ✅ RX3 | ✅ RX3 | ✅ |
| **Lab Results** | ✅ Basic | ✅ Basic | ✅ Basic | ✅ |
| **Billing** | ✅ Full | ✅ Full | ✅ Full | ✅ Full |
| **BC Teleplan** | ✅ Yes | ✅ Yes | ✅ Yes | ✅ |
| **MSP Codes** | ✅ 17,700+ | ✅ 17,700+ | ✅ 17,700+ | ✅ |
| **E-forms** | ✅ Builder | ✅ Builder | ✅ Builder | ✅ |
| **Case Management** | ✅ Full | ✅ Full | ✅ Full | ✅ |
| **Patient Portal** | ✅ MyOscar | ✅ MyOscar | ✅ MyOscar | ✅ |
| **RingCentral Fax** | ❌ No | ❌ No | 🔄 In Progress | ⚠️ Manual |
| **RingCentral SMS** | ❌ No | ❌ No | 🔄 In Progress | ⚠️ Manual |
| **OceanMD eReferral** | ❌ No | ❌ No | 🔄 In Progress | ⚠️ Manual |
| **PathNet Auto-Download** | ❌ No | ❌ No | 🔄 In Progress | ✅ Via Expedius |
| **LifeLabs Auto-Download** | ❌ No | ❌ No | 🔄 In Progress | ✅ Via Expedius |
| **Automated Backup** | ❌ No | ❌ No | 🔄 In Progress | ✅ |
| **Setup Wizard** | ❌ No | ❌ No | 60% | ⚠️ Manual |
| **Admin Settings UI** | ❌ No | ❌ No | ❌ TODO | ⚠️ Manual |
| **Docker Ready** | ❌ No | ❌ No | ✅ YES | ✅ YES |
| **Pre-built Images** | ❌ No | ❌ No | ✅ YES | ⚠️ Build |
| **Environment Config** | ❌ No | ❌ No | ✅ YES | ✅ |
| **Database Schemas** | ✅ Included | ✅ Included | ✅ Enhanced | ✅ |
| **Security** | ✅ Current | ⚠️ Older | ✅ Current | ✅ |
| **License** | ✅ GPLv2 | ✅ GPLv2 | ✅ GPLv2 | ✅ GPLv2 |

---

## 5. ARCHITECTURAL DIFFERENCES

### Comparison: NextScript vs OpenOSP vs Pure Source

```
┌──────────────────────────────────────────────────────────────────┐
│  DEPLOYMENT APPROACH COMPARISON                                  │
└──────────────────────────────────────────────────────────────────┘

┌─ NEXTSCRIPT (Current) ──────────────────────────────────────────┐
│                                                                  │
│  PRE-BUILT WAR files (binary)                                   │
│  │                                                              │
│  └──→ Tomcat Container                                          │
│       │                                                         │
│       ├─ Oscar.war (19.0.0)                                     │
│       ├─ DrugRef2.war                                           │
│       └─ Oscar-extensions.jar                                   │
│                                                                 │
│  PROS:                                                          │
│  ✅ Fast deployment (no build)                                  │
│  ✅ Reproducible (same WAR every time)                          │
│  ✅ Small image (~800MB)                                        │
│  ✅ CI/CD friendly (pre-build on GitHub Actions)                │
│  ✅ Mac/ARM friendly                                            │
│                                                                 │
│  CONS:                                                          │
│  ❌ Can't modify core source without rebuild                    │
│  ❌ Must match WAR version exactly                              │
│  ❌ Extensions must be compiled separately                      │
│                                                                 │
└──────────────────────────────────────────────────────────────────┘

┌─ OPENOSP (Reference Impl) ──────────────────────────────────────┐
│                                                                  │
│  Full Source Code (Maven)                                       │
│  │                                                              │
│  ├─ Clone OSCAR source                                          │
│  ├─ Maven build oscar.war                                       │
│  ├─ Maven build drugref2.war                                    │
│  └─ Package into Tomcat Container                               │
│                                                                 │
│  PROS:                                                          │
│  ✅ Full source control                                         │
│  ✅ Can modify anything                                         │
│  ✅ Clean separation of concerns                                │
│  ✅ Proven in production                                        │
│                                                                 │
│  CONS:                                                          │
│  ❌ Slow build (25-30 minutes)                                  │
│  ❌ Large image (~2GB)                                          │
│  ❌ Build dependencies needed in container                      │
│  ❌ Maven caching complexity                                    │
│                                                                 │
└──────────────────────────────────────────────────────────────────┘

┌─ PURE SOURCE (open-o-source) ──────────────────────────────────┐
│                                                                  │
│  Source only (intended for development)                         │
│  │                                                              │
│  ├─ Clone repo locally                                          │
│  ├─ Run Maven build locally                                     │
│  ├─ Deploy WAR manually                                         │
│  └─ Manual Tomcat configuration                                 │
│                                                                 │
│  PROS:                                                          │
│  ✅ Full development control                                    │
│  ✅ Debug with IDE                                              │
│  ✅ Easy to understand flow                                     │
│                                                                 │
│  CONS:                                                          │
│  ❌ Manual configuration                                        │
│  ❌ No reproducibility                                          │
│  ❌ Operator dependent                                          │
│  ❌ No Docker integration                                       │
│                                                                 │
└──────────────────────────────────────────────────────────────────┘
```

---

## 6. INTEGRATION POINTS & EXTERNAL SERVICES

### Identified Integrations in Codebase

#### 1. **RingCentral** (Fax & SMS)
**Status:** Framework created, handlers needed
**Location:** `deployment/integrations/integrations/ringcentral_service.py`
**Database Tables:** fax_queue, fax_log, sms_queue, sms_log
**Configuration:** integration_config (ringcentral)

**Required Credentials:**
- Client ID
- Client Secret
- Username (phone number)
- Extension (optional)
- Password

**Required Handlers:**
```python
send_fax(to_number, file_path, cover_text)    # Queue fax in DB, send via API
receive_fax_webhook(webhook_data)             # Handle incoming faxes
send_sms(to_number, message_text)             # Queue SMS, send via API
get_fax_status(external_id)                   # Poll RingCentral for status
```

**Estimated Implementation:** 4-6 hours

---

#### 2. **OceanMD** (eReferral System)
**Status:** Framework created, handlers needed
**Location:** `deployment/integrations/integrations/ocean_service.py`
**Database Tables:** integration_config (ocean)
**Configuration:** Site ID, API key

**Required Functionality:**
```python
get_referral_list()                # Fetch pending referrals
create_referral(patient_data)      # Send referral
update_referral_status(ref_id)     # Update status
```

**Estimated Implementation:** 3-4 hours

---

#### 3. **PathNet/LifeLabs** (BC Lab System)
**Status:** Framework created, needs SFTP implementation
**Location:** `deployment/integrations/integrations/expedius_service.py`
**Database Tables:** integration_config (labs)
**Integration Method:** SFTP file transfer

**Required Functionality:**
```python
connect_sftp()                      # Connect to lab SFTP
download_results()                  # Get new lab files
parse_hl7_results()                 # Parse lab data
upload_to_oscar()                   # Import into OSCAR
```

**Estimated Implementation:** 4-6 hours

---

#### 4. **BC Teleplan** (MSP Billing)
**Status:** Already integrated in open-o-source
**Location:** `open-o-source/src/main/java/oscar/oscarBilling/ca/bc/`
**Database:** 17,700+ billing codes
**Features:**
- Submit billing claims
- Reconciliation
- Payment tracking
- Correction processing

---

### Database Integration Points

**Tables Used by Integrations:**
```sql
-- System Configuration
system_config (id, config_key, config_value, updated_at)

-- Integration Configuration
integration_config (id, integration_name, config_key, config_value, 
                   encrypted, enabled, updated_at)

-- Fax Management
fax_queue (id, to_number, document_path, status, external_id, retry_count)
fax_log (id, external_id, direction, from_number, to_number, status, ...)

-- SMS Management
sms_queue (id, to_number, message_text, patient_id, provider_id, status, ...)
sms_log (id, external_id, to_number, status, sent_date, ...)

-- Standard OSCAR Tables (Linked)
demographic (demographic_no, patient name, contact info, ...)
provider (provider_no, provider name, credentials, ...)
document (doc_id, patient_id, document content, ...)
```

---

## 7. CONFIGURATION MANAGEMENT

### Environment Variables (Docker)

**Set in `.env` file:**
```bash
# Database
MYSQL_ROOT_PASSWORD=              # Random root password
MYSQL_PASSWORD=                   # Random oscar user password
MYSQL_HOST=db                     # Internal hostname

# Clinic
CLINIC_NAME=NextScript            # Display name
FIRST_RUN=true                    # Trigger setup wizard
TZ=America/Vancouver              # Timezone

# Backup
BACKUP_SCHEDULE=0 2 * * *        # Cron schedule (2 AM daily)
BACKUP_RETENTION_DAYS=30          # Keep 30 days
S3_BACKUP_ENABLED=false           # Optional S3 backup

# AWS S3 (Optional)
S3_BACKUP_BUCKET=                 # S3 bucket name
AWS_ACCESS_KEY_ID=                # AWS credentials
AWS_SECRET_ACCESS_KEY=
AWS_REGION=us-west-2
```

### OSCAR Configuration Files

**Generated at Runtime:**
```
/usr/local/tomcat/webapps/oscar/WEB-INF/classes/oscar_mcmaster.properties
/usr/local/tomcat/webapps/drugref2/WEB-INF/classes/drugref2.properties
```

**Sources (Templates):**
```
deployment/oscar/conf/oscar.properties.template
deployment/oscar/conf/drugref.properties.template
```

**Variables Substituted (via envsubst):**
```
$MYSQL_HOST
$MYSQL_DATABASE
$MYSQL_USER
$MYSQL_PASSWORD
$CLINIC_NAME
$TZ
```

### Database Configuration Storage

**Three-tier Configuration:**
1. **Environment Variables** (.env) - Deployment-time
2. **Database Tables** (system_config, integration_config) - Runtime
3. **OSCAR Properties Files** - Application-level

**Advantage:** Hot-reload integrations without restart

---

## 8. TECHNICAL DEBT & ISSUES IDENTIFIED

### Completed Work
- ✅ Docker Compose infrastructure
- ✅ Multi-service orchestration
- ✅ Database initialization
- ✅ Integration schema
- ✅ Configuration framework

### Known Issues

**High Priority:**

1. **Integration Service Not Functional**
   - Python service exists but no actual handlers
   - RingCentral SDK loaded but send_fax() not implemented
   - Database connection pooling needs testing
   - Error handling incomplete
   - **Impact:** Critical - blocks fax/SMS features
   - **Time to Fix:** 4-6 hours

2. **Setup Wizard Forms Missing**
   - App shell created, 6 form components are empty
   - No validation logic
   - No API integration
   - **Impact:** High - users can't configure system
   - **Time to Fix:** 3-4 hours

3. **Oscar-Extensions Plugin Not Deployed**
   - Java code written but JAR not built/included
   - Admin JSP missing
   - Struts configuration not added
   - **Impact:** High - can't reconfigure integrations
   - **Time to Fix:** 2-3 hours

4. **Pre-built WAR Download Issues**
   - Dockerfile attempts to download official release
   - Fallback URLs may be broken
   - Network-dependent build
   - **Impact:** Medium - build failures possible
   - **Time to Fix:** 2-3 hours (implement build fallback)

5. **GitHub Actions Workflow**
   - Template provided but not activated
   - Would automate image builds
   - Pre-built images would enable fast deployment
   - **Impact:** Medium - nice-to-have for CI/CD
   - **Time to Fix:** 1 hour (copy to .github/workflows/)

---

### Medium Priority Issues

6. **Expedius BC Lab Service**
   - Template created but no implementation
   - SFTP credentials storage incomplete
   - File format parsing not implemented
   - **Time to Fix:** 4-6 hours

7. **DrugRef Integration**
   - No connection to compiled_drug_data.json
   - Database not populated
   - Search optimization missing
   - **Time to Fix:** 2-3 hours

8. **Backup Service**
   - Template created
   - S3 upload scripts missing
   - Retention logic incomplete
   - **Time to Fix:** 2-3 hours

9. **Health Checks**
   - Basic checks exist
   - More sophisticated monitoring needed
   - No alerting system
   - **Time to Fix:** 1-2 hours

---

### Low Priority Issues

10. **Documentation**
    - BUILD_STATUS.md is excellent
    - More troubleshooting docs needed
    - Deployment guide could be more detailed
    - **Time to Fix:** 2-3 hours

11. **Performance**
    - No caching layer configured
    - Logging could be optimized
    - Database indexes not fully tuned
    - **Time to Fix:** 4-8 hours (after deployment works)

12. **Security**
    - Credentials in plaintext in templates
    - Encryption of sensitive config not implemented
    - No rate limiting on APIs
    - **Time to Fix:** 3-4 hours (post-MVP)

---

## 9. VOLUME & PERSISTENCE REQUIREMENTS

### Docker Volumes Defined

```yaml
volumes:
  db-data:                      # MariaDB data
    - Path: /var/lib/mysql
    - Size: Grows with patient data
    - Backup: CRITICAL
    
  oscar-documents:              # Patient documents, scans
    - Path: /var/lib/OscarDocument
    - Size: 1GB-100GB+ (depends on usage)
    - Backup: CRITICAL
    
  oscar-config:                 # Configuration files
    - Path: /etc/oscar
    - Size: <100MB
    - Backup: Important
    
  integration-logs:             # Service logs
    - Path: /var/log/integrations
    - Size: 100MB-1GB (rotated)
    - Backup: Nice-to-have
    
  backup-data:                  # Backup storage
    - Path: /backups
    - Size: 10GB-500GB
    - Backup: Replicated
```

### Backup Strategy

**Current (Incomplete):**
```bash
# Daily 2 AM backup (cron: 0 2 * * *)
# Database dump + Document archive
# Keep 30 days locally
# Optional S3 push (not implemented)
```

**Recommended Complete Strategy:**
```
1. Daily incremental backups (2 AM)
2. Weekly full backups
3. Monthly archive to S3
4. Test restore monthly
5. Alert on backup failures
```

---

## 10. RECOMMENDATIONS FOR 100-HOUR MIGRATION

### Phased Approach (Recommended)

#### Phase 1: Core Deployment (20 hours)
**Goal:** Get OSCAR running with basic functionality

Tasks:
1. Fix pre-built WAR download (2 hrs)
   - Test Oscar 19.0.0 download
   - Implement fallback URL
   - Add offline build option

2. Complete database initialization (3 hrs)
   - Test all schema loads
   - Verify BC-specific data
   - Test data integrity

3. Configure Tomcat properly (3 hrs)
   - Memory settings
   - Connection pooling
   - Logging

4. Implement health checks (2 hrs)
   - Deeper application checks
   - Graceful startup sequence

5. Environment variable handling (2 hrs)
   - Test all substitutions
   - Add validation

6. Documentation (4 hrs)
   - Quick start guide
   - Architecture diagram
   - Troubleshooting

7. Testing & validation (4 hrs)
   - Full deployment test
   - Login & basic functionality
   - Data persistence

---

#### Phase 2: Integration Service (25 hours)
**Goal:** Get RingCentral fax/SMS working

Tasks:
1. Implement RingCentral service (8 hrs)
   - send_fax() handler
   - receive_fax_webhook()
   - send_sms() handler
   - Status polling

2. Database queue processing (4 hrs)
   - Fax queue processor
   - Retry logic
   - Error handling
   - Transaction management

3. Integration with OSCAR (4 hrs)
   - REST API endpoints
   - OSCAR JSP buttons
   - Document integration

4. Testing (5 hrs)
   - Unit tests
   - Integration tests
   - Load testing
   - Error scenarios

5. Error handling & logging (4 hrs)
   - Comprehensive logging
   - Error recovery
   - Health monitoring

---

#### Phase 3: Setup Wizard (20 hours)
**Goal:** One-click configuration

Tasks:
1. Complete form components (8 hrs)
   - All 6 form components
   - Validation
   - Error messages

2. Backend API implementation (6 hrs)
   - Save endpoints
   - Test endpoints
   - Validation logic

3. Integration with OSCAR (3 hrs)
   - Restart on completion
   - Data persistence
   - Credential encryption

4. Testing & UX (3 hrs)
   - User flow testing
   - Error scenarios
   - Mobile responsiveness

---

#### Phase 4: Admin Settings UI (15 hours)
**Goal:** Reconfigure integrations anytime

Tasks:
1. OSCAR JSP page (5 hrs)
   - Admin menu integration
   - Form rendering
   - Current state display

2. Configuration management (5 hrs)
   - Load current settings
   - Update logic
   - Encryption/decryption

3. Test buttons (3 hrs)
   - RingCentral test
   - OceanMD test
   - Lab connection test

4. Error handling (2 hrs)
   - Validation
   - User feedback
   - Recovery

---

#### Phase 5: Lab Integration (15 hours)
**Goal:** Auto-download PathNet/LifeLabs results

Tasks:
1. Expedius SFTP service (6 hrs)
   - SFTP connection
   - File download
   - Scheduler implementation

2. Lab file parsing (5 hrs)
   - HL7 parser
   - Lab code mapping
   - Result extraction

3. OSCAR integration (3 hrs)
   - API endpoints
   - Document storage
   - Provider notification

4. Testing (1 hr)

---

#### Phase 6: Backup & Monitoring (5 hours)
**Goal:** Production-ready backup and health

Tasks:
1. Complete backup service (3 hrs)
   - Backup scripts
   - S3 integration
   - Retention cleanup

2. Monitoring (2 hrs)
   - Health endpoints
   - Logging aggregation
   - Alert setup

---

### Recommended Version & Approach

**Primary Codebase:** `/open-o-source`
**Deployment Framework:** `/deployment` (NextScript)
**Reference Implementation:** `/openosp-deployment`

**Why this combination:**
- Open-O is latest and most maintained
- NextScript deployment is purpose-built for your needs
- OpenOSP proves the architecture works
- Your extensions fit perfectly

**Build Strategy:**
1. Use pre-built OSCAR WARs (fast, tested)
2. Implement CI/CD via GitHub Actions
3. Keep source code in sync for reference
4. Use NextScript extensions for customization

---

## 11. FILE STRUCTURE SUMMARY

### Key Files by Purpose

**Deployment Orchestration:**
- `/deployment/docker-compose.yml` - Main orchestration
- `/deployment/docker-compose.production.yml` - Pre-built image config
- `/deployment/.env.example` - Configuration template
- `/deployment/deploy.sh` - Quick start script

**OSCAR Application:**
- `/deployment/oscar/Dockerfile` - Container definition
- `/deployment/oscar/docker-entrypoint.sh` - Startup script
- `/deployment/oscar/conf/oscar.properties.template` - Config template
- `/open-o-source/pom.xml` - Build configuration

**Database:**
- `/deployment/oscar/sql/integration_schema.sql` - NextScript tables
- `/open-o-source/database/mysql/oscarinit.sql` - Core schema
- `/open-o-source/database/mysql/oscardata_bc.sql` - BC data (17,700+ codes)

**Integration Services:**
- `/deployment/integrations/app.py` - Service framework
- `/deployment/integrations/integrations/ringcentral_service.py` - RingCentral SDK
- `/deployment/integrations/requirements.txt` - Python dependencies

**Setup Wizard:**
- `/deployment/setup-wizard/src/App.jsx` - Main component
- `/deployment/setup-wizard/server.js` - Express backend
- `/deployment/setup-wizard/package.json` - Node dependencies

**OSCAR Extensions:**
- `/deployment/oscar-extensions/pom.xml` - Maven build
- `/deployment/oscar-extensions/src/main/java/org/oscarehr/integration/nextscript/` - Java code

**Configuration & Documentation:**
- `/deployment/README.md` - Deployment guide
- `/deployment/BUILD_STATUS.md` - Implementation status
- `/deployment/README-PREBUILT.md` - Pre-built image guide
- `/OSCAR_EMR_ANALYSIS_AND_ROADMAP.md` - Project roadmap

**Data Files (Root Level):**
- `/compiled_drug_data.json` - 20MB drug database
- `/icd9codes.json` - ICD-9 codes
- `/examDictionary.json` - Exam templates
- `/medication_sigs.json` - Medication signatures

---

## 12. SUCCESS METRICS & MILESTONES

### Milestone 1: Core Deployment Works (Week 1)
- [ ] Docker Compose starts all services
- [ ] OSCAR accessible at http://localhost:8567/oscar
- [ ] Login with oscardoc/mac2002
- [ ] Database persists data
- [ ] MariaDB health checks passing

### Milestone 2: Integration Service Running (Week 2)
- [ ] Python service starts without errors
- [ ] Connects to database
- [ ] Configuration loads from integration_config table
- [ ] RingCentral SDK authenticates
- [ ] Fax queue processing starts

### Milestone 3: Setup Wizard Complete (Week 3)
- [ ] All 6 form pages display
- [ ] Forms validate input
- [ ] Data saves to database
- [ ] Service reloads configuration
- [ ] User can go through complete flow

### Milestone 4: First Fax Sent (Week 3-4)
- [ ] Create test fax queue entry
- [ ] Service picks it up
- [ ] Calls RingCentral API
- [ ] Fax sends successfully
- [ ] Status updated in database

### Milestone 5: Admin Settings Work (Week 4)
- [ ] Settings page displays in OSCAR admin
- [ ] Can view current configuration
- [ ] Can update settings
- [ ] Test buttons work
- [ ] Changes reflected in service

### Milestone 6: Labs Auto-Download (Week 5)
- [ ] Service connects to PathNet SFTP
- [ ] Downloads test file
- [ ] Parses HL7 format
- [ ] Imports into OSCAR
- [ ] Document appears in patient chart

### Milestone 7: Production Ready (Week 5-6)
- [ ] Backups working
- [ ] Health checks passing
- [ ] Monitoring configured
- [ ] Documentation complete
- [ ] Security audit passed

---

## 13. KNOWN WORKING & TESTED COMPONENTS

### From git log and BUILD_STATUS.md

**Definitely Working:**
✅ Multi-service Docker Compose setup
✅ MariaDB initialization and schema
✅ OSCAR container with Tomcat
✅ Environment variable substitution
✅ Database persistence volumes
✅ Health checks
✅ Restart policies

**Partially Working:**
🔄 Setup wizard UI (structure OK, forms need implementation)
🔄 Integration configuration storage
🔄 Oscar-extensions plugin framework
🔄 Python Flask framework

**Not Yet Tested:**
❓ Pre-built WAR downloads
❓ RingCentral SDK integration
❓ Full wizard flow
❓ Integration service with actual data

---

## 14. FINAL RECOMMENDATION

### Best Path Forward for 100-Hour Migration

**Start with:**
1. `/deployment` as primary deployment framework
2. `/open-o-source` as source code reference
3. `/openosp-deployment` as architecture reference

**Priority Order:**
1. **Phase 1 (20 hrs):** Make core deployment fully functional
2. **Phase 2 (25 hrs):** Get RingCentral fax/SMS working
3. **Phase 3 (20 hrs):** Complete setup wizard
4. **Phase 4 (15 hrs):** Admin settings UI
5. **Phase 5 (15 hrs):** Lab auto-download
6. **Phase 6 (5 hrs):** Backup & monitoring

**Why This Works:**
- You'll have a working EMR after Phase 1 (20 hrs)
- Each phase is independently deployable
- Integration services can be added incrementally
- No need to wait for everything to be done
- Operator can test at each step

**Estimated Completion:** 
- MVP (Phase 1): 20 hours
- Functional System (Phase 1-3): 65 hours
- Production Ready (All phases): 95-100 hours

---

## APPENDIX: QUICK REFERENCE

### Docker Commands Cheat Sheet

```bash
# Start deployment
cd /home/user/CliniStream-OscarEMR/deployment
./deploy.sh

# View logs
docker-compose logs -f oscar
docker-compose logs -f integrations

# Access containers
docker-compose exec oscar bash
docker-compose exec db mysql -u oscar -p oscar_nextscript

# Rebuild specific service
docker-compose build oscar
docker-compose up -d oscar

# Stop everything
docker-compose down
docker-compose down -v  # Also remove volumes

# Check status
docker-compose ps
docker-compose health
```

### File Locations Quick Reference

| What | Location |
|------|----------|
| Docker config | `/deployment/docker-compose.yml` |
| OSCAR entrypoint | `/deployment/oscar/docker-entrypoint.sh` |
| Property templates | `/deployment/oscar/conf/*.template` |
| Integration service | `/deployment/integrations/app.py` |
| Setup wizard | `/deployment/setup-wizard/src/App.jsx` |
| OSCAR source | `/open-o-source/src/main/java/oscar/` |
| OSCAR webapp | `/open-o-source/src/main/webapp/` |
| Database schemas | `/open-o-source/database/mysql/` |
| Build status | `/deployment/BUILD_STATUS.md` |

### Database Schema Reference

```sql
-- Check if tables exist
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA='oscar_nextscript' 
AND TABLE_NAME IN ('system_config', 'integration_config', 'fax_queue', 'sms_queue');

-- View integration config
SELECT * FROM integration_config WHERE integration_name='ringcentral';

-- Check fax queue
SELECT * FROM fax_queue WHERE status='pending';

-- View system config
SELECT * FROM system_config WHERE config_key LIKE 'clinic%';
```

---

## CONCLUSION

The **NextScript OSCAR EMR deployment** in `/deployment` is a well-structured, 65%-complete Docker implementation for BC-specific OSCAR EMR with built-in setup wizard and integration services framework.

**You have 100 hours to:**
1. Complete the remaining 35% of implementation
2. Add RingCentral, OceanMD, and lab integrations
3. Build the admin settings UI
4. Implement backup and monitoring
5. Test and document thoroughly

**The codebase is ready for this work. Start with Phase 1 to get a working deployment, then add features incrementally.**

