#!/bin/bash
set -e

if [ -z "$FORCE_ANGLE_REBUILD" ] &&
  [ -d "${SRCROOT}/Frameworks/libEGL.framework" ] &&
  [ -d "${SRCROOT}/Frameworks/libGLESv2.framework" ] &&
  [ -d "${SRCROOT}/Frameworks/libfeature_support.framework" ]; then
  echo "ANGLE frameworks already present -> skipping rebuild (set FORCE_ANGLE_REBUILD=1 to force)."
  exit 0
fi

cd "${SRCROOT}/angle"
export PATH="${SRCROOT}/depot_tools:$PATH"

unset SWIFT_DEBUG_INFORMATION_FORMAT
unset SWIFT_DEBUG_INFORMATION_VERSION

BUILD_TYPE="$1"

rm -rf out/$BUILD_TYPE-iphoneos
gn gen out/$BUILD_TYPE-iphoneos --args='
  is_official_build=true
  is_debug=false

  target_os="ios"
  target_cpu="arm64"
  target_environment="device"

  ios_deployment_target="16.0"
  ios_enable_code_signing=false

  angle_build_all=false
  angle_enable_metal=true
  angle_enable_gl=false
  angle_enable_null=false
  angle_enable_wgpu=false

  use_siso=false
'
autoninja -C out/$BUILD_TYPE-iphoneos libEGL libGLESv2 libfeature_support

cd ..
rm -rf Frameworks
mkdir -p Frameworks

cp -R angle/out/$BUILD_TYPE-iphoneos/libEGL.framework Frameworks/
cp -R angle/out/$BUILD_TYPE-iphoneos/libGLESv2.framework Frameworks/
cp -R angle/out/$BUILD_TYPE-iphoneos/libfeature_support.framework Frameworks/

/usr/libexec/PlistBuddy -c "Add :CFBundleShortVersionString string 1.0" "Frameworks/libEGL.framework/Info.plist"
/usr/libexec/PlistBuddy -c "Add :CFBundleShortVersionString string 1.0" "Frameworks/libGLESv2.framework/Info.plist"
/usr/libexec/PlistBuddy -c "Add :CFBundleShortVersionString string 1.0" "Frameworks/libfeature_support.framework/Info.plist"

echo "Frameworks ready in ./Frameworks:"
ls -1 Frameworks
