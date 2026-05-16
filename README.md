# 🦐 FLAVOR Shell Script

Flutter에서 flavor를 이용해서 개발된 앱에 사용

# Shells
- `generate_icons.sh` - 앱 아이콘 만들기
- `generate_splash.sh` - 앱 스플래시 만들기
- `flavor_common.sh` - 공통 Flavor 관리
- `version_code.sh` - 빌드 버전 관리
- `build_archive.sh` - 앱 빌드

# 설치(복사)
```bash
AFS_BASE="https://raw.githubusercontent.com/amusemon/flavor-shells/main"
curl -O $AFS_BASE/generate_icons.sh \
     -O $AFS_BASE/generate_splash.sh \
     -O $AFS_BASE/flavor_common.sh \
     -O $AFS_BASE/version_code.sh \
     -O $AFS_BASE/build_archive.sh
```

# **주의**
1. 프로젝트의 flavor 사용방법 및 일부 구조, 변수가 포멧에 맞아야 합니다.
    - {flavor name}, "VERSION_CODE", ...
2. 프로젝트에 맞는 `flavor_common.sh - ALLOWED_FLAVORS` 값을 수정해서 사용합니다.
3. 빌드된 파일을 저장하는 위치를 변경합니다. `build_archive.sh - EXPORT_ROOT="../../_export/amusemonapps-$FLAVOR"`