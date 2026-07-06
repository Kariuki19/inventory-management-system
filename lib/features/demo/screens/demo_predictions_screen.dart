import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart' as custom_date_utils;
import '../../inventory/services/inventory_service.dart';
import '../../predictions/models/stock_prediction.dart';

class _Urgency {
  final String label;
  final Color color;
  final IconData icon;

  const _Urgency(this.label, this.color, this.icon);
}

_Urgency _urgencyOf(int daysLeft) {
  if (daysLeft <= 0) return const _Urgency('OUT OF STOCK', AppColors.danger, Icons.error_outline);
  if (daysLeft <= 3) return const _Urgency('CRITICAL', AppColors.danger, Icons.error_outline);
  if (daysLeft <= 7) return const _Urgency('URGENT', AppColors.warning, Icons.warning_amber_rounded);
  if (daysLeft <= 14) return const _Urgency('MODERATE', AppColors.info, Icons.schedule);
  return const _Urgency('GOOD', AppColors.success, Icons.check_circle_outline);
}

Color _confidenceColor(PredictionConfidence confidence) {
  switch (confidence) {
    case PredictionConfidence.high:
      return AppColors.success;
    case PredictionConfidence.medium:
      return AppColors.warning;
    case PredictionConfidence.low:
      return AppColors.danger;
  }
}

String _confidenceLabel(PredictionConfidence confidence) {
  switch (confidence) {
    case PredictionConfidence.high:
      return 'High';
    case PredictionConfidence.medium:
      return 'Medium';
    case PredictionConfidence.low:
      return 'Low';
  }
}

/// Flat, bordered predictions page for the demo shell — no elevation, no
/// gradients, built entirely from the central AppColors/AppTextStyles
/// tokens. Mirrors the real PredictionsScreen's data/urgency logic but
/// drops the Firestore-pagination plumbing since the demo dataset is small
/// and already fully returned by MockInventoryService in one call.
class DemoPredictionsScreen extends StatefulWidget {
  const DemoPredictionsScreen({super.key});

  @override
  State<DemoPredictionsScreen> createState() => _DemoPredictionsScreenState();
}

class _DemoPredictionsScreenState extends State<DemoPredictionsScreen> {
  String _searchQuery = '';
  PredictionConfidence? _selectedConfidence;
  bool _urgentOnly = false;

