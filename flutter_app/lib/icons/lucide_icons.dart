// GENERATED FILE — DO NOT EDIT BY HAND.
//
// Produced by tool/generate_icons.mjs from lucide-static v1.27.0
// (fetched from registry.npmjs.org; Lucide is ISC licensed).
//
// Regenerate with:
//   ./tool/download_assets.sh && node tool/generate_icons.mjs
//
// Every icon is stored as geometry on Lucide's 24x24 grid and stroked at paint
// time, so it stays crisp at any size and needs no third-party dependency.

import 'dart:math' as math;
import 'package:flutter/widgets.dart';

/// The grid every Lucide icon is drawn on.
const double kLucideGrid = 24.0;

/// One drawing primitive on the 24x24 grid.
@immutable
sealed class _Prim {
  const _Prim();
  void addTo(Path path);
}

/// A path built from parsed SVG path data.
@immutable
class _P extends _Prim {
  const _P(this.segments);
  final List<_S> segments;

  @override
  void addTo(Path path) {
    for (final s in segments) {
      s.addTo(path);
    }
  }
}

@immutable
class _C extends _Prim {
  const _C(this.cx, this.cy, this.r);
  final double cx, cy, r;

  @override
  void addTo(Path path) {
    path.addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));
  }
}

@immutable
class _E extends _Prim {
  const _E(this.cx, this.cy, this.rx, this.ry);
  final double cx, cy, rx, ry;

  @override
  void addTo(Path path) {
    path.addOval(
      Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
    );
  }
}

@immutable
class _R extends _Prim {
  const _R(this.x, this.y, this.w, this.h, this.rx, this.ry);
  final double x, y, w, h, rx, ry;

  @override
  void addTo(Path path) {
    final rect = Rect.fromLTWH(x, y, w, h);
    if (rx <= 0 && ry <= 0) {
      path.addRect(rect);
    } else {
      path.addRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: Radius.elliptical(rx, ry),
          topRight: Radius.elliptical(rx, ry),
          bottomLeft: Radius.elliptical(rx, ry),
          bottomRight: Radius.elliptical(rx, ry),
        ),
      );
    }
  }
}

@immutable
class _L extends _Prim {
  const _L(this.x1, this.y1, this.x2, this.y2);
  final double x1, y1, x2, y2;

  @override
  void addTo(Path path) {
    path
      ..moveTo(x1, y1)
      ..lineTo(x2, y2);
  }
}

/// One segment of parsed SVG path data, already resolved to absolute
/// coordinates by tool/svg_path_parser.mjs.
@immutable
sealed class _S {
  const _S();
  void addTo(Path path);
}

class _Mv extends _S {
  const _Mv(this.x, this.y);
  final double x, y;
  @override
  void addTo(Path path) => path.moveTo(x, y);
}

class _Ln extends _S {
  const _Ln(this.x, this.y);
  final double x, y;
  @override
  void addTo(Path path) => path.lineTo(x, y);
}

class _Cu extends _S {
  const _Cu(this.x1, this.y1, this.x2, this.y2, this.x, this.y);
  final double x1, y1, x2, y2, x, y;
  @override
  void addTo(Path path) => path.cubicTo(x1, y1, x2, y2, x, y);
}

class _Qd extends _S {
  const _Qd(this.x1, this.y1, this.x, this.y);
  final double x1, y1, x, y;
  @override
  void addTo(Path path) => path.quadraticBezierTo(x1, y1, x, y);
}

class _Ar extends _S {
  const _Ar(this.rx, this.ry, this.rotation, this.largeArc, this.clockwise, this.x, this.y);
  final double rx, ry, rotation, x, y;
  final bool largeArc, clockwise;
  @override
  void addTo(Path path) => path.arcToPoint(
        Offset(x, y),
        radius: Radius.elliptical(rx, ry),
        rotation: rotation,
        largeArc: largeArc,
        clockwise: clockwise,
      );
}

