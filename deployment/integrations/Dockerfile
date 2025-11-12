# ==========================================
# OSCAR EMR Integrations Service Dockerfile
# Python Flask API for external integrations
# Handles: RingCentral, OceanMD, BC Labs
# ==========================================

FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    libmariadb-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Create non-root user
RUN useradd -m -u 1001 -s /bin/bash integrations

WORKDIR /app

# Copy and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    rm -rf ~/.cache/pip

# Copy application code
COPY --chown=integrations:integrations . .

# Switch to non-root user
USER integrations

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Start Flask application
CMD ["python", "-u", "app.py"]
