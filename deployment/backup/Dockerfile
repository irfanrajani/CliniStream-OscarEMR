FROM python:3.11-slim

# Install required packages
RUN apt-get update && apt-get install -y \
    mariadb-client \
    gzip \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt /tmp/
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Copy backup script
COPY backup.py /usr/local/bin/backup.py
RUN chmod +x /usr/local/bin/backup.py

# Create backup directory
RUN mkdir -p /backups

WORKDIR /

CMD ["python3", "/usr/local/bin/backup.py"]
