/**
 * Tests for the SVG path-data parser.
 * Run with:  node tool/svg_path_parser.test.mjs
 */
import assert from 'node:assert/strict';
import { parsePathData } from './svg_path_parser.mjs';

let passed = 0;
const tests = [];
const test = (name, fn) => tests.push([name, fn]);

const round = (segs) =>
  segs.map((s) => {
    const o = {};
    for (const [k, v] of Object.entries(s)) {
      o[k] = typeof v === 'number' ? Math.round(v * 1e6) / 1e6 : v;
    }
    return o;
  });

test('absolute moveto + lineto', () => {
  assert.deepEqual(round(parsePathData('M5 12L19 12')), [
    { op: 'M', x: 5, y: 12 },
    { op: 'L', x: 19, y: 12 },
  ]);
});

test('relative commands accumulate', () => {
  assert.deepEqual(round(parsePathData('m5 12l14 0l0 3')), [
    { op: 'M', x: 5, y: 12 },
    { op: 'L', x: 19, y: 12 },
    { op: 'L', x: 19, y: 15 },
  ]);
});

test('implicit repeat of lineto', () => {
  assert.deepEqual(round(parsePathData('M0 0 1 1 2 2')), [
    { op: 'M', x: 0, y: 0 },
    { op: 'L', x: 1, y: 1 },
    { op: 'L', x: 2, y: 2 },
  ]);
});

test('implicit repeat of relative moveto becomes relative lineto', () => {
  assert.deepEqual(round(parsePathData('m1 1 2 2 3 3')), [
    { op: 'M', x: 1, y: 1 },
    { op: 'L', x: 3, y: 3 },
    { op: 'L', x: 6, y: 6 },
  ]);
});

test('horizontal and vertical shorthands', () => {
  assert.deepEqual(round(parsePathData('M2 21h20v-3H2z')), [
    { op: 'M', x: 2, y: 21 },
    { op: 'L', x: 22, y: 21 },
    { op: 'L', x: 22, y: 18 },
    { op: 'L', x: 2, y: 18 },
    { op: 'Z' },
  ]);
});

test('sign acts as a separator', () => {
  assert.deepEqual(round(parsePathData('M10-5L-3-4')), [
    { op: 'M', x: 10, y: -5 },
    { op: 'L', x: -3, y: -4 },
  ]);
});

test('leading-dot numbers', () => {
  assert.deepEqual(round(parsePathData('M.5.25L-.5-.25')), [
    { op: 'M', x: 0.5, y: 0.25 },
    { op: 'L', x: -0.5, y: -0.25 },
  ]);
});

test('packed numbers: "1.09.09" is two numbers', () => {
  assert.deepEqual(round(parsePathData('M1.09.09')), [{ op: 'M', x: 1.09, y: 0.09 }]);
});

test('packed numbers: triple pack "1.5.5.5"', () => {
  assert.deepEqual(round(parsePathData('M1.5.5L.5.5')), [
    { op: 'M', x: 1.5, y: 0.5 },
    { op: 'L', x: 0.5, y: 0.5 },
  ]);
});

test('packed numbers in a real Lucide arc (message-circle)', () => {
  // "...a2 2 0 0 1 1.099.092..." — the last two arguments are packed.
  const segs = parsePathData(
    'M2.992 16.342a2 2 0 0 1 .094 1.167l-1.065 3.29a1 1 0 0 0 1.236 1.168l3.413-.998a2 2 0 0 1 1.099.092 10 10 0 1 0-4.777-4.719',
  );
  const arcs = segs.filter((s) => s.op === 'A');
  assert.equal(arcs.length, 4);
  const third = arcs[2];
  // The current point entering that arc is (6.67, 20.969); a naive scanner
  // that read ".092" as part of "1.099" would land somewhere else entirely.
  assert.equal(Math.round(third.x * 1000) / 1000, 6.67 + 1.099);
  assert.equal(Math.round(third.y * 1000) / 1000, 20.969 + 0.092);
});

test('exponent notation', () => {
  assert.deepEqual(round(parsePathData('M1e2 2E-1')), [{ op: 'M', x: 100, y: 0.2 }]);
});

