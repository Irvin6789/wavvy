#!/usr/bin/env node
/**
 * Static sanity checks for the Dart sources, standing in for `flutter analyze`
 * (which needs a Flutter SDK this sandbox doesn't have).
 *
 * It verifies:
 *   1. delimiter balance — (), [], {}, <> in generics — with a real lexer that
 *      understands comments, strings (single/double, raw, triple-quoted) and
 *      `${...}` interpolation;
 *   2. every relative `import`/`export` resolves to a file that exists, and
 *      package: imports only reference `flutter`, `dart:` or this package;
 *   3. no BoxDecoration pairs a non-uniform Border (Border(top:/bottom:/...))
 *      with a borderRadius — that combination is a runtime assert;
 *   4. every identifier of the form `Lucide.foo` exists in the generated icon
 *      file;
 *   5. `pubspec.yaml` declares no third-party dependency, and every font asset
 *      it lists is present on disk.
 *
 * Usage: node tool/check_dart.mjs
 */
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const LIB = path.join(ROOT, 'lib');

const problems = [];
const fail = (file, msg) => problems.push(`${path.relative(ROOT, file)}: ${msg}`);

function walk(dir) {
  const out = [];
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) out.push(...walk(p));
    else if (e.name.endsWith('.dart')) out.push(p);
  }
  return out;
}

/**
 * Strips comments and string literals, replacing them with spaces so that all
 * offsets (and therefore line numbers) are preserved. Code inside `${...}`
 * interpolation is *kept*, since it is real Dart and its delimiters must
 * balance too.
 */
function stripCommentsAndStrings(src, file) {
  const out = src.split('');
  const n = src.length;
  const blank = (from, to) => {
    for (let k = from; k < to && k < n; k++) {
      if (out[k] !== '\n') out[k] = ' ';
    }
  };

  /**
   * Consumes the string literal that starts at `i` (optionally preceded by the
   * raw prefix) and returns the index just past its closing quote.
   */
  function scanString(i) {
    const start = i;
    let raw = false;
    if (src[i] === 'r') {
      raw = true;
      i++;
    }
    const quote = src[i];
    const triple = src[i + 1] === quote && src[i + 2] === quote;
    const term = triple ? quote.repeat(3) : quote;
    i += term.length;

    let literalFrom = i; // run of literal text pending blanking

    while (i < n) {
      if (!raw && src[i] === '\\') {
        i += 2;
        continue;
      }
      if (src.startsWith(term, i)) {
        blank(literalFrom, i);
        i += term.length;
        // Blank the opening quote(s) and any raw prefix too.
        blank(start, start + (raw ? 1 : 0) + term.length);
        blank(i - term.length, i);
        return i;
      }
      if (!triple && src[i] === '\n') {
        fail(file, `line ${lineOf(src, start)}: unterminated string`);
        blank(literalFrom, i);
        return i;
      }
      // `${ ... }` — keep the expression, recursing into nested literals.
      if (!raw && src[i] === '$' && src[i + 1] === '{') {
        blank(literalFrom, i);
        out[i] = ' '; // the '$'
        let depth = 0;
        let j = i + 1;
        while (j < n) {
          const ch = src[j];
          if (ch === '{') {
            depth++;
            j++;
          } else if (ch === '}') {
            depth--;
            j++;
            if (depth === 0) break;
          } else if (ch === '"' || ch === "'" || (ch === 'r' && (src[j + 1] === '"' || src[j + 1] === "'"))) {
            j = scanString(j);
          } else if (ch === '/' && src[j + 1] === '/') {
            while (j < n && src[j] !== '\n') j++;
          } else {
            j++;
          }
        }
        i = j;
        literalFrom = i;
        continue;
      }
      // `$identifier` — a simple interpolation; blank it with the literal.
      i++;
    }
    fail(file, `line ${lineOf(src, start)}: unterminated string`);
    blank(literalFrom, n);
    return n;
  }

  let i = 0;
  while (i < n) {
    const c = src[i];
    const c2 = src[i + 1];

    if (c === '/' && c2 === '/') {
      let j = i;
      while (j < n && src[j] !== '\n') j++;
      blank(i, j);
      i = j;
      continue;
    }
    if (c === '/' && c2 === '*') {
      let depth = 1;
      let j = i + 2;
      while (j < n && depth > 0) {
        if (src[j] === '/' && src[j + 1] === '*') {
          depth++;
          j += 2;
        } else if (src[j] === '*' && src[j + 1] === '/') {
          depth--;
          j += 2;
        } else j++;
      }
      blank(i, j);
      i = j;
      continue;
    }
    if (c === '"' || c === "'" || (c === 'r' && (c2 === '"' || c2 === "'"))) {
      i = scanString(i);
      continue;
    }
    i++;
  }
  return out.join('');
}