class _Cl extends _S {
  const _Cl();
  @override
  void addTo(Path path) => path.close();
}

/// A Lucide icon: pure geometry, stroked when painted.
@immutable
class LucideIcon {
  const LucideIcon(this._prims);
  final List<_Prim> _prims;

  /// Builds the icon outline on the 24x24 grid.
  Path buildPath() {
    final path = Path();
    for (final p in _prims) {
      p.addTo(path);
    }
    return path;
  }
}

/// Renders a [LucideIcon] at [size] logical pixels.
///
/// [strokeWidth] is expressed on Lucide's 24-unit grid exactly like the
/// `stroke-width` prop of lucide-react, so the same numbers used by the React
/// design carry over unchanged.
class LucideIconWidget extends StatelessWidget {
  const LucideIconWidget(
    this.icon, {
    super.key,
    this.size = 24,
    this.color = const Color(0xFF000000),
    this.strokeWidth = 2,
    this.fill,
  });

  final LucideIcon icon;
  final double size;
  final Color color;
  final double strokeWidth;

  /// Optional fill painted underneath the stroke (mirrors the `fill` prop
  /// lucide-react accepts).
  final Color? fill;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _LucidePainter(
          icon: icon,
          color: color,
          strokeWidth: strokeWidth,
          fill: fill,
        ),
        isComplex: false,
      ),
    );
  }
}

class _LucidePainter extends CustomPainter {
  _LucidePainter({
    required this.icon,
    required this.color,
    required this.strokeWidth,
    required this.fill,
  });

  final LucideIcon icon;
  final Color color;
  final double strokeWidth;
  final Color? fill;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width, size.height) / kLucideGrid;
    if (scale <= 0) return;

    canvas.save();
    canvas.translate(
      (size.width - kLucideGrid * scale) / 2,
      (size.height - kLucideGrid * scale) / 2,
    );
    canvas.scale(scale);

    final path = icon.buildPath();
    final fillColor = fill;
    if (fillColor != null && fillColor.a > 0) {
      canvas.drawPath(path, Paint()..color = fillColor..style = PaintingStyle.fill);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LucidePainter old) =>
      old.icon != icon ||
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.fill != fill;
}

/// The Lucide icons used by Wavvy.
class Lucide {
  /// lucide `atSign`
  static const LucideIcon atSign = LucideIcon(<_Prim>[
    _C(12.0, 12.0, 4.0),
    _P(<_S>[_Mv(16.0, 8.0), _Ln(16.0, 13.0), _Ar(3.0, 3.0, 0.0, false, false, 22.0, 13.0), _Ln(22.0, 12.0), _Ar(10.0, 10.0, 0.0, true, false, 18.0, 20.0)]),
  ]);

  /// lucide `bell`
  static const LucideIcon bell = LucideIcon(<_Prim>[
    _P(<_S>[_Mv(10.268, 21.0), _Ar(2.0, 2.0, 0.0, false, false, 13.732, 21.0)]),
    _P(<_S>[_Mv(3.262, 15.326), _Ar(1.0, 1.0, 0.0, false, false, 4.0, 17.0), _Ln(20.0, 17.0), _Ar(1.0, 1.0, 0.0, false, false, 20.74, 15.327), _Cu(19.41, 13.956, 18.0, 12.499, 18.0, 8.0), _Ar(6.0, 6.0, 0.0, false, false, 6.0, 8.0), _Cu(6.0, 12.499, 4.589, 13.956, 3.262, 15.326)]),
  ]);

