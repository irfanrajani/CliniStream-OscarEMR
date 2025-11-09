#!/usr/bin/env python3
"""
NextScript EMR Backup Service
Automated backups of database and document files
"""

import os
import sys
import time
import logging
import subprocess
import tarfile
from datetime import datetime
from pathlib import Path
import schedule
import boto3
from botocore.exceptions import ClientError

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Configuration from environment variables
DB_HOST = os.getenv('MYSQL_HOST', 'db')
DB_USER = os.getenv('MYSQL_USER', 'oscar')
DB_PASSWORD = os.getenv('MYSQL_PASSWORD')
DB_NAME = os.getenv('MYSQL_DATABASE', 'oscar_nextscript')

BACKUP_DIR = os.getenv('BACKUP_DIR', '/backups')
DOCUMENT_DIR = os.getenv('DOCUMENT_DIR', '/var/lib/OscarDocument')
RETENTION_DAYS = int(os.getenv('BACKUP_RETENTION_DAYS', '30'))

# S3 Configuration (optional)
S3_ENABLED = os.getenv('S3_BACKUP_ENABLED', 'false').lower() == 'true'
S3_BUCKET = os.getenv('S3_BUCKET', '')
S3_ACCESS_KEY = os.getenv('AWS_ACCESS_KEY_ID', '')
S3_SECRET_KEY = os.getenv('AWS_SECRET_ACCESS_KEY', '')
S3_REGION = os.getenv('AWS_REGION', 'us-west-2')


class BackupService:
    """Automated backup service for OSCAR EMR"""

    def __init__(self):
        self.backup_dir = Path(BACKUP_DIR)
        self.backup_dir.mkdir(parents=True, exist_ok=True)

        self.s3_client = None
        if S3_ENABLED and S3_BUCKET:
            try:
                self.s3_client = boto3.client(
                    's3',
                    aws_access_key_id=S3_ACCESS_KEY,
                    aws_secret_access_key=S3_SECRET_KEY,
                    region_name=S3_REGION
                )
                logger.info(f"S3 backup enabled: {S3_BUCKET}")
            except Exception as e:
                logger.error(f"Failed to initialize S3 client: {e}")
                self.s3_client = None

    def backup_database(self) -> Path:
        """Backup MySQL database"""
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        backup_file = self.backup_dir / f"database_{timestamp}.sql.gz"

        logger.info(f"Starting database backup: {DB_NAME}")

        try:
            # Use mysqldump to create backup
            cmd = [
                'mysqldump',
                f'--host={DB_HOST}',
                f'--user={DB_USER}',
                f'--password={DB_PASSWORD}',
                '--single-transaction',
                '--routines',
                '--triggers',
                '--events',
                '--quick',
                '--lock-tables=false',
                DB_NAME
            ]

            # Pipe through gzip for compression
            with open(backup_file, 'wb') as f:
                p1 = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                p2 = subprocess.Popen(['gzip'], stdin=p1.stdout, stdout=f, stderr=subprocess.PIPE)
                p1.stdout.close()
                p2.communicate()

                if p2.returncode != 0:
                    raise Exception("mysqldump failed")

            size_mb = backup_file.stat().st_size / (1024 * 1024)
            logger.info(f"✅ Database backup complete: {backup_file.name} ({size_mb:.2f} MB)")
            return backup_file

        except Exception as e:
            logger.error(f"❌ Database backup failed: {e}")
            if backup_file.exists():
                backup_file.unlink()
            raise

    def backup_documents(self) -> Path:
        """Backup document files"""
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        backup_file = self.backup_dir / f"documents_{timestamp}.tar.gz"

        logger.info("Starting document backup...")

        try:
            document_path = Path(DOCUMENT_DIR)
            if not document_path.exists():
                logger.warning(f"Document directory does not exist: {DOCUMENT_DIR}")
                return None

            # Create tar.gz archive
            with tarfile.open(backup_file, 'w:gz') as tar:
                tar.add(document_path, arcname='OscarDocument')

            size_mb = backup_file.stat().st_size / (1024 * 1024)
            logger.info(f"✅ Document backup complete: {backup_file.name} ({size_mb:.2f} MB)")
            return backup_file

        except Exception as e:
            logger.error(f"❌ Document backup failed: {e}")
            if backup_file.exists():
                backup_file.unlink()
            raise

    def upload_to_s3(self, file_path: Path):
        """Upload backup file to S3"""
        if not self.s3_client:
            return

        try:
            s3_key = f"backups/{file_path.name}"
            logger.info(f"Uploading to S3: s3://{S3_BUCKET}/{s3_key}")

            self.s3_client.upload_file(
                str(file_path),
                S3_BUCKET,
                s3_key,
                ExtraArgs={'StorageClass': 'STANDARD_IA'}  # Infrequent Access for cost savings
            )

            logger.info(f"✅ S3 upload complete: {s3_key}")

        except ClientError as e:
            logger.error(f"❌ S3 upload failed: {e}")

    def cleanup_old_backups(self):
        """Remove backups older than retention period"""
        logger.info(f"Cleaning up backups older than {RETENTION_DAYS} days...")

        cutoff_time = time.time() - (RETENTION_DAYS * 24 * 60 * 60)
        removed_count = 0

        for backup_file in self.backup_dir.glob('*'):
            if backup_file.is_file() and backup_file.stat().st_mtime < cutoff_time:
                try:
                    backup_file.unlink()
                    removed_count += 1
                    logger.info(f"Removed old backup: {backup_file.name}")
                except Exception as e:
                    logger.error(f"Failed to remove {backup_file.name}: {e}")

        if removed_count > 0:
            logger.info(f"✅ Cleaned up {removed_count} old backup(s)")

    def run_backup(self):
        """Execute full backup process"""
        logger.info("=" * 50)
        logger.info("Starting NextScript EMR Backup")
        logger.info("=" * 50)

        try:
            # Backup database
            db_backup = self.backup_database()
            if db_backup and self.s3_client:
                self.upload_to_s3(db_backup)

            # Backup documents
            doc_backup = self.backup_documents()
            if doc_backup and self.s3_client:
                self.upload_to_s3(doc_backup)

            # Cleanup old backups
            self.cleanup_old_backups()

            logger.info("=" * 50)
            logger.info("✅ Backup completed successfully")
            logger.info("=" * 50)

        except Exception as e:
            logger.error(f"❌ Backup failed: {e}")


