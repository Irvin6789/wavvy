import 'dart:async';

import 'package:flutter/widgets.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/app_icon.dart';
import '../widgets/motion.dart';

/// `src/screens/SplashScreen.tsx`
///
/// Auto-advances after 2.6s. The React version composes three CSS animations
/// (`popIn` on the mark, a staggered `fadeUp` on the wordmark and the dot row,
/// plus looping `float`/`pulse`); each is reproduced with an explicit
/// controller here.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _pop;
  late final AnimationController _fade;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pop = AnimationController(vsync: this, duration: const Duration(milliseconds: 650))
      ..forward();
    _fade = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..forward();
    _timer = Timer(const Duration(milliseconds: 2600), widget.onDone);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pop.dispose();
    _fade.dispose();
    super.dispose();
  }

  /// `fadeUp 0.7s <delay> both` expressed against the 1200ms _fade controller.
  Animation<double> _fadeUp(double delayMs) {
    final double start = delayMs / 1200;
    return CurvedAnimation(
      parent: _fade,
      curve: Interval(start, (start + 700 / 1200).clamp(0.0, 1.0), curve: Curves.easeOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> wordmark = _fadeUp(250);
    final Animation<double> dots = _fadeUp(500);

    return ColoredBox(
      color: kBg,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // Floating background orbs and the pulsing dot row share one clock.
          Positioned.fill(
            child: TimeLoop(
              builder: (BuildContext context, double t) {
                return LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints c) {
                    return Stack(
                      children: <Widget>[
                        _orb(c, t, top: 0.18, left: 0.14, size: 9, color: kCrimson.a8(0x30), delay: 0, dur: 3),
                        _orb(c, t, top: 0.30, right: 0.12, size: 13, color: kDeep.a8(0x20), delay: 1, dur: 4),
                        _orb(c, t, bottom: 0.28, left: 0.16, size: 7, color: kCrimson.a8(0x20), delay: 0.5, dur: 3.5),
                        _orb(c, t, bottom: 0.20, right: 0.18, size: 10, color: kDeep.a8(0x15), delay: 1.5, dur: 2.8),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // popIn: scale 0.88 -> 1 with a slight overshoot, plus a lift.
              AnimatedBuilder(
                animation: _pop,
                builder: (BuildContext context, Widget? child) {
                  final double t = Curves.elasticOut.transform(
                    Curves.easeOut.transform(_pop.value),
                  );
                  return Opacity(
                    opacity: _pop.value.clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(0, 12 * (1 - t)),
                      child: Transform.scale(scale: 0.88 + 0.12 * t, child: child),
                    ),
                  );
                },
                child: const AppIcon(size: 80),
              ),
              const SizedBox(height: 24),
              _FadeUp(
                animation: wordmark,
                child: Column(
                  children: <Widget>[
                    Text(
                      'Wavvy',
                      style: zain(
                        size: 48,
                        weight: kExtraBold,
                        color: kDeep,
                        letterSpacing: -1.5,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'CHAT DIFFERENTLY',
                      style: zain(
                        size: 16,
                        weight: kLight,
                        color: kMuted,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 52),
              _FadeUp(
                animation: dots,
                child: TimeLoop(
                  builder: (BuildContext context, double t) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List<Widget>.generate(3, (int i) {
                        // `pulse 1.2s <i*0.2>s ease-in-out infinite`
                        final double wave = pingPong(t, 1.2, delay: i * 0.2);
                        return Padding(
                          padding: EdgeInsets.only(right: i == 2 ? 0 : 7),
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: kCrimson.withValues(alpha: 0.35 * (0.5 + wave * 0.5)),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _orb(
    BoxConstraints c,
    double t, {
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
    required double delay,
    required double dur,
  }) {
    // `float <dur>s <delay>s ease-in-out infinite`: a -10px vertical drift.
    final double dy = -10 * pingPong(t, dur, delay: delay);
    return Positioned(
      top: top == null ? null : c.maxHeight * top,
      bottom: bottom == null ? null : c.maxHeight * bottom,
      left: left == null ? null : c.maxWidth * left,
      right: right == null ? null : c.maxWidth * right,
      child: Transform.translate(
        offset: Offset(0, dy),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

/// `@keyframes fadeUp` — rise 12px while fading in.
class _FadeUp extends StatelessWidget {
  const _FadeUp({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? c) => Opacity(
        opacity: animation.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - animation.value)),
          child: c,
        ),
      ),
      child: child,
    );
  }
}
