import 'package:flutter/widgets.dart';

import '../../data/profile.dart';
import '../../icons/lucide_icons.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/glass.dart';
import '../../widgets/ui.dart';

/// `src/screens/home/ProfileScreen.tsx`
///
/// Rendered inside the Home tab's scroll view, so this widget lays out its own
/// content only — the surrounding padding for the nav bar lives in HomeScreen.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.bottomPadding = 0});

  /// Extra space under the log-out button so it clears the nav bar and the
  /// home indicator.
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: kBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Avatar + name
          Padding(
            padding: const EdgeInsets.only(top: 28, bottom: 20),
            child: Column(
              children: <Widget>[
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Container(
                        width: 80,
                        height: 80,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: kBrandGradient,
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Text(
                          'YO',
                          style: zain(size: 28, weight: kExtraBold, color: kBg),
                        ),
                      ),
                      Positioned(
                        bottom: -3,
                        right: -3,
                        child: Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: kCrimson,
                            shape: BoxShape.circle,
                            border: Border.all(color: kBg, width: 2),
                          ),
                          child: const Icn(
                            Lucide.camera,
                            size: 11,
                            color: kBg,
                            strokeWidth: 2.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Your Name',
                  style: zain(size: 20, weight: kExtraBold, color: kDeep, letterSpacing: -0.3),
                ),
                const SizedBox(height: 3),
                Text('@yourhandle', style: zain(size: 13, color: kMuted)),
              ],
            ),
          ),

          // Stats
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: kFieldBg,
              borderRadius: BorderRadius.circular(18),
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: <Widget>[
                for (int i = 0; i < kProfileStats.length; i++) ...<Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Column(
                        children: <Widget>[
                          Text(
                            kProfileStats[i].value,
                            style: zain(
                              size: 20,
                              weight: kExtraBold,
                              color: kDeep,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            kProfileStats[i].label,
                            style: zain(size: 11, color: kMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (i < kProfileStats.length - 1)
                    const SizedBox(width: 1, child: ColoredBox(color: kStatDivider)),
                ],
              ],
            ),
          ),

          // Edit profile
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
            child: Tappable(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 11),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kCrimson.a8(0x12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kCrimson.a8(0x30), width: 1.5),
                ),
                child: Text(
                  'Edit Profile',
                  style: zain(size: 14, weight: kBold, color: kCrimson, letterSpacing: 0.2),
                ),
              ),
            ),
          ),

          // Settings sections
          for (final ProfileSection section in kProfileSections)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 2, bottom: 8),
                    child: Text(
                      section.title.toUpperCase(),
                      style: zain(
                        size: 11,
                        weight: kBold,
                        color: kMuted,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: kFieldBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: <Widget>[
                        for (int i = 0; i < section.rows.length; i++) ...<Widget>[
                          _SettingsRow(row: section.rows[i]),
                          if (i < section.rows.length - 1)
                            const SizedBox(
                              height: 1,
                              child: ColoredBox(color: Color(0x0D000000)),
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Log out
          Padding(
            padding: EdgeInsets.fromLTRB(20, 14, 20, 24 + bottomPadding),
            child: Tappable(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: kDangerBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kDangerBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icn(Lucide.logOut, size: 16, color: kDanger, strokeWidth: 2),
                    const SizedBox(width: 8),
                    Text('Log out', style: zain(size: 14, weight: kBold, color: kDanger)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.row});

  final ProfileRow row;

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: kCrimson.a8(0x14),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icn(row.icon, size: 17, color: kCrimson, strokeWidth: 1.9),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(row.label, style: zain(size: 14, weight: kSemiBold, color: kDeep)),
                  const SizedBox(height: 1),
                  Text(row.sub, style: zain(size: 12, weight: kLight, color: kMuted)),
                ],
              ),
            ),
            const Icn(Lucide.chevronRight, size: 16, color: kChevron, strokeWidth: 2),
          ],
        ),
      ),
    );
  }
}
