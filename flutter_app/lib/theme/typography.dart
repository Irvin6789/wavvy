import 'package:flutter/widgets.dart';

import 'colors.dart';

/// The whole product is set in Zain (bundled under assets/fonts, declared in
/// pubspec.yaml — never fetched at runtime).
const String kFontFamily = 'Zain';

const FontWeight kLight = FontWeight.w300;
const FontWeight kRegular = FontWeight.w400;
const FontWeight kMedium = FontWeight.w500;
const FontWeight kSemiBold = FontWeight.w600;
const FontWeight kBold = FontWeight.w700;
const FontWeight kExtraBold = FontWeight.w800;

/// Zain only ships 300/400/700/800. Flutter would otherwise synthesise 500 and
/// 600 by picking the nearest face; snapping explicitly keeps rendering
/// identical across platforms.
FontWeight _snap(FontWeight w) => switch (w.value) {
      <= 300 => kLight,
      <= 500 => kRegular,
      <= 750 => kBold,
      _ => kExtraBold,
    };

/// Builds a Zain [TextStyle]. `height` is expressed as a CSS-style unitless
/// line-height multiplier, matching the React source.
TextStyle zain({
  double size = 14,
  FontWeight weight = kRegular,
  Color color = kDeep,
  double? letterSpacing,
  double? height,
  TextDecoration? decoration,
}) {
  return TextStyle(
    fontFamily: kFontFamily,
    fontSize: size,
    fontWeight: _snap(weight),
    color: color,
    letterSpacing: letterSpacing,
    height: height,
    decoration: decoration,
    leadingDistribution: TextLeadingDistribution.even,
  );
}
