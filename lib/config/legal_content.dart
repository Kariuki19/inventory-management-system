import 'contact_config.dart';

class LegalSection {
  final String heading;
  final String body;
  const LegalSection(this.heading, this.body);
}

class LegalDoc {
  final String title;
  final List<LegalSection> sections;
  const LegalDoc({required this.title, required this.sections});
}

/// Plain-language pages describing what the demo does today.
/// Cloudora (and a lawyer) must review and approve this text before launch.
class LegalContent {
  static const String lastUpdated = 'November 2026';

  static const LegalDoc privacy = LegalDoc(
    title: 'Privacy notice',
    sections: [
      LegalSection('What this notice covers',
          'This notice explains what the StockSense demo stores and why. The demo lets you explore StockSense without creating an account.'),
      LegalSection('What we store',
          'When you start the demo we create an anonymous workspace for you. We do not ask for your name, email address or phone number to start. We store the items, stock movements, photos and settings you enter, a technical identifier for your anonymous account, and the time your demo started. The start time is also kept in your browser so that the one-hour period continues if you leave and come back.'),
      LegalSection('Sample data',
          'Your workspace begins with a fictional sample shop so you can try the app. It is not real data and you can clear it at any time.'),
      LegalSection('Where it is stored',
          'Workspace data is stored on Google Firebase services operated for Cloudora.'),
      LegalSection('Information you choose to send us',
          'If you use the feedback form or ask for a consultation or an upgrade, we receive the details you submit and use them to reply to you. The feedback form is hosted by Google Forms.'),
      LegalSection('Your choices',
          'You can edit or delete your items and clear the sample data at any time inside the app. To ask a question about your demo data, or to ask for it to be deleted, contact us at ${ContactConfig.email}.'),
      LegalSection('Changes',
          'We may update this notice. The date at the top of the page shows when it was last changed.'),
    ],
  );

  static const LegalDoc terms = LegalDoc(
    title: 'Demo terms',
    sections: [
      LegalSection('The demo',
          'The StockSense demo lasts one hour from the moment you start it and is meant for evaluation, one demo per business.'),
      LegalSection('Sample data and your data',
          'The sample shop is fictional. Please do not treat the demo workspace as your only record of your stock. Before the demo ends you can download your items and stock history as CSV files.'),
      LegalSection('Upgrading',
          'StockSense is a monthly subscription with Basic, Pro and Premium plans, priced in US dollars by team size. A one-time deployment fee of 20% of your monthly plan covers setup and onboarding. To keep using StockSense, choose a plan and our team will contact you to set up your account. Final terms are confirmed when you upgrade.'),
      LegalSection('Fair use',
          'Please use the demo for genuine evaluation and do not try to disrupt or misuse the service.'),
      LegalSection('Availability',
          'The demo is provided for evaluation and may change or be unavailable from time to time.'),
      LegalSection('Contact',
          'Questions about the demo or these terms: ${ContactConfig.email}.'),
    ],
  );
}
