import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/demo_mode_provider.dart';

/// Prominent banner displayed when Demo Mode is active
/// Shows across the top of the app to indicate read-only state
class DemoModeBanner extends StatelessWidget {
  const DemoModeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DemoModeProvider>(
      builder: (context, demoModeProvider, child) {
        if (!demoModeProvider.isDemoMode) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          color: Colors.orange.shade600,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.visibility,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Text(
                'DEMO MODE ACTIVE — Browsing read-only sample inventory',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