test('arc flags may be packed with neighbours', () => {
  // at-sign: "a10 10 0 1 0-4 8" — the sweep flag is glued to "-4".
  const a = parsePathData('M16 8v5a3 3 0 0 0 6 0v-1a10 10 0 1 0-4 8').filter(
    (s) => s.op === 'A',
  );
  assert.equal(a.length, 2);
  assert.equal(a[1].largeArc, true);
  assert.equal(a[1].sweep, false);
  assert.equal(a[1].x, 18);
  assert.equal(a[1].y, 20);
});

test('fully packed arc flags "110-4"', () => {
  // "110-4" = largeArc 1, sweep 1, then the numbers 0 and -4.
  const [arc] = parsePathData('M22 12a10 10 0 110-4').filter((s) => s.op === 'A');
  assert.equal(arc.largeArc, true);
  assert.equal(arc.sweep, true);
  assert.equal(arc.x, 22);
  assert.equal(arc.y, 8);
});

test('smooth cubic reflects the previous control point', () => {
  const segs = parsePathData('M0 0C1 2 3 4 5 6S7 8 9 10');
  assert.equal(segs.length, 3);
  assert.deepEqual(round(segs)[1], { op: 'C', x1: 1, y1: 2, x2: 3, y2: 4, x: 5, y: 6 });
  const smooth = segs[2];
  assert.deepEqual(
    { x1: smooth.x1, y1: smooth.y1 },
    { x1: 2 * 5 - 3, y1: 2 * 6 - 4 },
  );
});

test('smooth cubic with no preceding cubic uses the current point', () => {
  const segs = parsePathData('M4 4S6 8 10 10');
  assert.deepEqual(round(segs)[1], { op: 'C', x1: 4, y1: 4, x2: 6, y2: 8, x: 10, y: 10 });
});

test('quadratic and smooth quadratic', () => {
  const segs = parsePathData('M0 0Q2 4 6 0T12 0');
  assert.equal(segs.length, 3);
  assert.deepEqual(round(segs)[1], { op: 'Q', x1: 2, y1: 4, x: 6, y: 0 });
  // reflection of (2,4) about (6,0) is (10,-4)
  assert.deepEqual(round(segs)[2], { op: 'Q', x1: 10, y1: -4, x: 12, y: 0 });
});

test('closepath returns the current point to the subpath start', () => {
  const segs = parsePathData('M5 5h5v5Zm10 0h1');
  assert.deepEqual(round(segs), [
    { op: 'M', x: 5, y: 5 },
    { op: 'L', x: 10, y: 5 },
    { op: 'L', x: 10, y: 10 },
    { op: 'Z' },
    { op: 'M', x: 15, y: 5 },
    { op: 'L', x: 16, y: 5 },
  ]);
});

test('zero-radius arc degrades to a line', () => {
  assert.deepEqual(round(parsePathData('M0 0A0 5 0 0 1 10 10')), [
    { op: 'M', x: 0, y: 0 },
    { op: 'L', x: 10, y: 10 },
  ]);
});

test('arc with coincident endpoints is dropped', () => {
  assert.deepEqual(round(parsePathData('M4 4a5 5 0 0 1 0 0')), [{ op: 'M', x: 4, y: 4 }]);
});

test('commas and extra whitespace are tolerated', () => {
  assert.deepEqual(round(parsePathData('  M 1 , 2\n\tL\r3,4  ')), [
    { op: 'M', x: 1, y: 2 },
    { op: 'L', x: 3, y: 4 },
  ]);
});

test('rejects path data that does not start with a command', () => {
  assert.throws(() => parsePathData('5 5 L 10 10'), SyntaxError);
});

test('rejects a truncated command', () => {
  assert.throws(() => parsePathData('M5 5 L 10'), SyntaxError);
});

test('rejects a bad arc flag', () => {
  assert.throws(() => parsePathData('M0 0a5 5 0 2 1 10 10'), SyntaxError);
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
console.log(`${passed}/${tests.length} path-parser tests passed`);
