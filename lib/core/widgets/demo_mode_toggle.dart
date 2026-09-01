import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/demo_mode_provider.dart';

/// Toggle switch to switch between Live Mode and Demo Mode
/// Can be placed in Navbar or Settings
class DemoModeToggle extends StatelessWidget {
  const DemoModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DemoModeProvider>(
      builder: (context, demoModeProvider, child) {
        final isDemoMode = demoModeProvider.isDemoMode;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isDemoMode ? 'Demo' : 'Live',
              style: TextStyle(
                color: isDemoMode ? Colors.orange : Colors.green,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Switch(
              value: isDemoMode,
              onChanged: (value) async {
                await demoModeProvider.setDemoMode(value);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        value
                            ? 'Switched to Demo Mode - Read-only'
                            : 'Switched to Live Mode - Full access',
                      ),
                      duration: const Duration(seconds: 2),
                      backgroundColor: value ? Colors.orange : Colors.green,
                    ),
                  );
                }
              },
              activeColor: Colors.orange,
              inactiveThumbColor: Colors.green,
              inactiveTrackColor: Colors.green.shade200,
            ),
          ],
        );
      },
    );
  }
}
