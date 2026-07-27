#!/usr/bin/env node
/**
 * Self-test for tool/check_dart.mjs: plants known-bad Dart into a scratch
 * package and asserts the checker reports it, so a green run of the real check
 * means something.
 *
 * Run with:  node tool/check_dart.test.mjs
 */
import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const CHECKER = path.join(ROOT, 'tool/check_dart.mjs');

const GOOD_PUBSPEC = `name: wavvy
environment:
  sdk: ">=3.12.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter

flutter:
  fonts:
    - family: Zain
      fonts:
        - asset: assets/fonts/Zain-Regular.ttf
          weight: 400
`;

/** Builds a throwaway package containing `files`, then runs the checker on it. */
function run(files, { pubspec = GOOD_PUBSPEC } = {}) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'wavvy-check-'));
  try {
    fs.mkdirSync(path.join(dir, 'lib/icons'), { recursive: true });
    fs.mkdirSync(path.join(dir, 'assets/fonts'), { recursive: true });
    fs.writeFileSync(path.join(dir, 'assets/fonts/Zain-Regular.ttf'), '');
    fs.writeFileSync(path.join(dir, 'assets/fonts/OFL.txt'), 'OFL');
    fs.writeFileSync(path.join(dir, 'pubspec.yaml'), pubspec);
    fs.writeFileSync(
      path.join(dir, 'lib/icons/lucide_icons.dart'),
      `class LucideIcon {
  const LucideIcon();
}

class Lucide {
  static const LucideIcon users = LucideIcon();
  static const LucideIcon check = LucideIcon();
}
`,
    );
    for (const [rel, src] of Object.entries(files)) {
      const p = path.join(dir, rel);
      fs.mkdirSync(path.dirname(p), { recursive: true });
      fs.writeFileSync(p, src);
    }
    // The checker resolves paths from its own location, so copy it in.
    fs.mkdirSync(path.join(dir, 'tool'), { recursive: true });
    fs.copyFileSync(CHECKER, path.join(dir, 'tool/check_dart.mjs'));
    fs.copyFileSync(
      path.join(ROOT, 'tool/flutter_symbols.txt'),
      path.join(dir, 'tool/flutter_symbols.txt'),
    );

    try {
      const stdout = execFileSync(process.execPath, [path.join(dir, 'tool/check_dart.mjs')], {
        encoding: 'utf8',
        stdio: ['ignore', 'pipe', 'pipe'],
      });
      return { code: 0, output: stdout };
    } catch (err) {
      return { code: err.status, output: `${err.stdout ?? ''}${err.stderr ?? ''}` };
    }
  } finally {
    fs.rmSync(dir, { recursive: true, force: true });
  }
}

let passed = 0;
const tests = [];
const test = (name, fn) => tests.push([name, fn]);

test('accepts a clean file', () => {
  const r = run({
    'lib/main.dart': `import 'package:flutter/widgets.dart';

/// A doc comment with an unbalanced ( paren and a "quote.
const String kGreeting = 'hello ( world )';
const String kInterp = 'count: \${<int>[1, 2].length} items';

Widget build() => Container(
      decoration: BoxDecoration(
        color: const Color(0xFF000000),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF111111)),
      ),
    );
`,
  });
  assert.equal(r.code, 0, r.output);
});

test('flags an unbalanced brace', () => {
  const r = run({ 'lib/main.dart': 'void main() { if (true) { }\n' });
  assert.equal(r.code, 1);
  assert.match(r.output, /unclosed '\{'/);
});

test('flags a mismatched delimiter', () => {
  const r = run({ 'lib/main.dart': 'final List<int> a = <int>[1, 2);\n' });
  assert.equal(r.code, 1);
  assert.match(r.output, /closes/);
});

test('flags an unresolved relative import', () => {
  const r = run({ 'lib/main.dart': "import 'nope/missing.dart';\n" });
  assert.equal(r.code, 1);
  assert.match(r.output, /does not resolve/);
});

test('accepts a relative import that resolves', () => {
  const r = run({
    'lib/main.dart': "import 'theme/colors.dart';\n",
    'lib/theme/colors.dart': 'const int kX = 1;\n',
  });
  assert.equal(r.code, 0, r.output);
});

test('flags a third-party package import', () => {
  const r = run({ 'lib/main.dart': "import 'package:google_fonts/google_fonts.dart';\n" });
  assert.equal(r.code, 1);
  assert.match(r.output, /third-party package import/);
});

test('flags Border(bottom:) next to a borderRadius', () => {
  const r = run({
    'lib/main.dart': `final d = BoxDecoration(
  borderRadius: BorderRadius.circular(20),
  border: Border(bottom: BorderSide(color: Color(0xFF000000))),
);
`,
  });
  assert.equal(r.code, 1);
  assert.match(r.output, /non-uniform Border/);
});

test('allows Border.all next to a borderRadius', () => {
  const r = run({
    'lib/main.dart': `final d = BoxDecoration(
  borderRadius: BorderRadius.circular(20),
  border: Border.all(color: const Color(0xFF000000), width: 1.5),
);
`,
  });
  assert.equal(r.code, 0, r.output);
});

