#!/bin/bash
set -e

echo "==================================="
echo "NextScript OSCAR EMR - Starting"
echo "==================================="

# Wait for database
echo "Waiting for database..."
until mariadb -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "SELECT 1" &>/dev/null; do
    echo "Database not ready, waiting..."
    sleep 5
done
echo "Database is ready!"

# Generate oscar.properties from template with environment variables
echo "Generating configuration..."
envsubst < /etc/oscar/oscar.properties.template > /usr/local/tomcat/webapps/oscar/WEB-INF/classes/oscar_mcmaster.properties

# Generate drugref.properties
envsubst < /etc/oscar/drugref.properties.template > /usr/local/tomcat/webapps/drugref2/WEB-INF/classes/drugref2.properties

# Check if this is first run
if [ "$FIRST_RUN" = "true" ]; then
    echo "==================================="
    echo "FIRST RUN DETECTED"
    echo "==================================="

    # Check if database is populated
    TABLE_COUNT=$(mariadb -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}" -se "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='${MYSQL_DATABASE}';" 2>/dev/null || echo "0")

    if [ "$TABLE_COUNT" -eq "0" ]; then
        echo "Initializing database with BC schema..."

        # Load BC-specific database schema
        echo "Loading BC core schema..."
        mariadb -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}" < /oscar-db/oscarinit_bc.sql

        echo "Loading BC data..."
        mariadb -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}" < /oscar-db/oscardata_bc.sql

        echo "Loading BC billing codes..."
        mariadb -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}" < /oscar-db/bc_billingServiceCodes.sql

        echo "Loading BC pharmacies..."
        mariadb -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}" < /oscar-db/bc_pharmacies.sql

        echo "Loading BC specialists..."
        mariadb -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}" < /oscar-db/bc_professionalSpecialists.sql

        echo "Database initialized!"

        echo ""
        echo "==================================="
        echo "IMPORTANT: Complete Setup Wizard"
        echo "==================================="
        echo ""
        echo "Visit: http://your-qnap-ip:3000"
        echo ""
        echo "Configure:"
        echo "  - Clinic details"
        echo "  - BC Teleplan billing"
        echo "  - RingCentral (Fax & SMS)"
        echo "  - OceanMD eReferral"
        echo "  - Lab integrations"
        echo ""
        echo "Default login (change immediately):"
        echo "  Username: oscardoc"
        echo "  Password: mac2002"
        echo "  PIN: 1117"
        echo ""
        echo "==================================="
    else
        echo "Database already initialized (${TABLE_COUNT} tables found)"
    fi
fi

echo "Starting Tomcat..."
exec "$@"
