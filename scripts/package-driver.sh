#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")"/.. && pwd)"
STAGING="$ROOT_DIR/staging"
OUTPUT="$ROOT_DIR/output"

BUILD_NAME="${BUILD_NAME:-Turnip MV Eclipse R1}"
MESA_REF="${MESA_REF:-mesa-26.1.0}"

mkdir -p "$OUTPUT"

COMMIT="unknown"
[[ -f "$ROOT_DIR/mesa-commit.txt" ]] && COMMIT="$(cat "$ROOT_DIR/mesa-commit.txt")"

cat > "$STAGING/meta.json" <<EOF
{
  "schemaVersion": 1,
  "name": "$BUILD_NAME",
  "description": "Turnip MV Eclipse R1 - Stable custom driver for POCO F6 / Snapdragon 8s Gen 3 / Adreno 735.",
  "author": "Shinigami-MV",
  "packageVersion": "1",
  "vendor": "Mesa",
  "driverVersion": "$MESA_REF ($COMMIT)",
  "minApi": 28,
  "libraryName": "vulkan.ad07xx.so"
}
EOF

cp "$ROOT_DIR/mesa-commit.txt" "$STAGING/mesa-commit.txt" 2>/dev/null || true

(
cd "$STAGING"

zip -9 -r "$OUTPUT/Turnip-MV-Eclipse-R1.zip" \
meta.json \
vulkan.ad07xx.so \
SHA256SUMS.txt \
mesa-commit.txt
)

sha256sum "$OUTPUT/Turnip-MV-Eclipse-R1.zip" > \
"$OUTPUT/Turnip-MV-Eclipse-R1.zip.sha256"
