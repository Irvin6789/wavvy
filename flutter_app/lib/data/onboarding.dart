/// Ported from `src/data/onboarding.ts`.
import 'package:flutter/foundation.dart';

import '../icons/lucide_icons.dart';

@immutable
class OnboardingSlide {
  const OnboardingSlide({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final LucideIcon icon;
  final String title;
  final String subtitle;
}

const List<OnboardingSlide> kOnboardingSlides = <OnboardingSlide>[
  OnboardingSlide(
    icon: Lucide.messageCircle,
    title: 'Real-time Messaging',
    subtitle: 'Share texts, photos, voice notes, and files in an instant.',
  ),
  OnboardingSlide(
    icon: Lucide.users,
    title: 'Build Your Tribe',
    subtitle: 'Create group chats and communities around what matters to you.',
  ),
  OnboardingSlide(
    icon: Lucide.shieldCheck,
    title: 'Private by Default',
    subtitle: 'End-to-end encrypted. No ads, no tracking — just pure messaging.',
  ),
];
