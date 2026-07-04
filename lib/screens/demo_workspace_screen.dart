import 'package:flutter/material.dart';
import '../services/inventory_service.dart';
import '../services/demo_service.dart' as demo_service;
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
    if (await demo_service.DemoService.isSessionExpired()) {
      if (mounted) _redirectToExpired(demo_service.DemoEndedReason.timeExpired);
      return;
    }

    await demo_service.DemoService.startSession();
    InventoryService.isDemoMode = true;
    _analytics.logDemoStarted();

    if (mounted) {
      setState(() => _sessionReady = true);
    }
  }

  void _redirectToExpired(demo_service.DemoEndedReason reason) {
    /// Double-trigger protection: If timer expires at exact same moment as manual exit,
    /// this guard ensures only ONE redirect happens, preventing navigation stack issues.
    if (_expiredHandled) return;
    _expiredHandled = true;

    InventoryService.isDemoMode = false;

    // Show brief toast before navigation to make the transition less abrupt
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

    await demo_service.DemoService.clearSession(
      reason: demo_service.DemoEndedReason.timeExpired,
    );
    if (mounted) _redirectToExpired(demo_service.DemoEndedReason.timeExpired);
  }

  /// Show confirmation dialog for manual exit
  Future<void> _showExitConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit demo mode?'),
          content: const Text('You can restart anytime.'),
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
    _analytics.logDemoExitClicked();
    await demo_service.DemoService.clearSession(
      reason: demo_service.DemoEndedReason.manualExit,
    );

    if (mounted) {
      _redirectToExpired(demo_service.DemoEndedReason.manualExit);
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
            getRemainingTime: demo_service.DemoService.getRemainingTime,
            onExpired: _handleDemoExpired,
            message: 'Free demo — data is not saved',
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
