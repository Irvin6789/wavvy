import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Drives a builder with a free-running clock, in seconds since the widget was
/// mounted.
///
/// The CSS in the React source layers animations with unrelated periods
/// (2s, 2.4s, 2.6s, 2.8s, 3s…) on the same element. Sharing one looping
/// [AnimationController] would make every sub-animation whose period doesn't
/// divide the controller's jump at the wrap point, so this exposes a
/// monotonically increasing time instead and lets each effect take its own
/// modulus.
class TimeLoop extends StatefulWidget {
  const TimeLoop({super.key, required this.builder});

  final Widget Function(BuildContext context, double seconds) builder;

  @override
  State<TimeLoop> createState() => _TimeLoopState();
}

class _TimeLoopState extends State<TimeLoop> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _seconds = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((Duration elapsed) {
      setState(() => _seconds = elapsed.inMicroseconds / Duration.microsecondsPerSecond);
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _seconds);
}

/// A 0 → 1 → 0 ease-in-out ping-pong, i.e. the shape of a CSS
/// `@keyframes { 0%,100% { a } 50% { b } }` with `ease-in-out infinite`.
double pingPong(double seconds, double period, {double delay = 0}) {
  final double phase = ((seconds - delay) / period) % 1.0;
  return (1 - math.cos(phase * 2 * math.pi)) / 2;
}

/// A one-shot pop inside a repeating cycle: rises to 1 at [peak] (a fraction of
/// the cycle) and falls back to 0 over ±[width].
double pulseAt(double seconds, double period, double peak, double width,
    {double delay = 0}) {
  final double phase = ((seconds - delay) / period) % 1.0;
  double distance = (phase - peak).abs();
  // Wrap the distance so a peak near 0 or 1 still eases from both sides.
  distance = math.min(distance, 1 - distance);
  if (distance >= width) return 0;
  return (1 + math.cos((distance / width) * math.pi)) / 2;
}
