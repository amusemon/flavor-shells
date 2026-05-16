#!/bin/bash

# =========================
# 설명:
#   정상적인 flavor인지 검사합니다.
# =========================

ALLOWED_FLAVORS=(
  "dev"
  "postteam"
  "japanoku"
  "chinabuy"
)

FLAVOR=$1

if [ -z "$FLAVOR" ]; then
  echo "❌ flavor 이름을 입력하세요"
  echo "💡 사용 가능: ${ALLOWED_FLAVORS[*]}"
  exit 1
fi

# Whitelist check
is_valid_flavor=false
for f in "${ALLOWED_FLAVORS[@]}"; do
  if [ "$f" == "$FLAVOR" ]; then
    is_valid_flavor=true
    break
  fi
done

if [ "$is_valid_flavor" != true ]; then
  echo "❌ 허용되지 않은 flavor 입니다.: $FLAVOR"
  echo "💡 사용 가능: ${ALLOWED_FLAVORS[*]}"
  exit 1
fi

# =========================
# Config(.yaml) file existence check
# =========================
# Resource generate config(e.g icons, splash)
MAIN_YAML="pubspec.yaml"
FLAVOR_YAML="pubspecs/pubspec-$FLAVOR.yaml"
if [ ! -f "$FLAVOR_YAML" ]; then
  echo "❌ 리소스 설정 파일을 찾을 수 없습니다: $FLAVOR_YAML"
  exit 1
fi
