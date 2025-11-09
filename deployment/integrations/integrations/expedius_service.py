"""
Expedius Lab Integration Service
Handles automated download and import of BC laboratory results via Expedius
"""

import os
import paramiko
import logging
from datetime import datetime
from typing import Dict, Optional, List
import mysql.connector
from pathlib import Path

logger = logging.getLogger(__name__)


class ExpediusService:
    """Service for downloading and processing lab results from Expedius"""

    def __init__(self, config: Dict, db_config: Dict):
        """
        Initialize Expedius service

        Args:
            config: Expedius configuration (host, username, password, path)
            db_config: Database configuration for OSCAR
        """
        self.config = config
        self.db_config = db_config

        # SFTP connection details
        self.host = config.get('host', 'sftp.excelleris.com')
        self.port = int(config.get('port', 22))
        self.username = config.get('username')
        self.password = config.get('password')
        self.remote_path = config.get('remote_path', '/inbox')

        # Local storage for downloaded labs
        self.local_path = config.get('local_path', '/var/lib/OscarDocument/oscar_nextscript/incomingdocs/labs')
        Path(self.local_path).mkdir(parents=True, exist_ok=True)

        # Track processed files
        self.processed_files = self._load_processed_files()

    def _load_processed_files(self) -> set:
        """Load list of already processed files from database"""
        try:
            conn = mysql.connector.connect(**self.db_config)
            cursor = conn.cursor()

            cursor.execute("""
                SELECT DISTINCT external_lab_id
                FROM integration_config
                WHERE integration_name = 'expedius'
                AND config_key = 'processed_file'
            """)

            processed = {row[0] for row in cursor.fetchall()}
            cursor.close()
            conn.close()

            return processed

        except Exception as e:
            logger.error(f"Error loading processed files: {e}")
            return set()

    def _mark_file_processed(self, filename: str):
        """Mark a file as processed in the database"""
        try:
            conn = mysql.connector.connect(**self.db_config)
            cursor = conn.cursor()

            cursor.execute("""
                INSERT INTO integration_config
                (integration_name, config_key, config_value)
                VALUES ('expedius', 'processed_file', %s)
            """, (filename,))

            conn.commit()
            cursor.close()
            conn.close()

            self.processed_files.add(filename)

        except Exception as e:
            logger.error(f"Error marking file as processed: {e}")

    def connect_sftp(self) -> Optional[paramiko.SFTPClient]:
        """Establish SFTP connection to Expedius"""
        try:
            transport = paramiko.Transport((self.host, self.port))
            transport.connect(username=self.username, password=self.password)
            sftp = paramiko.SFTPClient.from_transport(transport)

            logger.info(f"Connected to Expedius SFTP: {self.host}")
            return sftp

        except Exception as e:
            logger.error(f"Failed to connect to Expedius SFTP: {e}")
            return None

    def list_new_files(self, sftp: paramiko.SFTPClient) -> List[str]:
        """List new lab files that haven't been processed"""
        try:
            # List all files in remote directory
            files = sftp.listdir(self.remote_path)

            # Filter for HL7 lab files (typically .hl7 or .txt)
            lab_files = [f for f in files if f.endswith(('.hl7', '.txt', '.HL7', '.TXT'))]

            # Exclude already processed files
            new_files = [f for f in lab_files if f not in self.processed_files]

            logger.info(f"Found {len(new_files)} new lab files")
            return new_files

        except Exception as e:
            logger.error(f"Error listing files: {e}")
            return []

    def download_file(self, sftp: paramiko.SFTPClient, filename: str) -> Optional[str]:
        """Download a lab file from Expedius"""
        try:
            remote_file = os.path.join(self.remote_path, filename)
            local_file = os.path.join(self.local_path, filename)

            sftp.get(remote_file, local_file)
            logger.info(f"Downloaded: {filename}")

            return local_file

        except Exception as e:
            logger.error(f"Error downloading {filename}: {e}")
            return None

    def import_to_oscar(self, local_file: str) -> bool:
        """Import HL7 lab file into OSCAR"""
        try:
            # Read the HL7 file
            with open(local_file, 'r', encoding='utf-8', errors='ignore') as f:
                hl7_content = f.read()

            # Parse basic HL7 info (MSH segment)
            msh_line = next((line for line in hl7_content.split('\n') if line.startswith('MSH')), None)

            if not msh_line:
                logger.error(f"Invalid HL7 file: {local_file}")
                return False

            # Extract sending facility and message control ID
            segments = msh_line.split('|')
            sending_facility = segments[3] if len(segments) > 3 else 'Unknown'
            message_id = segments[9] if len(segments) > 9 else 'Unknown'

            # Insert into OSCAR's hl7TextInfo table
            conn = mysql.connector.connect(**self.db_config)
            cursor = conn.cursor()

            # Check if this message ID already exists
            cursor.execute("""
                SELECT COUNT(*) FROM hl7TextInfo
                WHERE message_unique_id = %s
            """, (message_id,))

            if cursor.fetchone()[0] > 0:
                logger.info(f"Lab already imported: {message_id}")
                cursor.close()
                conn.close()
                return True

            # Insert the HL7 message
            now = datetime.now()
            cursor.execute("""
                INSERT INTO hl7TextInfo (
                    message_unique_id,
                    sending_facility,
                    base64_hl7_message,
                    comment,
                    lab_type,
                    accession_num,
                    date_Created
                ) VALUES (%s, %s, %s, %s, %s, %s, %s)
            """, (
                message_id,
                sending_facility,
                hl7_content,  # OSCAR can accept text or base64
                f'Imported from Expedius: {os.path.basename(local_file)}',
                'Excelleris',
                message_id,
                now
            ))

            lab_id = cursor.lastrowid

            # Insert into hl7TextMessage for processing
            cursor.execute("""
                INSERT INTO hl7TextMessage (
                    lab_id,
                    lab_type,
                    message_unique_id
                ) VALUES (%s, %s, %s)
            """, (lab_id, 'Excelleris', message_id))

            conn.commit()
            cursor.close()
            conn.close()

            logger.info(f"Imported lab to OSCAR: {message_id} (ID: {lab_id})")
            return True

        except Exception as e:
            logger.error(f"Error importing lab to OSCAR: {e}")
            return False

    def process_labs(self):
        """Main method to poll and process new lab results"""
        logger.info("Starting Expedius lab polling...")

        # Check if service is enabled
        if not self.config.get('enabled') == 'true':
            logger.info("Expedius service is disabled")
            return

        # Validate credentials
        if not self.username or not self.password:
            logger.error("Expedius credentials not configured")
            return

        # Connect to SFTP
        sftp = self.connect_sftp()
        if not sftp:
            return

        try:
            # Get list of new files
            new_files = self.list_new_files(sftp)

            if not new_files:
                logger.info("No new lab files to process")
                return

            # Process each file
            success_count = 0
            for filename in new_files:
                logger.info(f"Processing: {filename}")

                # Download file
                local_file = self.download_file(sftp, filename)
                if not local_file:
                    continue

                # Import to OSCAR
                if self.import_to_oscar(local_file):
                    # Mark as processed
                    self._mark_file_processed(filename)
                    success_count += 1
                else:
                    logger.error(f"Failed to import: {filename}")

            logger.info(f"Processed {success_count}/{len(new_files)} lab files")

        finally:
            # Clean up SFTP connection
            if sftp:
                sftp.close()

    def test_connection(self) -> Dict:
        """Test SFTP connection to Expedius"""
        try:
            sftp = self.connect_sftp()
            if not sftp:
                return {
                    'success': False,
                    'message': 'Failed to connect to SFTP server'
                }

            # Try to list directory
            files = sftp.listdir(self.remote_path)
            sftp.close()

            return {
                'success': True,
                'message': f'Connection successful. Found {len(files)} files in {self.remote_path}'
            }

        except Exception as e:
            return {
                'success': False,
                'message': f'Connection failed: {str(e)}'
            }
