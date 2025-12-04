#!/bin/bash
# Firebase 업로드 환경 설정 스크립트

echo "=== Firebase 문제 업로드 설정 ==="
echo ""

# 1. Check Python3
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3가 설치되어 있지 않습니다."
    echo "   Homebrew로 설치: brew install python3"
    exit 1
fi
echo "✓ Python3 설치됨: $(python3 --version)"

# 2. Check pip3
if ! command -v pip3 &> /dev/null; then
    echo "❌ pip3가 설치되어 있지 않습니다."
    exit 1
fi
echo "✓ pip3 설치됨"

# 3. Install firebase-admin
echo ""
echo "Firebase Admin SDK 설치 중..."
pip3 install firebase-admin

if [ $? -eq 0 ]; then
    echo "✓ firebase-admin 설치 완료"
else
    echo "❌ firebase-admin 설치 실패"
    exit 1
fi

# 4. Check problem-generator folder
PROBLEM_GEN_PATH="$HOME/.claude/projects/problem-generator/outputs"
if [ ! -d "$PROBLEM_GEN_PATH" ]; then
    echo ""
    echo "⚠️  problem-generator 폴더를 찾을 수 없습니다: $PROBLEM_GEN_PATH"
    echo "   경로를 확인해주세요."
else
    echo ""
    echo "✓ problem-generator 폴더 확인됨"
    PROBLEM_COUNT=$(ls -1 "$PROBLEM_GEN_PATH"/p_*.json 2>/dev/null | wc -l)
    echo "  발견된 문제 파일: ${PROBLEM_COUNT}개"
fi

# 5. Check service account key
echo ""
echo "=== Firebase 서비스 계정 키 설정 ==="
echo ""

if [ -z "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
    echo "⚠️  GOOGLE_APPLICATION_CREDENTIALS 환경 변수가 설정되지 않았습니다."
    echo ""
    echo "다음 단계를 따라 설정하세요:"
    echo ""
    echo "1. Firebase Console에서 서비스 계정 키 다운로드"
    echo "   https://console.firebase.google.com/project/real-math-d9ddf/settings/serviceaccounts/adminsdk"
    echo ""
    echo "2. 다운로드한 JSON 파일을 안전한 위치에 저장"
    echo "   예: ~/firebase-keys/real-math-serviceAccountKey.json"
    echo ""
    echo "3. 환경 변수 설정 (~/.zshrc 또는 ~/.bash_profile에 추가)"
    echo "   export GOOGLE_APPLICATION_CREDENTIALS=\"\$HOME/firebase-keys/real-math-serviceAccountKey.json\""
    echo ""
    echo "4. 터미널 재시작 또는 source 실행"
    echo "   source ~/.zshrc"
    echo ""
else
    echo "✓ GOOGLE_APPLICATION_CREDENTIALS 설정됨"
    echo "  경로: $GOOGLE_APPLICATION_CREDENTIALS"

    if [ -f "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
        echo "  ✓ 파일 존재함"
    else
        echo "  ❌ 파일을 찾을 수 없습니다!"
    fi
fi

# 6. Summary
echo ""
echo "=== 설정 완료 ==="
echo ""
echo "다음 명령어로 문제를 업로드할 수 있습니다:"
echo ""
echo "  # 모든 문제 업로드 (미리보기)"
echo "  python3 upload_problems_to_firebase.py --all --dry-run"
echo ""
echo "  # 모든 문제 업로드"
echo "  python3 upload_problems_to_firebase.py --all"
echo ""
echo "  # 특정 문제 업로드"
echo "  python3 upload_problems_to_firebase.py --file p_20251117.json"
echo ""
echo "자세한 사용법은 UPLOAD_GUIDE.md를 참조하세요."
echo ""
