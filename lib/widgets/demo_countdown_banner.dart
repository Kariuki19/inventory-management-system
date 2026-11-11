import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/trial_service.dart';
import 'upgrade_widgets.dart';

/// Live countdown for the one-hour demo, with an Upgrade button.
class DemoCountdownBanner extends StatefulWidget {
  const DemoCountdownBanner({super.key});

  @override
  State<DemoCountdownBanner> createState() => _DemoCountdownBannerState();
}

class _DemoCountdownBannerState extends State<DemoCountdownBanner> {
  Timer? _ticker;
  DateTime? _endsAt;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final remaining = await TrialService.getRemaining();
    if (!mounted) return;
    setState(() => _endsAt = DateTime.now().add(remaining));
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final endsAt = _endsAt;
    if (endsAt == null) return const SizedBox.shrink();

    var left = endsAt.difference(DateTime.now());
    if (left.isNegative) left = Duration.zero;
    final ended = left == Duration.zero;
    final warning = left <= const Duration(minutes: 10);
    final color = warning ? const Color(0xFFFF4D4D) : const Color(0xFFFF6B00);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_outlined, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ended
                  ? 'Your demo has ended'
                  : 'Demo time left: ${_format(left)}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => UpgradeSheet.show(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: const Size(0, 36),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(
              'Upgrade',
              style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
