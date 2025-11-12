# ==========================================
# OSCAR EMR Backup Service Dockerfile
# Automated database and document backups
# Supports local and S3 storage with encryption
# ==========================================

FROM python:3.11-slim

# Install required system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    mariadb-client \
    gzip \
    rsync \
    curl \
    gnupg \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Create non-root user for backups
RUN useradd -m -u 1001 -s /bin/bash backup

# Install Python dependencies
COPY requirements.txt /tmp/
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r /tmp/requirements.txt && \
    rm -rf ~/.cache/pip /tmp/requirements.txt

# Create backup directories
RUN mkdir -p /backups/db /backups/documents && \
    chown -R backup:backup /backups

# Copy backup scripts
COPY --chown=backup:backup backup.py /usr/local/bin/backup.py
COPY --chown=backup:backup restore.sh /usr/local/bin/restore.sh
RUN chmod +x /usr/local/bin/backup.py /usr/local/bin/restore.sh

# Switch to non-root user
USER backup

WORKDIR /backups

# Run backup script (can be scheduled with cron in production)
CMD ["python3", "-u", "/usr/local/bin/backup.py"]
