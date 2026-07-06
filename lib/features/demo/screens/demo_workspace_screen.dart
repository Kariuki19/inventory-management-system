import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../inventory/services/inventory_service.dart';
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
    InventoryService.isDemoMode = true;
  }

  @override
  void dispose() {
    InventoryService.isDemoMode = false;
    super.dispose();
  }

  void _exitDemo() {
    Navigator.of(context).pop();
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
                  onExitDemo: _exitDemo,
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
              onExitDemo: _exitDemo,
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
