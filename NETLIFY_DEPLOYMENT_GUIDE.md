# Netlify 배포 가이드

## 목차
1. [빠른 시작](#빠른-시작)
2. [상세 배포 단계](#상세-배포-단계)
3. [문제 해결](#문제-해결)
4. [로컬 테스트](#로컬-테스트)

---

## 빠른 시작

### 1. 웹 빌드 생성
```bash
cd /Users/jaelee/.gemini/antigravity/scratch/world_math
flutter clean
flutter build web --release
```

### 2. Netlify에 배포
`build/web` 폴더 전체를 Netlify에 업로드하세요.

---

## 상세 배포 단계

### 방법 1: 드래그 앤 드롭 배포 (가장 간단)

1. **웹 빌드 생성**
   ```bash
   flutter clean
   flutter build web --release
   ```

2. **Netlify Drop 사용**
   - https://app.netlify.com/drop 접속
   - `build/web` 폴더를 드래그 앤 드롭
   - 배포 완료!

### 방법 2: Netlify CLI 배포

1. **Netlify CLI 설치**
   ```bash
   npm install -g netlify-cli
   ```

2. **로그인**
   ```bash
   netlify login
   ```

3. **배포**
   ```bash
   # 테스트 배포
   netlify deploy --dir=build/web

   # 프로덕션 배포
   netlify deploy --dir=build/web --prod
   ```

### 방법 3: Git 연동 자동 배포

1. **프로젝트를 GitHub에 푸시**
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin <your-repo-url>
   git push -u origin main
   ```

2. **Netlify에서 사이트 생성**
   - https://app.netlify.com 접속
   - "Add new site" > "Import an existing project"
   - GitHub 저장소 선택

3. **빌드 설정**
   - Build command: `flutter build web --release`
   - Publish directory: `build/web`
   - 또는 `netlify.toml` 파일이 자동으로 인식됨

---

## 중요 파일 설명

### 1. `netlify.toml` (프로젝트 루트)
```toml
[build]
  publish = "build/web"
  command = "flutter build web --release"

[build.environment]
  FLUTTER_CHANNEL = "stable"

# SPA 라우팅 설정
[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

### 2. `web/_redirects` (web 폴더 내)
```
/*    /index.html   200
```

이 파일은 빌드 시 자동으로 `build/web/_redirects`에 복사됩니다.

### 3. `build/web/_redirects` (빌드 후 자동 생성)
빌드 후 수동으로 추가되어 있습니다. Flutter 빌드가 이 파일을 삭제하지 않도록 `web/` 폴더에도 원본을 보관합니다.

---

## 문제 해결

### ❌ 문제 1: 하얀 화면만 표시됨

**원인:**
- SPA 라우팅이 설정되지 않음
- `_redirects` 파일이 없음
- JavaScript 로딩 실패

**해결 방법:**
1. `build/web/_redirects` 파일이 있는지 확인
   ```bash
   ls -la build/web/_redirects
   ```

2. 없다면 다시 생성
   ```bash
   echo "/*    /index.html   200" > build/web/_redirects
   ```

3. 다시 배포

### ❌ 문제 2: Firebase 연결 오류

**증상:**
브라우저 콘솔에 Firebase 관련 오류

**해결 방법:**
1. 브라우저 개발자 도구 열기 (F12)
2. Console 탭에서 오류 확인
3. Firebase 웹 설정 확인
   - `lib/firebase_options.dart`의 web 설정이 올바른지 확인

### ❌ 문제 3: 빌드 파일이 너무 큼

**해결 방법:**
```bash
# 아이콘 트리 쉐이킹 활성화 (기본값)
flutter build web --release

# WASM 빌드로 파일 크기 줄이기 (실험적)
flutter build web --release --wasm
```

### ❌ 문제 4: 404 오류 (페이지를 찾을 수 없음)

**원인:**
Netlify가 Flutter의 클라이언트 사이드 라우팅을 인식하지 못함

**해결 방법:**
1. `_redirects` 파일 확인
2. Netlify 대시보드에서 "Redirects and rewrites" 설정 확인

---

## 로컬 테스트

Netlify에 배포하기 전에 로컬에서 테스트하세요.

### 방법 1: Python 서버
```bash
cd build/web
python3 -m http.server 8000
```
브라우저에서 http://localhost:8000 열기

### 방법 2: Netlify Dev
```bash
npm install -g netlify-cli
netlify dev
```

### 방법 3: Flutter 웹 서버
```bash
flutter run -d chrome --release
```

---

## 배포 체크리스트

배포 전 확인사항:

- [ ] `flutter build web --release` 성공
- [ ] `build/web/_redirects` 파일 존재
- [ ] `build/web/index.html` 파일 존재
- [ ] Firebase 설정 확인 (웹용 API 키)
- [ ] 로컬에서 테스트 완료
- [ ] 브라우저 콘솔에 오류 없음

---

## 배포 후 확인사항

1. **사이트 접속 확인**
   - Netlify에서 제공한 URL 접속
   - 예: `https://your-site-name.netlify.app`

2. **브라우저 개발자 도구 확인 (F12)**
   ```
   Console 탭:
   - JavaScript 오류 확인
   - Firebase 연결 확인

   Network 탭:
   - 모든 리소스가 200 OK로 로드되는지 확인
   - 404 오류가 없는지 확인
   ```

3. **기능 테스트**
   - [ ] 로그인 화면 표시
   - [ ] Firebase 데이터 로드
   - [ ] 문제 목록 표시
   - [ ] 문제 풀이 가능
   - [ ] 랭킹 화면 표시

---

## 브라우저 콘솔 디버깅

하얀 화면이 나타나면 브라우저 콘솔을 확인하세요:

1. **F12 키** 또는 **우클릭 > 검사** 열기
2. **Console 탭** 선택
3. 오류 메시지 확인:

### 일반적인 오류들:

**1. Firebase 초기화 오류**
```
Error: Firebase: No Firebase App '[DEFAULT]' has been created
```
→ Firebase 설정 확인 필요

**2. 네트워크 오류**
```
Failed to load resource: net::ERR_CONNECTION_REFUSED
```
→ Firebase 프로젝트가 활성화되어 있는지 확인

**3. CORS 오류**
```
Access to fetch at '...' has been blocked by CORS policy
```
→ Firebase 보안 규칙 확인

**4. 경로 오류**
```
Failed to load resource: the server responded with a status of 404
```
→ `_redirects` 파일 확인

---

## 성능 최적화

### 1. 빌드 최적화
```bash
# 릴리즈 모드로 빌드 (최적화 적용)
flutter build web --release

# WASM 빌드 (더 작은 파일 크기)
flutter build web --release --wasm
```

### 2. Netlify 설정 최적화
`netlify.toml`에서 캐싱 설정:
```toml
[[headers]]
  for = "/*.js"
  [headers.values]
    Cache-Control = "public, max-age=31536000, immutable"

[[headers]]
  for = "/*.css"
  [headers.values]
    Cache-Control = "public, max-age=31536000, immutable"
```

### 3. 자산 압축
Netlify는 자동으로 gzip 압축을 적용하지만, 추가 설정 가능:
```toml
[[headers]]
  for = "/*"
  [headers.values]
    X-Content-Type-Options = "nosniff"
    X-Frame-Options = "DENY"
    X-XSS-Protection = "1; mode=block"
```

---

## 커스텀 도메인 설정

1. **Netlify 대시보드** 접속
2. **Domain settings** 선택
3. **Add custom domain** 클릭
4. 도메인 입력 및 DNS 설정 안내 따르기

---

## 환경 변수 설정 (필요시)

Netlify 대시보드에서:
1. **Site settings** > **Environment variables**
2. 필요한 환경 변수 추가
   - `FIREBASE_API_KEY`
   - `FIREBASE_PROJECT_ID`
   등

---

## 자동 배포 설정

GitHub 연동 시 자동 배포:
```yaml
# .github/workflows/deploy.yml
name: Deploy to Netlify

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter build web --release
      - uses: netlify/actions/cli@master
        with:
          args: deploy --dir=build/web --prod
        env:
          NETLIFY_SITE_ID: ${{ secrets.NETLIFY_SITE_ID }}
          NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
```

---

## 문의 및 지원

문제가 계속되면:
1. Netlify 빌드 로그 확인
2. 브라우저 콘솔 로그 확인
3. `build/web` 폴더 구조 확인
   ```bash
   tree build/web -L 2
   ```

배포 성공!
