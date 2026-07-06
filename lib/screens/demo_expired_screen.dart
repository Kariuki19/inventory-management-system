import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/utils/consultation_utils.dart';
import '../features/inventory/services/analytics_service.dart';
import '../features/inventory/services/demo_service.dart';
import '../features/onboarding/screens/landing_screen.dart';
import 'upgrade_plan_screen.dart';

class DemoExpiredScreen extends StatefulWidget {
  /// Optional parameter indicating why the demo ended
  /// Used only for analytics/logging, not for UI changes
  final DemoEndedReason? demoEndReason;

  const DemoExpiredScreen({
    super.key,
    this.demoEndReason = DemoEndedReason.timeExpired,
  });

  @override
  State<DemoExpiredScreen> createState() => _DemoExpiredScreenState();
}

class _DemoExpiredScreenState extends State<DemoExpiredScreen> {
  final AnalyticsService _analytics = AnalyticsService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logDemoEndedScreenViewed();
    });
  }

  void _logDemoEndedScreenViewed() {
    final reason =
        widget.demoEndReason?.toString().split('.').last ?? 'unknown';
    _analytics.logDemoEndedScreenViewed(reason);
  }

  Future<void> _openFeedbackForm() async {
    final reason =
        widget.demoEndReason?.toString().split('.').last ?? 'unknown';
    _analytics.logFeedbackFormOpened(reason);

    const feedbackFormUrl =
        'https://docs.google.com/forms/d/e/1FAIpQLScdS8WHJ_WW-vAoVjOUTQrJcog4kQo6MZhb3MqC9fOCq3la7g/viewform?usp=header';

    try {
      final uri = Uri.parse(feedbackFormUrl);
      // Check if URL can be launched
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // URL cannot be launched - show error to user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open feedback form. Please try again.'),
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error opening feedback form: $e');
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error opening feedback form'),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleViewPlans() {
    _analytics.logViewPlansClicked();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const UpgradePlanScreen(
          title: 'Upgrade to Continue',
          subtitle: 'Pick a plan that works for you — no credit card required.',
        ),
      ),
    );
  }

  void _handleTalkToSales() {
    _analytics.logTalkToSalesClicked();
    ConsultationUtils.showConsultationDialog(context);
  }

  void _handleBackToHome() {
    _analytics.logBackToHomeClicked();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LandingScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                // Timer icon in soft orange circle
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

                // Headline - consistent for all demo end paths
                Text(
                  'Your Demo Has Ended',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Subtext - consistent for all demo end paths
                Text(
                  'Your interactive demo session has expired. Choose a plan to continue using Cloudora.',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: const Color(0xFF666666),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Primary CTA: "View Plans & Upgrade"
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleViewPlans,
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

                // Secondary CTA: "Talk to Sales"
                TextButton(
                  onPressed: _handleTalkToSales,
                  child: Text(
                    'Talk to Sales',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF666666),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Feedback button (non-blocking, optional action)
                TextButton(
                  onPressed: _openFeedbackForm,
                  child: Text(
                    'Send Feedback',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF666666),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // "Back to Home" button
                TextButton(
                  onPressed: _handleBackToHome,
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

