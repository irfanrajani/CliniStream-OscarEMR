"""
RingCentral Service
Handles authentication and API access for RingCentral fax and SMS
"""

import logging
from ringcentral import SDK

logger = logging.getLogger(__name__)

class RingCentralService:
    def __init__(self, config):
        """
        Initialize RingCentral SDK
        config keys: client_id, client_secret, username, password, extension
        """
        self.config = config
        self.sdk = SDK(
            config['client_id'],
            config['client_secret'],
            'https://platform.ringcentral.com'
        )

        # Login
        self.platform = self.sdk.platform()
        try:
            self.platform.login(
                config['username'],
                config.get('extension', ''),
                config['password']
            )
            logger.info("✅ RingCentral authenticated successfully")
        except Exception as e:
            logger.error(f"❌ RingCentral authentication failed: {e}")
            raise

    def get_platform(self):
        """Get authenticated platform instance"""
        # Check if token needs refresh
        if not self.platform.logged_in():
            self.platform.refresh()
        return self.platform

    def send_fax(self, to_number, file_path, cover_text=None):
        """
        Send a fax via RingCentral
        """
        try:
            platform = self.get_platform()

            # Prepare fax request
            files = {
                'attachment': (file_path, open(file_path, 'rb'), 'application/pdf')
            }

            data = {
                'to': [{'phoneNumber': to_number}],
                'faxResolution': 'High',
                'coverPageText': cover_text or 'Fax from NextScript EMR'
            }

            # Send fax
            response = platform.post('/restapi/v1.0/account/~/extension/~/fax', files, data)

            logger.info(f"✅ Fax sent to {to_number}, ID: {response.json().get('id')}")
            return {
                'success': True,
                'fax_id': response.json().get('id'),
                'status': 'queued'
            }

        except Exception as e:
            logger.error(f"❌ Failed to send fax: {e}")
            return {
                'success': False,
                'error': str(e)
            }

    def get_inbound_faxes(self, date_from=None):
        """
        Retrieve inbound faxes
        """
        try:
            platform = self.get_platform()

            params = {
                'messageType': 'Fax',
                'direction': 'Inbound',
                'readStatus': 'Unread'
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
        """
        try:
            platform = self.get_platform()

            # Get message details
            response = platform.get(f'/restapi/v1.0/account/~/extension/~/message-store/{message_id}')
            message = response.json()

            # Download first attachment
            if message.get('attachments'):
                attachment = message['attachments'][0]
                attachment_url = attachment['uri']

                # Download
                attachment_response = platform.get(attachment_url)

                with open(save_path, 'wb') as f:
                    f.write(attachment_response.content)

                logger.info(f"✅ Downloaded fax {message_id} to {save_path}")
                return {'success': True, 'path': save_path}

        except Exception as e:
            logger.error(f"❌ Failed to download fax: {e}")
            return {'success': False, 'error': str(e)}

    def send_sms(self, to_number, message):
        """
        Send an SMS via RingCentral
        """
        try:
            platform = self.get_platform()

            data = {
                'from': {'phoneNumber': self.config.get('sms_number')},
                'to': [{'phoneNumber': to_number}],
                'text': message
            }

            response = platform.post('/restapi/v1.0/account/~/extension/~/sms', data)

            logger.info(f"✅ SMS sent to {to_number}, ID: {response.json().get('id')}")
            return {
                'success': True,
                'message_id': response.json().get('id'),
                'status': 'sent'
            }

        except Exception as e:
            logger.error(f"❌ Failed to send SMS: {e}")
            return {
                'success': False,
                'error': str(e)
            }