  /// lucide `cake`
  static const LucideIcon cake = LucideIcon(<_Prim>[
    _P(<_S>[_Mv(20.0, 21.0), _Ln(20.0, 13.0), _Ar(2.0, 2.0, 0.0, false, false, 18.0, 11.0), _Ln(6.0, 11.0), _Ar(2.0, 2.0, 0.0, false, false, 4.0, 13.0), _Ln(4.0, 21.0)]),
    _P(<_S>[_Mv(4.0, 16.0), _Cu(4.0, 16.0, 4.5, 15.0, 6.0, 15.0), _Cu(7.5, 15.0, 8.5, 17.0, 10.0, 17.0), _Cu(11.5, 17.0, 12.5, 15.0, 14.0, 15.0), _Cu(15.5, 15.0, 16.5, 17.0, 18.0, 17.0), _Cu(19.5, 17.0, 20.0, 16.0, 20.0, 16.0)]),
    _P(<_S>[_Mv(2.0, 21.0), _Ln(22.0, 21.0)]),
    _P(<_S>[_Mv(7.0, 8.0), _Ln(7.0, 11.0)]),
    _P(<_S>[_Mv(12.0, 8.0), _Ln(12.0, 11.0)]),
    _P(<_S>[_Mv(17.0, 8.0), _Ln(17.0, 11.0)]),
    _P(<_S>[_Mv(7.0, 4.0), _Ln(7.01, 4.0)]),
    _P(<_S>[_Mv(12.0, 4.0), _Ln(12.01, 4.0)]),
    _P(<_S>[_Mv(17.0, 4.0), _Ln(17.01, 4.0)]),
  ]);

  /// lucide `camera`
  static const LucideIcon camera = LucideIcon(<_Prim>[
    _P(<_S>[_Mv(13.997, 4.0), _Ar(2.0, 2.0, 0.0, false, true, 15.757, 5.05), _Ln(16.243, 5.95), _Ar(2.0, 2.0, 0.0, false, false, 18.003, 7.0), _Ln(20.0, 7.0), _Ar(2.0, 2.0, 0.0, false, true, 22.0, 9.0), _Ln(22.0, 18.0), _Ar(2.0, 2.0, 0.0, false, true, 20.0, 20.0), _Ln(4.0, 20.0), _Ar(2.0, 2.0, 0.0, false, true, 2.0, 18.0), _Ln(2.0, 9.0), _Ar(2.0, 2.0, 0.0, false, true, 4.0, 7.0), _Ln(5.997, 7.0), _Ar(2.0, 2.0, 0.0, false, false, 7.756, 5.952), _Ln(8.245, 5.048), _Ar(2.0, 2.0, 0.0, false, true, 10.004, 4.0), _Cl()]),
    _C(12.0, 13.0, 3.0),
  ]);

  /// lucide `check`
  static const LucideIcon check = LucideIcon(<_Prim>[
    _P(<_S>[_Mv(20.0, 6.0), _Ln(9.0, 17.0), _Ln(4.0, 12.0)]),
  ]);

  /// lucide `checkCheck`
  static const LucideIcon checkCheck = LucideIcon(<_Prim>[
    _P(<_S>[_Mv(18.0, 6.0), _Ln(7.0, 17.0), _Ln(2.0, 12.0)]),
    _P(<_S>[_Mv(22.0, 10.0), _Ln(14.5, 17.5), _Ln(13.0, 16.0)]),
  ]);

  /// lucide `chevronDown`
  static const LucideIcon chevronDown = LucideIcon(<_Prim>[
    _P(<_S>[_Mv(6.0, 9.0), _Ln(12.0, 15.0), _Ln(18.0, 9.0)]),
  ]);

  /// lucide `chevronLeft`
  static const LucideIcon chevronLeft = LucideIcon(<_Prim>[
    _P(<_S>[_Mv(15.0, 18.0), _Ln(9.0, 12.0), _Ln(15.0, 6.0)]),
  ]);

  /// lucide `chevronRight`
  static const LucideIcon chevronRight = LucideIcon(<_Prim>[
    _P(<_S>[_Mv(9.0, 18.0), _Ln(15.0, 12.0), _Ln(9.0, 6.0)]),
  ]);

