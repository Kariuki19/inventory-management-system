import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/inventory/services/demo_service.dart';

typedef RemainingTimeProvider = Future<Duration> Function();

class DemoCountdownBanner extends StatefulWidget {
  final RemainingTimeProvider getRemainingTime;
  final VoidCallback? onExpired;
  final String message;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onExit;

  const DemoCountdownBanner({
    super.key,
    required this.getRemainingTime,
    this.onExpired,
    required this.message,
    this.backgroundColor = const Color(0xFFFF6B00),
    this.foregroundColor = Colors.white,
    this.onExit,
  });

  @override
  State<DemoCountdownBanner> createState() => _DemoCountdownBannerState();
}

class _DemoCountdownBannerState extends State<DemoCountdownBanner> {
  Timer? _tickTimer;
  Duration _remaining = Duration.zero;
  bool _expiredHandled = false;

  @override
  void initState() {
    super.initState();
    _refreshRemaining();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _refreshRemaining();
    });
  }

  Future<void> _refreshRemaining() async {
    final remaining = await widget.getRemainingTime();
    if (!mounted) return;

    setState(() => _remaining = remaining);

    if (remaining <= Duration.zero && !_expiredHandled) {
      _expiredHandled = true;
      widget.onExpired?.call();
    }
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUrgent = _remaining.inMinutes < 5 && _remaining > Duration.zero;
    final bgColor = isUrgent ? Colors.red.shade700 : widget.backgroundColor;

    return Container(
      width: double.infinity,
      color: bgColor,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.timer_outlined, color: widget.foregroundColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.message,
              style: GoogleFonts.poppins(
                color: widget.foregroundColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              DemoService.formatDuration(_remaining),
              style: GoogleFonts.robotoMono(
                color: widget.foregroundColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
          ),
          if (widget.onExit != null) ...[
            const SizedBox(width: 12),
            TextButton(
              onPressed: widget.onExit,
              style: TextButton.styleFrom(
                foregroundColor: widget.foregroundColor,
                backgroundColor: Colors.white24,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: Size.zero,
              ),
              child: Text(
                'Exit',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
