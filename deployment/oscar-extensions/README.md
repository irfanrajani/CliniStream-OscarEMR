# OSCAR Extensions for NextScript EMR

This directory contains custom extensions and modifications to the base OSCAR EMR system.

## Structure

```
oscar-extensions/
├── src/main/java/           # Java source files (Actions, DAOs, Models)
└── src/main/webapp/         # Web application files (JSP pages)
```

## Custom Components

### Integration Configuration System

**Purpose**: Provides a web-based admin interface for configuring integrations (RingCentral, OceanMD, Labs) without editing configuration files.

**Files**:
- `org.oscarehr.integration.nextscript.NextScriptConfigAction` - Struts action handler
- `org.oscarehr.integration.nextscript.dao.IntegrationConfigDao` - Database access layer
- `org.oscarehr.integration.nextscript.model.IntegrationConfig` - JPA entity model
- `admin/nextscriptSettings.jsp` - Admin UI page

**Database Tables**:
- `integration_config` - Stores configuration for all integrations
- `system_config` - Stores system-wide configuration

**Features**:
- RingCentral configuration (Fax & SMS)
- OceanMD configuration (eReferrals)
- Lab integration configuration
- System settings (clinic name, timezone)
- Test connection functionality
- Hot-reload configuration without restart

## Required Modifications to Base OSCAR

The following files in the base OSCAR source must be modified:

1. **src/main/webapp/WEB-INF/struts-config.xml**
   - Add action mapping for `/admin/NextScriptConfig`

2. **src/main/webapp/admin/admin.jsp**
   - Add link to NextScript Integration Settings in the Integration section

## Deployment

These files are automatically copied into the OSCAR build during Docker image creation. The Dockerfile includes:

```dockerfile
COPY oscar-extensions/src/ /build/oscar-source/src/
```

## Development

When making changes:
1. Edit files in `oscar-extensions/`
2. Rebuild Docker image to test
3. Commit changes to main repository

## Integration with OSCAR Build

These extensions integrate with OSCAR's existing infrastructure:
- Uses OSCAR's Spring Framework beans
- Uses OSCAR's security model (`security.tld`)
- Uses OSCAR's database connection pool
- Follows OSCAR's Struts 1.x action pattern
- Uses OSCAR's Bootstrap CSS styling
