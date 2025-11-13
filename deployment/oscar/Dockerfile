FROM tomcat:9.0.102-jre8-temurin-jammy

# Install required packages
RUN apt-get update && apt-get install -y \
    curl \
    iputils-ping \
    gettext \
    ca-certificates \
    fontconfig \
    libfreetype6 \
    libjpeg-turbo8 \
    libpng16-16 \
    libssl3 \
    libstdc++6 \
    libx11-6 \
    libxcb1 \
    libxext6 \
    libxrender1 \
    xfonts-75dpi \
    xfonts-base \
    zlib1g \
    mariadb-client \
    wget \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Download OSCAR source for database schemas
WORKDIR /tmp
RUN git clone --depth 1 --branch master https://bitbucket.org/oscaremr/oscar.git oscar-source || \
    git clone --depth 1 https://github.com/purposemed/emr.git oscar-source

# Download pre-built OSCAR WAR from official release
RUN wget -O oscar.war "https://sourceforge.net/projects/oscarmcmaster/files/Oscar%20Document/Oscar%2019/oscar.war/download" || \
    curl -L -o oscar.war https://bitbucket.org/oscaremr/oscar/downloads/oscar-19.war || \
    { echo "ERROR: Failed to download OSCAR WAR"; exit 1; }

# Verify WAR file exists and is not empty
RUN if [ ! -s oscar.war ]; then echo "ERROR: oscar.war is missing or empty"; exit 1; fi

# Download DrugRef WAR
RUN curl -L -o drugref2.war https://bitbucket.org/openoscar/drugref/downloads/drugref2.war || \
    echo "DrugRef download failed, will skip"

# Deploy WARs to Tomcat
RUN mv oscar.war /usr/local/tomcat/webapps/ && \
    if [ -f drugref2.war ]; then mv drugref2.war /usr/local/tomcat/webapps/; fi
    # Wait for WAR to be extracted by Tomcat
    mkdir -p /usr/local/tomcat/webapps/oscar

# Copy database schemas from source
RUN mkdir -p /oscar-db && \
    if [ -d "/tmp/oscar-source/database/mysql" ]; then \
        cp /tmp/oscar-source/database/mysql/*.sql /oscar-db/ 2>/dev/null || true; \
    fi && \
    # Cleanup source to save space
    rm -rf /tmp/oscar-source

# Copy NextScript customizations
COPY oscar/conf/server.xml /usr/local/tomcat/conf/
COPY oscar/conf/logging.properties /usr/local/tomcat/conf/
COPY oscar/conf/web.xml /usr/local/tomcat/conf/

# Configuration template (will be populated by environment variables)
COPY oscar/conf/oscar.properties.template /etc/oscar/oscar.properties.template
COPY oscar/conf/drugref.properties.template /etc/oscar/drugref.properties.template

# Copy integration schema
COPY oscar/sql/integration_schema.sql /oscar-db/

# Create required directories
RUN mkdir -p /var/lib/OscarDocument/oscar_nextscript/document \
    /var/lib/OscarDocument/oscar_nextscript/billing/download \
    /var/lib/OscarDocument/oscar_nextscript/billing/invoices \
    /var/lib/OscarDocument/oscar_nextscript/eform/images \
    /var/lib/OscarDocument/oscar_nextscript/incomingdocs/1/Fax \
    /var/lib/bc-integrator/export \
# Copy NextScript integration bridge files
COPY oscar/webapp/integrations /oscar-integrations/

    /etc/oscar

# Copy entrypoint script
COPY oscar/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

# Expose ports
EXPOSE 8080 443

# Health check
HEALTHCHECK --interval=60s --timeout=10s --start-period=120s --retries=3 \
    CMD curl -f http://localhost:8080/oscar/ || exit 1

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["catalina.sh", "run"]