def main():
    """Main entry point"""
    logger.info("=" * 50)
    logger.info("NextScript EMR Backup Service")
    logger.info("=" * 50)
    logger.info(f"Backup directory: {BACKUP_DIR}")
    logger.info(f"Document directory: {DOCUMENT_DIR}")
    logger.info(f"Retention: {RETENTION_DAYS} days")
    logger.info(f"S3 backup: {'Enabled' if S3_ENABLED else 'Disabled'}")

    if S3_ENABLED and not S3_BUCKET:
        logger.warning("S3 backup enabled but S3_BUCKET not set!")

    # Wait for database to be ready
    logger.info("Waiting for database...")
    time.sleep(30)

    # Initialize backup service
    backup_service = BackupService()

    # Get backup schedule from environment (cron format)
    backup_schedule = os.getenv('BACKUP_SCHEDULE', '0 2 * * *')  # Default: 2 AM daily
    logger.info(f"Backup schedule: {backup_schedule}")

    # Parse cron schedule (simplified - only support daily backups)
    # Format: "minute hour * * *"
    parts = backup_schedule.split()
    if len(parts) >= 2:
        hour = parts[1]
        minute = parts[0]
        schedule_time = f"{hour:0>2}:{minute:0>2}"

        logger.info(f"Scheduling daily backup at {schedule_time}")
        schedule.every().day.at(schedule_time).do(backup_service.run_backup)
    else:
        logger.warning("Invalid BACKUP_SCHEDULE format, defaulting to 2:00 AM")
        schedule.every().day.at("02:00").do(backup_service.run_backup)

    # Run initial backup
    logger.info("Running initial backup...")
    backup_service.run_backup()

    # Run scheduler
    logger.info("Backup scheduler started")
    while True:
        schedule.run_pending()
        time.sleep(60)


if __name__ == '__main__':
    main()
