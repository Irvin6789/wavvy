import 'dart:async';

import 'package:flutter/widgets.dart';

import '../data/onboarding.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/glass.dart';
import '../widgets/ui.dart';

/// `src/screens/OnboardingScreen.tsx`
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  bool _animating = false;
  Timer? _timer;

  bool get _isLast => _step == kOnboardingSlides.length - 1;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// The React version fades the slide out, swaps the content, then fades back
  /// in — 240ms each way.
  void _transitionTo(int next) {
    if (_animating) return;
    setState(() => _animating = true);
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 240), () {
      if (!mounted) return;
      setState(() {
        _step = next;
        _animating = false;
      });
    });
  }

  void _next() {
    if (_animating) return;
    if (_isLast) {
      widget.onDone();
      return;
    }
    _transitionTo(_step + 1);
  }

  void _back() {
    if (_animating || _step == 0) return;
    _transitionTo(_step - 1);
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets insets = MediaQuery.viewPaddingOf(context);
    final OnboardingSlide slide = kOnboardingSlides[_step];

    return ColoredBox(
      color: kBg,
      child: Column(
        children: <Widget>[
          // Top row clears the status bar / notch.
          Padding(
            padding: EdgeInsets.fromLTRB(20, insets.top + 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                ChevronBackButton(onTap: _back, invisible: _step == 0),
                Tappable(
                  onTap: widget.onDone,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                    child: Text(
                      'Skip',
                      style: zain(size: 15, weight: kMedium, color: kMuted),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Icon + copy.
          Expanded(
            child: AnimatedOpacity(
              opacity: _animating ? 0 : 1,
              duration: const Duration(milliseconds: 220),
              child: AnimatedSlide(
                offset: _animating ? const Offset(0, 0.03) : Offset.zero,
                duration: const Duration(milliseconds: 220),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 120,
                        height: 120,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: kCrimson.a8(0x14),
                          shape: BoxShape.circle,
                        ),
                        child: Icn(
                          slide.icon,
                          size: 52,
                          color: kCrimson,
                          strokeWidth: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        slide.title,
                        textAlign: TextAlign.center,
                        style: zain(
                          size: 26,
                          weight: kExtraBold,
                          color: kDeep,
                          height: 1.25,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        slide.subtitle,
                        textAlign: TextAlign.center,
                        style: zain(size: 15, weight: kLight, color: kSlate, height: 1.65),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Dots + CTA, lifted clear of the home indicator.
          Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 36 + insets.bottom),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(kOnboardingSlides.length, (int i) {
                    final bool active = i == _step;
                    return Padding(
                      padding: EdgeInsets.only(
                        right: i == kOnboardingSlides.length - 1 ? 0 : 8,
                      ),
                      child: Tappable(
                        onTap: () {
                          if (!_animating && i != _step) _transitionTo(i);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          width: active ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: active ? kCrimson : kDotIdle,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 28),
                CTAButton(label: _isLast ? 'Get Started' : 'Next', onTap: _next),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
