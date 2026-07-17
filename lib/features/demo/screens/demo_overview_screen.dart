import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../inventory/models/inventory_item.dart';
import '../../inventory/services/inventory_service.dart';
import '../widgets/demo_stat_card.dart';


class DemoOverviewScreen extends StatefulWidget {
  const DemoOverviewScreen({super.key});

  @override
  State<DemoOverviewScreen> createState() => _DemoOverviewScreenState();
}

class _DemoOverviewScreenState extends State<DemoOverviewScreen> {
  late final Stream<Map<String, dynamic>> _statsStream;
  late final Stream<Map<String, int>> _categoryStream;
  late final Future<List<InventoryItem>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _statsStream = InventoryService.getDashboardStatsStream();
    _categoryStream = InventoryService.getCategoryStatsStream();
    _itemsFuture = InventoryService.getInventoryItems(limit: 50);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Container(
      color: AppColors.backgroundOf(brightness),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overview',
                style: AppTextStyles.h1(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                )),
            const SizedBox(height: 4),
            Text('Snapshot of your sample inventory — nothing here is saved.',
                style: AppTextStyles.subtitle(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                )),
            const SizedBox(height: AppSpacing.xl),
            _buildStatRow(),
            const SizedBox(height: AppSpacing.xl),
            LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 860;
                final chart = _SectionCard(
                  title: 'Stock Levels by Item',
                  child: SizedBox(height: 280, child: _buildStockLevelsChart()),
                );
                final alerts = _SectionCard(
                  title: 'Stock Alerts',
                  child: _buildStockAlerts(),
                );

                if (stacked) {
                  return Column(
                    children: [
                      chart,
                      const SizedBox(height: AppSpacing.lg),
                      alerts,
                    ],
                  );
                }

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 2, child: chart),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(flex: 1, child: alerts),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            _SectionCard(
              title: 'Items by Category',
              child: _buildCategoryBreakdown(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow() {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _statsStream,
      builder: (context, snapshot) {
        final stats = snapshot.data;
        final totalItems = (stats?['totalItems'] ?? 0) as int;
        final totalValue = (stats?['totalValue'] ?? 0.0) as double;
        final lowStock = (stats?['lowStockItems'] ?? 0) as int;
        final outOfStock = (stats?['outOfStockItems'] ?? 0) as int;

        final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

        return LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth < 560
                ? 2
                : constraints.maxWidth < 900
                    ? 2
                    : 4;
            final aspectRatio = columns == 4 ? 1.7 : 1.4;
            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppSpacing.lg,
              mainAxisSpacing: AppSpacing.lg,
              childAspectRatio: aspectRatio,
              children: [
                DemoStatCard(
                  label: 'Total Items',
                  value: '$totalItems',
                  icon: Icons.inventory_2_outlined,
                  accent: AppColors.info,
                ),
                DemoStatCard(
                  label: 'Total Value',
                  value: currency.format(totalValue),
                  icon: Icons.payments_outlined,
                  accent: AppColors.success,
                ),
                DemoStatCard(
                  label: 'Low Stock',
                  value: '$lowStock',
                  icon: Icons.warning_amber_rounded,
                  accent: AppColors.warning,
                ),
                DemoStatCard(
                  label: 'Out of Stock',
                  value: '$outOfStock',
                  icon: Icons.remove_shopping_cart_outlined,
                  accent: AppColors.danger,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStockLevelsChart() {
    return FutureBuilder<List<InventoryItem>>(
      future: _itemsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data!.take(8).toList();
        if (items.isEmpty) {
          return const Center(child: Text('No inventory items yet'));
        }

        final brightness = Theme.of(context).brightness;
        final maxQty = items.map((i) => i.quantity).reduce((a, b) => a > b ? a : b);

        return BarChart(
          BarChartData(
            maxY: (maxQty * 1.25).clamp(10, double.infinity).toDouble(),
            alignment: BarChartAlignment.spaceAround,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: (maxQty / 4).clamp(1, double.infinity).toDouble(),
              getDrawingHorizontalLine: (value) => FlLine(
                color: AppColors.borderOf(brightness),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => AppColors.surfaceOf(brightness),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final item = items[groupIndex];
                  return BarTooltipItem(
                    '${item.name}\n${item.quantity} units',
                    AppTextStyles.caption(
                      color: brightness == Brightness.dark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (value, _) => Text(
                    value.toInt().toString(),
                    style: AppTextStyles.caption(
                      color: brightness == Brightness.dark
                          ? AppColors.textMutedDark
                          : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  getTitlesWidget: (value, _) {
                    final index = value.toInt();
                    if (index < 0 || index >= items.length) return const SizedBox();
                    final name = items[index].name;
                    final short = name.length > 8 ? '${name.substring(0, 8)}…' : name;
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(short,
                          style: AppTextStyles.caption(
                            color: brightness == Brightness.dark
                                ? AppColors.textMutedDark
                                : AppColors.textMuted,
                          )),
                    );
                  },
                ),
              ),
            ),
            barGroups: items.asMap().entries.map((entry) {
              final item = entry.value;
              final color = item.quantity == 0
                  ? AppColors.danger
                  : item.quantity <= item.reorderLevel
                      ? AppColors.warning
                      : AppColors.success;
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: item.quantity.toDouble(),
                    color: color,
                    width: 18,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildStockAlerts() {
    return FutureBuilder<List<InventoryItem>>(
      future: _itemsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final brightness = Theme.of(context).brightness;
        final isDark = brightness == Brightness.dark;

        final alerts = snapshot.data!
            .where((i) => i.quantity <= i.reorderLevel)
            .toList()
          ..sort((a, b) => a.quantity.compareTo(b.quantity));

        if (alerts.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Column(
              children: [
                Icon(Icons.check_circle_outline, color: AppColors.success, size: 32),
                const SizedBox(height: AppSpacing.sm),
                Text('All items are well stocked',
                    style: AppTextStyles.bodyRegular(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    )),
              ],
            ),
          );
        }

        return Column(
          children: alerts.take(6).map((item) {
            final ratio = item.reorderLevel == 0
                ? 0.0
                : (item.quantity / item.reorderLevel).clamp(0.0, 1.0);
            final color = item.quantity == 0 ? AppColors.danger : AppColors.warning;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name,
                            style: AppTextStyles.bodyMedium(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 5,
                            backgroundColor: AppColors.borderOf(brightness),
                            valueColor: AlwaysStoppedAnimation(color),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text('${item.quantity} left',
                      style: AppTextStyles.caption(color: color)
                          .copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCategoryBreakdown() {
    return StreamBuilder<Map<String, int>>(
      stream: _categoryStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final brightness = Theme.of(context).brightness;
        final isDark = brightness == Brightness.dark;

        final entries = snapshot.data!.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final maxValue = entries.first.value;

        return Column(
          children: entries.asMap().entries.map((mapEntry) {
            final entry = mapEntry.value;
            final color = AppColors.chartSeries[mapEntry.key % AppColors.chartSeries.length];
            final ratio = maxValue == 0 ? 0.0 : entry.value / maxValue;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(entry.key,
                        style: AppTextStyles.bodyRegular(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 8,
                        backgroundColor: AppColors.borderOf(brightness),
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  SizedBox(
                    width: 36,
                    child: Text('${entry.value}',
                        textAlign: TextAlign.right,
                        style: AppTextStyles.bodyMedium(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        )),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

/// Flat, bordered section card shared by the Overview page's chart/list
/// blocks — no elevation, consistent radius/padding via AppSpacing/AppRadius.
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(brightness),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderOf(brightness)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTextStyles.h3(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              )),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}