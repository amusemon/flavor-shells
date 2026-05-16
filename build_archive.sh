#!/bin/bash
set -e

# =========================
# 설명:
#   - 앱을 빌드하고, _export 폴더로 복사합니다.
#   - 빌드번호를 확인합니다.
#     - android: android/app/build.gradle.kts/의 'versionCode'
#     - ios: ios/Flutter/AppBuildConfig.xcconfig의 'VERSION_CODE'
# 사용방법:
#   $ sh build_archive.sh {flavor name} {extension name}
# =========================

# =========================
# flavor 확인
# =========================
source ./flavor_common.sh

# =========================
# extension check
# =========================
ALLOWED_EXTENSIONS=(
  "apk"
  "aab"
  "ios"
  "ipa"
)

EXTENSION=$2

if [ -z "$EXTENSION" ]; then
  echo "❌ 파일 확장자를 입력하세요"
  echo "💡 사용 가능: ${ALLOWED_EXTENSIONS[*]}"
  exit 1
fi

# Whitelist check
is_valid_extension=false
for f in "${ALLOWED_EXTENSIONS[@]}"; do
  if [ "$f" == "$EXTENSION" ]; then
    is_valid_extension=true
    break
  fi
done

if [ "$is_valid_extension" != true ]; then
  echo "❌ 허용되지 않은 확장자 입니다.: $EXTENSION"
  echo "💡 사용 가능: ${ALLOWED_EXTENSIONS[*]}"
  exit 1
fi

# =========================
# 버전 확인(VERSION_CODE)
# =========================
if [ "$EXTENSION" = "apk" ] || [ "$EXTENSION" = "aab" ]; then
    echo "🎯 Detected Android platform (EXTENSION: $EXTENSION)."
    source ./version_code.sh android
    if [ $? -ne 0 ]; then
        echo "❌ EError: Failed to source version_code.sh for Android." >&2
        return 1
    fi
elif [ "$EXTENSION" = "ios" ] || [ "$EXTENSION" = "ipa" ]; then
    echo "🎯 Detected iOS platform (EXTENSION: $EXTENSION)."
    source ./version_code.sh ios
    if [ $? -ne 0 ]; then
        echo "❌ Error: Failed to source version_code.sh for iOS." >&2
        return 1
    fi
else
    echo "❌ Error: Invalid or unsupported EXTENSION value: '$EXTENSION'. Expected 'apk', 'aab', 'ios', or 'ipa'." >&2
    return 1
fi

# =========================
# copy
# =========================
cp -R "$FLAVOR_YAML" "$MAIN_YAML"

# =========================
# package get
# =========================
echo "💼 Package를 가져옵니다."
flutter pub get

# =========================
# build mode & command 설정
# =========================
BUILD_MODE="release"
BUILD_CMD=$EXTENSION

if [ "$EXTENSION" == "apk" ]; then
  BUILD_MODE="debug"
  echo "🛠 apk는 Debug 모드로 빌드합니다."
elif [ "$EXTENSION" == "aab" ]; then
  BUILD_CMD="appbundle"
  echo "📦 aab(appbundle)는 Release 모드로 빌드합니다."
else
  echo "🚀 ${EXTENSION}는 Release 모드로 빌드합니다."
fi

# =========================
# build 실행
# =========================
echo "🚀 Build for flavor: $FLAVOR ($BUILD_MODE)"

# apk는 --debug, 나머지는 --release 옵션을 명시적으로 부여
flutter build $BUILD_CMD --$BUILD_MODE --flavor $FLAVOR --dart-define=FLAVOR=$FLAVOR

echo "✅ 빌드가 완료되었습니다: $FLAVOR (.$EXTENSION - $BUILD_MODE)"

# =========================
# Export (파일 복사 로직)
# =========================
echo "📂 빌드 파일을 내보내는 중..."

# 1. 대상 디렉토리 설정 (프로젝트 루트의 2단계 위 _export/mall-{flavor})
EXPORT_ROOT="../../_export/mall-$FLAVOR"
mkdir -p "$EXPORT_ROOT"

# 2. 확장자별 소스 파일 경로 설정
SOURCE_PATH=""
EXPORT_PATH=""

case $EXTENSION in
  "apk")
    # 빌드된 Debug APK 경로
    SOURCE_PATH="build/app/outputs/flutter-apk/app-$FLAVOR-debug.apk"
    EXPORT_PATH="$EXPORT_ROOT/app-$FLAVOR-debug($VERSION_CODE).apk"
    ;;
  "aab")
    # 빌드된 Release AAB 경로
    # Flavor의 첫 글자를 대문자로 변환하여 경로 매칭 (예: dev -> devRelease)
    FLAVOR_CAPITALIZED="$(tr '[:lower:]' '[:upper:]' <<< ${FLAVOR:0:1})${FLAVOR:1}"
    SOURCE_PATH="build/app/outputs/bundle/${FLAVOR}Release/app-$FLAVOR-release.aab"
    EXPORT_PATH="$EXPORT_ROOT/app-$FLAVOR-release($VERSION_CODE).aab"
    ;;
  "ipa")
    # 빌드된 Release IPA 경로
    SOURCE_PATH="build/ios/ipa/*.ipa"
    EXPORT_PATH="$EXPORT_ROOT/app-$FLAVOR-release($VERSION_CODE).ipa"
    ;;
  "ios")
    echo "⚠️ 'ios' 확장자는 Framework/Archive 결과물이므로 파일 복사를 건너뜁니다 (ipa를 사용하세요)."
    exit 0
    ;;
esac

# 3. 파일 복사 실행
if ls $SOURCE_PATH 1> /dev/null 2>&1; then
  cp $SOURCE_PATH "$EXPORT_PATH"
  echo "📦 성공적으로 복사되었습니다: $EXPORT_PATH"
else
  echo "❌ 파일을 찾을 수 없습니다: $SOURCE_PATH"
  exit 1
fi