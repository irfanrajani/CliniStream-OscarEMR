const express = require('express');
const mysql = require('mysql2/promise');
const path = require('path');
const bcrypt = require('bcrypt');
const axios = require('axios');
const { encrypt, decrypt } = require('./crypto');

const app = express();
app.use(express.json());
app.use(express.static('dist'));

// Database connection
let db;
async function initDB() {
  db = await mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_DATABASE
  });
}

// Check if setup is complete
app.get('/api/setup-status', async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM system_config WHERE config_key = "setup_complete"');
    res.json({ complete: rows.length > 0 && rows[0].config_value === 'true' });
  } catch (error) {
    res.json({ complete: false, firstRun: true });
  }
});

// Save clinic details
app.post('/api/setup/clinic', async (req, res) => {
  try {
    const { name, address, city, province, postal, phone, fax, email, website } = req.body;

    // Create/update system_config table if doesn't exist
    await db.query(`
      CREATE TABLE IF NOT EXISTS system_config (
        id INT PRIMARY KEY AUTO_INCREMENT,
        config_key VARCHAR(100) UNIQUE,
        config_value TEXT,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      )
    `);

    // Store clinic details
    const configs = {
      'clinic_name': name,
      'clinic_address': address,
      'clinic_city': city,
      'clinic_province': province,
      'clinic_postal': postal,
      'clinic_phone': phone,
      'clinic_fax': fax,
      'clinic_email': email,
      'clinic_website': website
    };

    for (const [key, value] of Object.entries(configs)) {
      await db.query(
        'INSERT INTO system_config (config_key, config_value) VALUES (?, ?) ON DUPLICATE KEY UPDATE config_value = ?',
        [key, value, value]
      );
    }

    res.json({ success: true });
  } catch (error) {
    console.error('Error saving clinic details:', error);
    res.status(500).json({ error: error.message });
  }
});

// Save BC Teleplan configuration
app.post('/api/setup/billing', async (req, res) => {
  try {
    const { payeeNumber, groupNumber, billingLocation, dataCenter } = req.body;

    const configs = {
      'bc_payee_number': payeeNumber,
      'bc_group_number': groupNumber,
      'bc_billing_location': billingLocation,
      'bc_data_center': dataCenter
    };

    for (const [key, value] of Object.entries(configs)) {
      await db.query(
        'INSERT INTO system_config (config_key, config_value) VALUES (?, ?) ON DUPLICATE KEY UPDATE config_value = ?',
        [key, value, value]
      );
    }

    res.json({ success: true });
  } catch (error) {
    console.error('Error saving billing config:', error);
    res.status(500).json({ error: error.message });
  }
});

// Save RingCentral configuration
app.post('/api/setup/ringcentral', async (req, res) => {
  try {
    const { clientId, clientSecret, username, password, extension, faxNumber, smsNumber } = req.body;

    // Create integrations config table
    await db.query(`
      CREATE TABLE IF NOT EXISTS integration_config (
        id INT PRIMARY KEY AUTO_INCREMENT,
        integration_name VARCHAR(50),
        config_key VARCHAR(100),
        config_value TEXT,
        encrypted BOOLEAN DEFAULT FALSE,
        enabled BOOLEAN DEFAULT TRUE,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        UNIQUE KEY unique_config (integration_name, config_key)
      )
    `);

    const configs = [
      ['ringcentral', 'client_id', clientId, true],
      ['ringcentral', 'client_secret', clientSecret, true],
      ['ringcentral', 'username', username, true],
      ['ringcentral', 'password', password, true],
      ['ringcentral', 'extension', extension, false],
      ['ringcentral', 'fax_number', faxNumber, false],
      ['ringcentral', 'sms_number', smsNumber, false],
      ['ringcentral', 'enabled', 'true', false]
    ];

    for (const [integration, key, value, encrypted_flag] of configs) {
      // Encrypt sensitive values
      const finalValue = encrypted_flag ? encrypt(value) : value;
      await db.query(
        `INSERT INTO integration_config (integration_name, config_key, config_value, encrypted)
         VALUES (?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE config_value = ?, encrypted = ?`,
        [integration, key, finalValue, encrypted_flag, finalValue, encrypted_flag]
      );
    }

    res.json({ success: true });
  } catch (error) {
    console.error('Error saving RingCentral config:', error);
    res.status(500).json({ error: error.message });
  }
});

