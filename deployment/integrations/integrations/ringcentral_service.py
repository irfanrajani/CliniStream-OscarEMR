"""
RingCentral Service
Handles authentication and API access for RingCentral fax and SMS
Production-ready with retry logic and proper error handling
"""

import logging
import time
from ringcentral import SDK

logger = logging.getLogger(__name__)

class RingCentralService:
    def __init__(self, config):
        """
        Initialize RingCentral SDK
        config keys: client_id, client_secret, username, password, extension, sms_number
        """
        self.config = config
        self.sdk = SDK(
            config['client_id'],
            config['client_secret'],
            config.get('server_url', 'https://platform.ringcentral.com')
        )

        # Login
        self.platform = self.sdk.platform()
        self._authenticate()

    def _authenticate(self):
        """Authenticate with RingCentral"""
        try:
            self.platform.login(
                self.config['username'],
                self.config.get('extension', ''),
                self.config['password']
            )
            logger.info("✅ RingCentral authenticated successfully")
        except Exception as e:
            logger.error(f"❌ RingCentral authentication failed: {e}")
            raise

    def get_platform(self):
        """Get authenticated platform instance with auto-refresh"""
        try:
            # Check if token needs refresh
            if not self.platform.logged_in():
                logger.info("Token expired, refreshing...")
                self.platform.refresh()
        except Exception as e:
            logger.warning(f"Token refresh failed, re-authenticating: {e}")
            self._authenticate()

        return self.platform

    def send_fax(self, to_number, file_path, cover_text=None, retry_count=0):
        """
        Send a fax via RingCentral with retry logic

        Args:
            to_number: Fax number (e.g., +17785551234)
            file_path: Path to PDF file
            cover_text: Optional cover page text
            retry_count: Internal retry counter

        Returns:
            dict: {'success': bool, 'fax_id': str, 'status': str} or error
        """
        max_retries = 3

        try:
            platform = self.get_platform()

            # Prepare fax request with proper file handling
            with open(file_path, 'rb') as fax_file:
                files = {
                    'attachment': ('fax.pdf', fax_file, 'application/pdf')
                }

                data = {
                    'to': [{'phoneNumber': to_number}],
                    'faxResolution': 'High',
                    'coverPageText': cover_text or 'Fax from OSCAR EMR'
                }

                # Send fax
                response = platform.post('/restapi/v1.0/account/~/extension/~/fax', files, data)
                result = response.json()

            logger.info(f"✅ Fax sent to {to_number}, ID: {result.get('id')}")
            return {
                'success': True,
                'fax_id': result.get('id'),
                'message_id': result.get('id'),
                'status': 'queued',
                'to': to_number
            }

        except FileNotFoundError:
            logger.error(f"❌ Fax file not found: {file_path}")
            return {
                'success': False,
                'error': f'File not found: {file_path}'
            }

        except Exception as e:
            error_msg = str(e)
            logger.error(f"❌ Failed to send fax (attempt {retry_count + 1}/{max_retries}): {error_msg}")

            # Retry on network errors
            if retry_count < max_retries and ('connection' in error_msg.lower() or 'timeout' in error_msg.lower()):
                wait_time = 2 ** retry_count  # Exponential backoff: 1s, 2s, 4s
                logger.info(f"Retrying in {wait_time}s...")
                time.sleep(wait_time)
                return self.send_fax(to_number, file_path, cover_text, retry_count + 1)

            return {
                'success': False,
                'error': error_msg
            }

    def get_inbound_faxes(self, date_from=None, per_page=100):
        """
        Retrieve inbound faxes

        Args:
            date_from: ISO datetime string (e.g., '2024-11-01T00:00:00Z')
            per_page: Results per page (max 1000)

        Returns:
            list: Fax message records
        """
        try:
            platform = self.get_platform()

            params = {
                'messageType': 'Fax',
                'direction': 'Inbound',
                'readStatus': 'Unread',
                'perPage': per_page
            }

            if date_from:
                params['dateFrom'] = date_from

            response = platform.get('/restapi/v1.0/account/~/extension/~/message-store', params)
            faxes = response.json().get('records', [])

            logger.info(f"Retrieved {len(faxes)} inbound faxes")
            return faxes

        except Exception as e:
            logger.error(f"❌ Failed to get inbound faxes: {e}")
            return []

    def download_fax(self, message_id, save_path):
        """
        Download a fax attachment

        Args:
            message_id: RingCentral message ID
            save_path: Local file path to save

        Returns:
            dict: {'success': bool, 'path': str} or error
        """
        try:
            platform = self.get_platform()

            # Get message details
            response = platform.get(f'/restapi/v1.0/account/~/extension/~/message-store/{message_id}')
            message = response.json()

            # Download first attachment (usually PDF)
            if message.get('attachments'):
                attachment = message['attachments'][0]
                attachment_url = attachment['uri']
                content_type = attachment.get('contentType', 'application/pdf')

                # Download attachment
                attachment_response = platform.get(attachment_url)

                # Save to file
                with open(save_path, 'wb') as f:
                    f.write(attachment_response.content)

                logger.info(f"✅ Downloaded fax {message_id} to {save_path}")

                # Mark as read
                platform.put(f'/restapi/v1.0/account/~/extension/~/message-store/{message_id}', {
                    'readStatus': 'Read'
                })

                return {
                    'success': True,
                    'path': save_path,
                    'content_type': content_type,
                    'from': message.get('from', {}).get('phoneNumber'),
                    'to': message.get('to', [{}])[0].get('phoneNumber'),
                    'creation_time': message.get('creationTime')
                }
            else:
                logger.warning(f"No attachments found for fax {message_id}")
                return {
                    'success': False,
                    'error': 'No attachments found'
                }

        except Exception as e:
            logger.error(f"❌ Failed to download fax {message_id}: {e}")
            return {
                'success': False,
                'error': str(e)
            }

    def get_fax_status(self, message_id):
        """
        Get fax delivery status

        Args:
            message_id: RingCentral message ID

        Returns:
            dict: Status information
        """
        try:
            platform = self.get_platform()
            response = platform.get(f'/restapi/v1.0/account/~/extension/~/message-store/{message_id}')
            message = response.json()

            return {
                'success': True,
                'status': message.get('messageStatus'),
                'read_status': message.get('readStatus'),
                'fax_resolution': message.get('faxResolution'),
                'fax_page_count': message.get('faxPageCount'),
                'to': [recipient.get('phoneNumber') for recipient in message.get('to', [])],
                'creation_time': message.get('creationTime'),
                'last_modified_time': message.get('lastModifiedTime')
            }
        except Exception as e:
            logger.error(f"❌ Failed to get fax status for {message_id}: {e}")
            return {
                'success': False,
                'error': str(e)
            }

    def send_sms(self, to_number, message, retry_count=0):
        """
        Send an SMS via RingCentral with retry logic

        Args:
            to_number: Phone number (e.g., +17785551234)
            message: SMS text (max 1000 characters)
            retry_count: Internal retry counter

        Returns:
            dict: {'success': bool, 'message_id': str} or error
        """
        max_retries = 3

        try:
            platform = self.get_platform()

            # Get SMS-enabled number from config
            from_number = self.config.get('sms_number')
            if not from_number:
                raise ValueError("SMS number not configured")

            data = {
                'from': {'phoneNumber': from_number},
                'to': [{'phoneNumber': to_number}],
                'text': message[:1000]  # Truncate to 1000 chars
            }

            response = platform.post('/restapi/v1.0/account/~/extension/~/sms', data)
            result = response.json()

            logger.info(f"✅ SMS sent to {to_number}, ID: {result.get('id')}")
            return {
                'success': True,
                'message_id': result.get('id'),
                'status': 'sent',
                'to': to_number
            }

        except ValueError as e:
            logger.error(f"❌ SMS configuration error: {e}")
            return {
                'success': False,
                'error': str(e)
            }

        except Exception as e:
            error_msg = str(e)
            logger.error(f"❌ Failed to send SMS (attempt {retry_count + 1}/{max_retries}): {error_msg}")

            # Retry on network errors
            if retry_count < max_retries and ('connection' in error_msg.lower() or 'timeout' in error_msg.lower()):
                wait_time = 2 ** retry_count
                logger.info(f"Retrying in {wait_time}s...")
                time.sleep(wait_time)
                return self.send_sms(to_number, message, retry_count + 1)

            return {
                'success': False,
                'error': error_msg
            }

    def test_connection(self):
        """
        Test RingCentral connection and credentials

        Returns:
            dict: Connection test results
        """
        try:
            platform = self.get_platform()

            # Get account info to verify credentials
            response = platform.get('/restapi/v1.0/account/~')
            account = response.json()

            # Get extension info
            ext_response = platform.get('/restapi/v1.0/account/~/extension/~')
            extension = ext_response.json()

            return {
                'success': True,
                'account_id': account.get('id'),
                'company_name': account.get('serviceInfo', {}).get('brand', {}).get('name'),
                'extension_number': extension.get('extensionNumber'),
                'status': extension.get('status'),
                'fax_capable': any(f.get('features', {}).get('Fax') for f in extension.get('phoneNumbers', [])),
                'sms_capable': any(f.get('features', {}).get('SmsSender') for f in extension.get('phoneNumbers', []))
            }

        except Exception as e:
            logger.error(f"❌ Connection test failed: {e}")
            return {
                'success': False,
                'error': str(e)
            }
