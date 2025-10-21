#!/bin/sh

set -e

rm -rf build-ios
rm -rf Frameworks
rm -rf tmp
mkdir build-ios
mkdir tmp

xcodebuild archive \
    -project MetalANGLEKit.xcodeproj \
    -scheme MetalANGLEKit \
    -destination "generic/platform=iOS" \
    -archivePath "tmp/MetalANGLEKit-iOS"

cp -R tmp/MetalANGLEKit-iOS.xcarchive/Products/Library/Frameworks/MetalANGLEKit.framework Frameworks
cp -r Frameworks/* build-ios/
rm -rf build-ios/MetalANGLEKit.framework/frameworks
