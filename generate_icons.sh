#!/bin/bash
set -e

# =========================
# 설명:
#   아이콘 리소스를 생성합니다.
# 사용방법:
#   $ sh generate_icons.sh {flavor name}
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
MAIN_ASSETS="$IOS_RUNNER_DIR/Assets.xcassets/AppIcon.appiconset"
FLAVOR_ASSETS="$IOS_RUNNER_DIR/Flavor/$FLAVOR/Assets.xcassets/AppIcon.appiconset"

# =========================
# Generate icons
# =========================
echo "🚀 Generate launcher icons for flavor: $FLAVOR"
dart run flutter_launcher_icons -f $FLAVOR_YAML

# =========================
# Android: copy to flavor
# =========================
echo "📁 Prepare Android flavor res directory"
mkdir -p "$FLAVOR_RES"

echo "🧹 Clean existing mipmap resources"
rm -rf "$FLAVOR_RES/mipmap-"*

echo "📦 Copy mipmap icons to flavor"
cp -R "$MAIN_RES/mipmap-"* "$FLAVOR_RES/"

echo "✅ Android icons copied for flavor: $FLAVOR"

# =========================
# iOS: copy AppIcon only to flavor
# =========================
if [ ! -d "$MAIN_ASSETS" ]; then
  echo "❌ iOS AppIcon.appiconset not found: $MAIN_ASSETS"
else
  echo "📦 Copy iOS AppIcon to flavor"
  mkdir -p "$FLAVOR_ASSETS"
  # 기존 다른 파일은 그대로 두고 AppIcon 내용만 복사
  cp -R "$MAIN_ASSETS/"* "$FLAVOR_ASSETS/"
  echo "✅ iOS AppIcon copied for flavor: $FLAVOR"
fi