test('allows a non-uniform Border with no borderRadius', () => {
  const r = run({
    'lib/main.dart': `final d = BoxDecoration(
  border: Border(top: BorderSide(color: Color(0xFF000000))),
);
`,
  });
  assert.equal(r.code, 0, r.output);
});

test('flags an unknown Lucide icon', () => {
  const r = run({
    'lib/main.dart': "import 'icons/lucide_icons.dart';\nfinal x = Lucide.notARealIcon;\n",
  });
  assert.equal(r.code, 1);
  assert.match(r.output, /unknown icon Lucide\.notARealIcon/);
});

test('accepts a known Lucide icon', () => {
  const r = run({ 'lib/main.dart': "import 'icons/lucide_icons.dart';\nfinal x = Lucide.users;\n" });
  assert.equal(r.code, 0, r.output);
});

test('ignores icon-like text inside strings and comments', () => {
  const r = run({
    'lib/main.dart': `// Lucide.ghostIcon is only mentioned here.
const String s = 'Lucide.alsoNotReal';
`,
  });
  assert.equal(r.code, 0, r.output);
});

test('flags a third-party dependency in pubspec', () => {
  const r = run(
    { 'lib/main.dart': 'const int x = 1;\n' },
    {
      pubspec: `name: wavvy

dependencies:
  flutter:
    sdk: flutter
  lucide_icons_flutter: ^3.0.0
`,
    },
  );
  assert.equal(r.code, 1);
  assert.match(r.output, /third-party dependencies are not allowed/);
});

test('flags a missing font asset', () => {
  const r = run(
    { 'lib/main.dart': 'const int x = 1;\n' },
    {
      pubspec: `name: wavvy

dependencies:
  flutter:
    sdk: flutter

flutter:
  fonts:
    - family: Zain
      fonts:
        - asset: assets/fonts/Zain-Nope.ttf
`,
    },
  );
  assert.equal(r.code, 1);
  assert.match(r.output, /is missing/);
});

test('handles triple-quoted and raw strings', () => {
  const r = run({
    'lib/main.dart': `const String a = r'raw \\ ( unbalanced';
const String b = """
  a triple ) quoted } string
""";
const int c = 1;
`,
  });
  assert.equal(r.code, 0, r.output);
});

test('handles nested interpolation containing strings', () => {
  const r = run({
    'lib/main.dart': `String f(List<String> xs) => 'n=\${xs.where((String s) => s == 'a').length}';
`,
  });
  assert.equal(r.code, 0, r.output);
});

test('flags a material-only symbol without the material import', () => {
  const r = run({
    'lib/main.dart': `import 'package:flutter/widgets.dart';

Widget wrap(Widget child) => Material(type: MaterialType.transparency, child: child);
`,
  });
  assert.equal(r.code, 1);
  assert.match(r.output, /'Material' comes from package:flutter\/material\.dart/);
});

test('accepts a material-only symbol when material.dart is imported', () => {
  const r = run({
    'lib/main.dart': `import 'package:flutter/material.dart';

Widget wrap(Widget child) => Material(type: MaterialType.transparency, child: child);
`,
  });
  assert.equal(r.code, 0, r.output);
});

test('does not flag a material symbol that only appears in a comment', () => {
  const r = run({
    'lib/main.dart': `import 'package:flutter/widgets.dart';

// Scaffold is intentionally avoided here.
const int x = 1;
`,
  });
  assert.equal(r.code, 0, r.output);
});

test('does not treat a member access as a material-only symbol', () => {
  const r = run({
    'lib/main.dart': `import 'package:flutter/widgets.dart';

final x = someTheme.Material;
`,
  });
  assert.equal(r.code, 0, r.output);
});

test('flags a symbol from a sibling file that is not imported', () => {
  // Dart imports are not transitive: helper.dart importing shared.dart does
  // not make Shared visible in main.dart.
  const r = run({
    'lib/shared.dart': 'class Shared {}\n',
    'lib/helper.dart': "import 'shared.dart';\nfinal Shared a = Shared();\n",
    'lib/main.dart': "import 'helper.dart';\nfinal Shared b = Shared();\n",
  });
  assert.equal(r.code, 1);
  assert.match(r.output, /'Shared' is not defined in this file and is not imported/);
});

test('accepts a sibling symbol that is imported directly', () => {
  const r = run({
    'lib/shared.dart': 'class Shared {}\n',
    'lib/main.dart': "import 'shared.dart';\nfinal Shared b = Shared();\n",
  });
  assert.equal(r.code, 0, r.output);
});

test('flags a typo in a framework class name', () => {
  const r = run({
    'lib/main.dart': "import 'package:flutter/widgets.dart';\nfinal w = Contaner();\n",
  });
  assert.equal(r.code, 1);
  assert.match(r.output, /'Contaner' is not defined/);
});

test('accepts a private class declared in the same file', () => {
  const r = run({
    'lib/main.dart': `import 'package:flutter/widgets.dart';

class _Hidden {
  const _Hidden();
}

final _Hidden h = const _Hidden();
`,
  });
  assert.equal(r.code, 0, r.output);
});

for (const [name, fn] of tests) {
  try {
    fn();
    passed++;
  } catch (err) {
    console.error(`FAIL  ${name}\n      ${err.message}`);
    process.exitCode = 1;
  }
}
console.log(`${passed}/${tests.length} checker self-tests passed`);
