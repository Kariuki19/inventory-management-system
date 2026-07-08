import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/utils/consultation_utils.dart';
import '../features/onboarding/screens/landing_screen.dart';

class UpgradePlanScreen extends StatelessWidget {
  final String title;
  final String subtitle;

  const UpgradePlanScreen({
    super.key,
    this.title = 'Choose Your Plan',
    this.subtitle =
        'Unlock full access to Cloudora Inventory Management. No credit card required to start your free trial.',
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black87),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Upgrade Plan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : const Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: isDarkMode ? Colors.white60 : const Color(0xFF666666),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _PlanCard(
              title: 'Basic',
              price: 'KES 5,200 / mo',
              description: 'Small shops & boutiques',
              isHighlight: false,
              isDarkMode: isDarkMode,
              onSelect: () => ConsultationUtils.showConsultationDialog(context, plan: 'Basic'),
            ),
            const SizedBox(height: 16),
            _PlanCard(
              title: 'Pro',
              price: 'KES 13,000 / mo',
              description: 'Growing SMEs — most popular',
              isHighlight: true,
              isDarkMode: isDarkMode,
              onSelect: () => ConsultationUtils.showConsultationDialog(context, plan: 'Pro'),
            ),
            const SizedBox(height: 16),
            _PlanCard(
              title: 'Premium',
              price: 'KES 48,750 / mo',
              description: 'Retail chains & multi-location',
              isHighlight: false,
              isDarkMode: isDarkMode,
              onSelect: () => ConsultationUtils.showConsultationDialog(context, plan: 'Premium'),
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LandingScreen()),
                  (_) => false,
                );
              },
              child: Text(
                'Back to Home',
                style: GoogleFonts.poppins(
                  color: isDarkMode ? Colors.white54 : const Color(0xFF666666),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String description;
  final bool isHighlight;
  final bool isDarkMode;
  final VoidCallback onSelect;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.description,
    required this.isHighlight,
    required this.isDarkMode,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlight
              ? const Color(0xFFFF6B00)
              : (isDarkMode ? Colors.white24 : const Color(0xFFEEEEEE)),
          width: isHighlight ? 2 : 1,
        ),
        boxShadow: isHighlight
            ? [
                BoxShadow(
                  color: const Color(0xFFFF6B00).withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isHighlight)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B00).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Recommended',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFF6B00),
                ),
              ),
            ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFF6B00),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDarkMode ? Colors.white60 : const Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSelect,
              style: ElevatedButton.styleFrom(
                backgroundColor: isHighlight ? const Color(0xFFFF6B00) : null,
                foregroundColor: isHighlight ? Colors.white : const Color(0xFFFF6B00),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'Contact Sales',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
