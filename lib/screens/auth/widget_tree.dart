import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/demo_service.dart';
import '../../services/trial_service.dart';
import '../auth/login_register_page.dart';
import '../demo_expired_screen.dart';
import '../home_page.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  bool _isLoading = true;
  bool _trialExpired = false;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (AuthService.currentUser != null) {
      final expired = await TrialService.isTrialExpired();
      if (mounted) {
        setState(() {
          _trialExpired = expired;
          _isLoading = false;
        });
      }
    } else if (mounted) {
      setState(() => _isLoading = false);
    }

    AuthService.authStateChanges.listen((user) async {
      if (!mounted) return;

      if (user != null) {
        final expired = await TrialService.isTrialExpired();
        if (mounted) {
          setState(() {
            _trialExpired = expired;
          });
        }
      } else if (mounted) {
        setState(() => _trialExpired = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentUser = AuthService.currentUser;

    if (currentUser != null && _trialExpired) {
      return const PageTransition(
        type: PageTransitionType.fade,
       child: DemoExpiredScreen(demoEndReason: DemoEndedReason.timeExpired),
      );
    }

    if (currentUser != null) {
      return PageTransition(
        type: PageTransitionType.professionalSlide,
        child: HomePage(currentUser: currentUser),
      );
    }

    return const PageTransition(
      type: PageTransitionType.fade,
      child: LoginPage(),
    );
  }
}

// Custom page transition widget
class PageTransition extends StatelessWidget {
  final Widget child;
  final PageTransitionType type;
  final Curve curve;
  final Alignment alignment;
  final Duration duration;

  const PageTransition({
    super.key,
    required this.child,
    this.type = PageTransitionType.fade,
    this.curve = Curves.easeInOut,
    this.alignment = Alignment.center,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        switch (type) {
          case PageTransitionType.fade:
            return Opacity(opacity: value, child: child);
          case PageTransitionType.scale:
            return Transform.scale(scale: value, child: child);
          case PageTransitionType.rotate:
            return Transform.rotate(
              angle: (1 - value) * 0.5,
              child: child,
            );
          case PageTransitionType.fadeWithScale:
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: 0.6 + (0.4 * value),
                child: child,
              ),
            );
          case PageTransitionType.fadeWithScaleAndRotation:
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: 0.7 + (0.3 * value),
                child: Transform.rotate(
                  angle: (1 - value) * 0.2,
                  child: child,
                ),
              ),
            );
          case PageTransitionType.professionalSlide:
            return Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Transform.scale(
                  scale: 0.95 + (0.05 * value),
                  child: child,
                ),
              ),
            );
        }
      },
      child: child,
    );
  }
}

enum PageTransitionType {
  fade,
  scale,
  rotate,
  fadeWithScale,
  fadeWithScaleAndRotation,
  professionalSlide,
}
