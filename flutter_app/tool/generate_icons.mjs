#!/usr/bin/env node
/**
 * Generates lib/icons/lucide_icons.dart from the `lucide-static` npm package.
 *
 * The app must not depend on any pub.dev package, so Lucide icons are baked in
 * as plain Dart data: each icon becomes a list of primitives (paths, circles,
 * rects, lines) on Lucide's 24x24 grid, replayed at paint time by a
 * CustomPainter with a stroke whose width scales with the requested size.
 *
 * Usage:
 *   node tool/generate_icons.mjs [--pkg <dir>] [--out <file>]
 *
 * `--pkg` is the extracted lucide-static package directory; it defaults to
 * ../.lucide-static, which download_assets.sh populates from
 * registry.npmjs.org.
 */
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { parsePathData } from './svg_path_parser.mjs';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(HERE, '..');

function parseArgs(argv) {
  const args = { pkg: path.join(ROOT, '.lucide-static'), out: path.join(ROOT, 'lib/icons/lucide_icons.dart') };
  for (let i = 0; i < argv.length; i += 2) {
    const key = argv[i].replace(/^--/, '');
    if (!(key in args)) throw new Error(`Unknown flag ${argv[i]}`);
    if (argv[i + 1] === undefined) throw new Error(`Flag ${argv[i]} needs a value`);
    args[key] = path.resolve(argv[i + 1]);
  }
  return args;
}

/** Icons referenced by the Wavvy UI, as kebab-case lucide-static file names. */
const ICONS = [
  'at-sign',
  'bell',
  'cake',
  'camera',
  'check',
  'check-check',
  'chevron-down',
  'chevron-left',
  'chevron-right',
  'circle-user',
  'compass',
  'eye',
  'eye-off',
  'globe',
  'link',
  'link-2',
  'lock',
  'log-out',
  'mail',
  'message-circle',
  'mic',
  'moon',
  'more-vertical',
  'paperclip',
  'pencil',
  'phone',
  'pin',
  'plus',
  'rotate-ccw',
  'search',
  'send',
  'shield',
  'shield-check',
  'sliders-horizontal',
  'smile',
  'user',
  'user-plus',
  'users',
  'video',
  'x',
];

const camel = (kebab) =>
  kebab
    .split('-')
    .map((w, i) => (i === 0 ? w : w[0].toUpperCase() + w.slice(1)))
    .join('');

/** Minimal attribute reader for the flat, well-formed lucide SVG files. */
function readAttrs(tag) {
  const attrs = {};
  const re = /([a-zA-Z][a-zA-Z0-9-]*)\s*=\s*"([^"]*)"/g;
  let m;
  while ((m = re.exec(tag))) attrs[m[1]] = m[2];
  return attrs;
}

const num = (v, name, file) => {
  const n = Number(v);
  if (!Number.isFinite(n)) throw new Error(`Bad ${name} in ${file}: ${JSON.stringify(v)}`);
  return n;
};

/** Render a double the way Dart wants it (no bare "5." and no "5" for a double). */
function d2s(v) {
  if (!Number.isFinite(v)) throw new Error(`Non-finite coordinate: ${v}`);
  // Six decimals is well beyond what a 24-unit grid needs.
  let s = (Math.round(v * 1e6) / 1e6).toString();
  if (s.includes('e') || s.includes('E')) s = v.toFixed(6);
  if (!s.includes('.')) s += '.0';
  return s;
}