  /// lucide `circleUser`
  static const LucideIcon circleUser = LucideIcon(<_Prim>[
    _C(12.0, 12.0, 10.0),
    _C(12.0, 10.0, 3.0),
    _P(<_S>[_Mv(7.0, 20.662), _Ln(7.0, 19.0), _Ar(2.0, 2.0, 0.0, false, true, 9.0, 17.0), _Ln(15.0, 17.0), _Ar(2.0, 2.0, 0.0, false, true, 17.0, 19.0), _Ln(17.0, 20.662)]),
  ]);

  /// lucide `compass`
  static const LucideIcon compass = LucideIcon(<_Prim>[
    _C(12.0, 12.0, 10.0),
    _P(<_S>[_Mv(16.24, 7.76), _Ln(14.436, 13.171), _Ar(2.0, 2.0, 0.0, false, true, 13.171, 14.436), _Ln(7.76, 16.24), _Ln(9.564, 10.829), _Ar(2.0, 2.0, 0.0, false, true, 10.829, 9.564), _Cl()]),
  ]);

  /// lucide `eye`
  static const LucideIcon eye = LucideIcon(<_Prim>[
    _P(<_S>[_Mv(2.062, 12.348), _Ar(1.0, 1.0, 0.0, false, true, 2.062, 11.652), _Ar(10.75, 10.75, 0.0, false, true, 21.938, 11.652), _Ar(1.0, 1.0, 0.0, false, true, 21.938, 12.348), _Ar(10.75, 10.75, 0.0, false, true, 2.062, 12.348)]),
    _C(12.0, 12.0, 3.0),
  ]);

  /// lucide `eyeOff`
  static const LucideIcon eyeOff = LucideIcon(<_Prim>[
    _P(<_S>[_Mv(10.733, 5.076), _Ar(10.744, 10.744, 0.0, false, true, 21.938, 11.651), _Ar(1.0, 1.0, 0.0, false, true, 21.938, 12.347), _Ar(10.747, 10.747, 0.0, false, true, 20.494, 14.837)]),
    _P(<_S>[_Mv(14.084, 14.158), _Ar(3.0, 3.0, 0.0, false, true, 9.842, 9.916)]),
    _P(<_S>[_Mv(17.479, 17.499), _Ar(10.75, 10.75, 0.0, false, true, 2.062, 12.348), _Ar(1.0, 1.0, 0.0, false, true, 2.062, 11.652), _Ar(10.75, 10.75, 0.0, false, true, 6.508, 6.509)]),
    _P(<_S>[_Mv(2.0, 2.0), _Ln(22.0, 22.0)]),
  ]);

  /// lucide `globe`
  static const LucideIcon globe = LucideIcon(<_Prim>[
    _C(12.0, 12.0, 10.0),
    _P(<_S>[_Mv(12.0, 2.0), _Ar(14.5, 14.5, 0.0, false, false, 12.0, 22.0), _Ar(14.5, 14.5, 0.0, false, false, 12.0, 2.0)]),
    _P(<_S>[_Mv(2.0, 12.0), _Ln(22.0, 12.0)]),
  ]);

  /// lucide `link`
  static const LucideIcon link = LucideIcon(<_Prim>[
    _P(<_S>[_Mv(10.0, 13.0), _Ar(5.0, 5.0, 0.0, false, false, 17.54, 13.54), _Ln(20.54, 10.54), _Ar(5.0, 5.0, 0.0, false, false, 13.47, 3.47), _Ln(11.75, 5.18)]),
    _P(<_S>[_Mv(14.0, 11.0), _Ar(5.0, 5.0, 0.0, false, false, 6.46, 10.46), _Ln(3.46, 13.46), _Ar(5.0, 5.0, 0.0, false, false, 10.53, 20.53), _Ln(12.24, 18.82)]),
  ]);

