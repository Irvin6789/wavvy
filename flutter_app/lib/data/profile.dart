/// Ported from `src/data/profile.ts`.
import 'package:flutter/foundation.dart';

import '../icons/lucide_icons.dart';

@immutable
class ProfileStat {
  const ProfileStat({required this.label, required this.value});
  final String label;
  final String value;
}

const List<ProfileStat> kProfileStats = <ProfileStat>[
  ProfileStat(label: 'Friends', value: '248'),
  ProfileStat(label: 'Groups', value: '14'),
  ProfileStat(label: 'Media', value: '1.2k'),
];

@immutable
class ProfileRow {
  const ProfileRow({required this.icon, required this.label, required this.sub});
  final LucideIcon icon;
  final String label;
  final String sub;
}

@immutable
class ProfileSection {
  const ProfileSection({required this.title, required this.rows});
  final String title;
  final List<ProfileRow> rows;
}

const List<ProfileSection> kProfileSections = <ProfileSection>[
  ProfileSection(
    title: 'Account',
    rows: <ProfileRow>[
      ProfileRow(icon: Lucide.bell, label: 'Notifications', sub: 'Mentions & messages'),
      ProfileRow(icon: Lucide.moon, label: 'Appearance', sub: 'Dark mode, themes'),
      ProfileRow(icon: Lucide.link, label: 'Linked devices', sub: '2 active sessions'),
    ],
  ),
  ProfileSection(
    title: 'Privacy',
    rows: <ProfileRow>[
      ProfileRow(icon: Lucide.shield, label: 'Privacy & safety', sub: 'Blocked, visibility'),
      ProfileRow(icon: Lucide.lock, label: 'Two-step verify', sub: 'Enabled'),
    ],
  ),
];
