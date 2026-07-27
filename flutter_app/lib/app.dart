import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/auth/sign_in_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/colors.dart';
import 'theme/typography.dart';

enum AppScreen { splash, onboarding, signIn, signUp, home }

/// `src/App.tsx` — the top-level screen switch.
///
/// The React version wrapped everything in a 375x812 `PhoneFrame` bezel; that
/// was a desktop browser preview mock, so it is deliberately not ported. This
/// runs full-bleed on the real device instead, and every screen accounts for
/// the genuine safe-area insets itself.
class WavvyApp extends StatelessWidget {
  const WavvyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wavvy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: kFontFamily,
        scaffoldBackgroundColor: kBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kCrimson,
          primary: kCrimson,
          surface: kBg,
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: kCrimson,
          selectionColor: kCrimson.a8(0x33),
          selectionHandleColor: kCrimson,
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: const Color(0x00000000),
      ),
      home: const _Root(),
    );
  }
}

class _Root extends StatefulWidget {
  const _Root();

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  AppScreen _screen = AppScreen.splash;

  /// 1 = the new screen enters from the right, -1 = from the left.
  int _authDir = 0;

  void _goTo(AppScreen next, {int dir = 0}) {
    setState(() {
      _authDir = dir;
      _screen = next;
    });
  }

  Widget _current() {
    switch (_screen) {
      case AppScreen.splash:
        return SplashScreen(onDone: () => _goTo(AppScreen.onboarding));
      case AppScreen.onboarding:
        return OnboardingScreen(
          onDone: () => _goTo(AppScreen.signIn, dir: 1),
        );
      case AppScreen.signIn:
        return SignInScreen(
          onSignUp: () => _goTo(AppScreen.signUp, dir: 1),
          onHome: () => _goTo(AppScreen.home),
        );
      case AppScreen.signUp:
        return SignUpScreen(
          onBack: () => _goTo(AppScreen.signIn, dir: -1),
          onHome: () => _goTo(AppScreen.home),
        );
      case AppScreen.home:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Dark status-bar glyphs over the light UI, and a transparent system
      // chrome so the app really is edge to edge.
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0x00000000),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0x00000000),
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Color(0x00000000),
      ),
      child: Scaffold(
        backgroundColor: kBg,
        // Screens position themselves against the raw insets, and the chat
        // composer reads viewInsets directly, so the Scaffold must not resize.
        resizeToAvoidBottomInset: false,
        body: _AuthSlide(
          key: ValueKey<AppScreen>(_screen),
          direction: _authDir,
          child: _current(),
        ),
      ),
    );
  }
}

/// `authSlideLeft` / `authSlideRight` — a 40% horizontal drift with a fade.
class _AuthSlide extends StatefulWidget {
  const _AuthSlide({super.key, required this.direction, required this.child});

  final int direction;
  final Widget child;

  @override
  State<_AuthSlide> createState() => _AuthSlideState();
}

class _AuthSlideState extends State<_AuthSlide> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.direction == 0) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      builder: (BuildContext context, Widget? child) {
        final double t = Curves.easeOutCubic.transform(_c.value);
        return Opacity(
          opacity: t,
          child: FractionalTranslation(
            translation: Offset(0.4 * widget.direction * (1 - t), 0),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
