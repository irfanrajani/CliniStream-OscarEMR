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
  MenuItem
} from '@mui/material';

export default function BillingConfigForm({ data, onChange }) {
  const handleChange = (field) => (event) => {
    onChange({ ...data, [field]: event.target.value });
  };

  return (
    <Box>
      <Typography variant="h5" gutterBottom>
        BC Teleplan Billing Configuration
      </Typography>
      <Typography variant="body2" color="text.secondary" paragraph>
        Configure your BC MSP billing details. You'll need your payee number and group number from BC Teleplan.
      </Typography>

      <Alert severity="warning" sx={{ mb: 3 }}>
        <strong>Important:</strong> These settings are required for electronic billing submission to BC MSP Teleplan.
        If you don't have these numbers yet, you can configure them later in Settings.
      </Alert>

      <Grid container spacing={3}>
        <Grid item xs={12} sm={6}>
          <TextField
            required
            fullWidth
            label="Payee Number"
            value={data.payeeNumber || ''}
            onChange={handleChange('payeeNumber')}
            placeholder="12345"
            helperText="Your BC MSP payee number (5 digits)"
            inputProps={{ maxLength: 5, pattern: '[0-9]*' }}
          />
        </Grid>

        <Grid item xs={12} sm={6}>
          <TextField
            fullWidth
            label="Group Number"
            value={data.groupNumber || ''}
            onChange={handleChange('groupNumber')}
            placeholder="G1234"
            helperText="Optional - only if part of a group"
            inputProps={{ maxLength: 5 }}
          />
        </Grid>

        <Grid item xs={12} sm={6}>
          <FormControl fullWidth required>
            <InputLabel>Billing Location</InputLabel>
            <Select
              value={data.billingLocation || 'VICTORIA'}
              onChange={handleChange('billingLocation')}
              label="Billing Location"
            >
              <MenuItem value="VICTORIA">Victoria</MenuItem>
              <MenuItem value="VANCOUVER">Vancouver</MenuItem>
              <MenuItem value="SURREY">Surrey</MenuItem>
              <MenuItem value="BURNABY">Burnaby</MenuItem>
              <MenuItem value="RICHMOND">Richmond</MenuItem>
              <MenuItem value="KELOWNA">Kelowna</MenuItem>
              <MenuItem value="KAMLOOPS">Kamloops</MenuItem>
              <MenuItem value="NANAIMO">Nanaimo</MenuItem>
              <MenuItem value="PRINCE_GEORGE">Prince George</MenuItem>
              <MenuItem value="OTHER">Other</MenuItem>
            </Select>
          </FormControl>
        </Grid>

        <Grid item xs={12} sm={6}>
          <TextField
            required
            fullWidth
            label="Data Center ID"
            value={data.dataCenter || '00000'}
            onChange={handleChange('dataCenter')}
            placeholder="00000"
            helperText="Usually 00000 for most clinics"
            inputProps={{ maxLength: 5, pattern: '[0-9]*' }}
          />
        </Grid>

        <Grid item xs={12}>
          <Alert severity="info">
            <Typography variant="body2">
              <strong>Testing:</strong> Use BC Teleplan's test environment first before production.
              <br />
              Test URL: <code>https://tlpt2.moh.hnet.bc.ca/TeleplanBroker</code>
              <br />
              Production URL: <code>https://teleplan.hnet.bc.ca/TeleplanBroker</code>
            </Typography>
          </Alert>
        </Grid>

        <Grid item xs={12}>
          <Typography variant="subtitle2" gutterBottom>
            Additional Billing Information
          </Typography>
        </Grid>

        <Grid item xs={12} sm={6}>
          <FormControl fullWidth>
            <InputLabel>Default Visit Type</InputLabel>
            <Select
              value={data.visitType || 'Clinic Visit'}
              onChange={handleChange('visitType')}
              label="Default Visit Type"
            >
              <MenuItem value="Clinic Visit">Clinic Visit</MenuItem>
              <MenuItem value="Hospital Visit">Hospital Visit</MenuItem>
              <MenuItem value="Home Visit">Home Visit</MenuItem>
              <MenuItem value="Nursing Home">Nursing Home</MenuItem>
              <MenuItem value="Telephone">Telephone Consultation</MenuItem>
            </Select>
          </FormControl>
        </Grid>

        <Grid item xs={12} sm={6}>
          <FormControl fullWidth>
            <InputLabel>Visit Location Type</InputLabel>
            <Select
              value={data.visitLocation || 'A'}
              onChange={handleChange('visitLocation')}
              label="Visit Location Type"
            >
              <MenuItem value="A">A - Practitioner's Office in Community</MenuItem>
              <MenuItem value="B">B - Patient's Home</MenuItem>
              <MenuItem value="C">C - Long Term Care Facility</MenuItem>
              <MenuItem value="E">E - Emergency Department</MenuItem>
              <MenuItem value="H">H - Hospital Inpatient</MenuItem>
              <MenuItem value="K">K - Telehealth</MenuItem>
            </Select>
          </FormControl>
        </Grid>
      </Grid>
    </Box>
  );
}
