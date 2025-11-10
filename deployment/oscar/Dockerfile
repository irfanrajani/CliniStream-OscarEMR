FROM maven:3.8-openjdk-8 AS builder

# Install git for cloning OSCAR source
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Build OSCAR from Open-O source
WORKDIR /build

# Clone OSCAR source code from OpenOSP (BC-ready fork)
RUN git clone --depth 1 https://github.com/open-osp/Open-O.git oscar-source

# Copy NextScript extensions and customizations
COPY oscar-extensions/src ./oscar-source/src
COPY oscar-extensions/apply-modifications.sh ./

# Apply modifications to base OSCAR files
RUN chmod +x apply-modifications.sh && ./apply-modifications.sh ./oscar-source

# Build with Maven
WORKDIR /build/oscar-source
RUN mvn clean package -DskipTests -Dcheckstyle.skip=true -Ddependency-lock.skip=true

# Download DrugRef
WORKDIR /build
RUN curl -L -o drugref2.war https://bitbucket.org/openoscar/drugref/downloads/drugref2.war

# ===== Runtime Image =====
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
    && rm -rf /var/lib/apt/lists/*

# Copy built WARs
COPY --from=builder /build/oscar-source/target/oscar-*.war /usr/local/tomcat/webapps/oscar.war
COPY --from=builder /build/drugref2.war /usr/local/tomcat/webapps/drugref2.war

# Copy NextScript customizations
COPY oscar/conf/server.xml /usr/local/tomcat/conf/
COPY oscar/conf/logging.properties /usr/local/tomcat/conf/
COPY oscar/conf/web.xml /usr/local/tomcat/conf/

# Configuration template (will be populated by environment variables)
COPY oscar/conf/oscar.properties.template /etc/oscar/oscar.properties.template
COPY oscar/conf/drugref.properties.template /etc/oscar/drugref.properties.template

# Copy database initialization scripts
COPY --from=builder /build/oscar-source/database/mysql /oscar-db

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
