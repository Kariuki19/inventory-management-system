import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/demo_mode_provider.dart';
import '../../../screens/demo_expired_screen.dart';
import '../../../screens/demo_exited_screen.dart';
import '../../inventory/services/inventory_service.dart';
import '../../inventory/services/demo_service.dart';
import '../../inventory/services/analytics_service.dart';
import '../../auth/services/auth_service.dart';
import '../../inventory/screens/inventory_list_screen.dart';
import '../../stock/screens/stock_movements_screen.dart';
import '../widgets/demo_sidebar.dart';
import '../widgets/demo_top_bar.dart';
import 'demo_overview_screen.dart';
import 'demo_predictions_screen.dart';
import 'demo_profile_screen.dart';

const double _sidebarBreakpoint = 900;

class DemoWorkspaceScreen extends StatefulWidget {
  const DemoWorkspaceScreen({super.key});

  @override
  State<DemoWorkspaceScreen> createState() => _DemoWorkspaceScreenState();
}

class _DemoWorkspaceScreenState extends State<DemoWorkspaceScreen> {
  int _selectedIndex = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _expiredHandled = false;
  final AnalyticsService _analytics = AnalyticsService();
  Timer? _sessionTimer;

  // Gates building the demo pages until anonymous sign-in has actually
  // completed. Without this, DemoOverviewScreen (and friends) fire their
  // Firestore reads in initState() before AuthService.currentUser exists,
  // hit "User not authenticated", and — for stream-based stats — get stuck
  // on a permanently-frozen zero value with no retry.
  bool _demoReady = false;

  // Set if anonymous sign-in itself fails (e.g. Anonymous auth disabled in
  // Firebase Console). Shown as an always-visible banner so this is
  // debuggable from the device alone, without needing adb/log access.
  String? _authErrorMessage;

  final _pages = const [
    DemoOverviewScreen(),
    InventoryListScreen(),
    StockMovementsScreen(),
    DemoPredictionsScreen(),
    DemoProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _analytics.logDemoStarted();

    // Set demo mode via provider
    _initDemoSession();

    // Start periodic check for expiration
    _startSessionTimer();
  }

  Future<void> _initDemoSession() async {
    // Set demo mode to true via provider
    final demoModeProvider = Provider.of<DemoModeProvider>(context, listen: false);
    await demoModeProvider.setDemoMode(true);

    // Sign in anonymously if we don't already have an authenticated user.
    // This gives InventoryService an `isAnonymous` user to key off of, so
    // reads route to the shared, pre-seeded demo dataset rather than
    // failing with "User not authenticated".
    if (AuthService.currentUser == null) {
      try {
        await AuthService.signInAnonymously();
      } catch (e) {
        // Surface this instead of swallowing it — a failure here (most
        // commonly: Anonymous sign-in not enabled in Firebase Console under
        // Authentication > Sign-in method) means every demo screen will
        // fail with "User not authenticated", which is confusing to debug
        // without this line pointing at the actual cause.
        debugPrint('Demo mode anonymous sign-in failed: $e');
        _authErrorMessage = 'Demo sign-in failed: $e';
      }
    }

    // Start the demo session timer
    await DemoService.startSession();

    // Only now let the demo pages mount and fire their Firestore reads —
    // AuthService.currentUser is guaranteed to be set (or sign-in genuinely
    // failed, in which case the pages' own error states will show).
    if (mounted) {
      setState(() => _demoReady = true);
    }
  }

  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _checkSessionExpiration();
    });
  }

  Future<void> _checkSessionExpiration() async {
    final remaining = await DemoService.getRemainingTime();
    if (remaining <= Duration.zero && !_expiredHandled) {
      _handleDemoExpired();
    }
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    // Turn off demo mode when exiting demo workspace
    final demoModeProvider = Provider.of<DemoModeProvider>(context, listen: false);
    demoModeProvider.setDemoMode(false);
    super.dispose();
  }

  void _handleDemoExpired() async {
    await DemoService.clearSession(reason: DemoEndedReason.timeExpired);
    if (mounted) {
      _redirectToExpired(DemoEndedReason.timeExpired);
    }
  }

  void _redirectToExpired(DemoEndedReason reason) {
    if (_expiredHandled) return;
    _expiredHandled = true;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your demo session has expired'),
        duration: Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => DemoExpiredScreen(demoEndReason: reason),
          ),
        );
      }
    });
  }

  void _showExitConfirmation() {
    _analytics.logDemoExitClicked();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit demo mode?'),
          content: const Text('You can restart anytime.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _exitDemo();
              },
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
  }

  void _exitDemo() async {
    _analytics.logDemoExitConfirmed();
    await DemoService.pauseSession();
    if (mounted) {
      _redirectToExited();
    }
  }

  void _redirectToExited() {
    if (_expiredHandled) return;
    _expiredHandled = true;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const DemoExitedScreen(),
      ),
    );
  }

  Widget _buildAuthErrorBanner() {
    if (_authErrorMessage == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      color: Colors.red.shade900,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        _authErrorMessage!,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    if (!_demoReady) {
      return Scaffold(
        backgroundColor: AppColors.backgroundOf(brightness),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= _sidebarBreakpoint;

        if (isWide) {
          return Scaffold(
            backgroundColor: AppColors.backgroundOf(brightness),
            body: Row(
              children: [
                DemoSidebar(
                  selectedIndex: _selectedIndex,
                  onSelect: (index) => setState(() => _selectedIndex = index),
                  onExitDemo: _showExitConfirmation,
                ),
                Expanded(
                  child: Column(
                    children: [
                      DemoTopBar(title: demoNavItems[_selectedIndex].label),
                      _buildAuthErrorBanner(),
                      Expanded(
                        child: IndexedStack(index: _selectedIndex, children: _pages),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.backgroundOf(brightness),
          drawer: Drawer(
            child: DemoSidebar(
              selectedIndex: _selectedIndex,
              onSelect: (index) => setState(() => _selectedIndex = index),
              onExitDemo: _showExitConfirmation,
              onNavigate: () => Navigator.of(context).pop(),
            ),
          ),
          appBar: DemoTopBar(
            title: demoNavItems[_selectedIndex].label,
            onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          body: Column(
            children: [
              _buildAuthErrorBanner(),
              Expanded(child: IndexedStack(index: _selectedIndex, children: _pages)),
            ],
          ),
        );
      },
    );
  }
}
