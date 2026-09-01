import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';

/// Flat stat card used on the demo Overview page: icon badge, big value,
/// label, and a thin trend sparkline. No elevation/shadow — a 1px border
/// on a flat surface, matching the "no gradients, clean" brief.
class DemoStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final List<double> trendData;

  const DemoStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    this.trendData = const [],
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight;
        final padding = maxHeight < 100 ? AppSpacing.sm : AppSpacing.md;
        final spacing = maxHeight < 100 ? 4.0 : AppSpacing.sm;
        final iconSize = maxHeight < 100 ? 16.0 : 20.0;
        final sparklineHeight = maxHeight < 100 ? 16.0 : 24.0;

        return Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: AppColors.surfaceOf(Theme.of(context).brightness),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.borderOf(Theme.of(context).brightness)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(maxHeight < 100 ? 4 : AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(icon, color: accent, size: iconSize),
                  ),
                  if (trendData.isNotEmpty && trendData.any((v) => v > 0))
                    SizedBox(width: 56, height: sparklineHeight, child: _sparkline()),
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        style: AppTextStyles.statValue(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ).copyWith(
                          fontSize: maxHeight < 100 ? 18.0 : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: spacing / 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        label,
                        style: AppTextStyles.caption(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ).copyWith(
                          fontSize: maxHeight < 100 ? 10.0 : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sparkline() {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        minY: trendData.reduce((a, b) => a < b ? a : b) * 0.85,
        maxY: trendData.reduce((a, b) => a > b ? a : b) * 1.15,
        lineBarsData: [
          LineChartBarData(
            spots: trendData
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value))
                .toList(),
            isCurved: true,
            color: accent,
            barWidth: 1.6,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}
