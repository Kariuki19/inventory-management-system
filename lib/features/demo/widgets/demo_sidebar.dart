import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/consultation_utils.dart';
import '../../../screens/demo_exited_screen.dart';
import '../../inventory/services/demo_service.dart';

class DemoNavItem {
  final IconData icon;
  final String label;

  const DemoNavItem({required this.icon, required this.label});
}

const List<DemoNavItem> demoNavItems = [
  DemoNavItem(icon: Icons.grid_view_rounded, label: 'Overview'),
  DemoNavItem(icon: Icons.inventory_2_outlined, label: 'Inventory'),
  DemoNavItem(icon: Icons.swap_horiz_rounded, label: 'Stock Movements'),
  DemoNavItem(icon: Icons.assessment_rounded, label: 'Reports'),
  DemoNavItem(icon: Icons.trending_up_rounded, label: 'Predictions'),
  DemoNavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
];

/// Left sidebar navigation for the demo workspace, styled after the flat,
/// bordered sidebar pattern in the design references (no gradients/heavy
/// shadows). Reused for both the permanent desktop rail and the mobile
/// Drawer — pass [onNavigate] to close the drawer after a tap on mobile.
class DemoSidebar extends StatefulWidget {
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
  State<DemoSidebar> createState() => _DemoSidebarState();
}

class _DemoSidebarState extends State<DemoSidebar> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
    });
  }

  Future<void> _updateRemaining() async {
    final remaining = await DemoService.getRemainingTime();
    if (mounted) {
      setState(() {
        _remaining = remaining;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final sidebarWidth = (screenWidth * 0.8).clamp(248.0, 320.0);

    return Container(
      width: sidebarWidth,
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('DEMO',
                      style: AppTextStyles.caption(color: Colors.white)
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
            final selected = index == widget.selectedIndex;
            return Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: 4),
              child: Material(
                color: selected ? AppColors.primarySurface : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  onTap: () {
                    widget.onSelect(index);
                    widget.onNavigate?.call();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: 12),
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
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 12,
                                color: _remaining.inMinutes < 15
                                    ? AppColors.danger
                                    : (isDark
                                        ? AppColors.primaryLight
                                        : AppColors.primary),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DemoService.formatDuration(_remaining),
                                style: GoogleFonts.robotoMono(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _remaining.inMinutes < 15
                                      ? AppColors.danger
                                      : (isDark
                                          ? AppColors.primaryLight
                                          : AppColors.primary),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => ConsultationUtils.showConsultationDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                    child: Text('Get started', style: AppTextStyles.buttonLabel()),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const DemoExitedScreen()),
                    ),
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
