# 🦐 FLAVOR Shell Script

Flutter에서 flavor를 이용해서 개발된 앱에 사용

# Shells
- `generate_icons.sh` - 앱 아이콘 만들기
- `generate_splash.sh` - 앱 스플래시 만들기
- `flavor_common.sh` - 공통 Flavor 관리
- `version_code.sh` - 빌드 버전 관리
- `build_archive.sh` - 앱 빌드

# 설치
```bash
AFS_BASE="https://raw.githubusercontent.com/amusemon/flavor-shells/main"
curl -O $AFS_BASE/generate_icons.sh \
     -O $AFS_BASE/generate_splash.sh \
     -O $AFS_BASE/flavor_common.sh \
     -O $AFS_BASE/version_code.sh \
     -O $AFS_BASE/build_archive.sh
```
