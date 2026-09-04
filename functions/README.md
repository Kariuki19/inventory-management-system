Cloud Functions for StockSense

Setup:

- Set the sales email address and Gmail credentials for sending email:

```bash
firebase functions:config:set sales.email="sales@yourcompany.com" gmail.user="you@gmail.com" gmail.pass="your-app-password"
```

- Deploy functions with:

```bash
cd functions
firebase deploy --only functions
```

Notes:
- This function uses Nodemailer with Gmail SMTP. Use an App Password for Gmail when 2FA is enabled.
- The function logs errors on failure and does not rethrow to avoid retry storms.
