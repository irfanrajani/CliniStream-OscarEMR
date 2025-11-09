import React from 'react';
import {
  TextField,
  Grid,
  Typography,
  Box,
  Alert,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  FormControlLabel,
  Switch
} from '@mui/material';

export default function LabsForm({ data, onChange }) {
  const handleChange = (field) => (event) => {
    const value = event.target.type === 'checkbox' ? event.target.checked : event.target.value;
    onChange({ ...data, [field]: value });
  };

  return (
    <Box>
      <Typography variant="h5" gutterBottom>
        Laboratory Integration
      </Typography>
      <Typography variant="body2" color="text.secondary" paragraph>
        Configure automatic lab result download from BC laboratory services.
        Results will be automatically imported into OSCAR's document inbox.
      </Typography>

      <FormControlLabel
        control={
          <Switch
            checked={data.downloadEnabled || false}
            onChange={handleChange('downloadEnabled')}
          />
        }
        label="Enable Automatic Lab Download"
      />

      {!data.downloadEnabled && (
        <Alert severity="info" sx={{ mt: 2 }}>
          You can skip this step and configure labs later. You can still manually upload lab results.
        </Alert>
      )}

      {data.downloadEnabled && (
        <Box sx={{ mt: 3 }}>
          <Alert severity="info" sx={{ mb: 3 }}>
            <Typography variant="body2">
              <strong>BC Lab Systems Supported:</strong>
            </Typography>
            <ul style={{ margin: '8px 0', paddingLeft: '20px' }}>
              <li><strong>Excelleris:</strong> Most common in BC (LifeLabs)</li>
              <li><strong>PathNet:</strong> HL7 v2.3 based systems</li>
              <li><strong>IHA Labs:</strong> Interior Health Authority</li>
            </ul>
            <Typography variant="body2" sx={{ mt: 1 }}>
              Contact your lab provider to get your download credentials.
            </Typography>
          </Alert>

          <Grid container spacing={3}>
            <Grid item xs={12}>
              <FormControl fullWidth required>
                <InputLabel>Lab Provider</InputLabel>
                <Select
                  value={data.provider || 'EXCELLERIS'}
                  onChange={handleChange('provider')}
                  label="Lab Provider"
                >
                  <MenuItem value="EXCELLERIS">Excelleris (LifeLabs)</MenuItem>
                  <MenuItem value="PATHNET">PathNet (HL7)</MenuItem>
                  <MenuItem value="IHA">Interior Health Authority</MenuItem>
                  <MenuItem value="OTHER">Other HL7 Provider</MenuItem>
                </Select>
              </FormControl>
            </Grid>

            <Grid item xs={12}>
              <Typography variant="subtitle2" gutterBottom>
                Lab Download Credentials
              </Typography>
              <Alert severity="warning" size="small" sx={{ mb: 2 }}>
                These are different from your clinic billing credentials.
                Your lab provider will provide these separately.
              </Alert>
            </Grid>

            <Grid item xs={12} sm={6}>
              <TextField
                required
                fullWidth
                label="Lab Username"
                value={data.username || ''}
                onChange={handleChange('username')}
                helperText="Provided by your lab provider"
              />
            </Grid>

            <Grid item xs={12} sm={6}>
              <TextField
                required
                fullWidth
                label="Lab Password"
                type="password"
                value={data.password || ''}
                onChange={handleChange('password')}
                helperText="Keep this secure"
              />
            </Grid>

            {data.provider === 'EXCELLERIS' && (
              <>
                <Grid item xs={12} sm={6}>
                  <TextField
                    fullWidth
                    label="Facility Code"
                    value={data.facilityCode || ''}
                    onChange={handleChange('facilityCode')}
                    helperText="Optional - specific facility identifier"
                  />
                </Grid>
                <Grid item xs={12} sm={6}>
                  <TextField
                    fullWidth
                    label="Group ID"
                    value={data.groupId || ''}
                    onChange={handleChange('groupId')}
                    helperText="Optional - for group practices"
                  />
                </Grid>
              </>
            )}

            <Grid item xs={12}>
              <Typography variant="subtitle2" gutterBottom sx={{ mt: 2 }}>
                Download Settings
              </Typography>
            </Grid>

            <Grid item xs={12} sm={6}>
              <FormControl fullWidth>
                <InputLabel>Download Frequency</InputLabel>
                <Select
                  value={data.downloadFrequency || '15'}
                  onChange={handleChange('downloadFrequency')}
                  label="Download Frequency"
                >
                  <MenuItem value="5">Every 5 minutes</MenuItem>
                  <MenuItem value="15">Every 15 minutes (recommended)</MenuItem>
                  <MenuItem value="30">Every 30 minutes</MenuItem>
                  <MenuItem value="60">Every hour</MenuItem>
                </Select>
              </FormControl>
            </Grid>

            <Grid item xs={12} sm={6}>
              <FormControl fullWidth>
                <InputLabel>Download History</InputLabel>
                <Select
                  value={data.downloadHistory || '7'}
                  onChange={handleChange('downloadHistory')}
                  label="Download History"
                >
                  <MenuItem value="1">Last 24 hours</MenuItem>
                  <MenuItem value="7">Last 7 days (recommended)</MenuItem>
                  <MenuItem value="30">Last 30 days</MenuItem>
                  <MenuItem value="90">Last 90 days</MenuItem>
                </Select>
              </FormControl>
            </Grid>

            <Grid item xs={12}>
              <FormControlLabel
                control={
                  <Switch
                    checked={data.autoAcknowledge || false}
                    onChange={handleChange('autoAcknowledge')}
                  />
                }
                label="Automatically acknowledge downloaded results"
              />
              <Typography variant="caption" color="text.secondary" display="block">
                If enabled, the lab system will be notified when results are successfully downloaded.
              </Typography>
            </Grid>

            <Grid item xs={12}>
              <Alert severity="success">
                <Typography variant="subtitle2" gutterBottom>
                  Once configured, lab results will:
                </Typography>
                <ul style={{ margin: 0, paddingLeft: '20px' }}>
                  <li>Download automatically every {data.downloadFrequency || 15} minutes</li>
                  <li>Appear in provider Document Inbox</li>
                  <li>Be matched to patients automatically (by HIN)</li>
                  <li>Generate alerts for abnormal values</li>
                  <li>Be available for review and filing</li>
                </ul>
              </Alert>
            </Grid>
          </Grid>
        </Box>
      )}
    </Box>
  );
}