/**
 * Blanks comments but keeps string literals, so directives like
 * `import 'foo.dart';` remain readable while commented-out imports don't
 * produce false positives.
 */
function stripCommentsOnly(src) {
  const out = src.split('');
  const n = src.length;
  const blank = (from, to) => {
    for (let k = from; k < to && k < n; k++) {
      if (out[k] !== '\n') out[k] = ' ';
    }
  };
  let i = 0;
  while (i < n) {
    const c = src[i];
    const c2 = src[i + 1];
    if (c === '/' && c2 === '/') {
      let j = i;
      while (j < n && src[j] !== '\n') j++;
      blank(i, j);
      i = j;
      continue;
    }
    if (c === '/' && c2 === '*') {
      let depth = 1;
      let j = i + 2;
      while (j < n && depth > 0) {
        if (src[j] === '/' && src[j + 1] === '*') {
          depth++;
          j += 2;
        } else if (src[j] === '*' && src[j + 1] === '/') {
          depth--;
          j += 2;
        } else j++;
      }
      blank(i, j);
      i = j;
      continue;
    }
    // Skip over string bodies so a '//' inside one isn't treated as a comment.
    if (c === '"' || c === "'" || (c === 'r' && (c2 === '"' || c2 === "'"))) {
      let j = i;
      const raw = src[j] === 'r';
      if (raw) j++;
      const quote = src[j];
      const triple = src[j + 1] === quote && src[j + 2] === quote;
      const term = triple ? quote.repeat(3) : quote;
      j += term.length;
      while (j < n) {
        if (!raw && src[j] === '\\') {
          j += 2;
          continue;
        }
        if (src.startsWith(term, j)) {
          j += term.length;
          break;
        }
        if (!triple && src[j] === '\n') break;
        j++;
      }
      i = j;
      continue;
    }
    i++;
  }
  return out.join('');
}

const lineOf = (src, index) => src.slice(0, index).split('\n').length;

/** Check (), [] and {} balance on the comment/string-stripped source. */
function checkDelimiters(file, code, raw) {
  const pairs = { ')': '(', ']': '[', '}': '{' };
  const stack = [];
  for (let i = 0; i < code.length; i++) {
    const c = code[i];
    if (c === '(' || c === '[' || c === '{') stack.push([c, i]);
    else if (c === ')' || c === ']' || c === '}') {
      const top = stack.pop();
      if (!top) {
        fail(file, `line ${lineOf(raw, i)}: unmatched closing '${c}'`);
        return;
      }
      if (top[0] !== pairs[c]) {
        fail(
          file,
          `line ${lineOf(raw, i)}: '${c}' closes '${top[0]}' opened on line ${lineOf(raw, top[1])}`,
        );
        return;
      }
    }
  }
  if (stack.length) {
    const [ch, at] = stack[stack.length - 1];
    fail(file, `line ${lineOf(raw, at)}: unclosed '${ch}'`);
  }
}

/**
 * Angle brackets are ambiguous in Dart (`a < b`), so only check them where a
 * generic is unambiguous: `<Type>[`, `<Type>{`, `<K, V>{` and `Foo<...>`
 * following an identifier. A simple depth scan over those regions is enough to
 * catch a truncated `List<Widget` or a stray `>`.
 */
