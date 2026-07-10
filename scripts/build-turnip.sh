#!/usr/bin/env bash
set -euo pipefail

: "${ANDROID_NDK_ROOT:?ANDROID_NDK_ROOT is not set}"
API_LEVEL="${API_LEVEL:-34}"
PLATFORM_SDK="${PLATFORM_SDK:-34}"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MESA_DIR="$ROOT_DIR/mesa"
BUILD_DIR="$ROOT_DIR/build-android-aarch64"
TOOLCHAIN="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin"
CROSS_FILE="$ROOT_DIR/android-aarch64.ini"

cat > "$CROSS_FILE" <<EOF
[constants]
ndk_path = '$ANDROID_NDK_ROOT'
toolchain = ndk_path / 'toolchains/llvm/prebuilt/linux-x86_64/bin'

[binaries]
ar = toolchain / 'llvm-ar'
c = ['ccache', toolchain / 'aarch64-linux-android${API_LEVEL}-clang']
cpp = ['ccache', toolchain / 'aarch64-linux-android${API_LEVEL}-clang++', '-fno-exceptions', '-fno-unwind-tables', '-fno-asynchronous-unwind-tables', '--start-no-unused-arguments', '-static-libstdc++', '--end-no-unused-arguments']
c_ld = 'lld'
cpp_ld = 'lld'
strip = toolchain / 'llvm-strip'
pkg-config = 'pkg-config'

[host_machine]
system = 'android'
cpu_family = 'aarch64'
cpu = 'armv8'
endian = 'little'
EOF

rm -rf "$BUILD_DIR"

meson setup "$BUILD_DIR" "$MESA_DIR" \
  --cross-file "$CROSS_FILE" \
  --buildtype=release \
  --strip \
  -Db_ndebug=true \
  -Dplatforms=android \
  -Dplatform-sdk-version="$PLATFORM_SDK" \
  -Dandroid-stub=true \
  -Dandroid-libbacktrace=disabled \
  -Degl=disabled \
  -Dgbm=disabled \
  -Dglx=disabled \
  -Dgallium-drivers= \
  -Dvulkan-drivers=freedreno \
  -Dfreedreno-kmds=kgsl \
  -Dbuild-tests=false \
  -Dtools= \
  -Dvalgrind=disabled

meson compile -C "$BUILD_DIR" -j "$(nproc)"

LIB_PATH="$(find "$BUILD_DIR" -type f -name 'libvulkan_freedreno.so' -print -quit)"
if [[ -z "$LIB_PATH" ]]; then
  echo "ERROR: libvulkan_freedreno.so was not produced."
  find "$BUILD_DIR" -maxdepth 5 -type f | sort | tail -200
  exit 1
fi

mkdir -p "$ROOT_DIR/staging"
cp "$LIB_PATH" "$ROOT_DIR/staging/vulkan.ad07xx.so"
"$TOOLCHAIN/llvm-strip" --strip-unneeded "$ROOT_DIR/staging/vulkan.ad07xx.so" || true
file "$ROOT_DIR/staging/vulkan.ad07xx.so"
sha256sum "$ROOT_DIR/staging/vulkan.ad07xx.so" | tee "$ROOT_DIR/staging/SHA256SUMS.txt"
