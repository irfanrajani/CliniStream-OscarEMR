import React from 'react';
import {
  TextField,
  Grid,
  Typography,
  Box,
  Alert
} from '@mui/material';

export default function ClinicDetailsForm({ data, onChange }) {
  const handleChange = (field) => (event) => {
    onChange({ ...data, [field]: event.target.value });
  };

  return (
    <Box>
      <Typography variant="h5" gutterBottom>
        Clinic Information
      </Typography>
      <Typography variant="body2" color="text.secondary" paragraph>
        Enter your clinic details. This information will appear on prescriptions, forms, and the login page.
      </Typography>

      <Alert severity="info" sx={{ mb: 3 }}>
        You can change these details later in the OSCAR admin settings.
      </Alert>

      <Grid container spacing={3}>
        <Grid item xs={12}>
          <TextField
            required
            fullWidth
            label="Clinic Name"
            value={data.name || ''}
            onChange={handleChange('name')}
            placeholder="NextScript Medical Clinic"
            helperText="This will appear in the browser tab and on documents"
          />
        </Grid>

        <Grid item xs={12}>
          <TextField
            required
            fullWidth
            label="Street Address"
            value={data.address || ''}
            onChange={handleChange('address')}
            placeholder="123 Main Street"
          />
        </Grid>

        <Grid item xs={12} sm={6}>
          <TextField
            required
            fullWidth
            label="City"
            value={data.city || ''}
            onChange={handleChange('city')}
            placeholder="Victoria"
          />
        </Grid>

        <Grid item xs={12} sm={3}>
          <TextField
            required
            fullWidth
            label="Province"
            value={data.province || 'BC'}
            onChange={handleChange('province')}
            disabled
            helperText="BC only (configured)"
          />
        </Grid>

        <Grid item xs={12} sm={3}>
          <TextField
            required
            fullWidth
            label="Postal Code"
            value={data.postal || ''}
            onChange={handleChange('postal')}
            placeholder="V8W 1A1"
          />
        </Grid>

        <Grid item xs={12} sm={6}>
          <TextField
            required
            fullWidth
            label="Phone"
            value={data.phone || ''}
            onChange={handleChange('phone')}
            placeholder="(250) 555-1234"
            type="tel"
          />
        </Grid>

        <Grid item xs={12} sm={6}>
          <TextField
            fullWidth
            label="Fax"
            value={data.fax || ''}
            onChange={handleChange('fax')}
            placeholder="(250) 555-1235"
            type="tel"
            helperText="Optional - can configure RingCentral eFax later"
          />
        </Grid>

        <Grid item xs={12} sm={6}>
          <TextField
            required
            fullWidth
            label="Email"
            value={data.email || ''}
            onChange={handleChange('email')}
            placeholder="clinic@nextscript.ca"
            type="email"
          />
        </Grid>

        <Grid item xs={12} sm={6}>
          <TextField
            fullWidth
            label="Website"
            value={data.website || ''}
            onChange={handleChange('website')}
            placeholder="https://www.nextscript.ca"
            type="url"
            helperText="Optional"
          />
        </Grid>
      </Grid>
    </Box>
  );
}