/** Convert one <path d="..."> into Dart source for a `_P([...])` primitive. */
function pathToDart(d, file) {
  let segs;
  try {
    segs = parsePathData(d);
  } catch (err) {
    throw new Error(`Failed to parse path in ${file}: ${err.message}`);
  }
  const parts = [];
  for (const s of segs) {
    switch (s.op) {
      case 'M':
        parts.push(`_Mv(${d2s(s.x)}, ${d2s(s.y)})`);
        break;
      case 'L':
        parts.push(`_Ln(${d2s(s.x)}, ${d2s(s.y)})`);
        break;
      case 'C':
        parts.push(
          `_Cu(${d2s(s.x1)}, ${d2s(s.y1)}, ${d2s(s.x2)}, ${d2s(s.y2)}, ${d2s(s.x)}, ${d2s(s.y)})`,
        );
        break;
      case 'Q':
        parts.push(`_Qd(${d2s(s.x1)}, ${d2s(s.y1)}, ${d2s(s.x)}, ${d2s(s.y)})`);
        break;
      case 'A':
        parts.push(
          `_Ar(${d2s(s.rx)}, ${d2s(s.ry)}, ${d2s(s.rot)}, ${s.largeArc}, ${s.sweep}, ${d2s(s.x)}, ${d2s(s.y)})`,
        );
        break;
      case 'Z':
        parts.push('_Cl()');
        break;
      default:
        throw new Error(`Unhandled segment ${s.op} in ${file}`);
    }
  }
  return `_P(<_S>[${parts.join(', ')}])`;
}

function svgToDart(svg, file) {
  const prims = [];
  const tagRe = /<(path|circle|rect|line|ellipse|polyline|polygon)\b([^>]*)\/?>/g;
  let m;
  while ((m = tagRe.exec(svg))) {
    const [, tag, rest] = m;
    const a = readAttrs(rest);
    switch (tag) {
      case 'path':
        if (!a.d) throw new Error(`<path> without d in ${file}`);
        prims.push(pathToDart(a.d, file));
        break;
      case 'circle':
        prims.push(
          `_C(${d2s(num(a.cx, 'cx', file))}, ${d2s(num(a.cy, 'cy', file))}, ${d2s(num(a.r, 'r', file))})`,
        );
        break;
      case 'ellipse':
        prims.push(
          `_E(${d2s(num(a.cx, 'cx', file))}, ${d2s(num(a.cy, 'cy', file))}, ${d2s(num(a.rx, 'rx', file))}, ${d2s(num(a.ry, 'ry', file))})`,
        );
        break;
      case 'rect': {
        const x = num(a.x ?? '0', 'x', file);
        const y = num(a.y ?? '0', 'y', file);
        const w = num(a.width, 'width', file);
        const h = num(a.height, 'height', file);
        const rx = a.rx !== undefined ? num(a.rx, 'rx', file) : a.ry !== undefined ? num(a.ry, 'ry', file) : 0;
        const ry = a.ry !== undefined ? num(a.ry, 'ry', file) : rx;
        prims.push(`_R(${d2s(x)}, ${d2s(y)}, ${d2s(w)}, ${d2s(h)}, ${d2s(rx)}, ${d2s(ry)})`);
        break;
      }
      case 'line':
        prims.push(
          `_L(${d2s(num(a.x1, 'x1', file))}, ${d2s(num(a.y1, 'y1', file))}, ${d2s(num(a.x2, 'x2', file))}, ${d2s(num(a.y2, 'y2', file))})`,
        );
        break;
      case 'polyline':
      case 'polygon': {
        const pts = a.points.trim().split(/[\s,]+/).map(Number);
        if (pts.length < 4 || pts.length % 2 !== 0) throw new Error(`Bad points in ${file}`);
        const segs = [`_Mv(${d2s(pts[0])}, ${d2s(pts[1])})`];
        for (let i = 2; i < pts.length; i += 2) segs.push(`_Ln(${d2s(pts[i])}, ${d2s(pts[i + 1])})`);
        if (tag === 'polygon') segs.push('_Cl()');
        prims.push(`_P(<_S>[${segs.join(', ')}])`);
        break;
      }
    }
  }
  if (prims.length === 0) throw new Error(`No drawable shapes found in ${file}`);
  return prims;
}