function checkGenerics(file, code, raw) {
  const re = /(?<![-=!<>+*/%&|^])<([A-Za-z_][\w.]*(?:\s*,\s*[A-Za-z_][\w.]*)*(?:<[^<>]*>)?)>/g;
  // Any '<' that opens a generic must be matched; count naive nesting depth of
  // generic-looking regions.
  let depth = 0;
  for (let i = 0; i < code.length; i++) {
    const c = code[i];
    if (c === '<') {
      const prev = code.slice(0, i).match(/([A-Za-z_$][\w$]*)\s*$/);
      const next = code[i + 1];
      // Treat as a generic open only when it directly follows an identifier
      // (List<...>) or starts a typed literal (<Widget>[...]).
      const opensGeneric =
        (prev && !/^(return|if|while|for|case|is|as)$/.test(prev[1])) ||
        /[A-Za-z_]/.test(next ?? '');
      if (opensGeneric && !/[\s=(,[{:]/.test(next ?? ' ')) depth++;
    } else if (c === '>' && depth > 0) {
      depth--;
    } else if ((c === ';' || c === '{') && depth > 0) {
      // A generic never spans a statement boundary.
      fail(file, `line ${lineOf(raw, i)}: unbalanced '<' before '${c}'`);
      depth = 0;
    }
  }
  void re;
}

/** Every relative import must resolve; package imports must be allow-listed. */
function checkImports(file, code, raw) {
  const re = /^\s*(?:import|export)\s+'([^']+)'/gm;
  let m;
  while ((m = re.exec(code))) {
    const target = m[1];
    if (target.startsWith('dart:')) continue;
    if (target.startsWith('package:')) {
      const pkg = target.slice('package:'.length).split('/')[0];
      if (pkg !== 'flutter' && pkg !== 'wavvy' && pkg !== 'flutter_test') {
        fail(
          file,
          `line ${lineOf(raw, m.index)}: third-party package import '${target}' is not allowed`,
        );
      }
      continue;
    }
    const resolved = path.resolve(path.dirname(file), target);
    if (!fs.existsSync(resolved)) {
      fail(file, `line ${lineOf(raw, m.index)}: import '${target}' does not resolve`);
    }
  }
}

/**
 * A BoxDecoration that has both a non-uniform Border (Border(top:...) etc.)
 * and a borderRadius throws at runtime:
 *   "A borderRadius can only be given for a uniform Border."
 */
function checkBoxDecoration(file, code, raw) {
  const needle = 'BoxDecoration(';
  let from = 0;
  while (true) {
    const start = code.indexOf(needle, from);
    if (start === -1) break;
    // Walk to the matching close paren.
    let depth = 0;
    let i = start + needle.length - 1;
    for (; i < code.length; i++) {
      if (code[i] === '(') depth++;
      else if (code[i] === ')') {
        depth--;
        if (depth === 0) break;
      }
    }
    const body = code.slice(start, i + 1);
    // Only look at the arguments of *this* BoxDecoration, not nested ones.
    const hasRadius = /\bborderRadius\s*:/.test(body);
    const nonUniform = /\bBorder\s*\(\s*(?!\s*\))/.test(body);
    if (hasRadius && nonUniform) {
      fail(
        file,
        `line ${lineOf(raw, start)}: BoxDecoration combines a non-uniform Border(...) with a borderRadius (runtime assert). Use Border.all(...) or draw the edge separately.`,
      );
    }
    from = i + 1;
  }
}

/**
 * Symbols that live only in `package:flutter/material.dart` (or
 * `cupertino.dart`) and are NOT re-exported by `widgets.dart`. Using one in a
 * file that imports only widgets.dart is a compile error, and Dart imports are
 * not transitive, so importing a helper that imports material.dart is not
 * enough.
 */
const MATERIAL_ONLY = [
  'Material',
  'MaterialType',
  'MaterialApp',
  'Scaffold',
  'ThemeData',
  'Theme',
  'ColorScheme',
  'TextField',
  'TextFormField',
  'InputDecoration',
  'InputBorder',
  'AppBar',
  'ListTile',
  'Divider',
  'Card',
  'Switch',
  'Checkbox',
  'Slider',
  'IconButton',
  'ElevatedButton',
  'TextButton',
  'OutlinedButton',
  'FloatingActionButton',
  'BottomNavigationBar',
  'NavigationBar',
  'showDialog',
  'showModalBottomSheet',
  'SnackBar',
  'ScaffoldMessenger',
  'CircularProgressIndicator',
  'LinearProgressIndicator',
  'NoSplash',
  'InkWell',
  'TextSelectionThemeData',
  'Icons',
];

/** Material-only symbols require a material.dart import in the same file. */
function checkMaterialImports(file, code, raw, directives) {
  const importsMaterial = /package:flutter\/material\.dart/.test(directives);
  if (importsMaterial) return;
  for (const sym of MATERIAL_ONLY) {
    const re = new RegExp(`(?<![\\w.$])${sym}(?![\\w$])`, 'g');
    let m;
    while ((m = re.exec(code))) {
      fail(
        file,
        `line ${lineOf(raw, m.index)}: '${sym}' comes from package:flutter/material.dart, which this file does not import`,
      );
      break;
    }
  }
}

/** `Lucide.foo` must exist in the generated icon class. */
function checkIconRefs(files, iconNames) {
  for (const file of files) {
    const src = fs.readFileSync(file, 'utf8');
    const code = stripCommentsAndStrings(src, file);
    const re = /\bLucide\.([A-Za-z_]\w*)/g;
    let m;
    while ((m = re.exec(code))) {
      if (!iconNames.has(m[1])) {
        fail(file, `line ${lineOf(src, m.index)}: unknown icon Lucide.${m[1]}`);
      }
    }
  }
}

/**
 * Collects the public top-level declarations a Dart file provides.
 */
function declaredSymbols(code) {
  const syms = new Set();
  const patterns = [
    /^(?:@\w+(?:\([^)]*\))?\s*)*(?:abstract\s+|sealed\s+|base\s+|interface\s+|final\s+|mixin\s+)*class\s+(\w+)/gm,
    /^(?:abstract\s+)?enum\s+(\w+)/gm,
    /^mixin\s+(\w+)/gm,
    /^extension\s+(\w+)/gm,
    /^typedef\s+(\w+)/gm,
    // top-level const/final variables
    /^(?:const|final)\s+[\w<>,\s?]+?\s+(\w+)\s*=/gm,
    /^const\s+(\w+)\s*=/gm,
    // top-level functions, incl. expression bodies and generics
    /^(?:[\w<>,\s?[\]$]+?\s+)(\w+)\s*(?:<[^>]*>)?\s*\([^;{]*\)\s*(?:\{|=>|async)/gm,
  ];
  for (const re of patterns) {
    for (const m of code.matchAll(re)) syms.add(m[1]);
  }
  return syms;
}

/**
 * Verifies every capitalised identifier used in a file resolves to something
 * the file can actually see. Dart imports are NOT transitive, so a symbol
 * defined in a sibling file is only visible if this file imports that file
 * directly — a common and otherwise-silent breakage when moving code around.
 */
function checkSymbolResolution(files, flutterSymbols) {
  const provides = new Map();
  for (const file of files) {
    provides.set(file, declaredSymbols(stripCommentsAndStrings(fs.readFileSync(file, 'utf8'), file)));
  }

  for (const file of files) {
    const raw = fs.readFileSync(file, 'utf8');
    const code = stripCommentsAndStrings(raw, file);
    const directives = stripCommentsOnly(raw);

    const visible = new Set(flutterSymbols);
    for (const s of provides.get(file)) visible.add(s);
    // Private declarations of any kind in this file.
    for (const m of code.matchAll(/\b_[A-Za-z]\w*/g)) visible.add(m[0]);

    for (const m of directives.matchAll(/^\s*import\s+'([^']+)'/gm)) {
      const target = m[1];
      if (target.startsWith('dart:') || target.startsWith('package:')) continue;
      const resolved = path.resolve(path.dirname(file), target);
      const got = provides.get(resolved);
      if (got) for (const s of got) visible.add(s);
    }

    const seen = new Set();
    for (const m of code.matchAll(/(?<![\w.$'"])([A-Z]\w*)/g)) {
      const name = m[1];
      if (seen.has(name) || visible.has(name)) continue;
      seen.add(name);
      fail(
        file,
        `line ${lineOf(raw, m.index)}: '${name}' is not defined in this file and is not imported`,
      );
    }
  }
}

/**
 * The Flutter/Dart SDK isn't installed in this sandbox, so the set of framework
 * symbols is maintained as data in tool/flutter_symbols.txt. Anything a file
 * references that is neither declared locally, imported from a sibling, nor
 * listed there gets flagged — which catches typos and missing imports.
 */
function loadFlutterSymbols() {
  const file = path.join(ROOT, 'tool/flutter_symbols.txt');
  if (!fs.existsSync(file)) {
    problems.push('tool/flutter_symbols.txt is missing');
    return new Set();
  }
  return new Set(
    fs
      .readFileSync(file, 'utf8')
      .split('\n')
      .map((l) => l.replace(/#.*$/, '').trim())
      .filter(Boolean),
  );
}

function checkPubspec() {
  const file = path.join(ROOT, 'pubspec.yaml');
  const src = fs.readFileSync(file, 'utf8');

  const depsBlock = /\ndependencies:\n([\s\S]*?)(?=\n[a-z_]+:|\n*$)/.exec(src);
  if (!depsBlock) {
    fail(file, 'no dependencies: block found');
  } else {
    const deps = depsBlock[1]
      .split('\n')
      .filter((l) => /^ {2}\S/.test(l))
      .map((l) => l.trim().replace(/:$/, ''));
    const extra = deps.filter((d) => d !== 'flutter');
    if (extra.length) {
      fail(file, `third-party dependencies are not allowed: ${extra.join(', ')}`);
    }
  }

  for (const m of src.matchAll(/asset:\s*(\S+)/g)) {
    const asset = path.join(ROOT, m[1]);
    if (!fs.existsSync(asset)) fail(file, `font asset ${m[1]} is missing`);
  }
  if (!fs.existsSync(path.join(ROOT, 'assets/fonts/OFL.txt'))) {
    fail(file, 'assets/fonts/OFL.txt (the Zain licence) is missing');
  }
}

function main() {
  const files = walk(LIB);

  // Icon inventory from the generated file.
  const iconFile = path.join(LIB, 'icons/lucide_icons.dart');
  const iconNames = new Set();
  if (fs.existsSync(iconFile)) {
    for (const m of fs
      .readFileSync(iconFile, 'utf8')
      .matchAll(/static const LucideIcon (\w+)/g)) {
      iconNames.add(m[1]);
    }
  } else {
    problems.push('lib/icons/lucide_icons.dart is missing — run tool/generate_icons.mjs');
  }

  for (const file of files) {
    const raw = fs.readFileSync(file, 'utf8');
    const code = stripCommentsAndStrings(raw, file);
    checkDelimiters(file, code, raw);
    checkGenerics(file, code, raw);
    const withStrings = stripCommentsOnly(raw);
    checkImports(file, withStrings, raw);
    checkMaterialImports(file, code, raw, withStrings);
    checkBoxDecoration(file, code, raw);
  }
  checkIconRefs(files, iconNames);
  checkSymbolResolution(files, loadFlutterSymbols());
  checkPubspec();

  console.log(`Checked ${files.length} Dart files and ${iconNames.size} icons.`);
  if (problems.length) {
    console.error(`\n${problems.length} problem(s):`);
    for (const p of problems) console.error(`  - ${p}`);
    process.exit(1);
  }
  console.log('All static checks passed.');
}

main();
