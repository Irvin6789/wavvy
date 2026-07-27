import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../icons/lucide_icons.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/glass.dart';
import '../../widgets/ui.dart';

/// `src/screens/auth/SignInScreen.tsx`
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, required this.onSignUp, required this.onHome});

  final VoidCallback onSignUp;
  final VoidCallback onHome;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets insets = MediaQuery.viewPaddingOf(context);

    return ColoredBox(
      color: kBg,
      child: SafeArea(
        // The form is vertically centred; scrolling keeps it reachable once the
        // keyboard is up or on short devices.
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height -
                  insets.top -
                  insets.bottom -
                  MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: <Widget>[
                      const AppIcon(size: 68),
                      const SizedBox(height: 12),
                      Text(
                        'Welcome back',
                        style: zain(size: 28, weight: kExtraBold, color: kDeep, height: 1.2),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sign in to continue to Wavvy',
                        style: zain(size: 15, weight: kLight, color: kSlate),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      IconField(
                        icon: const Icn(
                          Lucide.atSign,
                          size: 16,
                          color: kFieldIcon,
                          strokeWidth: 1.8,
                        ),
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
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => widget.onHome(),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Tappable(
                          onTap: () {},
                          child: Text(
                            'Forgot password?',
                            style: zain(size: 13, weight: kSemiBold, color: kCrimson),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      CTAButton(
                        label: 'Sign In',
                        onTap: () {
                          SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
                          widget.onHome();
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          const Expanded(child: SizedBox(height: 1, child: ColoredBox(color: kDivider))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('OR', style: zain(size: 12, color: kMuted)),
                          ),
                          const Expanded(child: SizedBox(height: 1, child: ColoredBox(color: kDivider))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text.rich(
                          TextSpan(
                            children: <InlineSpan>[
                              TextSpan(
                                text: "Don't have an account? ",
                                style: zain(size: 14, weight: kLight, color: kSlate),
                              ),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.baseline,
                                baseline: TextBaseline.alphabetic,
                                child: Tappable(
                                  onTap: widget.onSignUp,
                                  child: Text(
                                    'Create one',
                                    style: zain(size: 14, weight: kBold, color: kCrimson),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
