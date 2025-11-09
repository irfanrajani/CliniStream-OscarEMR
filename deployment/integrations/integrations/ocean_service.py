"""
Ocean eReferral Service
Handles electronic specialist referrals via OceanMD
"""

import logging
import requests
import mysql.connector
from datetime import datetime
import json

logger = logging.getLogger(__name__)

class OceanService:
    def __init__(self, config, db_config):
        self.config = config
        self.db_config = db_config
        self.api_base = 'https://ocean.cognisantmd.com/api/v1'
        self.site_id = config['site_id']
        self.api_key = config['api_key']

    def get_db_connection(self):
        """Get database connection"""
        return mysql.connector.connect(**self.db_config)

    def _make_request(self, method, endpoint, data=None):
        """Make authenticated API request to Ocean"""
        try:
            url = f"{self.api_base}/{endpoint}"
            headers = {
                'Authorization': f'Bearer {self.api_key}',
                'Content-Type': 'application/json',
                'X-Site-ID': self.site_id
            }

            if method == 'GET':
                response = requests.get(url, headers=headers, timeout=30)
            elif method == 'POST':
                response = requests.post(url, headers=headers, json=data, timeout=30)
            elif method == 'PUT':
                response = requests.put(url, headers=headers, json=data, timeout=30)
            else:
                raise ValueError(f"Unsupported method: {method}")

            response.raise_for_status()
            return {
                'success': True,
                'data': response.json()
            }

        except requests.exceptions.RequestException as e:
            logger.error(f"Ocean API request failed: {e}")
            return {
                'success': False,
                'error': str(e)
            }

    def create_referral(self, referral_data):
        """
        Create an eReferral in Ocean

        referral_data format:
        {
            'patient_id': 123,
            'specialist_id': 456,
            'reason': 'Cardiology consultation',
            'priority': 'routine|urgent|emergent',
            'clinical_info': '...',
            'attachments': [...]
        }
        """
        try:
            patient_id = referral_data['patient_id']
            specialist_id = referral_data.get('specialist_id')
            reason = referral_data['reason']
            priority = referral_data.get('priority', 'routine')
            clinical_info = referral_data.get('clinical_info', '')
            attachments = referral_data.get('attachments', [])

            # Get patient demographics from OSCAR
            db = self.get_db_connection()
            cursor = db.cursor(dictionary=True)

            cursor.execute("""
                SELECT first_name, last_name, hin, ver, sex, year_of_birth,
                       month_of_birth, date_of_birth, phone, email
                FROM demographic
                WHERE demographic_no = %s
            """, (patient_id,))

            patient = cursor.fetchone()

            if not patient:
                return {'success': False, 'error': 'Patient not found'}

            # Get provider info
            cursor.execute("""
                SELECT first_name, last_name, practitioner_no, phone
                FROM provider
                WHERE provider_no = (
                    SELECT provider_no FROM demographic
                    WHERE demographic_no = %s
                )
            """, (patient_id,))

            provider = cursor.fetchone()

            # Build Ocean referral request
            ocean_request = {
                'patient': {
                    'firstName': patient['first_name'],
                    'lastName': patient['last_name'],
                    'healthNumber': patient['hin'],
                    'versionCode': patient['ver'],
                    'sex': patient['sex'],
                    'dateOfBirth': f"{patient['year_of_birth']}-{patient['month_of_birth']:02d}-{patient['date_of_birth']:02d}",
                    'phone': patient.get('phone'),
                    'email': patient.get('email')
                },
                'referral': {
                    'reason': reason,
                    'priority': priority,
                    'clinicalInformation': clinical_info,
                    'urgency': priority
                },
                'provider': {
                    'firstName': provider['first_name'] if provider else '',
                    'lastName': provider['last_name'] if provider else '',
                    'licenseNumber': provider['practitioner_no'] if provider else '',
                    'phone': provider['phone'] if provider else ''
                }
            }

            # Add specialist if specified
            if specialist_id:
                cursor.execute("""
                    SELECT first_name, last_name, specialty, fax_number
                    FROM professionalSpecialists
                    WHERE specialist_no = %s
                """, (specialist_id,))

                specialist = cursor.fetchone()

                if specialist:
                    ocean_request['specialist'] = {
                        'firstName': specialist['first_name'],
                        'lastName': specialist['last_name'],
                        'specialty': specialist['specialty'],
                        'fax': specialist.get('fax_number')
                    }

            # Send to Ocean
            result = self._make_request('POST', 'referrals', ocean_request)

            if result['success']:
                ocean_referral_id = result['data'].get('id')

                # Log in database
                cursor.execute("""
                    INSERT INTO ocean_referrals (
                        patient_id, specialist_id, ocean_referral_id,
                        reason, priority, clinical_info,
                        status, created_at
                    ) VALUES (%s, %s, %s, %s, %s, %s, 'sent', %s)
                """, (
                    patient_id, specialist_id, ocean_referral_id,
                    reason, priority, clinical_info, datetime.now()
                ))

                # Link to OSCAR consultation request if it exists
                cursor.execute("""
                    UPDATE consultationRequests
                    SET referralNo = %s,
                        status = 'sent via Ocean'
                    WHERE demographicId = %s
                    AND status = 'pending'
                    ORDER BY referalDate DESC
                    LIMIT 1
                """, (ocean_referral_id, patient_id))

                db.commit()

                logger.info(f"✅ Created Ocean referral {ocean_referral_id} for patient {patient_id}")

                # Handle attachments if any
                if attachments and ocean_referral_id:
                    self._upload_attachments(ocean_referral_id, attachments)

                cursor.close()
                db.close()

                return {
                    'success': True,
                    'ocean_referral_id': ocean_referral_id,
                    'data': result['data']
                }

            else:
                cursor.close()
                db.close()
                return result

        except Exception as e:
            logger.error(f"Error creating Ocean referral: {e}")
            return {'success': False, 'error': str(e)}

    def _upload_attachments(self, referral_id, attachments):
        """Upload attachments to Ocean referral"""
        try:
            for attachment in attachments:
                # attachment format: {'path': '...', 'type': 'lab|document|image'}
                with open(attachment['path'], 'rb') as f:
                    files = {'file': f}
                    result = self._make_request(
                        'POST',
                        f'referrals/{referral_id}/attachments',
                        data={'type': attachment.get('type', 'document')}
                    )

                    if result['success']:
                        logger.info(f"✅ Uploaded attachment to Ocean referral {referral_id}")
                    else:
                        logger.error(f"❌ Failed to upload attachment: {result.get('error')}")

        except Exception as e:
            logger.error(f"Error uploading attachments: {e}")

    def get_referral_status(self, ocean_referral_id):
        """Get status of an Ocean referral"""
        try:
            result = self._make_request('GET', f'referrals/{ocean_referral_id}')

            if result['success']:
                status_data = result['data']

                # Update in database
                db = self.get_db_connection()
                cursor = db.cursor()

                cursor.execute("""
                    UPDATE ocean_referrals
                    SET status = %s,
                        updated_at = %s
                    WHERE ocean_referral_id = %s
                """, (status_data.get('status'), datetime.now(), ocean_referral_id))

                db.commit()
                cursor.close()
                db.close()

                return result

            return result

        except Exception as e:
            logger.error(f"Error getting referral status: {e}")
            return {'success': False, 'error': str(e)}

    def poll_referral_updates(self):
        """Poll Ocean for referral status updates"""
        logger.info("Polling Ocean for referral updates...")

        try:
            db = self.get_db_connection()
            cursor = db.cursor(dictionary=True)

            # Get active referrals
            cursor.execute("""
                SELECT ocean_referral_id, patient_id
                FROM ocean_referrals
                WHERE status NOT IN ('completed', 'cancelled')
                AND created_at > DATE_SUB(NOW(), INTERVAL 90 DAY)
            """)

            referrals = cursor.fetchall()
            logger.info(f"Checking {len(referrals)} active referrals")

            for ref in referrals:
                self.get_referral_status(ref['ocean_referral_id'])

            cursor.close()
            db.close()

        except Exception as e:
            logger.error(f"Error polling referral updates: {e}")

    def download_consultation_report(self, ocean_referral_id):
        """Download consultation report from Ocean"""
        try:
            result = self._make_request('GET', f'referrals/{ocean_referral_id}/report')

            if result['success']:
                report_data = result['data']

                # Save to OSCAR documents
                db = self.get_db_connection()
                cursor = db.cursor()

                # Get patient ID
                cursor.execute("""
                    SELECT patient_id FROM ocean_referrals
                    WHERE ocean_referral_id = %s
                """, (ocean_referral_id,))

                patient_id = cursor.fetchone()[0] if cursor.rowcount > 0 else None

                if patient_id:
                    # Create document
                    cursor.execute("""
                        INSERT INTO document (
                            doctype, docdesc, docxml, doccreator,
                            source, sourceFacility, updatedatetime,
                            status, contenttype
                        ) VALUES (
                            'consultation', 'Ocean Consultation Report',
                            %s, 'ocean', 'Ocean', 'Ocean eReferral',
                            %s, 'A', 'text/html'
                        )
                    """, (json.dumps(report_data), datetime.now()))

                    doc_id = cursor.lastrowid

                    # Link to demographic
                    cursor.execute("""
                        INSERT INTO ctl_document (
                            module, module_id, document_no, status
                        ) VALUES ('demographic', %s, %s, 'A')
                    """, (patient_id, doc_id))

                    db.commit()
                    logger.info(f"✅ Downloaded consultation report for referral {ocean_referral_id}")

                cursor.close()
                db.close()

                return result

            return result

        except Exception as e:
            logger.error(f"Error downloading consultation report: {e}")
            return {'success': False, 'error': str(e)}