function main() {
  const { pkg, out } = parseArgs(process.argv.slice(2));
  const iconDir = path.join(pkg, 'icons');
  if (!fs.existsSync(iconDir)) {
    console.error(
      `lucide-static not found at ${iconDir}\nRun tool/download_assets.sh first (it fetches the tarball from registry.npmjs.org).`,
    );
    process.exit(1);
  }
  const version = JSON.parse(fs.readFileSync(path.join(pkg, 'package.json'), 'utf8')).version;

  const entries = [];
  for (const name of ICONS) {
    const file = path.join(iconDir, `${name}.svg`);
    if (!fs.existsSync(file)) throw new Error(`Icon ${name} is missing from lucide-static ${version}`);
    const svg = fs.readFileSync(file, 'utf8');
    const viewBox = /viewBox="([^"]+)"/.exec(svg);
    if (!viewBox || viewBox[1].trim() !== '0 0 24 24') {
      throw new Error(`Unexpected viewBox in ${name}.svg: ${viewBox && viewBox[1]}`);
    }
    entries.push([camel(name), svgToDart(svg, `${name}.svg`)]);
  }

  const body = entries
    .map(([id, prims]) => {
      const inner = prims.map((p) => `    ${p},`).join('\n');
      return `  /// lucide \`${id}\`\n  static const LucideIcon ${id} = LucideIcon(<_Prim>[\n${inner}\n  ]);`;
    })
    .join('\n\n');

  const src = `// GENERATED FILE — DO NOT EDIT BY HAND.
//
// Produced by tool/generate_icons.mjs from lucide-static v${version}
// (fetched from registry.npmjs.org; Lucide is ISC licensed).
//
// Regenerate with:
//   ./tool/download_assets.sh && node tool/generate_icons.mjs
//
// Every icon is stored as geometry on Lucide's 24x24 grid and stroked at paint
// time, so it stays crisp at any size and needs no third-party dependency.

import 'dart:math' as math;
import 'package:flutter/widgets.dart';

/// The grid every Lucide icon is drawn on.
const double kLucideGrid = 24.0;

/// One drawing primitive on the 24x24 grid.
@immutable
sealed class _Prim {
  const _Prim();
  void addTo(Path path);
}

/// A path built from parsed SVG path data.
@immutable
class _P extends _Prim {
  const _P(this.segments);
  final List<_S> segments;

  @override
  void addTo(Path path) {
    for (final s in segments) {
      s.addTo(path);
    }
  }
}

@immutable
class _C extends _Prim {
  const _C(this.cx, this.cy, this.r);
  final double cx, cy, r;

  @override
  void addTo(Path path) {
    path.addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));
  }
}

@immutable
class _E extends _Prim {
  const _E(this.cx, this.cy, this.rx, this.ry);
  final double cx, cy, rx, ry;

  @override
  void addTo(Path path) {
    path.addOval(
      Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
    );
  }
}

@immutable
class _R extends _Prim {
  const _R(this.x, this.y, this.w, this.h, this.rx, this.ry);
  final double x, y, w, h, rx, ry;

  @override
  void addTo(Path path) {
    final rect = Rect.fromLTWH(x, y, w, h);
    if (rx <= 0 && ry <= 0) {
      path.addRect(rect);
    } else {
      path.addRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: Radius.elliptical(rx, ry),
          topRight: Radius.elliptical(rx, ry),
          bottomLeft: Radius.elliptical(rx, ry),
          bottomRight: Radius.elliptical(rx, ry),
        ),
      );
    }
  }
}

@immutable
class _L extends _Prim {
  const _L(this.x1, this.y1, this.x2, this.y2);
  final double x1, y1, x2, y2;

  @override
  void addTo(Path path) {
    path
      ..moveTo(x1, y1)
      ..lineTo(x2, y2);
  }
}

/// One segment of parsed SVG path data, already resolved to absolute
/// coordinates by tool/svg_path_parser.mjs.
@immutable
sealed class _S {
  const _S();
  void addTo(Path path);
}

class _Mv extends _S {
  const _Mv(this.x, this.y);
  final double x, y;
  @override
  void addTo(Path path) => path.moveTo(x, y);
}

class _Ln extends _S {
  const _Ln(this.x, this.y);
  final double x, y;
  @override
  void addTo(Path path) => path.lineTo(x, y);
}

class _Cu extends _S {
  const _Cu(this.x1, this.y1, this.x2, this.y2, this.x, this.y);
  final double x1, y1, x2, y2, x, y;
  @override
  void addTo(Path path) => path.cubicTo(x1, y1, x2, y2, x, y);
}

class _Qd extends _S {
  const _Qd(this.x1, this.y1, this.x, this.y);
  final double x1, y1, x, y;
  @override
  void addTo(Path path) => path.quadraticBezierTo(x1, y1, x, y);
}

class _Ar extends _S {
  const _Ar(this.rx, this.ry, this.rotation, this.largeArc, this.clockwise, this.x, this.y);
  final double rx, ry, rotation, x, y;
  final bool largeArc, clockwise;
  @override
  void addTo(Path path) => path.arcToPoint(
        Offset(x, y),
        radius: Radius.elliptical(rx, ry),
        rotation: rotation,
        largeArc: largeArc,
        clockwise: clockwise,
      );
}

class _Cl extends _S {
  const _Cl();
  @override
  void addTo(Path path) => path.close();
}

/// A Lucide icon: pure geometry, stroked when painted.
@immutable
class LucideIcon {
  const LucideIcon(this._prims);
  final List<_Prim> _prims;

  /// Builds the icon outline on the 24x24 grid.
  Path buildPath() {
    final path = Path();
    for (final p in _prims) {
      p.addTo(path);
    }
    return path;
  }
}

/// Renders a [LucideIcon] at [size] logical pixels.
///
/// [strokeWidth] is expressed on Lucide's 24-unit grid exactly like the
/// \`stroke-width\` prop of lucide-react, so the same numbers used by the React
/// design carry over unchanged.
class LucideIconWidget extends StatelessWidget {
  const LucideIconWidget(
    this.icon, {
    super.key,
    this.size = 24,
    this.color = const Color(0xFF000000),
    this.strokeWidth = 2,
    this.fill,
  });

  final LucideIcon icon;
  final double size;
  final Color color;
  final double strokeWidth;

  /// Optional fill painted underneath the stroke (mirrors the \`fill\` prop
  /// lucide-react accepts).
  final Color? fill;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _LucidePainter(
          icon: icon,
          color: color,
          strokeWidth: strokeWidth,
          fill: fill,
        ),
        isComplex: false,
      ),
    );
  }
}

class _LucidePainter extends CustomPainter {
  _LucidePainter({
    required this.icon,
    required this.color,
    required this.strokeWidth,
    required this.fill,
  });

  final LucideIcon icon;
  final Color color;
  final double strokeWidth;
  final Color? fill;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width, size.height) / kLucideGrid;
    if (scale <= 0) return;

    canvas.save();
    canvas.translate(
      (size.width - kLucideGrid * scale) / 2,
      (size.height - kLucideGrid * scale) / 2,
    );
    canvas.scale(scale);

    final path = icon.buildPath();
    final fillColor = fill;
    if (fillColor != null && fillColor.a > 0) {
      canvas.drawPath(path, Paint()..color = fillColor..style = PaintingStyle.fill);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LucidePainter old) =>
      old.icon != icon ||
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.fill != fill;
}

/// The Lucide icons used by Wavvy.
class Lucide {
${body}
}
`;

  fs.mkdirSync(path.dirname(out), { recursive: true });
  fs.writeFileSync(out, src);
  console.log(
    `Wrote ${path.relative(ROOT, out)} — ${entries.length} icons from lucide-static v${version} (${(src.length / 1024).toFixed(1)} KB)`,
  );
}

main();