  /// lucide `link2`
  static const LucideIcon link2 = LucideIcon(<_Prim>[
    _P(<_S>[_Mv(9.0, 17.0), _Ln(7.0, 17.0), _Ar(5.0, 5.0, 0.0, false, true, 7.0, 7.0), _Ln(9.0, 7.0)]),
    _P(<_S>[_Mv(15.0, 7.0), _Ln(17.0, 7.0), _Ar(5.0, 5.0, 0.0, true, true, 17.0, 17.0), _Ln(15.0, 17.0)]),
    _L(8.0, 12.0, 16.0, 12.0),
  ]);

  /// lucide `lock`
  static const LucideIcon lock = LucideIcon(<_Prim>[
    _R(3.0, 11.0, 18.0, 11.0, 2.0, 2.0),
    _P(<_S>[_Mv(7.0, 11.0), _Ln(7.0, 7.0), _Ar(5.0, 5.0, 0.0, false, true, 17.0, 7.0), _Ln(17.0, 11.0)]),
  ]);

  /// lucide `logOut`
  static const LucideIcon logOut = LucideIcon(<_Prim>[
    _P(<_S>[_Mv(16.0, 17.0), _Ln(21.0, 12.0), _Ln(16.0, 7.0)]),
    _P(<_S>[_Mv(21.0, 12.0), _Ln(9.0, 12.0)]),
    _P(<_S>[_Mv(9.0, 21.0), _Ln(5.0, 21.0), _Ar(2.0, 2.0, 0.0, false, true, 3.0, 19.0), _Ln(3.0, 5.0), _Ar(2.0, 2.0, 0.0, false, true, 5.0, 3.0), _Ln(9.0, 3.0)]),
  ]);

  /// lucide `mail`
  static const LucideIcon mail = LucideIcon(<_Prim>[
    _P(<_S>[_Mv(22.0, 7.0), _Ln(13.009, 12.727), _Ar(2.0, 2.0, 0.0, false, true, 11.0, 12.727), _Ln(2.0, 7.0)]),
    _R(2.0, 4.0, 20.0, 16.0, 2.0, 2.0),
  ]);

  /// lucide `messageCircle`
  static const LucideIcon messageCircle = LucideIcon(<_Prim>[
    _P(<_S>[_Mv(2.992, 16.342), _Ar(2.0, 2.0, 0.0, false, true, 3.086, 17.509), _Ln(2.021, 20.799), _Ar(1.0, 1.0, 0.0, false, false, 3.257, 21.967), _Ln(6.67, 20.969), _Ar(2.0, 2.0, 0.0, false, true, 7.769, 21.061), _Ar(10.0, 10.0, 0.0, true, false, 2.992, 16.342)]),
  ]);

  /// lucide `mic`
  static const LucideIcon mic = LucideIcon(<_Prim>[
    _P(<_S>[_Mv(12.0, 19.0), _Ln(12.0, 22.0)]),
    _P(<_S>[_Mv(19.0, 10.0), _Ln(19.0, 12.0), _Ar(7.0, 7.0, 0.0, false, true, 5.0, 12.0), _Ln(5.0, 10.0)]),
    _R(9.0, 2.0, 6.0, 13.0, 3.0, 3.0),
  ]);

  /// lucide `moon`
  static const LucideIcon moon = LucideIcon(<_Prim>[
    _P(<_S>[_Mv(20.985, 12.486), _Ar(9.0, 9.0, 0.0, true, true, 11.512, 3.014), _Cu(11.917, 2.992, 12.129, 3.474, 11.914, 3.817), _Ar(6.0, 6.0, 0.0, false, false, 20.182, 12.085), _Cu(20.526, 11.87, 21.007, 12.081, 20.985, 12.486)]),
  ]);

  /// lucide `moreVertical`
  static const LucideIcon moreVertical = LucideIcon(<_Prim>[
    _C(12.0, 12.0, 1.0),
    _C(12.0, 5.0, 1.0),
    _C(12.0, 19.0, 1.0),
  ]);

