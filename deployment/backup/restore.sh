#!/bin/bash
# ==========================================
# OSCAR EMR Backup Restore Script
# Restores database and documents from backup
# ==========================================

set -e

BACKUP_DIR="${BACKUP_DIR:-/backups}"
DB_HOST="${MYSQL_HOST:-db}"
DB_PORT="${MYSQL_PORT:-3306}"
DB_NAME="${MYSQL_DATABASE:-oscar_mcmaster}"
DB_USER="${MYSQL_USER:-oscar}"
DB_PASSWORD="${MYSQL_PASSWORD}"

usage() {
    echo "Usage: $0 <backup-date>"
    echo "  backup-date: Format YYYY-MM-DD-HHMMSS"
    echo ""
    echo "Example: $0 2024-11-12-120000"
    echo ""
    echo "Available backups:"
    ls -1 ${BACKUP_DIR}/db/*.sql.gz 2>/dev/null | sed 's/.*\//  /' || echo "  No backups found"
    exit 1
}

if [ -z "$1" ]; then
    usage
fi

BACKUP_DATE="$1"
DB_BACKUP="${BACKUP_DIR}/db/oscar_${BACKUP_DATE}.sql.gz"
DOCS_BACKUP="${BACKUP_DIR}/documents/documents_${BACKUP_DATE}.tar.gz"

# Restore database
if [ -f "${DB_BACKUP}" ]; then
    echo "Restoring database from ${DB_BACKUP}..."
    gunzip -c "${DB_BACKUP}" | mysql -h "${DB_HOST}" -P "${DB_PORT}" -u "${DB_USER}" -p"${DB_PASSWORD}" "${DB_NAME}"
    echo "✅ Database restored successfully"
else
    echo "❌ Database backup not found: ${DB_BACKUP}"
    exit 1
fi

# Restore documents
if [ -f "${DOCS_BACKUP}" ]; then
    echo "Restoring documents from ${DOCS_BACKUP}..."
    tar -xzf "${DOCS_BACKUP}" -C /
    echo "✅ Documents restored successfully"
else
    echo "⚠️  Documents backup not found: ${DOCS_BACKUP}"
fi

echo ""
echo "🎉 Restore completed successfully!"
echo "Please restart OSCAR EMR service for changes to take effect."
