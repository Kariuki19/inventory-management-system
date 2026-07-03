import 'package:flutter/material.dart';
import '../services/inventory_service.dart';
import '../services/demo_service.dart';
import '../services/analytics_service.dart';
import '../widgets/demo_countdown_banner.dart';
import 'demo_expired_screen.dart';
import 'home_page.dart';

class DemoWorkspaceScreen extends StatefulWidget {
  const DemoWorkspaceScreen({super.key});

  @override
  State<DemoWorkspaceScreen> createState() => _DemoWorkspaceScreenState();
}

class _DemoWorkspaceScreenState extends State<DemoWorkspaceScreen> {
  bool _sessionReady = false;
  bool _isExiting = false;
  bool _expiredHandled = false;
  final AnalyticsService _analytics = AnalyticsService();

  @override
  void initState() {
    super.initState();
    _initDemoSession();
  }

  Future<void> _initDemoSession() async {
    if (await DemoService.isSessionExpired()) {
      if (mounted) _redirectToExpired(DemoEndedReason.timeExpired);
      return;
    }

    await DemoService.startSession();
    InventoryService.isDemoMode = true;
    _analytics.logDemoStarted();

    if (mounted) {
      setState(() => _sessionReady = true);
    }
  }

  void _redirectToExpired(DemoEndedReason reason) {
    if (_expiredHandled) return;
    _expiredHandled = true;

    InventoryService.isDemoMode = false;

    // Show brief toast before navigation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Your demo session has expired'),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );

    if (mounted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => DemoExpiredScreen(
                reason: DemoExpiryReason.guestSession,
                demoEndReason: reason,
              ),
            ),
          );
        }
      });
    }
  }

  Future<void> _handleDemoExpired() async {
    if (_expiredHandled || _isExiting) return;

    await DemoService.clearSession(reason: DemoEndedReason.timeExpired);
    if (mounted) _redirectToExpired(DemoEndedReason.timeExpired);
  }

  /// Show confirmation dialog for manual exit
  Future<void> _showExitConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit Demo Mode?'),
          content: const Text('You can restart the demo anytime from the home screen.'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFF6B00),
              ),
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _exitDemo();
    }
  }

  /// Handle manual exit from demo
  Future<void> _exitDemo() async {
    if (_isExiting || _expiredHandled) return;

    _isExiting = true;
    _expiredHandled = true;

    InventoryService.isDemoMode = false;
    await DemoService.clearSession(reason: DemoEndedReason.manualExit);

    if (mounted) {
      _redirectToExpired(DemoEndedReason.manualExit);
    }
  }

  @override
  void dispose() {
    InventoryService.isDemoMode = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_sessionReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          DemoCountdownBanner(
            getRemainingTime: DemoService.getRemainingTime,
            onExpired: _handleDemoExpired,
            message: 'Free demo — data is not saved',
            onExit: _showExitConfirmation,
          ),
          const Expanded(
            child: ClipRect(
              child: HomePage(),
            ),
          ),
        ],
      ),
    );
  }
}