  /// lucide `paperclip`
  static const LucideIcon paperclip = LucideIcon(<_Prim>[
    _P(<_S>[_Mv(16.0, 6.0), _Ln(7.586, 14.586), _Ar(2.0, 2.0, 0.0, false, false, 10.415, 17.415), _Ln(18.829, 8.829), _Ar(4.0, 4.0, 0.0, true, false, 13.172, 3.172), _Ln(4.793, 11.723), _Ar(6.0, 6.0, 0.0, true, false, 13.278, 20.208), _Ln(21.657, 11.657)]),
  ]);

  /// lucide `pencil`
  static const LucideIcon pencil = LucideIcon(<_Prim>[
    _P(<_S>[_Mv(21.174, 6.812), _Ar(1.0, 1.0, 0.0, false, false, 17.188, 2.825), _Ln(3.842, 16.174), _Ar(2.0, 2.0, 0.0, false, false, 3.342, 17.004), _Ln(2.021, 21.356), _Ar(0.5, 0.5, 0.0, false, false, 2.644, 21.978), _Ln(6.997, 20.658), _Ar(2.0, 2.0, 0.0, false, false, 7.827, 20.161), _Cl()]),
    _P(<_S>[_Mv(15.0, 5.0), _Ln(19.0, 9.0)]),
  ]);

  /// lucide `phone`
  static const LucideIcon phone = LucideIcon(<_Prim>[
    _P(<_S>[_Mv(13.832, 16.568), _Ar(1.0, 1.0, 0.0, false, false, 15.045, 16.265), _Ln(15.4, 15.8), _Ar(2.0, 2.0, 0.0, false, true, 17.0, 15.0), _Ln(20.0, 15.0), _Ar(2.0, 2.0, 0.0, false, true, 22.0, 17.0), _Ln(22.0, 20.0), _Ar(2.0, 2.0, 0.0, false, true, 20.0, 22.0), _Ar(18.0, 18.0, 0.0, false, true, 2.0, 4.0), _Ar(2.0, 2.0, 0.0, false, true, 4.0, 2.0), _Ln(7.0, 2.0), _Ar(2.0, 2.0, 0.0, false, true, 9.0, 4.0), _Ln(9.0, 7.0), _Ar(2.0, 2.0, 0.0, false, true, 8.2, 8.6), _Ln(7.732, 8.951), _Ar(1.0, 1.0, 0.0, false, false, 7.44, 10.184), _Ar(14.0, 14.0, 0.0, false, false, 13.832, 16.568)]),
  ]);

  /// lucide `pin`
  static const LucideIcon pin = LucideIcon(<_Prim>[
    _P(<_S>[_Mv(12.0, 17.0), _Ln(12.0, 22.0)]),
    _P(<_S>[_Mv(9.0, 10.76), _Ar(2.0, 2.0, 0.0, false, true, 7.89, 12.55), _Ln(6.11, 13.45), _Ar(2.0, 2.0, 0.0, false, false, 5.0, 15.24), _Ln(5.0, 16.0), _Ar(1.0, 1.0, 0.0, false, false, 6.0, 17.0), _Ln(18.0, 17.0), _Ar(1.0, 1.0, 0.0, false, false, 19.0, 16.0), _Ln(19.0, 15.24), _Ar(2.0, 2.0, 0.0, false, false, 17.89, 13.45), _Ln(16.11, 12.55), _Ar(2.0, 2.0, 0.0, false, true, 15.0, 10.76), _Ln(15.0, 7.0), _Ar(1.0, 1.0, 0.0, false, true, 16.0, 6.0), _Ar(2.0, 2.0, 0.0, false, false, 16.0, 2.0), _Ln(8.0, 2.0), _Ar(2.0, 2.0, 0.0, false, false, 8.0, 6.0), _Ar(1.0, 1.0, 0.0, false, true, 9.0, 7.0), _Cl()]),
  ]);

  /// lucide `plus`
  static const LucideIcon plus = LucideIcon(<_Prim>[
    _P(<_S>[_Mv(5.0, 12.0), _Ln(19.0, 12.0)]),
    _P(<_S>[_Mv(12.0, 5.0), _Ln(12.0, 19.0)]),
  ]);