// Save OceanMD configuration
app.post('/api/setup/ocean', async (req, res) => {
  try {
    const { siteId, apiKey } = req.body;

    const configs = [
      ['ocean', 'site_id', siteId, false],
      ['ocean', 'api_key', apiKey, true],
      ['ocean', 'enabled', 'true', false]
    ];

    for (const [integration, key, value, encrypted_flag] of configs) {
      const finalValue = encrypted_flag ? encrypt(value) : value;
      await db.query(
        `INSERT INTO integration_config (integration_name, config_key, config_value, encrypted)
         VALUES (?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE config_value = ?, encrypted = ?`,
        [integration, key, finalValue, encrypted_flag, finalValue, encrypted_flag]
      );
    }

    res.json({ success: true });
  } catch (error) {
    console.error('Error saving Ocean config:', error);
    res.status(500).json({ error: error.message });
  }
});

// Save lab configuration
app.post('/api/setup/labs', async (req, res) => {
  try {
    const { provider, username, password, downloadEnabled } = req.body;

    const configs = [
      ['labs', 'provider', provider, false],
      ['labs', 'username', username, true],
      ['labs', 'password', password, true],
      ['labs', 'enabled', downloadEnabled ? 'true' : 'false', false],
      ['labs', 'host', 'sftp.excelleris.com', false],
      ['labs', 'port', '22', false],
      ['labs', 'remote_path', '/inbox', false]
    ];

    for (const [integration, key, value, encrypted_flag] of configs) {
      const finalValue = encrypted_flag ? encrypt(value) : value;
      await db.query(
        `INSERT INTO integration_config (integration_name, config_key, config_value, encrypted)
         VALUES (?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE config_value = ?, encrypted = ?`,
        [integration, key, finalValue, encrypted_flag, finalValue, encrypted_flag]
      );
    }

    res.json({ success: true });
  } catch (error) {
    console.error('Error saving lab config:', error);
    res.status(500).json({ error: error.message });
  }
});

// Test RingCentral connection
app.post('/api/test/ringcentral', async (req, res) => {
  try {
    const { clientId, clientSecret, username, password } = req.body;

    // Test authentication by getting a token
    const tokenResponse = await axios.post('https://platform.ringcentral.com/restapi/oauth/token',
      new URLSearchParams({
        'grant_type': 'password',
        'username': username,
        'password': password
      }),
      {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Basic ' + Buffer.from(`${clientId}:${clientSecret}`).toString('base64')
        },
        timeout: 10000
      }
    );

    if (tokenResponse.data.access_token) {
      res.json({ success: true, message: 'RingCentral credentials verified!' });
    } else {
      res.json({ success: false, error: 'Invalid credentials' });
    }
  } catch (error) {
    console.error('RingCentral test failed:', error.response?.data || error.message);
    res.json({
      success: false,
      error: error.response?.data?.error_description || error.message || 'Connection failed'
    });
  }
});

// Test Ocean connection
app.post('/api/test/ocean', async (req, res) => {
  try {
    const { siteId, apiKey } = req.body;

    // Test Ocean API connection
    const oceanResponse = await axios.get(`https://ocean.cognisantmd.com/api/v1/site/${siteId}/referrals`, {
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json'
      },
      timeout: 10000
    });

    if (oceanResponse.status === 200) {
      res.json({ success: true, message: 'Ocean credentials verified!' });
    } else {
      res.json({ success: false, error: 'Invalid credentials' });
    }
  } catch (error) {
    console.error('Ocean test failed:', error.response?.data || error.message);
    res.json({
      success: false,
      error: error.response?.data?.message || error.message || 'Connection failed'
    });
  }
});

// Test Lab SFTP connection
app.post('/api/test/labs', async (req, res) => {
  try {
    const { username, password, provider } = req.body;

    // We can't test SFTP from Node.js without ssh2 library
    // For now, just validate credentials are provided
    if (!username || !password) {
      res.json({ success: false, error: 'Username and password are required' });
      return;
    }

    // Basic validation - real test happens when integration service starts
    res.json({
      success: true,
      message: `Lab credentials saved. Connection will be verified when integration service starts.`,
      note: 'SFTP connection test requires integration service to be running'
    });
  } catch (error) {
    console.error('Lab test failed:', error.message);
    res.json({
      success: false,
      error: error.message || 'Connection test failed'
    });
  }
});

// Complete setup
app.post('/api/setup/complete', async (req, res) => {
  try {
    await db.query(
      'INSERT INTO system_config (config_key, config_value) VALUES ("setup_complete", "true") ON DUPLICATE KEY UPDATE config_value = "true"'
    );

    res.json({
      success: true,
      message: 'Setup complete! You can now access OSCAR EMR at http://localhost:8567/oscar'
    });
  } catch (error) {
    console.error('Error completing setup:', error);
    res.status(500).json({ error: error.message });
  }
});

// Serve React app for all other routes
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'dist', 'index.html'));
});

// Start server
const PORT = process.env.PORT || 3000;
initDB().then(() => {
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`Setup wizard running on http://0.0.0.0:${PORT}`);
  });
}).catch(err => {
  console.error('Failed to connect to database:', err);
  process.exit(1);
});
