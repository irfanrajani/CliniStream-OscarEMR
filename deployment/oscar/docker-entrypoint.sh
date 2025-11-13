#!/bin/bash
set -e

echo "==================================="
echo "NextScript OSCAR EMR - Starting"
echo "==================================="

# Validate critical volumes are mounted
if [ ! -d "/var/lib/OscarDocument" ]; then
    echo "ERROR: /var/lib/OscarDocument volume not mounted!"
    exit 1
fi

# Wait for database
echo "Waiting for database..."
MAX_TRIES=30
COUNT=0
until mariadb -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "SELECT 1" &>/dev/null; do
    COUNT=$((COUNT+1))
    if [ $COUNT -ge $MAX_TRIES ]; then
        echo "ERROR: Database connection timeout after ${MAX_TRIES} attempts"
        exit 1
    fi
    echo "Database not ready, waiting... (${COUNT}/${MAX_TRIES})"
    sleep 5
done
echo "✅ Database is ready!"

# Extract WAR files manually if not already extracted
echo "Extracting WAR files..."
if [ ! -d "/usr/local/tomcat/webapps/oscar" ]; then
    echo "Extracting OSCAR WAR..."
    mkdir -p /usr/local/tomcat/webapps/oscar
    cd /usr/local/tomcat/webapps/oscar
    jar -xf /usr/local/tomcat/webapps/oscar.war
    cd /
fi

if [ -f "/usr/local/tomcat/webapps/drugref2.war" ] && [ ! -d "/usr/local/tomcat/webapps/drugref2" ]; then
    echo "Extracting DrugRef WAR..."
    mkdir -p /usr/local/tomcat/webapps/drugref2
    cd /usr/local/tomcat/webapps/drugref2
    jar -xf /usr/local/tomcat/webapps/drugref2.war
    cd /
fi

# Generate oscar.properties from template with environment variables
echo "Generating configuration..."
if [ ! -f /etc/oscar/oscar.properties.template ]; then
    echo "ERROR: oscar.properties.template not found!"
    exit 1
fi

envsubst < /etc/oscar/oscar.properties.template > /usr/local/tomcat/webapps/oscar/WEB-INF/classes/oscar_mcmaster.properties

# Generate drugref.properties if template exists
if [ -f /etc/oscar/drugref.properties.template ] && [ -d /usr/local/tomcat/webapps/drugref2 ]; then
    envsubst < /etc/oscar/drugref.properties.template > /usr/local/tomcat/webapps/drugref2/WEB-INF/classes/drugref2.properties
fi

# Check if this is first run
if [ "$FIRST_RUN" = "true" ]; then
    echo "==================================="
    echo "FIRST RUN DETECTED"
    echo "==================================="

    # Check if database is populated
    TABLE_COUNT=$(mariadb -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}" -se "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='${MYSQL_DATABASE}';" 2>/dev/null || echo "0")

    if [ "$TABLE_COUNT" -eq "0" ]; then
        echo "Initializing database with BC schema..."

        # Check if database files exist
        if [ ! -d "/oscar-db" ] || [ -z "$(ls -A /oscar-db/*.sql 2>/dev/null)" ]; then
            echo "ERROR: Database schema files not found in /oscar-db/"
            echo "Available files:"
            ls -la /oscar-db/ || echo "Directory doesn't exist"
            exit 1
        fi

        # Load database schemas in correct order
        echo "Loading BC core schema..."
        if [ -f "/oscar-db/oscarinit_bc.sql" ]; then
            mariadb -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}" < /oscar-db/oscarinit_bc.sql
        elif [ -f "/oscar-db/oscarinit.sql" ]; then
            echo "Using generic oscarinit.sql (BC-specific not found)"
            mariadb -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}" < /oscar-db/oscarinit.sql
        else
            echo "ERROR: No oscarinit*.sql file found!"
            exit 1
        fi

        echo "Loading BC data..."
        for sql_file in /oscar-db/oscardata_bc.sql /oscar-db/bc_billingServiceCodes.sql /oscar-db/bc_pharmacies.sql /oscar-db/bc_professionalSpecialists.sql; do
            if [ -f "$sql_file" ]; then
                echo "Loading $(basename $sql_file)..."
                mariadb -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}" < "$sql_file" || echo "Warning: Failed to load $(basename $sql_file)"
            else
                echo "Warning: $(basename $sql_file) not found, skipping..."
            fi
        done

        echo "Loading NextScript integration tables..."
        if [ -f "/oscar-db/integration_schema.sql" ]; then
            mariadb -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}" < /oscar-db/integration_schema.sql
        else
            echo "Warning: integration_schema.sql not found"
        fi

        echo "✅ Database initialized!"

        echo ""
        echo "==================================="
        echo "IMPORTANT: Complete Setup Wizard"
        echo "==================================="
        echo ""
        echo "Visit: http://your-server:8568"
        echo "       (Setup Wizard)"
        echo ""
        echo "Then access OSCAR at:"
        echo "Visit: http://your-server:8567/oscar"
        echo "       (Main Application)"
        echo ""
        echo "Configure in Setup Wizard:"
        echo "  ✓ Clinic details"
        echo "  ✓ BC Teleplan billing"
        echo "  ✓ RingCentral (Fax & SMS)"
        echo "  ✓ OceanMD eReferral"
        echo "  ✓ Lab integrations"
        echo ""
        echo "Default OSCAR login (CHANGE IMMEDIATELY):"
        echo "  Username: oscardoc"
        echo "  Password: mac2002"
        echo "  PIN: 1117"
        echo ""
        echo "==================================="
    else
        echo "✅ Database already initialized (${TABLE_COUNT} tables found)"
    fi
fi

# Copy integration bridge files to OSCAR webapp
if [ -d "/oscar-integrations" ]; then
    echo "Installing NextScript integration bridge..."
    mkdir -p /usr/local/tomcat/webapps/oscar/integrations
    cp -r /oscar-integrations/* /usr/local/tomcat/webapps/oscar/integrations/
    echo "✅ Integration bridge installed"
fi

echo "Starting Tomcat..."
exec "$@"
