import 'package:flutter/widgets.dart';

/// Palette ported from `src/constants/colors.ts`.
const Color kCrimson = Color(0xFF005F92);
const Color kDeep = Color(0xFF02023A);
const Color kCrimsonLight = Color(0xFF0096C7);
const Color kBg = Color(0xFFFFFFFF);
const Color kFieldBg = Color(0xFFF0F1F5);
const Color kFieldIcon = Color(0xFF94A3B8);

/// Supporting greys and accents used inline throughout the React screens.
const Color kSlate = Color(0xFF64748B);
const Color kMuted = Color(0xFF94A3B8);
const Color kMutedSoft = Color(0xFFB0B8C5);
const Color kHairline = Color(0xFFF4F6F9);
const Color kDivider = Color(0xFFE2E8F0);
const Color kOnline = Color(0xFF22C55E);
const Color kDotIdle = Color(0xFFD1D5DB);
const Color kChevron = Color(0xFFC4CAD4);
const Color kChipBorder = Color(0xFFEBEBF0);
const Color kStatDivider = Color(0xFFE4E8EF);
const Color kAvatarRing = Color(0xFFE8EBF0);
const Color kChatCanvas = Color(0xFFF7F9FC);
const Color kDanger = Color(0xFFE11D48);
const Color kDangerBg = Color(0xFFFFF1F2);
const Color kDangerBorder = Color(0xFFFECDD3);
const Color kIconGrey = Color(0xFF555555);
const Color kCloseGrey = Color(0xFF888888);
const Color kInputText = Color(0xFF1A1A2E);

/// The React source writes translucent brand colours as CSS 8-digit hex, e.g.
/// `${CRIMSON}14`. [a8] carries those suffixes over unchanged: write
/// `kCrimson.a8(0x14)` for `${CRIMSON}14`.
///
/// The method is deliberately not called `a` — `Color.a` already exists as the
/// normalised alpha channel, and an instance member always wins over an
/// extension member.
extension HexAlpha on Color {
  Color a8(int alpha) => withAlpha(alpha);
}

/// `linear-gradient(135deg, CRIMSON_LIGHT, CRIMSON)`
const LinearGradient kBrandGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: <Color>[kCrimsonLight, kCrimson],
);
