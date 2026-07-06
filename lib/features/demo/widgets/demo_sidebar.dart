import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/screens/widget_tree.dart';

class DemoNavItem {
  final IconData icon;
  final String label;

  const DemoNavItem({required this.icon, required this.label});
}

const List<DemoNavItem> demoNavItems = [
  DemoNavItem(icon: Icons.grid_view_rounded, label: 'Overview'),
  DemoNavItem(icon: Icons.inventory_2_outlined, label: 'Inventory'),
  DemoNavItem(icon: Icons.swap_horiz_rounded, label: 'Stock Movements'),
  DemoNavItem(icon: Icons.trending_up_rounded, label: 'Predictions'),
  DemoNavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
];

/// Left sidebar navigation for the demo workspace, styled after the flat,
/// bordered sidebar pattern in the design references (no gradients/heavy
/// shadows). Reused for both the permanent desktop rail and the mobile
/// Drawer — pass [onNavigate] to close the drawer after a tap on mobile.
class DemoSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onExitDemo;
  final VoidCallback? onNavigate;

  const DemoSidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    required this.onExitDemo,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Container(
      width: 248,
      color: AppColors.surfaceOf(brightness),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(Icons.inventory_2, color: Colors.white, size: 18),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text('StockSense',
                      style: AppTextStyles.h3(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      )),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('DEMO',
                      style: AppTextStyles.caption(color: AppColors.primaryDark)
                          .copyWith(fontSize: 10, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.borderOf(brightness)),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('MAIN',
                  style: AppTextStyles.caption(
                    color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                  ).copyWith(letterSpacing: 0.6)),
            ),
          ),
          ...List.generate(demoNavItems.length, (index) {
            final item = demoNavItems[index];
            final selected = index == selectedIndex;
            return Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: 2),
              child: Material(
                color: selected ? AppColors.primarySurface : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  onTap: () {
                    onSelect(index);
                    onNavigate?.call();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: 10),
                    child: Row(
                      children: [
                        Icon(item.icon,
                            size: 19,
                            color: selected
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary)),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            item.label,
                            style: AppTextStyles.navLabel(
                              color: selected
                                  ? AppColors.primary
                                  : (isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary),
                            ).copyWith(
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          Divider(height: 1, color: AppColors.borderOf(brightness)),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primarySurface,
                      child: Text('DA',
                          style: AppTextStyles.caption(color: AppColors.primaryDark)
                              .copyWith(fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Demo Admin',
                              style: AppTextStyles.bodyMedium(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                              )),
                          Text('Sandbox session',
                              style: AppTextStyles.caption(
                                color: isDark
                                    ? AppColors.textMutedDark
                                    : AppColors.textMuted,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const WidgetTree()),
                      (route) => false,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                    child: Text('Sign Up Free', style: AppTextStyles.buttonLabel()),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: onExitDemo,
                    icon: const Icon(Icons.logout, size: 16),
                    label: const Text('Exit Demo'),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      textStyle: AppTextStyles.navLabel(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
