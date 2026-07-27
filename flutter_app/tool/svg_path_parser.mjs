/**
 * A complete SVG path-data ("d" attribute) parser.
 *
 * Implements the grammar from SVG 1.1 §8.3 / SVG 2 §9.3, including all the
 * shorthand that real-world path data relies on:
 *
 *   - every command:  M m L l H h V v C c S s Q q T t A a Z z
 *   - implicit repeated commands ("M 1 2 3 4" == "M 1 2 L 3 4", and the
 *     implicit-lineto rule where a repeated `m`/`M` becomes `l`/`L`)
 *   - arbitrary whitespace and/or commas between numbers
 *   - a sign acting as its own separator ("10-5" == "10 -5")
 *   - "packed" numbers, where the decimal point terminates the previous
 *     number and starts the next one:  "1.09.09" == "1.09 0.09"
 *     (this really happens in the Lucide icon set, e.g. message-circle:
 *      "a 2 2 0 0 1 1.099.092")
 *   - exponent notation ("1e-5", "3.2E+2")
 *   - arc flag packing, where the two single-digit boolean flags of an
 *     elliptical arc may be glued to their neighbours:
 *     "a10 10 0 1 0-4 8" and even "a10 10 0 110-4 8"
 *
 * Output is a flat list of *absolute* segments that map 1:1 onto the
 * dart:ui Path API:
 *
 *   { op: 'M', x, y }                                       -> moveTo
 *   { op: 'L', x, y }                                       -> lineTo
 *   { op: 'C', x1, y1, x2, y2, x, y }                       -> cubicTo
 *   { op: 'Q', x1, y1, x, y }                               -> quadraticBezierTo
 *   { op: 'A', rx, ry, rot, largeArc, sweep, x, y }         -> arcToPoint
 *   { op: 'Z' }                                             -> close
 */

const WSP = new Set([' ', '\t', '\n', '\r', '\f', '\v']);
const COMMANDS = new Set('MmLlHhVvCcSsQqTtAaZz');

class Scanner {
  constructor(d) {
    this.d = d;
    this.i = 0;
  }

  get eof() {
    return this.i >= this.d.length;
  }

  /** Skip whitespace and at most the separators allowed by the grammar. */
  skipSeparators() {
    while (this.i < this.d.length) {
      const c = this.d[this.i];
      if (WSP.has(c) || c === ',') this.i++;
      else break;
    }
  }

  peek() {
    this.skipSeparators();
    return this.eof ? null : this.d[this.i];
  }

  isNumberStart() {
    const c = this.peek();
    if (c === null) return false;
    return c === '+' || c === '-' || c === '.' || (c >= '0' && c <= '9');
  }

  /**
   * Read one number. Stops at the first character that cannot extend the
   * current number, which is what makes "1.09.09" scan as two numbers: the
   * second '.' cannot extend "1.09" because a number has at most one dot.
   */
  readNumber() {
    this.skipSeparators();
    const start = this.i;
    const d = this.d;

    if (d[this.i] === '+' || d[this.i] === '-') this.i++;

    let sawDigit = false;
    while (this.i < d.length && d[this.i] >= '0' && d[this.i] <= '9') {
      this.i++;
      sawDigit = true;
    }
    if (d[this.i] === '.') {
      this.i++;
      while (this.i < d.length && d[this.i] >= '0' && d[this.i] <= '9') {
        this.i++;
        sawDigit = true;
      }
    }
    if (!sawDigit) {
      throw new SyntaxError(
        `Expected a number at offset ${start} of path data: ${JSON.stringify(d)}`,
      );
    }
    // Exponent — only consumed when it is well formed, so that a trailing
    // "e" belonging to nothing does not swallow characters.
    if (d[this.i] === 'e' || d[this.i] === 'E') {
      const save = this.i;
      this.i++;
      if (d[this.i] === '+' || d[this.i] === '-') this.i++;
      let expDigits = false;
      while (this.i < d.length && d[this.i] >= '0' && d[this.i] <= '9') {
        this.i++;
        expDigits = true;
      }
      if (!expDigits) this.i = save;
    }

    const text = d.slice(start, this.i);
    const value = Number(text);
    if (!Number.isFinite(value)) {
      throw new SyntaxError(`Malformed number ${JSON.stringify(text)} in path data`);
    }
    return value;
  }

  /**
   * Read an arc flag. Per the grammar a flag is exactly one character, '0'
   * or '1', and needs no separator from what follows — so "110-4" is
   * flag 1, flag 1, then the number 0 (and then -4).
   */
  readFlag() {
    this.skipSeparators();
    const c = this.d[this.i];
    if (c === '0' || c === '1') {
      this.i++;
      return c === '1';
    }
    throw new SyntaxError(
      `Expected an arc flag (0 or 1) at offset ${this.i} of path data: ${JSON.stringify(this.d)}`,
    );
  }
}

/**
 * @param {string} d raw "d" attribute value
 * @returns {Array<object>} absolute segments
 */
