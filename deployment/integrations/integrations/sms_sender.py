"""
SMS Sender
Handles SMS messaging via RingCentral for patient notifications
"""

import logging
import mysql.connector
from datetime import datetime

logger = logging.getLogger(__name__)

class SMSSender:
    def __init__(self, ringcentral_service, db_config):
        self.rc = ringcentral_service
        self.db_config = db_config

    def get_db_connection(self):
        """Get database connection"""
        return mysql.connector.connect(**self.db_config)

    def send_sms(self, to_number, message, patient_id=None, provider_id=None):
        """
        Send an SMS message
        """
        try:
            # Validate phone number (basic)
            if not to_number.startswith('+'):
                # Assume North American number
                to_number = '+1' + to_number.replace('-', '').replace('(', '').replace(')', '').replace(' ', '')

            # Send via RingCentral
            result = self.rc.send_sms(to_number, message)

            # Log to database
            db = self.get_db_connection()
            cursor = db.cursor()

            cursor.execute("""
                INSERT INTO sms_log (
                    external_id, to_number, message_text,
                    patient_id, provider_id, status,
                    sent_at, created_at
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """, (
                result.get('message_id'),
                to_number,
                message,
                patient_id,
                provider_id,
                'sent' if result['success'] else 'failed',
                datetime.now() if result['success'] else None,
                datetime.now()
            ))

            db.commit()
            cursor.close()
            db.close()

            if result['success']:
                logger.info(f"✅ SMS sent to {to_number}")
            else:
                logger.error(f"❌ SMS failed to {to_number}: {result.get('error')}")

            return result

        except Exception as e:
            logger.error(f"Error sending SMS: {e}")
            return {
                'success': False,
                'error': str(e)
            }

    def process_queue(self):
        """Process queued SMS messages"""
        logger.info("Processing SMS queue...")

        try:
            db = self.get_db_connection()
            cursor = db.cursor(dictionary=True)

            # Get pending messages
            cursor.execute("""
                SELECT * FROM sms_queue
                WHERE status = 'pending'
                AND (retry_count < 3 OR retry_count IS NULL)
                AND (scheduled_for IS NULL OR scheduled_for <= %s)
                ORDER BY scheduled_for ASC, created_at ASC
                LIMIT 20
            """, (datetime.now(),))

            pending = cursor.fetchall()
            logger.info(f"Found {len(pending)} pending SMS messages")

            for sms in pending:
                self._send_queued_sms(sms, cursor)

            db.commit()
            cursor.close()
            db.close()

        except Exception as e:
            logger.error(f"Error processing SMS queue: {e}")

    def _send_queued_sms(self, sms, cursor):
        """Send a queued SMS"""
        try:
            sms_id = sms['id']
            to_number = sms['to_number']
            message = sms['message_text']
            patient_id = sms.get('patient_id')
            provider_id = sms.get('provider_id')

            logger.info(f"Sending SMS {sms_id} to {to_number}")

            # Send
            result = self.send_sms(to_number, message, patient_id, provider_id)

            if result['success']:
                # Update queue status
                cursor.execute("""
                    UPDATE sms_queue
                    SET status = 'sent',
                        external_id = %s,
                        sent_at = %s
                    WHERE id = %s
                """, (result['message_id'], datetime.now(), sms_id))

                logger.info(f"✅ Sent SMS {sms_id}")

            else:
                # Update retry count
                retry_count = (sms.get('retry_count') or 0) + 1
                cursor.execute("""
                    UPDATE sms_queue
                    SET retry_count = %s,
                        last_error = %s,
                        status = CASE WHEN %s >= 3 THEN 'failed' ELSE 'pending' END
                    WHERE id = %s
                """, (retry_count, result.get('error'), retry_count, sms_id))

                logger.error(f"❌ Failed to send SMS {sms_id}: {result.get('error')}")

        except Exception as e:
            logger.error(f"Error sending queued SMS: {e}")

    def queue_sms(self, to_number, message, patient_id=None, provider_id=None, scheduled_for=None):
        """
        Queue an SMS for sending
        """
        try:
            db = self.get_db_connection()
            cursor = db.cursor()

            cursor.execute("""
                INSERT INTO sms_queue (
                    to_number, message_text, patient_id, provider_id,
                    scheduled_for, status, created_at
                ) VALUES (%s, %s, %s, %s, %s, 'pending', %s)
            """, (to_number, message, patient_id, provider_id, scheduled_for, datetime.now()))

            sms_id = cursor.lastrowid

            db.commit()
            cursor.close()
            db.close()

            logger.info(f"Queued SMS {sms_id} to {to_number}")

            return {
                'success': True,
                'sms_id': sms_id,
                'status': 'queued'
            }

        except Exception as e:
            logger.error(f"Error queuing SMS: {e}")
            return {
                'success': False,
                'error': str(e)
            }

    def send_appointment_reminder(self, patient_id, appointment_date, provider_name):
        """
        Send appointment reminder SMS
        """
        try:
            # Get patient phone from database
            db = self.get_db_connection()
            cursor = db.cursor(dictionary=True)

            cursor.execute("""
                SELECT phone, phone2, cell
                FROM demographic
                WHERE demographic_no = %s
            """, (patient_id,))

            patient = cursor.fetchone()
            cursor.close()
            db.close()

            if not patient:
                return {'success': False, 'error': 'Patient not found'}

            # Get mobile number (prefer cell, then phone2, then phone)
            mobile = patient.get('cell') or patient.get('phone2') or patient.get('phone')

            if not mobile:
                return {'success': False, 'error': 'No mobile number found'}

            # Format message
            message = f"Reminder: You have an appointment with {provider_name} on {appointment_date}. Reply CONFIRM to confirm or call us to reschedule."

            # Send
            return self.queue_sms(mobile, message, patient_id=patient_id)

        except Exception as e:
            logger.error(f"Error sending appointment reminder: {e}")
            return {'success': False, 'error': str(e)}

    def send_lab_notification(self, patient_id, lab_description):
        """
        Send lab result notification
        """
        try:
            # Get patient info
            db = self.get_db_connection()
            cursor = db.cursor(dictionary=True)

            cursor.execute("""
                SELECT first_name, cell, phone2, phone
                FROM demographic
                WHERE demographic_no = %s
            """, (patient_id,))

            patient = cursor.fetchone()
            cursor.close()
            db.close()

            if not patient:
                return {'success': False, 'error': 'Patient not found'}

            mobile = patient.get('cell') or patient.get('phone2') or patient.get('phone')

            if not mobile:
                return {'success': False, 'error': 'No mobile number found'}

            first_name = patient.get('first_name', 'Patient')

            # Format message
            message = f"Hi {first_name}, your {lab_description} results are ready. Please call the clinic to discuss your results with your provider."

            # Send
            return self.queue_sms(mobile, message, patient_id=patient_id)

        except Exception as e:
            logger.error(f"Error sending lab notification: {e}")
            return {'success': False, 'error': str(e)}
