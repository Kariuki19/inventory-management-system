import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';

/// Flat top bar shared by every page in the demo shell: page title, a
/// decorative search field (matches the reference designs), and a theme
/// toggle. Shows a menu button on narrow layouts to open the nav drawer.
class DemoTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuTap;

  const DemoTopBar({super.key, required this.title, this.onMenuTap});

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final showSearch = MediaQuery.of(context).size.width >= 700;

    return SafeArea(
      child: Container(
        height: preferredSize.height,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceOf(brightness),
          border: Border(bottom: BorderSide(color: AppColors.borderOf(brightness))),
        ),
        child: Row(
          children: [
            if (onMenuTap != null) ...[
              IconButton(
                onPressed: onMenuTap,
                icon: Icon(Icons.menu,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Flexible(
              child: Text(title,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h2(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  )),
            ),
            if (showSearch) ...[
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: TextField(
                    enabled: false,
                    style: AppTextStyles.bodyRegular(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search inventory...',
                      hintStyle: AppTextStyles.bodyRegular(
                        color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                      ),
                      prefixIcon: Icon(Icons.search,
                          size: 20,
                          color:
                              isDark ? AppColors.textMutedDark : AppColors.textMuted),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.backgroundDark
                          : AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        borderSide: BorderSide(color: AppColors.borderOf(brightness)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        borderSide: BorderSide(color: AppColors.borderOf(brightness)),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        borderSide: BorderSide(color: AppColors.borderOf(brightness)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            const Spacer(),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) => IconButton(
                tooltip: themeProvider.isDarkMode ? 'Switch to light theme' : 'Switch to dark theme',
                onPressed: themeProvider.toggleTheme,
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
