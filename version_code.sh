#!/bin/bash

# =========================
# 설명:
#   입력된 인자값(android, ios)에 따라 해당 플랫폼의 빌드 번호를 가져옵니다.
#   가져온 빌드 번호는 VERSION_CODE 변수에 저장됩니다.
# 사용법:
#   ./version_code.sh [android|ios]
# 예시:
#   source ./version_code.sh android
#   echo "Selected Version: $VERSION"
# =========================

# VERSION_CODE 변수 초기화
VERSION_CODE=-1

# 입력된 인자값 확인
if [ -z "$1" ]; then
    echo "Usage: $0 [android|ios]"
    exit 1
fi

PLATFORM="$1"

# 파일 경로, 버전 키값 정의
if [ "$PLATFORM" = "android" ]; then
    VERSION_INFO_FILE="android/app/build.gradle.kts"
    VERSION_INFO_KEY="versionCode"
elif [ "$PLATFORM" = "ios" ]; then
    VERSION_INFO_FILE="ios/Flutter/AppBuildConfig.xcconfig"
    VERSION_INFO_KEY="VERSION_CODE"
else
    echo "Invalid platform specified: $PLATFORM. Use 'android' or 'ios'." >&2
    exit 1
fi

# 현재 버전 번호 추출
CURRENT_VERSION=$(grep -E "^\s*"$VERSION_INFO_KEY"\s*=" "$VERSION_INFO_FILE" | awk -F'=' '{print $2}' | tr -d ' ' | tr -d '\r')

# 버전 번호 추출 실패 시 체크
if [ -z "$CURRENT_VERSION" ] || [ "$CURRENT_VERSION" = "" ]; then
    echo "Error: Could not find current version code for $PLATFORM" >&2
    exit 1
fi

# 메인 스크립트에서 사용할 수 있도록 변수 할당
VERSION_CODE=$CURRENT_VERSION