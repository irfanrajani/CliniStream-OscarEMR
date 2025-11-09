import React, { useState } from 'react';
import {
  TextField,
  Grid,
  Typography,
  Box,
  Alert,
  FormControlLabel,
  Switch,
  Button,
  Link,
  Paper
} from '@mui/material';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import ErrorIcon from '@mui/icons-material/Error';

export default function RingCentralForm({ data, onChange }) {
  const [testing, setTesting] = useState(false);
  const [testResult, setTestResult] = useState(null);

  const handleChange = (field) => (event) => {
    const value = event.target.type === 'checkbox' ? event.target.checked : event.target.value;
    onChange({ ...data, [field]: value });
  };

  const testConnection = async () => {
    setTesting(true);
    setTestResult(null);

    try {
      // Test RingCentral credentials
      const response = await fetch('/api/test/ringcentral', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          clientId: data.clientId,
          clientSecret: data.clientSecret,
          username: data.username,
          password: data.password,
          extension: data.extension
        })
      });

      const result = await response.json();
      setTestResult(result);
    } catch (error) {
      setTestResult({ success: false, error: error.message });
    } finally {
      setTesting(false);
    }
  };

  return (
    <Box>
      <Typography variant="h5" gutterBottom>
        RingCentral Configuration (eFax & SMS)
      </Typography>
      <Typography variant="body2" color="text.secondary" paragraph>
        Configure RingCentral for electronic faxing and SMS messaging. This enables:
        - Prescription faxing to pharmacies
        - Consultation faxing to specialists
        - Patient SMS notifications (appointment reminders, etc.)
      </Typography>

      <FormControlLabel
        control={
          <Switch
            checked={data.enabled || false}
            onChange={handleChange('enabled')}
          />
        }
        label="Enable RingCentral Integration"
      />

      {!data.enabled && (
        <Alert severity="info" sx={{ mt: 2 }}>
          You can skip this step and configure RingCentral later in Settings.
          Basic email-to-fax will still work.
        </Alert>
      )}

      {data.enabled && (
        <Box sx={{ mt: 3 }}>
          <Alert severity="info" sx={{ mb: 3 }}>
            <Typography variant="body2">
              Don't have a RingCentral account yet?
              <Link href="https://www.ringcentral.com/signup.html" target="_blank" sx={{ ml: 1 }}>
                Sign up here
              </Link>
            </Typography>
            <Typography variant="body2" sx={{ mt: 1 }}>
              You'll need to create an app in the{' '}
              <Link href="https://developers.ringcentral.com/" target="_blank">
                RingCentral Developer Portal
              </Link>
              {' '}to get your Client ID and Client Secret.
            </Typography>
          </Alert>

          <Grid container spacing={3}>
            <Grid item xs={12}>
              <Typography variant="subtitle2" gutterBottom>
                API Credentials
              </Typography>
            </Grid>

            <Grid item xs={12} sm={6}>
              <TextField
                required
                fullWidth
                label="Client ID"
                value={data.clientId || ''}
                onChange={handleChange('clientId')}
                helperText="From RingCentral Developer Portal"
              />
            </Grid>

            <Grid item xs={12} sm={6}>
              <TextField
                required
                fullWidth
                label="Client Secret"
                type="password"
                value={data.clientSecret || ''}
                onChange={handleChange('clientSecret')}
                helperText="Keep this secret!"
              />
            </Grid>

            <Grid item xs={12}>
              <Typography variant="subtitle2" gutterBottom sx={{ mt: 2 }}>
                Account Credentials
              </Typography>
            </Grid>

            <Grid item xs={12} sm={4}>
              <TextField
                required
                fullWidth
                label="Username"
                value={data.username || ''}
                onChange={handleChange('username')}
                helperText="RingCentral phone number or email"
              />
            </Grid>

            <Grid item xs={12} sm={4}>
              <TextField
                required
                fullWidth
                label="Extension"
                value={data.extension || ''}
                onChange={handleChange('extension')}
                helperText="Usually 101"
                placeholder="101"
              />
            </Grid>

            <Grid item xs={12} sm={4}>
              <TextField
                required
                fullWidth
                label="Password"
                type="password"
                value={data.password || ''}
                onChange={handleChange('password')}
                helperText="RingCentral account password"
              />
            </Grid>

            <Grid item xs={12}>
              <Typography variant="subtitle2" gutterBottom sx={{ mt: 2 }}>
                Phone Numbers
              </Typography>
            </Grid>

            <Grid item xs={12} sm={6}>
              <TextField
                required
                fullWidth
                label="Fax Number"
                value={data.faxNumber || ''}
                onChange={handleChange('faxNumber')}
                placeholder="+17785551234"
                helperText="Your RingCentral fax number (with country code)"
              />
            </Grid>

            <Grid item xs={12} sm={6}>
              <TextField
                required
                fullWidth
                label="SMS Number"
                value={data.smsNumber || ''}
                onChange={handleChange('smsNumber')}
                placeholder="+17785551234"
                helperText="Your RingCentral SMS-enabled number"
              />
            </Grid>

            <Grid item xs={12}>
              <Paper sx={{ p: 2, bgcolor: 'grey.50' }}>
                <Typography variant="subtitle2" gutterBottom>
                  Test Connection
                </Typography>
                <Typography variant="body2" color="text.secondary" paragraph>
                  Verify your credentials before proceeding.
                </Typography>
                <Button
                  variant="outlined"
                  onClick={testConnection}
                  disabled={testing || !data.clientId || !data.clientSecret || !data.username || !data.password}
                >
                  {testing ? 'Testing...' : 'Test RingCentral Connection'}
                </Button>

                {testResult && (
                  <Alert
                    severity={testResult.success ? 'success' : 'error'}
                    icon={testResult.success ? <CheckCircleIcon /> : <ErrorIcon />}
                    sx={{ mt: 2 }}
                  >
                    {testResult.success ? (
                      <>
                        <strong>Connection successful!</strong>
                        <br />
                        Account: {testResult.account}
                        <br />
                        Extension: {testResult.extension}
                      </>
                    ) : (
                      <>
                        <strong>Connection failed</strong>
                        <br />
                        {testResult.error}
                      </>
                    )}
                  </Alert>
                )}
              </Paper>
            </Grid>
          </Grid>
        </Box>
      )}
    </Box>
  );
}