export function parsePathData(d) {
  const s = new Scanner(d);
  const out = [];

  // Current point, start-of-subpath, and the reflected control points used
  // by the smooth shorthands.
  let cx = 0;
  let cy = 0;
  let startX = 0;
  let startY = 0;
  let lastCubicCtrlX = null;
  let lastCubicCtrlY = null;
  let lastQuadCtrlX = null;
  let lastQuadCtrlY = null;
  let command = null;

  const clearCubic = () => {
    lastCubicCtrlX = null;
    lastCubicCtrlY = null;
  };
  const clearQuad = () => {
    lastQuadCtrlX = null;
    lastQuadCtrlY = null;
  };

  while (true) {
    const c = s.peek();
    if (c === null) break;

    if (COMMANDS.has(c)) {
      command = c;
      s.i++;
    } else if (command === null) {
      throw new SyntaxError(`Path data must start with a command: ${JSON.stringify(d)}`);
    } else if (!s.isNumberStart()) {
      throw new SyntaxError(
        `Unexpected character ${JSON.stringify(c)} at offset ${s.i} of path data: ${JSON.stringify(d)}`,
      );
    } else if (command === 'M') {
      // An implicit repetition of moveto is treated as lineto.
      command = 'L';
    } else if (command === 'm') {
      command = 'l';
    } else if (command === 'Z' || command === 'z') {
      throw new SyntaxError(`closepath takes no parameters in path data: ${JSON.stringify(d)}`);
    }

    const rel = command === command.toLowerCase();
    const ox = rel ? cx : 0;
    const oy = rel ? cy : 0;

    switch (command.toUpperCase()) {
      case 'M': {
        const x = s.readNumber() + ox;
        const y = s.readNumber() + oy;
        out.push({ op: 'M', x, y });
        cx = startX = x;
        cy = startY = y;
        clearCubic();
        clearQuad();
        break;
      }
      case 'L': {
        const x = s.readNumber() + ox;
        const y = s.readNumber() + oy;
        out.push({ op: 'L', x, y });
        cx = x;
        cy = y;
        clearCubic();
        clearQuad();
        break;
      }
      case 'H': {
        const x = s.readNumber() + ox;
        out.push({ op: 'L', x, y: cy });
        cx = x;
        clearCubic();
        clearQuad();
        break;
      }
      case 'V': {
        const y = s.readNumber() + oy;
        out.push({ op: 'L', x: cx, y });
        cy = y;
        clearCubic();
        clearQuad();
        break;
      }
      case 'C': {
        const x1 = s.readNumber() + ox;
        const y1 = s.readNumber() + oy;
        const x2 = s.readNumber() + ox;
        const y2 = s.readNumber() + oy;
        const x = s.readNumber() + ox;
        const y = s.readNumber() + oy;
        out.push({ op: 'C', x1, y1, x2, y2, x, y });
        cx = x;
        cy = y;
        lastCubicCtrlX = x2;
        lastCubicCtrlY = y2;
        clearQuad();
        break;
      }
      case 'S': {
        const x2 = s.readNumber() + ox;
        const y2 = s.readNumber() + oy;
        const x = s.readNumber() + ox;
        const y = s.readNumber() + oy;
        // Reflect the previous cubic control point about the current point;
        // with no previous cubic the control point coincides with it.
        const x1 = lastCubicCtrlX === null ? cx : 2 * cx - lastCubicCtrlX;
        const y1 = lastCubicCtrlY === null ? cy : 2 * cy - lastCubicCtrlY;
        out.push({ op: 'C', x1, y1, x2, y2, x, y });
        cx = x;
        cy = y;
        lastCubicCtrlX = x2;
        lastCubicCtrlY = y2;
        clearQuad();
        break;
      }
      case 'Q': {
        const x1 = s.readNumber() + ox;
        const y1 = s.readNumber() + oy;
        const x = s.readNumber() + ox;
        const y = s.readNumber() + oy;
        out.push({ op: 'Q', x1, y1, x, y });
        cx = x;
        cy = y;
        lastQuadCtrlX = x1;
        lastQuadCtrlY = y1;
        clearCubic();
        break;
      }
      case 'T': {
        const x = s.readNumber() + ox;
        const y = s.readNumber() + oy;
        const x1 = lastQuadCtrlX === null ? cx : 2 * cx - lastQuadCtrlX;
        const y1 = lastQuadCtrlY === null ? cy : 2 * cy - lastQuadCtrlY;
        out.push({ op: 'Q', x1, y1, x, y });
        cx = x;
        cy = y;
        lastQuadCtrlX = x1;
        lastQuadCtrlY = y1;
        clearCubic();
        break;
      }
      case 'A': {
        const rx = Math.abs(s.readNumber());
        const ry = Math.abs(s.readNumber());
        const rot = s.readNumber();
        const largeArc = s.readFlag();
        const sweep = s.readFlag();
        const x = s.readNumber() + ox;
        const y = s.readNumber() + oy;
        if (x === cx && y === cy) {
          // Per spec: an arc whose endpoints are identical is dropped.
        } else if (rx === 0 || ry === 0) {
          // Per spec: a degenerate radius makes the arc a straight line.
          out.push({ op: 'L', x, y });
        } else {
          out.push({ op: 'A', rx, ry, rot, largeArc, sweep, x, y });
        }
        cx = x;
        cy = y;
        clearCubic();
        clearQuad();
        break;
      }
      case 'Z': {
        out.push({ op: 'Z' });
        cx = startX;
        cy = startY;
        clearCubic();
        clearQuad();
        break;
      }
      default:
        throw new SyntaxError(`Unsupported path command ${command}`);
    }
  }

  return out;
}

export default parsePathData;
