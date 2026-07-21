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

    // Start the demo session timer
    await DemoService.startSession();
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

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

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
          body: IndexedStack(index: _selectedIndex, children: _pages),
        );
      },
    );
  }
}
