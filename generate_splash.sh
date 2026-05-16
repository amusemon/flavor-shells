#!/bin/bash
set -e

# =========================
# 설명:
#   스플래시 리소스를 생성합니다.
# 사용방법:
#   $ sh generate_splash.sh {flavor name}
# =========================

# 공통 체크 include
source ./flavor_common.sh

# =========================
# Paths
# =========================
# Android
ANDROID_APP_PATH="android/app"
MAIN_RES="$ANDROID_APP_PATH/src/main/res"
FLAVOR_RES="$ANDROID_APP_PATH/src/$FLAVOR/res"

# iOS
IOS_RUNNER_DIR="ios/Runner"
MAIN_ASSETS="$IOS_RUNNER_DIR/Assets.xcassets/LaunchImage.imageset"
MAIN_ASSETS_BACKGROUND="$IOS_RUNNER_DIR/Assets.xcassets/LaunchBackground.imageset"
FLAVOR_ASSETS="$IOS_RUNNER_DIR/Flavor/$FLAVOR/Assets.xcassets/LaunchImage.imageset"
FLAVOR_ASSETS_BACKGROUND="$IOS_RUNNER_DIR/Flavor/$FLAVOR/Assets.xcassets/LaunchBackground.imageset"

# =========================
# Generate splash
# =========================
echo "🚀 Generating splash for flavor: $FLAVOR"
dart run flutter_native_splash:create --path=$FLAVOR_YAML

# =========================
# Android: copy to flavor
# =========================
echo "📦 Copy Android splash resources to flavor"
mkdir -p "$FLAVOR_RES"
cp -R "$MAIN_RES/drawable"* "$FLAVOR_RES/"
cp -R "$MAIN_RES/values"* "$FLAVOR_RES/"

echo "✅ Android splash copied for flavor: $FLAVOR"

# =========================
# iOS: copy LaunchImage and storyboard
# =========================
if [ -d "$MAIN_ASSETS" ]; then
  echo "📦 Copy iOS LaunchImage assets for flavor"
  mkdir -p "$FLAVOR_ASSETS"
  cp -R "$MAIN_ASSETS/"* "$FLAVOR_ASSETS/"
fi

if [ -d "$MAIN_ASSETS_BACKGROUND" ]; then
  echo "📦 Copy iOS LaunchBackground assets for flavor"
  mkdir -p "$FLAVOR_ASSETS_BACKGROUND"
  cp -R "$MAIN_ASSETS_BACKGROUND/"* "$FLAVOR_ASSETS_BACKGROUND/"
fi

echo "✅ iOS splash copied for flavor: $FLAVOR"
