#!/bin/bash
# Netlify 배포 스크립트

set -e  # 오류 시 스크립트 중단

echo "🚀 Netlify 배포 스크립트 시작"
echo ""

# 1. Clean build
echo "🧹 이전 빌드 정리 중..."
flutter clean
echo "✓ 정리 완료"
echo ""

# 2. Build web
echo "🔨 웹 앱 빌드 중..."
flutter build web --release
echo "✓ 빌드 완료"
echo ""

# 3. Add _redirects file
echo "📝 _redirects 파일 추가 중..."
cat > build/web/_redirects << 'EOF'
# Netlify redirects for Flutter SPA
# This ensures that all routes are handled by the Flutter app

# Redirect all requests to index.html for client-side routing
/*    /index.html   200
EOF
echo "✓ _redirects 파일 생성 완료"
echo ""

# 4. Verify build
echo "🔍 빌드 파일 확인 중..."
if [ ! -f "build/web/index.html" ]; then
    echo "❌ index.html을 찾을 수 없습니다!"
    exit 1
fi

if [ ! -f "build/web/_redirects" ]; then
    echo "❌ _redirects 파일을 찾을 수 없습니다!"
    exit 1
fi

echo "✓ 필수 파일 확인 완료"
echo ""

# 5. List files
echo "📦 빌드된 파일 목록:"
ls -lh build/web/ | head -15
echo ""

# 6. Build summary
BUILD_SIZE=$(du -sh build/web | cut -f1)
echo "📊 빌드 요약:"
echo "  - 빌드 디렉토리: build/web"
echo "  - 전체 크기: $BUILD_SIZE"
echo "  - _redirects: ✓"
echo "  - index.html: ✓"
echo ""

# 7. Deployment instructions
echo "✅ 빌드 완료!"
echo ""
echo "다음 방법 중 하나로 배포하세요:"
echo ""
echo "방법 1: Netlify Drop (가장 간단)"
echo "  1. https://app.netlify.com/drop 접속"
echo "  2. build/web 폴더를 드래그 앤 드롭"
echo ""
echo "방법 2: Netlify CLI"
echo "  netlify deploy --dir=build/web --prod"
echo ""
echo "방법 3: GitHub 연동"
echo "  git add ."
echo "  git commit -m \"Update web build\""
echo "  git push origin main"
echo ""
echo "자세한 내용은 NETLIFY_DEPLOYMENT_GUIDE.md를 참조하세요."
echo ""
