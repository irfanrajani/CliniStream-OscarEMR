# ==========================================
# OSCAR EMR Production Dockerfile
# Optimized for security, size, and performance
# ==========================================

FROM tomcat:9.0.102-jre8-temurin-jammy AS base

# Install required runtime packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    gettext \
    ca-certificates \
    fontconfig \
    libfreetype6 \
    libjpeg-turbo8 \
    libpng16-16 \
    libssl3 \
    libx11-6 \
    libxcb1 \
    libxext6 \
    libxrender1 \
    xfonts-75dpi \
    xfonts-base \
    zlib1g \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Remove default Tomcat webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# ==========================================
# Application Layer
# ==========================================

# Create application directories
RUN mkdir -p \
    /var/lib/OscarDocument/oscar_nextscript/document \
    /var/lib/OscarDocument/oscar_nextscript/billing/download \
    /var/lib/OscarDocument/oscar_nextscript/billing/invoices \
    /var/lib/OscarDocument/oscar_nextscript/eform/images \
    /var/lib/OscarDocument/oscar_nextscript/incomingdocs \
    /var/lib/bc-integrator/export \
    /etc/oscar \
    /sql

# Copy pre-built OSCAR WAR (from GitHub Actions artifact)
COPY --chown=root:root prebuilt-wars/*.war /usr/local/tomcat/webapps/oscar.war

# Copy Tomcat configuration
COPY --chown=root:root oscar/conf/server.xml /usr/local/tomcat/conf/
COPY --chown=root:root oscar/conf/logging.properties /usr/local/tomcat/conf/
COPY --chown=root:root oscar/conf/web.xml /usr/local/tomcat/conf/

# Copy OSCAR configuration templates
COPY --chown=root:root oscar/conf/oscar.properties.template /etc/oscar/
COPY --chown=root:root oscar/conf/drugref.properties.template /etc/oscar/

# Copy database initialization scripts
COPY --chown=root:root oscar/sql/*.sql /sql/

# Copy entrypoint script
COPY --chown=root:root oscar/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

# ==========================================
# Security Hardening
# ==========================================

# Create non-root user for Tomcat
RUN groupadd -r oscar && useradd -r -g oscar -u 1000 oscar

# Set proper ownership
RUN chown -R oscar:oscar \
    /usr/local/tomcat \
    /var/lib/OscarDocument \
    /var/lib/bc-integrator \
    /etc/oscar

# Set proper permissions (no write access to config)
RUN chmod 755 /usr/local/tomcat/webapps && \
    chmod 644 /etc/oscar/*.template && \
    chmod 600 /sql/*.sql

# Switch to non-root user
USER oscar

# ==========================================
# Runtime Configuration
# ==========================================

# Environment variables
ENV CATALINA_OPTS="-Xms512m -Xmx2048m -XX:MaxPermSize=512m -Djava.security.egd=file:/dev/./urandom"
ENV JAVA_OPTS="-Djava.awt.headless=true -Dfile.encoding=UTF-8"

# Expose ports
EXPOSE 8080

# Health check
HEALTHCHECK --interval=60s --timeout=10s --start-period=180s --retries=3 \
    CMD curl -f http://localhost:8080/oscar/ || exit 1

# Start Tomcat
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["catalina.sh", "run"]
