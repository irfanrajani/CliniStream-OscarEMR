import React, { useState, useEffect } from 'react';
import { Container, Stepper, Step, StepLabel, Button, Box, Typography, Alert } from '@mui/material';
import ClinicDetailsForm from './steps/ClinicDetailsForm';
import BillingConfigForm from './steps/BillingConfigForm';
import RingCentralForm from './steps/RingCentralForm';
import OceanForm from './steps/OceanForm';
import LabsForm from './steps/LabsForm';
import CompletionStep from './steps/CompletionStep';

const steps = [
  'Clinic Details',
  'BC Billing',
  'RingCentral',
  'OceanMD',
  'Labs',
  'Complete'
];

export default function App() {
  const [activeStep, setActiveStep] = useState(0);
  const [setupComplete, setSetupComplete] = useState(false);
  const [error, setError] = useState(null);

  const [clinicData, setClinicData] = useState({});
  const [billingData, setBillingData] = useState({});
  const [ringcentralData, setRingcentralData] = useState({});
  const [oceanData, setOceanData] = useState({});
  const [labsData, setLabsData] = useState({});

  useEffect(() => {
    // Check if setup is already complete
    fetch('/api/setup-status')
      .then(res => res.json())
      .then(data => {
        if (data.complete) {
          setSetupComplete(true);
        }
      });
  }, []);

  const handleNext = async () => {
    try {
      setError(null);

      // Save current step data
      if (activeStep === 0) {
        await fetch('/api/setup/clinic', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(clinicData)
        });
      } else if (activeStep === 1) {
        await fetch('/api/setup/billing', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(billingData)
        });
      } else if (activeStep === 2) {
        if (ringcentralData.enabled) {
          await fetch('/api/setup/ringcentral', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(ringcentralData)
          });
        }
      } else if (activeStep === 3) {
        if (oceanData.enabled) {
          await fetch('/api/setup/ocean', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(oceanData)
          });
        }
      } else if (activeStep === 4) {
        if (labsData.downloadEnabled) {
          await fetch('/api/setup/labs', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(labsData)
          });
        }
      } else if (activeStep === 5) {
        // Complete setup
        await fetch('/api/setup/complete', { method: 'POST' });
        setSetupComplete(true);
        return;
      }

      setActiveStep(prev => prev + 1);
    } catch (err) {
      setError(err.message);
    }
  };

  const handleBack = () => {
    setActiveStep(prev => prev - 1);
  };

  if (setupComplete) {
    return (
      <Container maxWidth="md" sx={{ mt: 8 }}>
        <Alert severity="success">
          <Typography variant="h5">Setup Complete!</Typography>
          <Typography sx={{ mt: 2 }}>
            Your NextScript OSCAR EMR is ready to use.
          </Typography>
          <Typography sx={{ mt: 1 }}>
            Access OSCAR at: <strong>http://your-server:8080/oscar</strong>
          </Typography>
          <Typography>
            Default login: oscardoc / mac2002 / PIN: 1117
          </Typography>
          <Typography color="error" sx={{ mt: 1 }}>
            Please change this password immediately!
          </Typography>
        </Alert>
      </Container>
    );
  }

  return (
    <Container maxWidth="md" sx={{ mt: 4, mb: 4 }}>
      <Typography variant="h3" align="center" gutterBottom>
        NextScript OSCAR EMR
      </Typography>
      <Typography variant="h6" align="center" color="text.secondary" gutterBottom>
        First-Run Setup Wizard
      </Typography>

      <Stepper activeStep={activeStep} sx={{ mt: 4, mb: 4 }}>
        {steps.map((label) => (
          <Step key={label}>
            <StepLabel>{label}</StepLabel>
          </Step>
        ))}
      </Stepper>

      {error && (
        <Alert severity="error" sx={{ mb: 2 }}>
          {error}
        </Alert>
      )}

      <Box sx={{ mt: 4 }}>
        {activeStep === 0 && (
          <ClinicDetailsForm data={clinicData} onChange={setClinicData} />
        )}
        {activeStep === 1 && (
          <BillingConfigForm data={billingData} onChange={setBillingData} />
        )}
        {activeStep === 2 && (
          <RingCentralForm data={ringcentralData} onChange={setRingcentralData} />
        )}
        {activeStep === 3 && (
          <OceanForm data={oceanData} onChange={setOceanData} />
        )}
        {activeStep === 4 && (
          <LabsForm data={labsData} onChange={setLabsData} />
        )}
        {activeStep === 5 && (
          <CompletionStep
            clinic={clinicData}
            billing={billingData}
            ringcentral={ringcentralData}
            ocean={oceanData}
            labs={labsData}
          />
        )}
      </Box>

      <Box sx={{ display: 'flex', justifyContent: 'space-between', mt: 4 }}>
        <Button
          disabled={activeStep === 0}
          onClick={handleBack}
        >
          Back
        </Button>
        <Button
          variant="contained"
          onClick={handleNext}
        >
          {activeStep === steps.length - 1 ? 'Complete Setup' : 'Next'}
        </Button>
      </Box>
    </Container>
  );
}
