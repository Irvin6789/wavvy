import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';
import 'motion.dart';

/// `EmptyChats` from `src/screens/home/ChatScreen`'s sibling HomeScreen — two
/// floating speech bubbles over a pulsing shadow, with three popping dots.
class EmptyChats extends StatelessWidget {
  const EmptyChats({super.key, required this.filter});

  final String filter;

  String get _title => switch (filter) {
        'Unread' => 'All caught up!',
        'Groups' => 'No groups yet',
        'Online' => 'Nobody online',
        _ => 'No conversations',
      };

  String get _body => switch (filter) {
        'Unread' => "You've read all your messages.\nGreat job staying on top of things.",
        'Groups' => 'Tap + to create a new group\nand start chatting together.',
        'Online' => 'None of your contacts\nare online right now.',
        _ => 'Start a new conversation\nby tapping the + button.',
      };

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TimeLoop(
              builder: (BuildContext context, double t) => SizedBox(
                width: 130,
                height: 120,
                child: CustomPaint(painter: _BubblesPainter(t)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _title,
              textAlign: TextAlign.center,
              style: zain(size: 18, weight: kExtraBold, color: kDeep, letterSpacing: -0.3),
            ),
            const SizedBox(height: 8),
            Text(
              _body,
              textAlign: TextAlign.center,
              style: zain(size: 13, weight: kLight, color: kMuted, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _BubblesPainter extends CustomPainter {
  _BubblesPainter(this.t);

  /// Seconds since the illustration was mounted.
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width / 130;
    canvas.save();
    canvas.scale(s);

    // Shadow — `shadowPulse 2.8s`
    final double shadow = pingPong(t, 2.8);
    canvas.save();
    canvas.translate(65, 108);
    canvas.scale(1 - 0.25 * shadow, 1);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 84, height: 14),
      Paint()..color = kCrimson.withValues(alpha: 0.07 * (1 - 0.5 * shadow)),
    );
    canvas.restore();

    // Back bubble — `emptyFloatBack 2.8s`, drifts down 5px.
    canvas.save();
    canvas.translate(0, 5 * pingPong(t, 2.8));
    final RRect back = RRect.fromRectAndRadius(
      const Rect.fromLTWH(34, 18, 70, 52),
      const Radius.circular(18),
    );
    canvas.drawRRect(back, Paint()..color = kCrimson.a8(0x0C));
    canvas.drawRRect(
      back,
      Paint()
        ..color = kCrimson.a8(0x22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    final Path backTail = Path()
      ..moveTo(48, 70)
      ..lineTo(42, 82)
      ..lineTo(58, 72);
    canvas.drawPath(backTail, Paint()..color = kCrimson.a8(0x0C));
    canvas.drawPath(
      backTail,
      Paint()
        ..color = kCrimson.a8(0x22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();

    // Front bubble — `emptyFloat 2.8s`, lifts 7px.
    canvas.save();
    canvas.translate(0, -7 * pingPong(t, 2.8));
    final RRect front = RRect.fromRectAndRadius(
      const Rect.fromLTWH(22, 10, 66, 48),
      const Radius.circular(16),
    );
    canvas.drawRRect(front, Paint()..color = kBg);
    canvas.drawRRect(
      front,
      Paint()
        ..color = kCrimson.a8(0x30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    final Path frontTail = Path()
      ..moveTo(80, 58)
      ..lineTo(87, 70)
      ..lineTo(72, 60);
    canvas.drawPath(frontTail, Paint()..color = kBg);
    canvas.drawPath(
      frontTail,
      Paint()
        ..color = kCrimson.a8(0x30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round,
    );

    // `dotPop1/2/3 1.6s` — each dot swells to 1.5x on its own beat, at 20%,
    // 40% and 60% through the shared 1.6s cycle.
    const List<double> xs = <double>[44, 55, 66];
    const List<int> alphas = <int>[0x50, 0x80, 0xFF];
    for (int i = 0; i < 3; i++) {
      final double scale = 1 + 0.5 * pulseAt(t, 1.6, 0.2 * (i + 1), 0.2);
      canvas.save();
      canvas.translate(xs[i], 34);
      canvas.scale(scale);
      canvas.drawCircle(Offset.zero, 4, Paint()..color = kCrimson.a8(alphas[i]));
      canvas.restore();
    }
    canvas.restore();

    canvas.restore();
  }

  @override
  bool shouldRepaint(_BubblesPainter old) => old.t != t;
}

/// `EmptyDiscover` — a floating compass whose needle swings.
class EmptyDiscover extends StatelessWidget {
  const EmptyDiscover({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TimeLoop(
              builder: (BuildContext context, double t) => SizedBox(
                width: 130,
                height: 125,
                child: CustomPaint(painter: _CompassPainter(t)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Coming soon',
              textAlign: TextAlign.center,
              style: zain(size: 18, weight: kExtraBold, color: kDeep, letterSpacing: -0.3),
            ),
            const SizedBox(height: 8),
            Text(
              'Discover new people and groups\nwill be available in a future update.',
              textAlign: TextAlign.center,
              style: zain(size: 13, weight: kLight, color: kMuted, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  _CompassPainter(this.t);

  /// Seconds since the illustration was mounted.
  final double t;

  void _label(Canvas canvas, String text, Offset at, Color color, double fontSize, FontWeight weight) {
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: zain(size: fontSize, weight: weight, color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    // SVG <text> anchors on the baseline; Flutter lays out from the top.
    tp.paint(canvas, Offset(at.dx, at.dy - tp.height * 0.82));
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 130);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(65, 112), width: 76, height: 12),
      Paint()..color = kCrimson.a8(0x0E),
    );

    // `compassFloat 3s` lifts the whole body 6px.
    canvas.save();
    canvas.translate(0, -6 * pingPong(t, 3));

    canvas.drawCircle(const Offset(65, 58), 36, Paint()..color = kBg);
    canvas.drawCircle(
      const Offset(65, 58),
      36,
      Paint()
        ..color = kCrimson.a8(0x25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(const Offset(65, 58), 28, Paint()..color = kCrimson.a8(0x08));
    canvas.drawCircle(
      const Offset(65, 58),
      28,
      Paint()
        ..color = kCrimson.a8(0x18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // `compassLoop 2.4s` swings the needle between -14deg and +14deg.
    canvas.save();
    canvas.translate(65, 58);
    canvas.rotate((-14 + 28 * pingPong(t, 2.4)) * math.pi / 180);
    canvas.translate(-65, -58);
    canvas.drawPath(
      Path()
        ..moveTo(65, 58)
        ..lineTo(58, 36)
        ..lineTo(65, 42)
        ..close(),
      Paint()..color = kCrimson,
    );
    canvas.drawPath(
      Path()
        ..moveTo(65, 58)
        ..lineTo(72, 80)
        ..lineTo(65, 74)
        ..close(),
      Paint()..color = kCrimson.a8(0x45),
    );
    canvas.restore();

    canvas.drawCircle(const Offset(65, 58), 4, Paint()..color = kBg);
    canvas.drawCircle(
      const Offset(65, 58),
      4,
      Paint()
        ..color = kCrimson
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    _label(canvas, 'N', const Offset(63, 27), kCrimson, 8, kBold);
    _label(canvas, 'S', const Offset(63, 95), kCrimson.a8(0x60), 7, kRegular);
    _label(canvas, 'W', const Offset(24, 61), kCrimson.a8(0x60), 7, kRegular);
    _label(canvas, 'E', const Offset(98, 61), kCrimson.a8(0x60), 7, kRegular);

    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CompassPainter old) => old.t != t;
}

/// `EmptyState` from `NewChatScreen` — a floating magnifier with a swinging
/// handle and a pulsing crosshair.
class EmptySearch extends StatelessWidget {
  const EmptySearch({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TimeLoop(
              builder: (BuildContext context, double t) => SizedBox(
                width: 120,
                height: 115,
                child: CustomPaint(painter: _MagnifierPainter(t)),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No results found',
              textAlign: TextAlign.center,
              style: zain(size: 17, weight: kExtraBold, color: kDeep),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different name or\nuse the + button to start fresh.',
              textAlign: TextAlign.center,
              style: zain(size: 13, weight: kLight, color: kMuted, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _MagnifierPainter extends CustomPainter {
  _MagnifierPainter(this.t);

  /// Seconds since the illustration was mounted.
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 120);

    // `magShadow 2.6s` — squashes and fades the ground shadow.
    final double shadow = pingPong(t, 2.6);
    canvas.save();
    canvas.translate(60, 108);
    canvas.scale(1 - 0.25 * shadow, 1);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 64, height: 10),
      Paint()..color = kCrimson.withValues(alpha: 0.07 * (1 - 0.5 * shadow)),
    );
    canvas.restore();

    // `magFloat 2.6s` — the whole magnifier bobs 6px.
    canvas.save();
    canvas.translate(0, -6 * pingPong(t, 2.6));

    canvas.drawCircle(const Offset(52, 48), 26, Paint()..color = kBg);
    canvas.drawCircle(
      const Offset(52, 48),
      26,
      Paint()
        ..color = kCrimson.a8(0x25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(const Offset(52, 48), 18, Paint()..color = kCrimson.a8(0x08));

    // `crossPulse 2s` — the crosshair breathes between 0.4 and 1 opacity.
    final double pulse = 0.4 + 0.6 * pingPong(t, 2);
    final Paint cross = Paint()
      ..color = kCrimson.withValues(alpha: (0x55 / 255) * pulse)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(44, 48), const Offset(60, 48), cross);
    canvas.drawLine(const Offset(52, 40), const Offset(52, 56), cross);

    // `magSwing 2.6s` — the handle swings about the lens centre.
    canvas.save();
    canvas.translate(52, 48);
    canvas.rotate((-14 + 28 * pingPong(t, 2.6)) * math.pi / 180);
    canvas.translate(-52, -48);
    canvas.drawLine(
      const Offset(71, 67),
      const Offset(84, 82),
      Paint()
        ..color = kCrimson
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();

    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MagnifierPainter old) => old.t != t;
}
