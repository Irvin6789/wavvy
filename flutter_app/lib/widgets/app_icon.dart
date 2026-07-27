import 'package:flutter/widgets.dart';

import '../theme/colors.dart';

/// The three-wave Wavvy mark, ported from `src/components/AppIcon.tsx`.
///
/// The React version is an inline SVG on a 56x56 viewBox with three
/// horizontally-shaded gradient strokes; here the same cubics are stroked onto
/// a canvas with matching left-to-right gradients.
class AppIcon extends StatelessWidget {
  const AppIcon({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: const _AppIconPainter()),
    );
  }
}

@immutable
class _Wave {
  const _Wave({
    required this.y,
    required this.strokeWidth,
    required this.colors,
    required this.opacity,
    this.stops,
  });

  final double y;
  final double strokeWidth;
  final List<Color> colors;
  final List<double>? stops;
  final double opacity;
}

class _AppIconPainter extends CustomPainter {
  const _AppIconPainter();

  static const double _grid = 56;
  static const Rect _span = Rect.fromLTWH(0, 0, _grid, _grid);

  static const List<_Wave> _waves = <_Wave>[
    _Wave(y: 18, strokeWidth: 4, colors: <Color>[kDeep, kCrimson], opacity: 0.55),
    _Wave(
      y: 28,
      strokeWidth: 5.5,
      colors: <Color>[kCrimson, kCrimsonLight, kDeep],
      stops: <double>[0, 0.6, 1],
      opacity: 1,
    ),
    _Wave(y: 38, strokeWidth: 4, colors: <Color>[kDeep, kCrimson], opacity: 0.7),
  ];

  /// "M6 y C12 y-7, 20 y-7, 28 y C36 y+7, 44 y+7, 50 y"
  static Path _path(double y) => Path()
    ..moveTo(6, y)
    ..cubicTo(12, y - 7, 20, y - 7, 28, y)
    ..cubicTo(36, y + 7, 44, y + 7, 50, y);

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.shortestSide / _grid;
    if (scale <= 0) return;

    canvas.save();
    canvas.translate(
      (size.width - _grid * scale) / 2,
      (size.height - _grid * scale) / 2,
    );
    canvas.scale(scale);

    for (final _Wave wave in _waves) {
      // The SVG applies `opacity` to the whole <path>. Baking it into the
      // gradient stops is equivalent here (the strokes never self-overlap) and
      // avoids relying on how a Paint's colour alpha interacts with a shader.
      final Shader shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: <Color>[
          for (final Color c in wave.colors)
            c.withValues(alpha: c.a * wave.opacity),
        ],
        stops: wave.stops,
      ).createShader(_span);

      canvas.drawPath(
        _path(wave.y),
        Paint()
          ..shader = shader
          ..style = PaintingStyle.stroke
          ..strokeWidth = wave.strokeWidth
          ..strokeCap = StrokeCap.round
          ..isAntiAlias = true,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_AppIconPainter oldDelegate) => false;
}
