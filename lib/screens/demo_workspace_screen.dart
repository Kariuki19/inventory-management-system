import 'package:flutter/material.dart';
import '../services/inventory_service.dart';
import '../services/demo_service.dart';
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

  @override
  void initState() {
    super.initState();
    _initDemoSession();
  }

  Future<void> _initDemoSession() async {
    if (await DemoService.isSessionExpired()) {
      if (mounted) _redirectToExpired();
      return;
    }

    await DemoService.startSession();
    InventoryService.isDemoMode = true;

    if (mounted) {
      setState(() => _sessionReady = true);
    }
  }

  void _redirectToExpired() {
    InventoryService.isDemoMode = false;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const DemoExpiredScreen(
          reason: DemoExpiryReason.guestSession,
        ),
      ),
    );
  }

  Future<void> _handleDemoExpired() async {
    await DemoService.clearSession();
    if (mounted) _redirectToExpired();
  }

  void _exitDemo() {
    Navigator.of(context).pop();
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
            onExit: _exitDemo,
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