  /// lucide `rotateCcw`
  static const LucideIcon rotateCcw = LucideIcon(<_Prim>[
    _P(<_S>[_Mv(3.0, 12.0), _Ar(9.0, 9.0, 0.0, true, false, 12.0, 3.0), _Ar(9.75, 9.75, 0.0, false, false, 5.26, 5.74), _Ln(3.0, 8.0)]),
    _P(<_S>[_Mv(3.0, 3.0), _Ln(3.0, 8.0), _Ln(8.0, 8.0)]),
  ]);

  /// lucide `search`
  static const LucideIcon search = LucideIcon(<_Prim>[
    _P(<_S>[_Mv(21.0, 21.0), _Ln(16.66, 16.66)]),
    _C(11.0, 11.0, 8.0),
  ]);

  /// lucide `send`
  static const LucideIcon send = LucideIcon(<_Prim>[
    _P(<_S>[_Mv(14.536, 21.686), _Ar(0.5, 0.5, 0.0, false, false, 15.473, 21.662), _Ln(21.973, 2.662), _Ar(0.496, 0.496, 0.0, false, false, 21.338, 2.027), _Ln(2.338, 8.527), _Ar(0.5, 0.5, 0.0, false, false, 2.314, 9.464), _Ln(10.244, 12.644), _Ar(2.0, 2.0, 0.0, false, true, 11.356, 13.754), _Cl()]),
    _P(<_S>[_Mv(21.854, 2.147), _Ln(10.914, 13.086)]),
  ]);

  /// lucide `shield`
  static const LucideIcon shield = LucideIcon(<_Prim>[
    _P(<_S>[_Mv(20.0, 13.0), _Cu(20.0, 18.0, 16.5, 20.5, 12.34, 21.95), _Ar(1.0, 1.0, 0.0, false, true, 11.67, 21.94), _Cu(7.5, 20.5, 4.0, 18.0, 4.0, 13.0), _Ln(4.0, 6.0), _Ar(1.0, 1.0, 0.0, false, true, 5.0, 5.0), _Cu(7.0, 5.0, 9.5, 3.8, 11.24, 2.28), _Ar(1.17, 1.17, 0.0, false, true, 12.76, 2.28), _Cu(14.51, 3.81, 17.0, 5.0, 19.0, 5.0), _Ar(1.0, 1.0, 0.0, false, true, 20.0, 6.0), _Cl()]),
  ]);

  /// lucide `shieldCheck`
  static const LucideIcon shieldCheck = LucideIcon(<_Prim>[
    _P(<_S>[_Mv(20.0, 13.0), _Cu(20.0, 18.0, 16.5, 20.5, 12.34, 21.95), _Ar(1.0, 1.0, 0.0, false, true, 11.67, 21.94), _Cu(7.5, 20.5, 4.0, 18.0, 4.0, 13.0), _Ln(4.0, 6.0), _Ar(1.0, 1.0, 0.0, false, true, 5.0, 5.0), _Cu(7.0, 5.0, 9.5, 3.8, 11.24, 2.28), _Ar(1.17, 1.17, 0.0, false, true, 12.76, 2.28), _Cu(14.51, 3.81, 17.0, 5.0, 19.0, 5.0), _Ar(1.0, 1.0, 0.0, false, true, 20.0, 6.0), _Cl()]),
    _P(<_S>[_Mv(9.0, 12.0), _Ln(11.0, 14.0), _Ln(15.0, 10.0)]),
  ]);