  List<StockPrediction> _predictions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final predictions = await InventoryService.getStockPredictions(limit: 50);
      predictions.sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
      if (!mounted) return;
      setState(() {
        _predictions = predictions;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final filtered = _predictions.where((p) {
      if (_searchQuery.isNotEmpty &&
          !p.itemName.toLowerCase().contains(_searchQuery)) {
        return false;
      }
      if (_selectedConfidence != null && p.confidence != _selectedConfidence) {
        return false;
      }
      if (_urgentOnly && p.daysLeft > 7) return false;
      return true;
    }).toList();

    return Container(
      color: AppColors.backgroundOf(brightness),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(brightness),
            const SizedBox(height: AppSpacing.xl),
            _buildFilters(brightness),
            const SizedBox(height: AppSpacing.lg),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 64),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              _buildErrorState(brightness)
            else if (filtered.isEmpty)
              _buildEmptyState(brightness)
            else
              _buildGrid(filtered, brightness),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Predictions',
                  style: AppTextStyles.h1(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  )),
              const SizedBox(height: 4),
              Text('AI-powered restock forecasts for your sample inventory.',
                  style: AppTextStyles.subtitle(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  )),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => _showStatusGuide(brightness),
          icon: const Icon(Icons.help_outline, size: 18),
          label: const Text('Status Guide'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
            textStyle: AppTextStyles.bodyMedium(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(brightness),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderOf(brightness)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            style: AppTextStyles.bodyRegular(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Search items by name...',
              hintStyle: AppTextStyles.bodyRegular(
                color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
              ),
              prefixIcon: Icon(Icons.search,
                  size: 20, color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
              filled: true,
              fillColor: isDark ? AppColors.backgroundDark : AppColors.background,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide(color: AppColors.borderOf(brightness)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide(color: AppColors.borderOf(brightness)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _filterChip('All', _selectedConfidence == null,
                  () => setState(() => _selectedConfidence = null), brightness),
              for (final confidence in PredictionConfidence.values)
                _filterChip(
                  _confidenceLabel(confidence),
                  _selectedConfidence == confidence,
                  () => setState(() => _selectedConfidence = confidence),
                  brightness,
                ),
              const SizedBox(width: AppSpacing.md),
              _filterChip('Urgent only (≤ 7 days)', _urgentOnly,
                  () => setState(() => _urgentOnly = !_urgentOnly), brightness),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return Material(
      color: selected ? AppColors.primarySurface : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.borderOf(brightness),
            ),
          ),
          child: Text(label,
              style: AppTextStyles.caption(
                color: selected
                    ? AppColors.primaryDark
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
              ).copyWith(fontWeight: selected ? FontWeight.w600 : FontWeight.w500)),
        ),
      ),
    );
  }

  Widget _buildGrid(List<StockPrediction> predictions, Brightness brightness) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 1300
            ? 3
            : constraints.maxWidth > 820
                ? 2
                : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: AppSpacing.lg,
            mainAxisSpacing: AppSpacing.lg,
            childAspectRatio: columns == 1 ? 2.6 : 1.9,
          ),
          itemCount: predictions.length,
          itemBuilder: (context, index) => _buildCard(predictions[index], brightness),
        );
      },
    );
  }

  Widget _buildCard(StockPrediction prediction, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final urgency = _urgencyOf(prediction.daysLeft);
    final confidenceColor = _confidenceColor(prediction.confidence);
    final stockPercent = prediction.currentQuantity <= 0
        ? 0.0
        : (prediction.daysLeft / 30).clamp(0.05, 1.0);
    final daysLabel = prediction.currentQuantity <= 0
        ? 'Out of stock'
        : custom_date_utils.DateUtils.formatDaysDifference(prediction.daysLeft);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(brightness),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderOf(brightness)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(prediction.itemName,
                        style: AppTextStyles.h3(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        _badge(urgency.label, urgency.color),
                        _badge(_confidenceLabel(prediction.confidence), confidenceColor),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(urgency.icon, color: urgency.color, size: 16),
                      const SizedBox(width: 4),
                      Text(daysLabel,
                          style: AppTextStyles.bodyMedium(color: urgency.color)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('${prediction.currentQuantity} units',
                      style: AppTextStyles.caption(
                        color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                      )),
                ],
              ),
            ],
          ),
          const Spacer(),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: stockPercent,
              minHeight: 6,
              backgroundColor: AppColors.borderOf(brightness),
              valueColor: AlwaysStoppedAnimation(urgency.color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: AppTextStyles.caption(color: color).copyWith(fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildEmptyState(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl * 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(brightness),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderOf(brightness)),
      ),
      child: Column(
        children: [
          Icon(Icons.analytics_outlined,
              size: 40, color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
          const SizedBox(height: AppSpacing.md),
          Text('No predictions match your filters',
              style: AppTextStyles.bodyMedium(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              )),
        ],
      ),
    );
  }

  Widget _buildErrorState(Brightness brightness) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(brightness),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderOf(brightness)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 40, color: AppColors.danger),
          const SizedBox(height: AppSpacing.md),
          Text('Couldn\'t load predictions', style: AppTextStyles.bodyMedium()),
          const SizedBox(height: AppSpacing.sm),
          Text(_error ?? '', style: AppTextStyles.caption()),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(
            onPressed: _load,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showStatusGuide(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceOf(brightness),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text('Prediction Status Guide',
            style: AppTextStyles.h3(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            )),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _guideRow('CRITICAL', '≤ 3 days', AppColors.danger,
                  'Immediate action required — place an order now.'),
              _guideRow('URGENT', '4–7 days', AppColors.warning,
                  'High priority — order soon.'),
              _guideRow('MODERATE', '8–14 days', AppColors.info,
                  'Plan restocking within the next couple of weeks.'),
              _guideRow('GOOD', '15+ days', AppColors.success,
                  'Stock levels are healthy.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it', style: AppTextStyles.bodyMedium(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _guideRow(String label, String timeframe, Color color, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 3),
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(label, style: AppTextStyles.bodyMedium(color: color)),
                    const SizedBox(width: AppSpacing.sm),
                    Text(timeframe, style: AppTextStyles.caption(color: color)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(description, style: AppTextStyles.caption()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
