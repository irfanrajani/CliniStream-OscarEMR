import React from 'react';
import {
  Typography,
  Box,
  Alert,
  Paper,
  Grid,
  Chip,
  List,
  ListItem,
  ListItemIcon,
  ListItemText,
  Divider
} from '@mui/material';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import WarningIcon from '@mui/icons-material/Warning';
import InfoIcon from '@mui/icons-material/Info';
import LocalHospitalIcon from '@mui/icons-material/LocalHospital';
import FaxIcon from '@mui/icons-material/Fax';
import SmsIcon from '@mui/icons-material/Sms';
import SendIcon from '@mui/icons-material/Send';
import ScienceIcon from '@mui/icons-material/Science';

export default function CompletionStep({ clinic, billing, ringcentral, ocean, labs }) {
  const configured = {
    clinic: !!clinic.name,
    billing: !!billing.payeeNumber,
    ringcentral: ringcentral.enabled && !!ringcentral.clientId,
    ocean: ocean.enabled && !!ocean.siteId,
    labs: labs.downloadEnabled && !!labs.username
  };

  const allConfigured = Object.values(configured).every(v => v);

  return (
    <Box>
      <Typography variant="h5" gutterBottom>
        Setup Summary
      </Typography>
      <Typography variant="body2" color="text.secondary" paragraph>
        Review your configuration before completing setup.
      </Typography>

      <Grid container spacing={3}>
        {/* Configuration Status */}
        <Grid item xs={12}>
          <Paper sx={{ p: 3 }}>
            <Typography variant="h6" gutterBottom>
              Configuration Status
            </Typography>

            <List>
              <ListItem>
                <ListItemIcon>
                  {configured.clinic ? <CheckCircleIcon color="success" /> : <WarningIcon color="warning" />}
                </ListItemIcon>
                <ListItemText
                  primary="Clinic Details"
                  secondary={configured.clinic ? clinic.name : 'Not configured'}
                />
                {configured.clinic && <Chip label="Configured" color="success" size="small" />}
              </ListItem>

              <Divider />

              <ListItem>
                <ListItemIcon>
                  {configured.billing ? <CheckCircleIcon color="success" /> : <WarningIcon color="warning" />}
                </ListItemIcon>
                <ListItemText
                  primary="BC Teleplan Billing"
                  secondary={configured.billing ? `Payee: ${billing.payeeNumber}` : 'Not configured'}
                />
                {configured.billing && <Chip label="Configured" color="success" size="small" />}
              </ListItem>

              <Divider />

              <ListItem>
                <ListItemIcon>
                  <FaxIcon color={configured.ringcentral ? 'success' : 'disabled'} />
                </ListItemIcon>
                <ListItemText
                  primary="RingCentral eFax & SMS"
                  secondary={configured.ringcentral ? 'Enabled and configured' : ringcentral.enabled ? 'Enabled but not configured' : 'Disabled'}
                />
                {configured.ringcentral && <Chip label="Enabled" color="success" size="small" />}
                {!ringcentral.enabled && <Chip label="Skipped" size="small" />}
              </ListItem>

              <Divider />

              <ListItem>
                <ListItemIcon>
                  <SendIcon color={configured.ocean ? 'success' : 'disabled'} />
                </ListItemIcon>
                <ListItemText
                  primary="OceanMD eReferral"
                  secondary={configured.ocean ? 'Enabled and configured' : ocean.enabled ? 'Enabled but not configured' : 'Disabled'}
                />
                {configured.ocean && <Chip label="Enabled" color="success" size="small" />}
                {!ocean.enabled && <Chip label="Skipped" size="small" />}
              </ListItem>

              <Divider />

              <ListItem>
                <ListItemIcon>
                  <ScienceIcon color={configured.labs ? 'success' : 'disabled'} />
                </ListItemIcon>
                <ListItemText
                  primary="Laboratory Integration"
                  secondary={configured.labs ? `${labs.provider} - Auto-download enabled` : labs.downloadEnabled ? 'Enabled but not configured' : 'Disabled'}
                />
                {configured.labs && <Chip label="Enabled" color="success" size="small" />}
                {!labs.downloadEnabled && <Chip label="Skipped" size="small" />}
              </ListItem>
            </List>
          </Paper>
        </Grid>

        {/* Next Steps */}
        <Grid item xs={12}>
          {allConfigured ? (
            <Alert severity="success" icon={<CheckCircleIcon />}>
              <Typography variant="subtitle1" gutterBottom>
                <strong>All systems configured!</strong>
              </Typography>
              <Typography variant="body2">
                Click "Complete Setup" to finish. Your OSCAR EMR will be ready to use.
              </Typography>
            </Alert>
          ) : (
            <Alert severity="warning" icon={<WarningIcon />}>
              <Typography variant="subtitle1" gutterBottom>
                <strong>Some integrations not configured</strong>
              </Typography>
              <Typography variant="body2">
                You can proceed with setup and configure these later in OSCAR Settings.
              </Typography>
            </Alert>
          )}
        </Grid>

        {/* Access Information */}
        <Grid item xs={12}>
          <Paper sx={{ p: 3, bgcolor: 'primary.light', color: 'primary.contrastText' }}>
            <Typography variant="h6" gutterBottom>
              <LocalHospitalIcon sx={{ verticalAlign: 'middle', mr: 1 }} />
              Access Information
            </Typography>

            <Grid container spacing={2} sx={{ mt: 1 }}>
              <Grid item xs={12} md={6}>
                <Typography variant="subtitle2" gutterBottom>
                  OSCAR EMR URL:
                </Typography>
                <Typography variant="body1" sx={{ fontFamily: 'monospace', bgcolor: 'rgba(0,0,0,0.2)', p: 1, borderRadius: 1 }}>
                  https://your-domain.com
                </Typography>
                <Typography variant="caption" display="block" sx={{ mt: 0.5 }}>
                  (via Cloudflare, port 8567)
                </Typography>
              </Grid>

              <Grid item xs={12} md={6}>
                <Typography variant="subtitle2" gutterBottom>
                  Default Login:
                </Typography>
                <Typography variant="body2" sx={{ fontFamily: 'monospace', bgcolor: 'rgba(0,0,0,0.2)', p: 1, borderRadius: 1 }}>
                  Username: oscardoc<br />
                  Password: mac2002<br />
                  PIN: 1117
                </Typography>
                <Alert severity="error" sx={{ mt: 1 }}>
                  <strong>Change this password immediately after first login!</strong>
                </Alert>
              </Grid>
            </Grid>
          </Paper>
        </Grid>

        {/* Important Notes */}
        <Grid item xs={12}>
          <Alert severity="info" icon={<InfoIcon />}>
            <Typography variant="subtitle2" gutterBottom>
              After setup completes:
            </Typography>
            <ul style={{ margin: '8px 0', paddingLeft: '20px' }}>
              <li>Add provider billing numbers in Administration → Billing</li>
              <li>Configure staff accounts in Administration → Admin</li>
              <li>Customize forms and templates in Administration → Forms</li>
              <li>Update integrations anytime in Administration → NextScript Settings</li>
              <li>Review security settings in Administration → Security</li>
            </ul>
          </Alert>
        </Grid>

        {/* Clinic Summary */}
        {configured.clinic && (
          <Grid item xs={12}>
            <Paper sx={{ p: 2 }}>
              <Typography variant="subtitle2" gutterBottom>
                Clinic Information:
              </Typography>
              <Typography variant="body2">
                {clinic.name}<br />
                {clinic.address}<br />
                {clinic.city}, {clinic.province} {clinic.postal}<br />
                Phone: {clinic.phone}<br />
                {clinic.fax && <>Fax: {clinic.fax}<br /></>}
                Email: {clinic.email}
                {clinic.website && <><br />Website: {clinic.website}</>}
              </Typography>
            </Paper>
          </Grid>
        )}
      </Grid>
    </Box>
  );
}
