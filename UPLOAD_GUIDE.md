# Firebase 문제 업로드 가이드

## 개요
`problem-generator`에서 생성된 문제를 Firebase Firestore에 자동으로 업로드하는 가이드입니다.

## 초기 설정

### 1. Firebase Admin SDK 설치
```bash
pip3 install firebase-admin
```

### 2. Firebase 인증 설정

Firebase Admin SDK를 사용하려면 서비스 계정 키가 필요합니다:

1. **Firebase Console 접속**
   - https://console.firebase.google.com/
   - 프로젝트 선택: `real-math-d9ddf`

2. **서비스 계정 키 생성**
   - 프로젝트 설정 > 서비스 계정 탭
   - "새 비공개 키 생성" 클릭
   - JSON 파일 다운로드

3. **환경 변수 설정**
   ```bash
   export GOOGLE_APPLICATION_CREDENTIALS="/path/to/your/serviceAccountKey.json"
   ```

   또는 `~/.zshrc` 또는 `~/.bash_profile`에 추가:
   ```bash
   echo 'export GOOGLE_APPLICATION_CREDENTIALS="/path/to/your/serviceAccountKey.json"' >> ~/.zshrc
   source ~/.zshrc
   ```

## 사용 방법

### 1. 모든 문제 업로드
```bash
cd /Users/jaelee/.gemini/antigravity/scratch/world_math
python3 upload_problems_to_firebase.py --all
```

### 2. 특정 문제 파일 업로드
```bash
python3 upload_problems_to_firebase.py --file p_20251117.json
```

### 3. 특정 주의 문제 업로드
```bash
# 2025년 12월 1일부터 7일간의 문제 업로드
python3 upload_problems_to_firebase.py --week 20251201
```

### 4. 업로드 전 미리보기 (Dry Run)
```bash
# 실제로 업로드하지 않고 어떤 문제가 업로드될지 확인
python3 upload_problems_to_firebase.py --all --dry-run
```

## 워크플로우

### 일반적인 작업 순서

1. **문제 생성**
   ```bash
   cd ~/.claude/projects/problem-generator
   # 문제 생성 스크립트 실행
   # 생성된 문제는 outputs/ 폴더에 저장됨
   ```

2. **생성된 문제 확인**
   ```bash
   ls -lt ~/.claude/projects/problem-generator/outputs/p_*.json | head -5
   ```

3. **업로드 전 미리보기**
   ```bash
   cd /Users/jaelee/.gemini/antigravity/scratch/world_math
   python3 upload_problems_to_firebase.py --file p_YYYYMMDD.json --dry-run
   ```

4. **Firebase에 업로드**
   ```bash
   python3 upload_problems_to_firebase.py --file p_YYYYMMDD.json
   ```

5. **Flutter 앱에서 확인**
   - Flutter 앱을 실행하면 자동으로 새 문제가 표시됩니다
   - 앱이 실행 중이라면 hot reload로 확인 가능

## 문제 데이터 구조

### problem-generator 출력 형식
```json
{
  "problem_id": "PID_20251129_000001",
  "date": "2025-11-17",
  "title": "문제 제목",
  "problem": {
    "scenario_text": "문제 상황 설명...",
    "questions": [{
      "question": "질문 내용",
      "choices": ["① 선택지1", "② 선택지2", ...],
      "correct_answer": "③ 정답",
      "answer_value": 22
    }]
  },
  "solution": { ... },
  "metadata": { ... }
}
```

### Firestore에 저장되는 형식
```
problems (collection)
  └── PID_20251129_000001 (document)
      ├── problemId: "PID_20251129_000001"
      ├── week: "20251117"
      ├── title: "문제 제목"
      ├── content: "문제 상황 설명..."
      ├── question: "질문 내용"
      ├── choices: ["① 선택지1", ...]
      ├── correctAnswer: "③ 정답"
      ├── solution: { ... }
      ├── metadata: { ... }
      └── statistics: { totalAttempts: 0, correctAttempts: 0 }
```

## 트러블슈팅

### 1. "firebase-admin not installed" 오류
```bash
pip3 install firebase-admin
```

### 2. "Permission denied" 오류
Firebase 보안 규칙 확인:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;  // 개발 중에만 사용
    }
  }
}
```

### 3. "GOOGLE_APPLICATION_CREDENTIALS not set" 오류
서비스 계정 키 설정:
```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/serviceAccountKey.json"
```

### 4. "Problem generator folder not found" 오류
problem-generator 경로 확인:
```bash
ls ~/.claude/projects/problem-generator/outputs/
```

## 주의사항

1. **서비스 계정 키 보안**
   - 서비스 계정 JSON 파일을 Git에 커밋하지 마세요
   - `.gitignore`에 `*serviceAccountKey*.json` 추가 권장

2. **중복 업로드**
   - 같은 `problemId`로 업로드하면 기존 문제를 덮어씁니다
   - 의도하지 않은 덮어쓰기를 방지하려면 `--dry-run`으로 먼저 확인하세요

3. **보안 규칙**
   - 현재 보안 규칙은 개발용입니다 (모든 읽기/쓰기 허용)
   - 프로덕션 배포 전에 적절한 보안 규칙으로 변경해야 합니다

## 자동화 스크립트 예시

매주 월요일마다 새 문제를 자동으로 업로드하는 cron job:

```bash
# crontab -e
0 9 * * 1 cd /Users/jaelee/.gemini/antigravity/scratch/world_math && python3 upload_problems_to_firebase.py --week $(date +\%Y\%m\%d) >> /tmp/firebase_upload.log 2>&1
```

## 문의 및 지원

문제 발생 시:
1. 로그 확인: `--dry-run` 옵션으로 먼저 테스트
2. Firebase Console에서 Firestore 데이터 확인
3. Flutter 앱 로그 확인: `flutter run -d macos`
