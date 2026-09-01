import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/demo_mode_provider.dart';

/// Utility functions for Demo Mode
class DemoModeUtils {
  /// Show a toast notification when an action is blocked in Demo Mode
  static void showBlockedActionToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demo Mode is read-only. Action cannot be saved.'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Check if demo mode is active and show toast if action is blocked
  static bool checkAndBlockAction(BuildContext context) {
    final demoModeProvider = Provider.of<DemoModeProvider>(context, listen: false);
    if (demoModeProvider.isDemoMode) {
      showBlockedActionToast(context);
      return true; // Action is blocked
    }
    return false; // Action is not blocked
  }
}

/// Wrapper widget that disables child widget in Demo Mode
/// Shows a tooltip explaining why it's disabled
class DemoModeDisabledWrapper extends StatelessWidget {
  final Widget child;
  final String? customTooltip;

  const DemoModeDisabledWrapper({
    super.key,
    required this.child,
    this.customTooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DemoModeProvider>(
      builder: (context, demoModeProvider, child) {
        if (!demoModeProvider.isDemoMode) {
          return child;
        }

        return Tooltip(
          message: customTooltip ?? 'Disabled in Demo Mode',
          child: AbsorbPointer(
            child: Opacity(
              opacity: 0.5,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

/// Helper widget to conditionally disable buttons in Demo Mode
class DemoModeAwareButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final ButtonStyle? style;
  final bool? enabled;

  const DemoModeAwareButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DemoModeProvider>(
      builder: (context, demoModeProvider, child) {
        final isDemoMode = demoModeProvider.isDemoMode;
        final isEnabled = enabled != false && !isDemoMode;

        return ElevatedButton(
          onPressed: isEnabled
              ? () {
                  if (isDemoMode) {
                    DemoModeUtils.showBlockedActionToast(context);
                  } else {
                    onPressed();
                  }
                }
              : null,
          style: style,
          child: child,
        );
      },
      child: child,
    );
  }
}
