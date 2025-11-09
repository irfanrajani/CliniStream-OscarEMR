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

export default function OceanForm({ data, onChange }) {
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
      const response = await fetch('/api/test/ocean', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          siteId: data.siteId,
          apiKey: data.apiKey
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
        OceanMD eReferral Configuration
      </Typography>
      <Typography variant="body2" color="text.secondary" paragraph>
        Configure OceanMD for electronic specialist referrals. This enables:
        - Electronic specialist referrals
        - Automated referral tracking
        - Digital forms and questionnaires
        - Two-way communication with specialists
      </Typography>

      <FormControlLabel
        control={
          <Switch
            checked={data.enabled || false}
            onChange={handleChange('enabled')}
          />
        }
        label="Enable OceanMD Integration"
      />

      {!data.enabled && (
        <Alert severity="info" sx={{ mt: 2 }}>
          You can skip this step and configure OceanMD later in Settings.
          Traditional paper referrals will still work via fax.
        </Alert>
      )}

      {data.enabled && (
        <Box sx={{ mt: 3 }}>
          <Alert severity="info" sx={{ mb: 3 }}>
            <Typography variant="body2">
              Don't have an OceanMD account yet?{' '}
              <Link href="https://ocean.cognisantmd.com/register" target="_blank">
                Sign up here
              </Link>
            </Typography>
            <Typography variant="body2" sx={{ mt: 1 }}>
              After registration, you'll receive your Site ID and API Key via email.
              You can also find them in your{' '}
              <Link href="https://ocean.cognisantmd.com/settings/api" target="_blank">
                Ocean Settings
              </Link>.
            </Typography>
          </Alert>

          <Grid container spacing={3}>
            <Grid item xs={12} sm={6}>
              <TextField
                required
                fullWidth
                label="Site ID"
                value={data.siteId || ''}
                onChange={handleChange('siteId')}
                placeholder="12345"
                helperText="Your OceanMD site identifier"
              />
            </Grid>

            <Grid item xs={12} sm={6}>
              <TextField
                required
                fullWidth
                label="API Key"
                type="password"
                value={data.apiKey || ''}
                onChange={handleChange('apiKey')}
                helperText="Keep this secret!"
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
                  disabled={testing || !data.siteId || !data.apiKey}
                >
                  {testing ? 'Testing...' : 'Test OceanMD Connection'}
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
                        Site: {testResult.siteName}
                        <br />
                        Status: Active
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

            <Grid item xs={12}>
              <Alert severity="success">
                <Typography variant="subtitle2" gutterBottom>
                  What you'll be able to do with OceanMD:
                </Typography>
                <ul style={{ margin: 0, paddingLeft: '20px' }}>
                  <li>Send electronic referrals to specialists</li>
                  <li>Track referral status in real-time</li>
                  <li>Receive consultation reports automatically</li>
                  <li>Send patient questionnaires and forms</li>
                  <li>Enable online patient booking (optional)</li>
                  <li>Integrate with Ocean Tablet for waiting room</li>
                </ul>
              </Alert>
            </Grid>
          </Grid>
        </Box>
      )}
    </Box>
  );
}
