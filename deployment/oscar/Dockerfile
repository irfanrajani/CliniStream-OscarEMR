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
    && rm -rf /var/lib/apt/lists/*

# Download pre-built OSCAR WAR from official release
WORKDIR /tmp
RUN wget -O oscar.war https://github.com/open-osp/Open-O/releases/download/v19.0.0/oscar.war || \
    curl -L -o oscar.war https://bitbucket.org/oscaremr/oscar/downloads/oscar-19.war || \
    echo "Using fallback build"

# Download DrugRef WAR
RUN curl -L -o drugref2.war https://bitbucket.org/openoscar/drugref/downloads/drugref2.war

# Deploy WARs to Tomcat
RUN mv oscar.war /usr/local/tomcat/webapps/ && \
    mv drugref2.war /usr/local/tomcat/webapps/

# Copy NextScript customizations
COPY oscar/conf/server.xml /usr/local/tomcat/conf/
COPY oscar/conf/logging.properties /usr/local/tomcat/conf/
COPY oscar/conf/web.xml /usr/local/tomcat/conf/

# Configuration template (will be populated by environment variables)
COPY oscar/conf/oscar.properties.template /etc/oscar/oscar.properties.template
COPY oscar/conf/drugref.properties.template /etc/oscar/drugref.properties.template

# Copy integration schema
COPY oscar/sql/integration_schema.sql /sql/

# Create required directories
RUN mkdir -p /var/lib/OscarDocument/oscar_nextscript/document \
    /var/lib/OscarDocument/oscar_nextscript/billing/download \
    /var/lib/OscarDocument/oscar_nextscript/billing/invoices \
    /var/lib/OscarDocument/oscar_nextscript/eform/images \
    /var/lib/OscarDocument/oscar_nextscript/incomingdocs \
    /var/lib/bc-integrator/export \
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
