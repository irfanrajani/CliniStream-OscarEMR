#!/usr/bin/env python3
"""
NextScript Integration Service
Handles RingCentral (Fax/SMS), OceanMD, and other external integrations
All configuration loaded from database - no hardcoded credentials
"""

import os
import sys
import time
import logging
import schedule
import mysql.connector
from flask import Flask, jsonify, request
from datetime import datetime
import threading

# Import integration modules
from integrations.ringcentral_service import RingCentralService
from integrations.ocean_service import OceanService
from integrations.fax_processor import FaxProcessor
from integrations.sms_sender import SMSSender

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# Database connection
db_config = {
    'host': os.getenv('DB_HOST', 'db'),
    'user': os.getenv('DB_USER', 'oscar'),
    'password': os.getenv('DB_PASSWORD'),
    'database': os.getenv('DB_DATABASE', 'oscar_nextscript'),
    'autocommit': True
}

# Global services (loaded from DB)
services = {
    'ringcentral': None,
    'ocean': None,
    'fax': None,
    'sms': None
}

def get_db_connection():
    """Get database connection with retry"""
    max_retries = 5
    for i in range(max_retries):
        try:
            return mysql.connector.connect(**db_config)
        except mysql.connector.Error as err:
            if i < max_retries - 1:
                logger.warning(f"Database connection failed (attempt {i+1}/{max_retries}): {err}")
                time.sleep(5)
            else:
                logger.error(f"Failed to connect to database after {max_retries} attempts")
                raise

def load_integration_config(integration_name):
    """Load configuration for an integration from database"""
    try:
        db = get_db_connection()
        cursor = db.cursor(dictionary=True)

        cursor.execute("""
            SELECT config_key, config_value, encrypted
            FROM integration_config
            WHERE integration_name = %s AND enabled = TRUE
        """, (integration_name,))

        config = {}
        for row in cursor.fetchall():
            value = row['config_value']
            # TODO: Decrypt if row['encrypted'] is True
            config[row['config_key']] = value

        cursor.close()
        db.close()

        return config if config else None
    except Exception as e:
        logger.error(f"Error loading config for {integration_name}: {e}")
        return None

def initialize_services():
    """Initialize all integration services from database config"""
    logger.info("Initializing integration services...")

    # RingCentral
    rc_config = load_integration_config('ringcentral')
    if rc_config and rc_config.get('enabled') == 'true':
        try:
            services['ringcentral'] = RingCentralService(rc_config)
            services['fax'] = FaxProcessor(services['ringcentral'], db_config)
            services['sms'] = SMSSender(services['ringcentral'], db_config)
            logger.info("✅ RingCentral service initialized")
        except Exception as e:
            logger.error(f"❌ Failed to initialize RingCentral: {e}")

    # OceanMD
    ocean_config = load_integration_config('ocean')
    if ocean_config and ocean_config.get('enabled') == 'true':
        try:
            services['ocean'] = OceanService(ocean_config, db_config)
            logger.info("✅ Ocean eReferral service initialized")
        except Exception as e:
            logger.error(f"❌ Failed to initialize Ocean: {e}")

    logger.info("Service initialization complete")

def reload_services():
    """Hot-reload services if configuration changed"""
    logger.info("Reloading services...")
    initialize_services()

# ===== Scheduled Jobs =====

def poll_inbound_faxes():
    """Poll for inbound faxes from RingCentral"""
    if services['fax']:
        try:
            services['fax'].poll_inbound()
        except Exception as e:
            logger.error(f"Error polling faxes: {e}")

def process_outbound_fax_queue():
    """Process queued outbound faxes"""
    if services['fax']:
        try:
            services['fax'].process_queue()
        except Exception as e:
            logger.error(f"Error processing fax queue: {e}")

def process_sms_queue():
    """Process queued SMS messages"""
    if services['sms']:
        try:
            services['sms'].process_queue()
        except Exception as e:
            logger.error(f"Error processing SMS queue: {e}")

# Schedule jobs
schedule.every(5).minutes.do(poll_inbound_faxes)
schedule.every(1).minutes.do(process_outbound_fax_queue)
schedule.every(1).minutes.do(process_sms_queue)
schedule.every(10).minutes.do(reload_services)  # Hot reload config

def run_scheduler():
    """Run scheduled tasks in background thread"""
    logger.info("Starting scheduler...")
    while True:
        schedule.run_pending()
        time.sleep(1)

# ===== Flask API Endpoints =====

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    status = {
        'status': 'healthy',
        'services': {
            'ringcentral': services['ringcentral'] is not None,
            'ocean': services['ocean'] is not None,
            'fax': services['fax'] is not None,
            'sms': services['sms'] is not None
        },
        'timestamp': datetime.now().isoformat()
    }
    return jsonify(status)

@app.route('/api/fax/send', methods=['POST'])
def send_fax():
    """
    Send a fax
    POST /api/fax/send
    {
        "to": "+17785551234",
        "document_path": "/var/lib/OscarDocument/.../file.pdf",
        "cover_page": "Optional cover page text"
    }
    """
    if not services['fax']:
        return jsonify({'error': 'Fax service not configured'}), 503

    try:
        data = request.json
        result = services['fax'].send_fax(
            to_number=data['to'],
            document_path=data['document_path'],
            cover_page=data.get('cover_page', '')
        )
        return jsonify(result)
    except Exception as e:
        logger.error(f"Error sending fax: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/sms/send', methods=['POST'])
def send_sms():
    """
    Send an SMS
    POST /api/sms/send
    {
        "to": "+17785551234",
        "message": "Your appointment is tomorrow at 2pm"
    }
    """
    if not services['sms']:
        return jsonify({'error': 'SMS service not configured'}), 503

    try:
        data = request.json
        result = services['sms'].send_sms(
            to_number=data['to'],
            message=data['message']
        )
        return jsonify(result)
    except Exception as e:
        logger.error(f"Error sending SMS: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/ocean/refer', methods=['POST'])
def create_referral():
    """
    Create an Ocean eReferral
    POST /api/ocean/refer
    {
        "patient_id": 123,
        "specialist_id": 456,
        "reason": "Cardiology consultation",
        "attachments": [...]
    }
    """
    if not services['ocean']:
        return jsonify({'error': 'Ocean service not configured'}), 503

    try:
        data = request.json
        result = services['ocean'].create_referral(data)
        return jsonify(result)
    except Exception as e:
        logger.error(f"Error creating referral: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/reload', methods=['POST'])
def reload():
    """Reload all services (hot-reload configuration)"""
    try:
        reload_services()
        return jsonify({'status': 'reloaded', 'timestamp': datetime.now().isoformat()})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ===== Main =====

if __name__ == '__main__':
    logger.info("=================================")
    logger.info("NextScript Integration Service")
    logger.info("=================================")

    # Wait for database
    logger.info("Waiting for database...")
    time.sleep(10)

    # Initialize services
    initialize_services()

    # Start scheduler in background
    scheduler_thread = threading.Thread(target=run_scheduler, daemon=True)
    scheduler_thread.start()

    # Start Flask API
    logger.info("Starting API server on port 8080...")
    app.run(host='0.0.0.0', port=8080, debug=False)
