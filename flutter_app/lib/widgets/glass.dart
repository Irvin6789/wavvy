import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// Which edge gets the 1px hairline that the CSS drew with `border-bottom` /
/// `border-top`.
enum HairlineEdge { none, top, bottom }

/// The frosted bars the React app builds with
/// `background: rgba(255,255,255,x); backdrop-filter: blur(y)`.
///
/// The hairline is painted as a positioned 1px line rather than through
/// `Border(bottom: ...)`, because a non-uniform [Border] combined with a
/// `borderRadius` trips a runtime assert in [BoxDecoration].
class GlassBar extends StatelessWidget {
  const GlassBar({
    super.key,
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.blur = 8,
    this.tint = const Color(0x8CFFFFFF),
    this.edge = HairlineEdge.none,
    this.hairlineColor = const Color(0x0F000000),
  });

  final Widget child;
  final BorderRadius borderRadius;
  final double blur;
  final Color tint;
  final HairlineEdge edge;
  final Color hairlineColor;

  @override
  Widget build(BuildContext context) {
    final Widget hairline = Container(height: 1, color: hairlineColor);

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(color: tint),
          child: Stack(
            children: <Widget>[
              child,
              if (edge == HairlineEdge.top)
                Positioned(top: 0, left: 0, right: 0, child: hairline),
              if (edge == HairlineEdge.bottom)
                Positioned(bottom: 0, left: 0, right: 0, child: hairline),
            ],
          ),
        ),
      ),
    );
  }
}

/// A tap target with no ink, no splash and no minimum size — the React design
/// is built from bare `<button>` elements with custom padding.
class Tappable extends StatelessWidget {
  const Tappable({
    super.key,
    required this.child,
    this.onTap,
    this.behavior = HitTestBehavior.opaque,
  });

  final Widget child;
  final VoidCallback? onTap;
  final HitTestBehavior behavior;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: behavior,
      onTap: onTap,
      child: child,
    );
  }
}
