import 'package:flutter/widgets.dart';

import '../icons/lucide_icons.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import 'ui.dart';

/// A rounded-square initials avatar, optionally badged with the green presence
/// dot or the little group marker the design puts on group rows.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.initials,
    this.size = 50,
    this.radius = 16,
    this.background,
    this.foreground = kCrimson,
    this.fontSize = 16,
    this.fontWeight = kBold,
    this.online = false,
    this.group = false,
    this.gradient,
    this.border,
  });

  final String initials;
  final double size;
  final double radius;
  final Color? background;
  final Color foreground;
  final double fontSize;
  final FontWeight fontWeight;
  final bool online;
  final bool group;
  final Gradient? gradient;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // The badges overhang the avatar box, so the stack must not clip.
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: gradient == null ? (background ?? kCrimson.a8(0x14)) : null,
              gradient: gradient,
              borderRadius: BorderRadius.circular(radius),
              border: border,
            ),
            child: Text(
              initials,
              style: zain(
                size: fontSize,
                weight: fontWeight,
                color: gradient != null ? kBg : foreground,
              ),
            ),
          ),
          if (group)
            Positioned(
              bottom: -3,
              right: -3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: kCrimson,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: kBg, width: 2),
                ),
                child: const Icn(Lucide.users, size: 9, color: kBg, strokeWidth: 2.5),
              ),
            ),
          if (online && !group)
            Positioned(
              bottom: 1,
              right: 1,
              child: Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: kOnline,
                  shape: BoxShape.circle,
                  border: Border.all(color: kBg, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
