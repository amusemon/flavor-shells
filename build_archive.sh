#!/bin/bash
set -e

# =========================
# 설명:
#   - 앱을 빌드하고, _export 폴더로 복사합니다.
#   - 릴리스 빌드에는 Dart 난독화를 적용하고 심볼을 저장합니다.
#   - 빌드번호 확인 위치:
#     - 안드로이드: android/app/build.gradle.kts의 versionCode
#     - iOS: ios/Flutter/AppBuildConfig.xcconfig의 VERSION_CODE
#
# 사용방법:
#   bash build_archive.sh {flavor 이름} {확장자}
#
# 예시:
#   bash build_archive.sh dev aab
# =========================

# =========================
# 빌드 환경 확인
# =========================
source ./flavor_common.sh

# =========================
# 확장자 확인
# =========================
ALLOWED_EXTENSIONS=(
  "apk"
  "aab"
  "ios"
  "ipa"
)

EXTENSION=$2

if [ -z "$EXTENSION" ]; then
  echo "❌ 파일 확장자를 입력하세요."
  echo "💡 사용 가능: ${ALLOWED_EXTENSIONS[*]}"
  exit 1
fi

# 허용된 확장자인지 확인
is_valid_extension=false

for f in "${ALLOWED_EXTENSIONS[@]}"; do
  if [ "$f" = "$EXTENSION" ]; then
    is_valid_extension=true
    break
  fi
done

if [ "$is_valid_extension" != true ]; then
  echo "❌ 허용되지 않은 확장자입니다: $EXTENSION"
  echo "💡 사용 가능: ${ALLOWED_EXTENSIONS[*]}"
  exit 1
fi

# =========================
# 빌드번호 확인
# =========================
if [ "$EXTENSION" = "apk" ] || [ "$EXTENSION" = "aab" ]; then
  echo "🎯 안드로이드 빌드번호를 확인합니다: $EXTENSION"
  source ./version_code.sh android
elif [ "$EXTENSION" = "ios" ] || [ "$EXTENSION" = "ipa" ]; then
  echo "🎯 iOS 빌드번호를 확인합니다: $EXTENSION"
  source ./version_code.sh ios
fi

# =========================
# 빌드 환경별 설정 파일 복사
# =========================
cp -R "$FLAVOR_YAML" "$MAIN_YAML"

# =========================
# 패키지 가져오기
# =========================
echo "💼 패키지를 가져옵니다."
flutter pub get

# =========================
# 빌드 모드 및 명령 설정
# =========================
BUILD_MODE="release"
BUILD_CMD="$EXTENSION"

if [ "$EXTENSION" = "apk" ]; then
  BUILD_MODE="debug"
  echo "🛠 apk는 디버그 모드로 빌드합니다."
elif [ "$EXTENSION" = "aab" ]; then
  BUILD_CMD="appbundle"
  echo "📦 aab는 릴리스 모드로 빌드합니다."
else
  echo "🚀 ${EXTENSION}는 릴리스 모드로 빌드합니다."
fi

# =========================
# 내보내기 경로 준비
# =========================
# 프로젝트 루트의 두 단계 위에 생성
EXPORT_ROOT="../../_export/mall-$FLAVOR"
mkdir -p "$EXPORT_ROOT"

# =========================
# 릴리스 빌드 난독화 옵션 설정
# =========================
BUILD_OPTION=()

if [ "$BUILD_MODE" = "release" ]; then
  SYMBOLS_DIR="$EXPORT_ROOT/symbols/${EXTENSION}_${VERSION_CODE}"
  mkdir -p "$SYMBOLS_DIR"

  BUILD_OPTION=(
    "--obfuscate"
    "--split-debug-info=$SYMBOLS_DIR"
  )

  echo "🔐 Dart 난독화를 적용합니다."
  echo "🗂 심볼 저장 경로: $SYMBOLS_DIR"
fi

# =========================
# 빌드 실행
# =========================
echo "🚀 빌드 대상: $FLAVOR ($BUILD_MODE)"

flutter build "$BUILD_CMD" "--$BUILD_MODE" \
  --flavor "$FLAVOR" \
  "--dart-define=FLAVOR=$FLAVOR" \
  "${BUILD_OPTION[@]}"

echo "✅ 빌드가 완료되었습니다: $FLAVOR (.$EXTENSION - $BUILD_MODE)"

# =========================
# 빌드 결과물 내보내기
# =========================
echo "📂 빌드 파일을 내보내는 중..."

SOURCE_PATH=""
EXPORT_PATH=""

case "$EXTENSION" in
  "apk")
    # 디버그 APK 경로
    SOURCE_PATH="build/app/outputs/flutter-apk/app-$FLAVOR-debug.apk"
    EXPORT_PATH="$EXPORT_ROOT/app-$FLAVOR-debug($VERSION_CODE).apk"
    ;;
  "aab")
    # 릴리스 AAB 경로
    SOURCE_PATH="build/app/outputs/bundle/${FLAVOR}Release/app-$FLAVOR-release.aab"
    EXPORT_PATH="$EXPORT_ROOT/app-$FLAVOR-release($VERSION_CODE).aab"
    ;;
  "ipa")
    # 릴리스 IPA 경로
    SOURCE_PATH="build/ios/ipa/*.ipa"
    EXPORT_PATH="$EXPORT_ROOT/app-$FLAVOR-release($VERSION_CODE).ipa"
    ;;
  "ios")
    echo "⚠️ ios 빌드는 파일 복사를 건너뜁니다. 파일 내보내기는 ipa를 사용하세요."
    exit 0
    ;;
esac

# IPA 와일드카드가 확장되도록 소스 경로를 처리
if ls $SOURCE_PATH 1> /dev/null 2>&1; then
  cp $SOURCE_PATH "$EXPORT_PATH"
  echo "📦 성공적으로 복사되었습니다: $EXPORT_PATH"
else
  echo "❌ 파일을 찾을 수 없습니다: $SOURCE_PATH"
  exit 1
fi
