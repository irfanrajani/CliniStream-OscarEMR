"""
Fax Processor
Handles inbound and outbound fax processing with RingCentral
"""

import logging
import os
import mysql.connector
from datetime import datetime, timedelta

logger = logging.getLogger(__name__)

class FaxProcessor:
    def __init__(self, ringcentral_service, db_config):
        self.rc = ringcentral_service
        self.db_config = db_config
        self.fax_dir = '/var/lib/OscarDocument/oscar_nextscript/incomingdocs/1/Fax/'
        os.makedirs(self.fax_dir, exist_ok=True)

    def get_db_connection(self):
        """Get database connection"""
        return mysql.connector.connect(**self.db_config)

    def poll_inbound(self):
        """Poll RingCentral for new inbound faxes"""
        logger.info("Polling for inbound faxes...")

        try:
            # Get last poll time from database
            db = self.get_db_connection()
            cursor = db.cursor(dictionary=True)

            cursor.execute("""
                SELECT config_value
                FROM system_config
                WHERE config_key = 'last_fax_poll'
            """)
            result = cursor.fetchone()

            last_poll = result['config_value'] if result else None
            if not last_poll:
                # First poll - get faxes from last 7 days
                last_poll = (datetime.now() - timedelta(days=7)).isoformat()

            # Get faxes from RingCentral
            faxes = self.rc.get_inbound_faxes(date_from=last_poll)

            logger.info(f"Found {len(faxes)} new faxes")

            # Process each fax
            for fax in faxes:
                self._process_inbound_fax(fax, cursor)

            # Update last poll time
            cursor.execute("""
                INSERT INTO system_config (config_key, config_value)
                VALUES ('last_fax_poll', %s)
                ON DUPLICATE KEY UPDATE config_value = %s
            """, (datetime.now().isoformat(), datetime.now().isoformat()))

            db.commit()
            cursor.close()
            db.close()

        except Exception as e:
            logger.error(f"Error polling faxes: {e}")

    def _process_inbound_fax(self, fax, cursor):
        """Process a single inbound fax"""
        try:
            message_id = fax['id']
            from_number = fax.get('from', {}).get('phoneNumber', 'Unknown')
            received_date = fax.get('creationTime')

            # Check if already processed
            cursor.execute("""
                SELECT id FROM fax_log
                WHERE external_id = %s
            """, (message_id,))

            if cursor.fetchone():
                logger.debug(f"Fax {message_id} already processed, skipping")
                return

            # Download fax
            filename = f"fax_{message_id}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.pdf"
            save_path = os.path.join(self.fax_dir, filename)

            result = self.rc.download_fax(message_id, save_path)

            if result['success']:
                # Log to database
                cursor.execute("""
                    INSERT INTO fax_log (
                        external_id, direction, from_number, to_number,
                        file_path, status, received_date, created_at
                    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                """, (
                    message_id, 'inbound', from_number, self.rc.config.get('fax_number'),
                    save_path, 'received', received_date, datetime.now()
                ))

                # Create OSCAR document entry
                self._create_oscar_document(filename, from_number, received_date, cursor)

                logger.info(f"✅ Processed inbound fax from {from_number}")

        except Exception as e:
            logger.error(f"Error processing inbound fax: {e}")

    def _create_oscar_document(self, filename, from_number, received_date, cursor):
        """Create document entry in OSCAR"""
        try:
            # Insert into ctl_document table
            cursor.execute("""
                INSERT INTO ctl_document (
                    module, module_id, document_no, status,
                    document_description, responsible, source,
                    created_date, updatedatetime
                ) VALUES (
                    'demographic', 0, 0, 'A',
                    %s, 'system', 'fax',
                    %s, %s
                )
            """, (
                f"Inbound Fax from {from_number}",
                received_date,
                datetime.now()
            ))

            # Get document ID
            doc_id = cursor.lastrowid

            # Insert into document table
            cursor.execute("""
                INSERT INTO document (
                    doctype, docdesc, docxml, docfilename,
                    doccreator, source, sourceFacility,
                    public1, updatedatetime, status,
                    contenttype, abnormal, receivedDate
                ) VALUES (
                    'fax', %s, '', %s,
                    'system', 'fax', %s,
                    '0', %s, 'A',
                    'application/pdf', '0', %s
                )
            """, (
                f"Inbound Fax from {from_number}",
                filename,
                from_number,
                datetime.now(),
                received_date
            ))

            logger.debug(f"Created OSCAR document {doc_id} for fax")

        except Exception as e:
            logger.error(f"Error creating OSCAR document: {e}")

    def process_queue(self):
        """Process outbound fax queue"""
        logger.info("Processing outbound fax queue...")

        try:
            db = self.get_db_connection()
            cursor = db.cursor(dictionary=True)

            # Get pending faxes
            cursor.execute("""
                SELECT * FROM fax_queue
                WHERE status = 'pending'
                AND (retry_count < 3 OR retry_count IS NULL)
                ORDER BY created_at ASC
                LIMIT 10
            """)

            pending = cursor.fetchall()
            logger.info(f"Found {len(pending)} pending faxes")

            for fax in pending:
                self._send_queued_fax(fax, cursor)

            db.commit()
            cursor.close()
            db.close()

        except Exception as e:
            logger.error(f"Error processing fax queue: {e}")

    def _send_queued_fax(self, fax, cursor):
        """Send a queued fax"""
        try:
            fax_id = fax['id']
            to_number = fax['to_number']
            document_path = fax['document_path']
            cover_page = fax.get('cover_page', '')

            logger.info(f"Sending fax {fax_id} to {to_number}")

            # Send via RingCentral
            result = self.rc.send_fax(to_number, document_path, cover_page)

            if result['success']:
                # Update queue status
                cursor.execute("""
                    UPDATE fax_queue
                    SET status = 'sent',
                        external_id = %s,
                        sent_at = %s
                    WHERE id = %s
                """, (result['fax_id'], datetime.now(), fax_id))

                # Log successful send
                cursor.execute("""
                    INSERT INTO fax_log (
                        external_id, direction, from_number, to_number,
                        file_path, status, created_at
                    ) VALUES (%s, %s, %s, %s, %s, %s, %s)
                """, (
                    result['fax_id'], 'outbound',
                    self.rc.config.get('fax_number'), to_number,
                    document_path, 'sent', datetime.now()
                ))

                logger.info(f"✅ Sent fax {fax_id} to {to_number}, RC ID: {result['fax_id']}")

            else:
                # Update retry count
                retry_count = (fax.get('retry_count') or 0) + 1
                cursor.execute("""
                    UPDATE fax_queue
                    SET retry_count = %s,
                        last_error = %s,
                        status = CASE WHEN %s >= 3 THEN 'failed' ELSE 'pending' END
                    WHERE id = %s
                """, (retry_count, result.get('error'), retry_count, fax_id))

                logger.error(f"❌ Failed to send fax {fax_id}: {result.get('error')}")

        except Exception as e:
            logger.error(f"Error sending queued fax: {e}")

    def send_fax(self, to_number, document_path, cover_page=''):
        """
        Queue a fax for sending
        Called from API endpoint
        """
        try:
            db = self.get_db_connection()
            cursor = db.cursor()

            cursor.execute("""
                INSERT INTO fax_queue (
                    to_number, document_path, cover_page,
                    status, created_at
                ) VALUES (%s, %s, %s, 'pending', %s)
            """, (to_number, document_path, cover_page, datetime.now()))

            fax_id = cursor.lastrowid

            db.commit()
            cursor.close()
            db.close()

            logger.info(f"Queued fax {fax_id} to {to_number}")

            return {
                'success': True,
                'fax_id': fax_id,
                'status': 'queued'
            }

        except Exception as e:
            logger.error(f"Error queuing fax: {e}")
            return {
                'success': False,
                'error': str(e)
            }
