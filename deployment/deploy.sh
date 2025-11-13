#!/bin/bash
set -e

echo "==========================================="
echo "NextScript OSCAR EMR - Automated Deploy"
echo "==========================================="
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if .env exists
if [ ! -f .env ]; then
    echo -e "${BLUE}📝 Creating .env file with auto-generated secrets...${NC}"
    cp .env.example .env

    # Generate secure random passwords (32 characters)
    DB_PASS=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)
    ROOT_PASS=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)
    ENCRYPTION_KEY=$(openssl rand -base64 32)

    # Update .env (Mac/Linux compatible)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s|MYSQL_ROOT_PASSWORD=.*|MYSQL_ROOT_PASSWORD=${ROOT_PASS}|" .env
        sed -i '' "s|MYSQL_PASSWORD=.*|MYSQL_PASSWORD=${DB_PASS}|" .env
        sed -i '' "s|FIRST_RUN=.*|FIRST_RUN=true|" .env

        # Add encryption key if not present
        if ! grep -q "ENCRYPTION_KEY=" .env; then
            echo "ENCRYPTION_KEY=${ENCRYPTION_KEY}" >> .env
        else
            sed -i '' "s|ENCRYPTION_KEY=.*|ENCRYPTION_KEY=${ENCRYPTION_KEY}|" .env
        fi
    else
        # Linux
        sed -i "s|MYSQL_ROOT_PASSWORD=.*|MYSQL_ROOT_PASSWORD=${ROOT_PASS}|" .env
        sed -i "s|MYSQL_PASSWORD=.*|MYSQL_PASSWORD=${DB_PASS}|" .env
        sed -i "s|FIRST_RUN=.*|FIRST_RUN=true|" .env

        # Add encryption key if not present
        if ! grep -q "ENCRYPTION_KEY=" .env; then
            echo "ENCRYPTION_KEY=${ENCRYPTION_KEY}" >> .env
        else
            sed -i "s|ENCRYPTION_KEY=.*|ENCRYPTION_KEY=${ENCRYPTION_KEY}|" .env
        fi
    fi

    echo -e "${GREEN}✅ Environment file created with secure auto-generated secrets${NC}"

    # Save credentials to a secure file
    CREDS_FILE=".secrets-$(date +%Y%m%d-%H%M%S).txt"
    cat > "$CREDS_FILE" << EOF
=========================================
NextScript OSCAR EMR - Generated Secrets
Generated: $(date)
=========================================

IMPORTANT: Save these credentials securely!
This file will be automatically deleted after you acknowledge.

Database Credentials:
--------------------
Root Password: ${ROOT_PASS}
OSCAR DB Password: ${DB_PASS}

Encryption Key:
--------------
${ENCRYPTION_KEY}

OSCAR Default Login (CHANGE IMMEDIATELY):
-----------------------------------------
Username: oscardoc
Password: mac2002
PIN: 1117

Setup Wizard URL:
----------------
http://localhost:8568

OSCAR EMR URL:
-------------
http://localhost:8567/oscar

=========================================
EOF

    echo ""
    echo -e "${YELLOW}⚠️  IMPORTANT: Generated secrets saved to: ${CREDS_FILE}${NC}"
    echo -e "${YELLOW}⚠️  Please read and save these credentials NOW!${NC}"
    echo ""
    echo -e "${RED}Press ENTER after you have saved the credentials (file will be deleted)...${NC}"
    read -r

    # Show the credentials
    cat "$CREDS_FILE"
    echo ""
    echo -e "${RED}Press ENTER to confirm you have saved these credentials (file will be DELETED)...${NC}"
    read -r

    # Securely delete the credentials file
    shred -vfz -n 10 "$CREDS_FILE" 2>/dev/null || rm -f "$CREDS_FILE"
    echo -e "${GREEN}✅ Credentials file securely deleted${NC}"

else
    echo -e "${GREEN}✅ Using existing .env file${NC}"

    # Check if ENCRYPTION_KEY exists, if not generate it
    if ! grep -q "ENCRYPTION_KEY=" .env; then
        echo -e "${BLUE}🔐 Generating missing ENCRYPTION_KEY...${NC}"
        ENCRYPTION_KEY=$(openssl rand -base64 32)
        echo "ENCRYPTION_KEY=${ENCRYPTION_KEY}" >> .env
        echo -e "${GREEN}✅ Encryption key generated and added to .env${NC}"
        echo -e "${YELLOW}⚠️  New Encryption Key: ${ENCRYPTION_KEY}${NC}"
        echo -e "${YELLOW}⚠️  Save this key securely!${NC}"
        echo ""
    fi
fi

echo ""
echo -e "${BLUE}🐳 Building Docker images...${NC}"
docker-compose build

echo ""
echo -e "${BLUE}🚀 Starting Docker services...${NC}"
docker-compose --profile setup up -d

echo ""
echo "==========================================="
echo -e "${GREEN}✅ DEPLOYMENT COMPLETE!${NC}"
echo "==========================================="
echo ""
echo -e "${BLUE}Services are starting... This will take 3-5 minutes.${NC}"
echo ""
echo -e "${YELLOW}📋 Monitor Progress:${NC}"
echo "   docker-compose logs -f oscar"
echo ""
echo "   Look for these messages:"
echo "   - '✅ Database is ready!'"
echo "   - '✅ Database initialized!'"
echo "   - 'Tomcat started'"
echo ""
echo -e "${YELLOW}📝 Next Steps (Automated in order):${NC}"
echo ""
echo "1. Wait for services (3-5 minutes)"
echo "   Check: docker-compose ps"
echo "   All services should show 'Up (healthy)'"
echo ""
echo "2. Complete Setup Wizard:"
echo -e "   ${GREEN}http://localhost:8568${NC}"
echo ""
echo "   Configure:"
echo "   ✓ Clinic details"
echo "   ✓ BC Teleplan billing"
echo "   ✓ RingCentral (Fax & SMS)"
echo "   ✓ OceanMD eReferral"
echo "   ✓ Lab integrations"
echo ""
echo "3. Access OSCAR EMR:"
echo -e "   ${GREEN}http://localhost:8567/oscar${NC}"
echo ""
echo -e "   ${RED}Default login (CHANGE IMMEDIATELY):${NC}"
echo "   Username: oscardoc"
echo "   Password: mac2002"
echo "   PIN: 1117"
echo ""
echo "4. Integration Service API:"
echo -e "   ${GREEN}http://localhost:8080/health${NC}"
echo ""
echo "==========================================="
echo ""
echo -e "${BLUE}💡 Useful Commands:${NC}"
echo "   View all logs:         docker-compose logs -f"
echo "   View OSCAR logs:       docker-compose logs -f oscar"
echo "   View integration logs: docker-compose logs -f integrations"
echo "   Check service health:  docker-compose ps"
echo "   Restart services:      docker-compose restart"
echo "   Stop all services:     docker-compose down"
echo "   Full cleanup:          docker-compose down -v"
echo ""
echo -e "${GREEN}🎉 Setup is complete! Wait 3-5 minutes then access the setup wizard.${NC}"
echo ""