  /// lucide `slidersHorizontal`
  static const LucideIcon slidersHorizontal = LucideIcon(<_Prim>[
    _P(<_S>[_Mv(10.0, 5.0), _Ln(3.0, 5.0)]),
    _P(<_S>[_Mv(12.0, 19.0), _Ln(3.0, 19.0)]),
    _P(<_S>[_Mv(14.0, 3.0), _Ln(14.0, 7.0)]),
    _P(<_S>[_Mv(16.0, 17.0), _Ln(16.0, 21.0)]),
    _P(<_S>[_Mv(21.0, 12.0), _Ln(12.0, 12.0)]),
    _P(<_S>[_Mv(21.0, 19.0), _Ln(16.0, 19.0)]),
    _P(<_S>[_Mv(21.0, 5.0), _Ln(14.0, 5.0)]),
    _P(<_S>[_Mv(8.0, 10.0), _Ln(8.0, 14.0)]),
    _P(<_S>[_Mv(8.0, 12.0), _Ln(3.0, 12.0)]),
  ]);

  /// lucide `smile`
  static const LucideIcon smile = LucideIcon(<_Prim>[
    _C(12.0, 12.0, 10.0),
    _P(<_S>[_Mv(8.0, 14.0), _Cu(8.0, 14.0, 9.5, 16.0, 12.0, 16.0), _Cu(14.5, 16.0, 16.0, 14.0, 16.0, 14.0)]),
    _L(9.0, 9.0, 9.01, 9.0),
    _L(15.0, 9.0, 15.01, 9.0),
  ]);

  /// lucide `user`
  static const LucideIcon user = LucideIcon(<_Prim>[
    _P(<_S>[_Mv(19.0, 21.0), _Ln(19.0, 19.0), _Ar(4.0, 4.0, 0.0, false, false, 15.0, 15.0), _Ln(9.0, 15.0), _Ar(4.0, 4.0, 0.0, false, false, 5.0, 19.0), _Ln(5.0, 21.0)]),
    _C(12.0, 7.0, 4.0),
  ]);

  /// lucide `userPlus`
  static const LucideIcon userPlus = LucideIcon(<_Prim>[
    _P(<_S>[_Mv(16.0, 21.0), _Ln(16.0, 19.0), _Ar(4.0, 4.0, 0.0, false, false, 12.0, 15.0), _Ln(6.0, 15.0), _Ar(4.0, 4.0, 0.0, false, false, 2.0, 19.0), _Ln(2.0, 21.0)]),
    _C(9.0, 7.0, 4.0),
    _L(19.0, 8.0, 19.0, 14.0),
    _L(22.0, 11.0, 16.0, 11.0),
  ]);

  /// lucide `users`
  static const LucideIcon users = LucideIcon(<_Prim>[
    _P(<_S>[_Mv(16.0, 21.0), _Ln(16.0, 19.0), _Ar(4.0, 4.0, 0.0, false, false, 12.0, 15.0), _Ln(6.0, 15.0), _Ar(4.0, 4.0, 0.0, false, false, 2.0, 19.0), _Ln(2.0, 21.0)]),
    _P(<_S>[_Mv(16.0, 3.128), _Ar(4.0, 4.0, 0.0, false, true, 16.0, 10.872)]),
    _P(<_S>[_Mv(22.0, 21.0), _Ln(22.0, 19.0), _Ar(4.0, 4.0, 0.0, false, false, 19.0, 15.13)]),
    _C(9.0, 7.0, 4.0),
  ]);

  /// lucide `video`
  static const LucideIcon video = LucideIcon(<_Prim>[
    _P(<_S>[_Mv(16.0, 13.0), _Ln(21.223, 16.482), _Ar(0.5, 0.5, 0.0, false, false, 22.0, 16.066), _Ln(22.0, 7.87), _Ar(0.5, 0.5, 0.0, false, false, 21.248, 7.438), _Ln(16.0, 10.5)]),
    _R(2.0, 6.0, 14.0, 12.0, 2.0, 2.0),
  ]);

  /// lucide `x`
  static const LucideIcon x = LucideIcon(<_Prim>[
    _P(<_S>[_Mv(18.0, 6.0), _Ln(6.0, 18.0)]),
    _P(<_S>[_Mv(6.0, 6.0), _Ln(18.0, 18.0)]),
  ]);
}
