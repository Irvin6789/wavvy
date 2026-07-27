import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../icons/lucide_icons.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/glass.dart';
import '../../widgets/ui.dart';

@immutable
class _SignUpStep {
  const _SignUpStep({required this.label, required this.title, required this.subtitle});
  final String label;
  final String title;
  final String subtitle;
}

const List<_SignUpStep> _steps = <_SignUpStep>[
  _SignUpStep(
    label: 'Account',
    title: 'Create your\naccount',
    subtitle: 'Start with your email and birthday',
  ),
  _SignUpStep(
    label: 'Credentials',
    title: 'Choose your\nidentity',
    subtitle: 'Pick a username and set a password',
  ),
  _SignUpStep(
    label: 'Profile',
    title: "You're almost\nthere",
    subtitle: 'How will your friends see you?',
  ),
];

/// `src/screens/auth/SignUpScreen.tsx`
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, required this.onBack, required this.onHome});

  final VoidCallback onBack;
  final VoidCallback onHome;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  int _step = 0;

  final TextEditingController _email = TextEditingController();
  final TextEditingController _birthday = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  final TextEditingController _displayName = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _birthdayFocus = FocusNode();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmFocus = FocusNode();
  final FocusNode _displayNameFocus = FocusNode();

  bool get _isFirst => _step == 0;
  bool get _isLast => _step == _steps.length - 1;

  @override
  void dispose() {
    for (final TextEditingController c in <TextEditingController>[
      _email,
      _birthday,
      _username,
      _password,
      _confirm,
      _displayName,
    ]) {
      c.dispose();
    }
    for (final FocusNode f in <FocusNode>[
      _emailFocus,
      _birthdayFocus,
      _usernameFocus,
      _passwordFocus,
      _confirmFocus,
      _displayNameFocus,
    ]) {
      f.dispose();
    }
    super.dispose();
  }

  void _goBack() {
    FocusScope.of(context).unfocus();
    if (_isFirst) {
      widget.onBack();
      return;
    }
    setState(() => _step -= 1);
  }

  void _goNext() {
    FocusScope.of(context).unfocus();
    if (!_isLast) {
      setState(() => _step += 1);
      return;
    }
    widget.onHome();
  }

  Widget _illustration() {
    const List<(Color, LucideIcon, Color)> configs = <(Color, LucideIcon, Color)>[
      (kCrimson, Lucide.mail, kCrimson),
      (kDeep, Lucide.lock, kDeep),
      (kCrimson, Lucide.user, kCrimson),
    ];
    final (Color tint, LucideIcon icon, Color color) = configs[_step];
    return Container(
      width: 80,
      height: 80,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tint.a8(0x12),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Icn(icon, size: 38, color: color, strokeWidth: 1.5),
    );
  }

  List<Widget> _fields() {
    switch (_step) {
      case 0:
        return <Widget>[
          IconField(
            icon: const Icn(Lucide.mail, size: 16, color: kFieldIcon, strokeWidth: 1.8),
            controller: _email,
            focusNode: _emailFocus,
            placeholder: 'Email address',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _birthdayFocus.requestFocus(),
          ),
          const SizedBox(height: 12),
          IconField(
            icon: const Icn(Lucide.cake, size: 16, color: kFieldIcon, strokeWidth: 1.8),
            controller: _birthday,
            focusNode: _birthdayFocus,
            placeholder: 'Birthday',
            keyboardType: TextInputType.datetime,
            textInputAction: TextInputAction.done,
          ),
        ];
      case 1:
        return <Widget>[
          IconField(
            icon: const Icn(Lucide.atSign, size: 16, color: kFieldIcon, strokeWidth: 1.8),
            controller: _username,
            focusNode: _usernameFocus,
            placeholder: 'Username',
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _passwordFocus.requestFocus(),
          ),
          const SizedBox(height: 12),
          PasswordField(
            controller: _password,
            focusNode: _passwordFocus,
            placeholder: 'Password',
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _confirmFocus.requestFocus(),
          ),
          const SizedBox(height: 12),
          PasswordField(
            icon: const Icn(
              Lucide.shieldCheck,
              size: 16,
              color: kFieldIcon,
              strokeWidth: 1.8,
            ),
            controller: _confirm,
            focusNode: _confirmFocus,
            placeholder: 'Confirm password',
            textInputAction: TextInputAction.done,
          ),
        ];
      default:
        return <Widget>[
          IconField(
            icon: const Icn(Lucide.user, size: 16, color: kFieldIcon, strokeWidth: 1.8),
            controller: _displayName,
            focusNode: _displayNameFocus,
            placeholder: 'Display name',
            textInputAction: TextInputAction.done,
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _displayName,
            builder: (BuildContext context, TextEditingValue value, _) {
              final String name = value.text.trim();
              if (name.isEmpty) return const SizedBox.shrink();
              final String initials = name
                  .split(RegExp(r'\s+'))
                  .where((String w) => w.isNotEmpty)
                  .map((String w) => w[0])
                  .join()
                  .toUpperCase();
              return Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: kFieldBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          gradient: kBrandGradient,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          initials.length > 2 ? initials.substring(0, 2) : initials,
                          style: zain(size: 14, weight: kBold, color: kBg),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(name, style: zain(size: 14, weight: kBold, color: kDeep)),
                          Text(
                            'Preview',
                            style: zain(size: 12, weight: kLight, color: kMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              'You can change this later in settings.',
              style: zain(size: 12, weight: kLight, color: kMuted),
            ),
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets viewPadding = MediaQuery.viewPaddingOf(context);
    final double keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final _SignUpStep current = _steps[_step];

    return ColoredBox(
      color: kBg,
      child: Column(
        children: <Widget>[
          // Top bar clears the status bar.
          Padding(
            padding: EdgeInsets.fromLTRB(20, viewPadding.top + 12, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                ChevronBackButton(onTap: _goBack),
                Row(
                  children: List<Widget>.generate(_steps.length, (int i) {
                    return Padding(
                      padding: EdgeInsets.only(right: i == _steps.length - 1 ? 0 : 5),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOut,
                        width: i == _step ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i <= _step ? kCrimson : kDivider,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Hero
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _illustration(),
                        const SizedBox(height: 14),
                        StepPill(label: current.label),
                        const SizedBox(height: 8),
                        Text(
                          current.title,
                          style: zain(
                            size: 26,
                            weight: kExtraBold,
                            color: kDeep,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          current.subtitle,
                          style: zain(size: 14, weight: kLight, color: kSlate),
                        ),
                      ],
                    ),
                  ),
                  // Fields
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _fields(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // CTA rides above the keyboard and clears the home indicator.
          Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              16,
              24,
              28 + (keyboard > 0 ? 0 : viewPadding.bottom) + keyboard,
            ),
            child: CTAButton(
              label: _isLast ? 'Create Account' : 'Continue',
              onTap: _goNext,
            ),
          ),
        ],
      ),
    );
  }
}
