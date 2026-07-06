import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../features/inventory/services/analytics_service.dart';
import '../features/inventory/services/demo_service.dart';
import '../core/utils/consultation_utils.dart';
import '../features/demo/screens/demo_workspace_screen.dart';
import '../features/onboarding/screens/landing_screen.dart';
import 'upgrade_plan_screen.dart';

class DemoExitedScreen extends StatelessWidget {
  final DemoEndedReason? demoEndReason;

  const DemoExitedScreen({
    super.key,
    this.demoEndReason = DemoEndedReason.manualExit,
  });

  static const Color _blue = Color(0xFF3B82F6);

  String _reasonString() {
    return demoEndReason?.toString().split('.').last ?? 'manualExit';
  }

  String _formatRemainingTime(Duration duration) {
    if (duration <= Duration.zero) {
      return 'Less than 1 minute';
    }

    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    final parts = <String>[];

    if (days > 0) {
      parts.add('$days day${days == 1 ? '' : 's'}');
      if (hours > 0) {
        parts.add('$hours hour${hours == 1 ? '' : 's'}');
      }
    } else if (hours > 0) {
      parts.add('$hours hour${hours == 1 ? '' : 's'}');
      if (minutes > 0) {
        parts.add('$minutes minute${minutes == 1 ? '' : 's'}');
      }
    } else {
      if (minutes > 0) {
        parts.add('$minutes minute${minutes == 1 ? '' : 's'}');
      } else {
        parts.add('Less than 1 minute');
      }
    }

    return parts.join(' ');
  }

  Future<void> _openFeedbackForm(BuildContext context) async {
    final reason = _reasonString();
    AnalyticsService().logFeedbackFormOpened(reason);

    const feedbackFormUrl =
        'https://docs.google.com/forms/d/e/1FAIpQLScdS8WHJ_WW-vAoVjOUTQrJcog4kQo6MZhb3MqC9fOCq3la7g/viewform?usp=header';

    try {
      final uri = Uri.parse(feedbackFormUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open feedback form. Please try again.'),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error opening feedback form: $e');
      if (context.mounted) {
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

  void _handleViewPlans(BuildContext context) {
    AnalyticsService().logViewPlansClicked();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const UpgradePlanScreen(
          title: 'Upgrade to Continue',
          subtitle: 'Pick a plan that works for you — no credit card required.',
        ),
      ),
    );
  }

  void _handleTalkToSales(BuildContext context) {
    AnalyticsService().logTalkToSalesClicked();
    ConsultationUtils.showConsultationDialog(context);
  }

  void _handleBackToHome(BuildContext context) {
    AnalyticsService().logBackToHomeClicked();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LandingScreen()),
      (_) => false,
    );
  }

  Future<void> _resumeDemo(BuildContext context) async {
    final resumed = await DemoService.resumeSession();
    if (!context.mounted) return;

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
            color: const Color(0xFFFF6B00).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: const Color(0xFFFF6B00).withValues(alpha: 0.16),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _blue,
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B00).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout,
                    size: 64,
                    color: Color(0xFFFF6B00),
                  ),
                ),
                const SizedBox(height: 32),
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
                _buildTimeBadge(context),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => _resumeDemo(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B00),
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
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () => _handleViewPlans(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFF6B00),
                      side: const BorderSide(color: Color(0xFFFF6B00), width: 1.5),
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
                TextButton(
                  onPressed: () => _handleTalkToSales(context),
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
                  onPressed: () => _openFeedbackForm(context),
                  child: Text(
                    'Send Feedback',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF666666),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _handleBackToHome(context),
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