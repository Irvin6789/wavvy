# Wavvy — Flutter

The `src/` React + Vite design ported to Flutter (targeting Flutter 3.44.7 /
Dart 3.12.2), with **zero third-party packages**: `dependencies:` contains only
`flutter`.

## Running

```sh
flutter pub get     # resolves offline — nothing comes from pub.dev
flutter run
```

## How the two external assets are handled

Neither is fetched at runtime, and neither adds a dependency.

| Asset | Source | How it gets in |
| --- | --- | --- |
| Lucide icons | `lucide-static` on registry.npmjs.org | `tool/download_assets.sh` unpacks the tarball; `tool/generate_icons.mjs` parses the SVGs and emits `lib/icons/lucide_icons.dart` as native `CustomPainter` geometry |
| Zain font | `github.com/googlefonts/zain` | `tool/download_assets.sh` copies the four TTFs plus `OFL.txt` into `assets/fonts/`, declared in `pubspec.yaml` |

Regenerate both with:

```sh
./tool/download_assets.sh
```

### The SVG path parser

`tool/svg_path_parser.mjs` is a complete implementation of the SVG path-data
grammar: every command (`M m L l H h V v C c S s Q q T t A a Z z`), implicit
repeated commands, the implicit-lineto rule after `m`/`M`, exponent notation,
sign-as-separator, and **packed numbers** — `1.09.09` is two numbers, `1.09` and
`0.09`, because a number may contain only one decimal point. That case is real:
Lucide's `message-circle` contains `a2 2 0 0 1 1.099.092`. Arc flags may also be
packed against their neighbours (`a10 10 0 1 0-4 8`, and even `110-4`).

Parsed output maps 1:1 onto `dart:ui`'s `Path` API, so arcs become `arcToPoint`
rather than being approximated.

## Verifying changes

`flutter analyze` is the real check. Where a SDK is unavailable, the repo ships
static substitutes:

```sh
node tool/svg_path_parser.test.mjs   # 23 parser tests
node tool/check_dart.mjs             # static checks over lib/
node tool/check_dart.test.mjs        # 24 self-tests proving the checker bites
```

`tool/check_dart.mjs` verifies:

1. delimiter balance, using a lexer that understands comments, raw and
   triple-quoted strings, and `${...}` interpolation;
2. that every relative import resolves and no third-party package is imported;
3. that material-only symbols (`Material`, `TextField`, `Scaffold`, …) are only
   used in files that import `package:flutter/material.dart` — Dart imports are
   not transitive;
4. that no `BoxDecoration` pairs a non-uniform `Border` (e.g. `Border(bottom:)`)
   with a `borderRadius`, which is a runtime assert;
5. that every `Lucide.foo` exists;
6. that every capitalised identifier resolves locally, via a direct import, or
   to a known framework symbol (`tool/flutter_symbols.txt`);
7. that `pubspec.yaml` declares no third-party dependency and every font asset
   it lists is present.

## Notes on the port

- **`PhoneFrame.tsx` is not ported.** The 375×812 bezel was a desktop browser
  preview mock, not part of the product. The app runs full-bleed edge to edge
  (`SystemUiMode.edgeToEdge`) and handles genuine device insets: top bars pad by
  `viewPadding.top` to clear the status bar and notch, the nav bar and the
  members sheet pad by `viewPadding.bottom` to clear the home indicator, and the
  chat composer tracks `viewInsets.bottom` so it rises with the keyboard.
- **Animations.** CSS keyframes became explicit controllers. Effects that loop
  on unrelated periods (2s, 2.4s, 2.6s, 2.8s, 3s…) share a free-running clock
  (`lib/widgets/motion.dart`) rather than one wrapping controller, which would
  make any sub-animation whose period doesn't divide it jump at the wrap point.
- **Interaction.** The reaction tray opens on long-press; the web build used a
  double click, which has no touch equivalent.
- **Layout.** Fixed pixel widths from the mock (e.g. `maxWidth: 260` on a
  bubble) became fractions of the real screen width, so the UI adapts across
  device sizes instead of assuming a 375pt viewport.

## Layout of the code

```
lib/
  main.dart              entrypoint; edge-to-edge + portrait lock
  app.dart               screen switch (was src/App.tsx), theme
  theme/                 colours and Zain text styles
  data/                  chats, onboarding and profile fixtures
  icons/lucide_icons.dart  GENERATED — do not edit
  widgets/               shared UI: glass bars, avatars, composer, motion
  screens/               splash, onboarding, auth/, home/
tool/                    asset download, icon generation, static checks
```
