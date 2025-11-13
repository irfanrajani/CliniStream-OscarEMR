# NextScript Integration Bridge Files

These JSP files act as a bridge between OSCAR EMR and the NextScript integration service.

## Files

- `sendFax.jsp` - Send faxes via RingCentral
- `sendSMS.jsp` - Send SMS messages via RingCentral
- `oceanReferral.jsp` - Create eReferrals via OceanMD

## Usage from OSCAR

### Send Fax
```javascript
fetch('/oscar/integrations/sendFax.jsp', {
    method: 'POST',
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: `to=+17785551234&documentPath=/path/to/document.pdf&coverPage=Patient Referral`
});
```

### Send SMS
```javascript
fetch('/oscar/integrations/sendSMS.jsp', {
    method: 'POST',
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: `to=+17785551234&message=Your appointment is tomorrow at 2pm`
});
```

## Installation

These files are automatically copied to the OSCAR webapp during container build.

## Configuration

The integration service URL defaults to `http://integrations:8080` but can be overridden with the `INTEGRATION_SERVICE_URL` environment variable.
