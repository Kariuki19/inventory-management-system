import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/config/demo_constants.dart';
import '../features/inventory/services/analytics_service.dart';
import '../features/inventory/services/demo_service.dart';
import '../core/utils/consultation_utils.dart';
import '../features/demo/screens/demo_workspace_screen.dart';
import '../features/onboarding/screens/landing_screen.dart';
import 'upgrade_plan_screen.dart';
import 'demo_expired_screen.dart';

class DemoExitedScreen extends StatefulWidget {
  final DemoEndedReason demoEndReason;

  const DemoExitedScreen({
    super.key,
    this.demoEndReason = DemoEndedReason.manualExit,
  });

  @override
  State<DemoExitedScreen> createState() => _DemoExitedScreenState();
}

class _DemoExitedScreenState extends State<DemoExitedScreen> {
  final AnalyticsService _analytics = AnalyticsService();
  static const Color _orange = Color(0xFFF97316);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _analytics.logDemoEndedScreenViewed('manualExit');
    });
  }

  String _formatRemainingTime(Duration duration) {
    if (duration <= Duration.zero) {
      return '0 minutes';
    }

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '$hours hour${hours == 1 ? '' : 's'} $minutes minute${minutes == 1 ? '' : 's'}';
    } else {
      return '$minutes minute${minutes == 1 ? '' : 's'}';
    }
  }

  Future<void> _openFeedbackForm() async {
    _analytics.logFeedbackFormOpened('manualExit');

    const feedbackFormUrl = DemoConstants.feedbackFormUrl;

    try {
      final uri = Uri.parse(feedbackFormUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
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

  Future<void> _resumeDemo() async {
    final isExpired = await DemoService.isSessionExpired();
    if (isExpired) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const DemoExpiredScreen(
            demoEndReason: DemoEndedReason.timeExpired,
          ),
        ),
      );
      return;
    }

    _analytics.logDemoResumed();
    final resumed = await DemoService.resumeSession();
    if (!mounted) return;

    if (!resumed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not resume your demo session.'),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const DemoWorkspaceScreen(),
      ),
    );
  }

  Widget _buildTimeBadge(BuildContext context) {
    return FutureBuilder<Duration>(
      future: DemoService.getRemainingTime(),
      builder: (context, snapshot) {
        final label = snapshot.hasData
            ? '⏱ ${_formatRemainingTime(snapshot.data!)} left in your demo'
            : '⏱ Loading remaining time…';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _orange.withOpacity(0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: _orange.withOpacity(0.16),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _orange,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon: exit/door arrow, orange, in soft orange circle (130x130, ~12% opacity fill)
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: _orange.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout,
                    size: 64,
                    color: _orange,
                  ),
                ),
                const SizedBox(height: 32),

                // Headline
                Text(
                  "You've Exited the Demo",
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Body
                Text(
                  'You left your demo session early. Your remaining time is saved — pick up right where you left off, or explore a plan to unlock full access.',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: const Color(0xFF666666),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Time Remaining Badge
                _buildTimeBadge(context),
                const SizedBox(height: 48),

                // Primary CTA: "Resume Demo" (filled orange, height 54px, radius 14px)
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _resumeDemo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Resume Demo',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Secondary CTA: "View Plans & Upgrade" (outlined orange, height 54px, radius 14px, 1.5 side)
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: _handleViewPlans,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _orange,
                      side: const BorderSide(color: _orange, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
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

                // Talk to Sales Link
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

                // Feedback button (non-blocking, optional action, grey with small icon)
                TextButton.icon(
                  onPressed: _openFeedbackForm,
                  icon: const Icon(
                    Icons.feedback_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                  label: Text(
                    'Send Feedback',
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Back to Home Link (light grey)
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
      ),
    );
  }
}