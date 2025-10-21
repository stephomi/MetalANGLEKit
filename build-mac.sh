#!/bin/bash
set -e

# rm -rf angle/out/mac-x64
# rm -rf angle/out/mac-arm64

repack() {
  mkdir -p repack
  for A in lib*.a; do
    DIR="${A%.a}"
    [ -d "$DIR" ] || {
      echo "skip $A (no $DIR/)"
      continue
    }
    OBJS=$(find "$DIR" -type f -name '*.o')
    /opt/homebrew/opt/llvm/bin/llvm-libtool-darwin -static -o "repack/${DIR}_full.a" $OBJS
  done
}

export PATH="$(pwd)/depot_tools:$PATH"
export SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"

# /opt/homebrew/opt/llvm/lib/clang/21/lib/darwin/libclang_rt.osx.a

cd angle
# Common GN args for static clean builds
COMMON_ARGS='
  is_official_build=true
  is_debug=false
  is_component_build=false
  use_siso=false
  chrome_pgo_phase=0
  mac_deployment_target="12.0"

  use_lld=false
  use_thin_lto=false
  thin_lto_enable_cache=false
  thin_lto_enable_optimizations=false

  # clang_base_path="/opt/homebrew/opt/llvm"  
  # clang_version=21 
  # clang_use_chrome_plugins=false

  angle_build_all=false
  angle_enable_gl=true
  angle_enable_vulkan=false
  angle_enable_null=false
  angle_enable_wgpu=false
  angle_enable_metal=true
'

# ------------------------
# macOS arm64
# ------------------------
gn gen out/mac-arm64 --args="
  $COMMON_ARGS
  target_os=\"mac\"
  target_cpu=\"arm64\"
"
autoninja -C out/mac-arm64 libEGL libGLESv2
# autoninja -C out/mac-arm64 libEGL_static libGLESv2_static

# cd out/mac-arm64/obj
# repack
# cd ../../../

# ------------------------
# macOS x64
# ------------------------
gn gen out/mac-x64 --args="
  $COMMON_ARGS
  target_os=\"mac\"
  target_cpu=\"x64\"
"
autoninja -C out/mac-x64 libEGL libGLESv2
# autoninja -C out/mac-x64 libEGL_static libGLESv2_static

# cd out/mac-arm64/obj
# repack
# cd ../../../

# ------------------------
# Merge into fat libs
# ------------------------
cd ..
mkdir -p build-mac
lipo -create angle/out/mac-x64/libEGL.dylib angle/out/mac-arm64/libEGL.dylib -output build-mac/libEGL.dylib
lipo -create angle/out/mac-x64/libGLESv2.dylib angle/out/mac-arm64/libGLESv2.dylib -output build-mac/libGLESv2.dylib
