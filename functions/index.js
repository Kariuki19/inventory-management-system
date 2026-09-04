const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

admin.initializeApp();

exports.onNewConsultation = functions.firestore
  .document('consultations/{docId}')
  .onCreate(async (snap, context) => {
    const data = snap.data() || {};

    const salesEmail = functions.config().sales && functions.config().sales.email;
    if (!salesEmail) {
      console.error('No sales.email configured in functions config. Set it with: firebase functions:config:set sales.email="your@email.com"');
      return null;
    }

    const gmailUser = functions.config().gmail && functions.config().gmail.user;
    const gmailPass = functions.config().gmail && functions.config().gmail.pass;

    if (!gmailUser || !gmailPass) {
      console.error('No gmail credentials found in functions config. Set with: firebase functions:config:set gmail.user="you@gmail.com" gmail.pass="app-password"');
      return null;
    }

    const transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: gmailUser,
        pass: gmailPass,
      },
    });

    const submittedAt = data.submittedAt && data.submittedAt.toDate ? data.submittedAt.toDate() : data.submittedAt;

    const bodyLines = [
      `Name: ${data.name || 'N/A'}`,
      `Email: ${data.email || 'N/A'}`,
      `Phone: ${data.phone || 'N/A'}`,
      `Company: ${data.companyName || 'N/A'}`,
      `Business Type: ${data.businessType || 'N/A'}`,
      `Role: ${data.role || 'N/A'}`,
      `Timeline: ${data.timeline || 'N/A'}`,
      `Preferred Contact: ${Array.isArray(data.preferredContact) ? data.preferredContact.join(', ') : (data.preferredContact || 'N/A')}`,
      `Submitted At: ${submittedAt || 'N/A'}`,
      `Source: ${data.source || 'N/A'}`,
    ];

    const mailOptions = {
      from: gmailUser,
      to: salesEmail,
      subject: `New StockSense Consultation Request — ${data.companyName || 'Unknown Company'}`,
      text: bodyLines.join('\n'),
    };

    try {
      await transporter.sendMail(mailOptions);
      console.log('Consultation notification email sent to', salesEmail);
    } catch (err) {
      console.error('Error sending consultation email:', err);
    }

    return null;
  });
