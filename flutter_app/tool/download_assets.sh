#!/usr/bin/env bash
#
# Fetches the two external asset sources this app bakes in, so that the Flutter
# project itself needs zero pub.dev dependencies:
#
#   1. lucide-static from registry.npmjs.org  -> .lucide-static/ (git-ignored),
#      consumed by tool/generate_icons.mjs to emit native Dart CustomPainter
#      geometry.
#   2. the Zain font family from github.com/googlefonts/zain -> assets/fonts/,
#      committed alongside the OFL licence and loaded by pubspec.yaml.
#
# Usage: ./tool/download_assets.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

LUCIDE_VERSION="${LUCIDE_VERSION:-1.27.0}"
ZAIN_REF="${ZAIN_REF:-main}"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

echo "==> lucide-static v${LUCIDE_VERSION} from registry.npmjs.org"
curl -fsSL -o "$WORK/lucide.tgz" \
  "https://registry.npmjs.org/lucide-static/-/lucide-static-${LUCIDE_VERSION}.tgz"
rm -rf .lucide-static
mkdir -p .lucide-static
tar xzf "$WORK/lucide.tgz" -C "$WORK"
# The tarball unpacks into package/; keep icons + package.json, drop the rest.
cp -R "$WORK/package/icons" .lucide-static/icons
cp "$WORK/package/package.json" .lucide-static/package.json
cp "$WORK/package/LICENSE" .lucide-static/LICENSE
echo "    $(ls .lucide-static/icons | wc -l | tr -d ' ') SVGs unpacked into .lucide-static/"

echo "==> Zain (${ZAIN_REF}) from github.com/googlefonts/zain"
curl -fsSL -o "$WORK/zain.zip" \
  "https://github.com/googlefonts/zain/archive/refs/heads/${ZAIN_REF}.zip"
unzip -q -o "$WORK/zain.zip" -d "$WORK/zain"
SRC="$(find "$WORK/zain" -maxdepth 1 -type d -name 'zain-*' | head -n1)"
mkdir -p assets/fonts
for f in Zain-Light Zain-Regular Zain-Bold Zain-ExtraBold; do
  cp "$SRC/Fonts/TTF/$f.ttf" "assets/fonts/$f.ttf"
done
cp "$SRC/OFL.txt" assets/fonts/OFL.txt
echo "    4 TTFs + OFL.txt copied into assets/fonts/"

echo "==> regenerating Dart icon data"
node tool/generate_icons.mjs

echo "Done."
