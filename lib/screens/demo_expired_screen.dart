import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/consultation_utils.dart';
import 'auth/login_register_page.dart';
import 'landing_screen.dart';
import 'upgrade_plan_screen.dart';

enum DemoExpiryReason { guestSession, authenticatedTrial }

class DemoExpiredScreen extends StatelessWidget {
  final DemoExpiryReason reason;

  const DemoExpiredScreen({
    super.key,
    this.reason = DemoExpiryReason.guestSession,
  });

  @override
  Widget build(BuildContext context) {
    final isGuest = reason == DemoExpiryReason.guestSession;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B00).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.timer_off_outlined,
                    size: 64,
                    color: Color(0xFFFF6B00),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  isGuest ? 'Your Demo Has Ended' : 'Your Free Trial Has Ended',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  isGuest
                      ? 'Your interactive demo session has expired. Sign up for a free 14-day trial or choose a plan to continue using Cloudora.'
                      : 'We hope you enjoyed Cloudora. Upgrade to a paid plan to keep managing your inventory without interruption.',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: const Color(0xFF666666),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => UpgradePlanScreen(
                            title: isGuest ? 'Upgrade to Continue' : 'Choose Your Plan',
                            subtitle: isGuest
                                ? 'Pick a plan or start your free trial — no credit card required.'
                                : 'Select a plan to restore full access to your workspace.',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B00),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'View Plans & Upgrade',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const LoginPage(startWithRegister: true),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFF6B00),
                      side: const BorderSide(color: Color(0xFFFF6B00)),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Start 14-Day Free Trial',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => ConsultationUtils.showConsultationDialog(context),
                  child: Text(
                    'Talk to Sales',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF666666),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
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
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
