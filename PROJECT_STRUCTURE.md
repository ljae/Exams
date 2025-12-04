# World Math 앱 프로젝트 구조

이 문서는 World Math Flutter 앱의 소스 코드 구조와 주요 기능에 대해 설명합니다.

## 1. 프로젝트 개요

- **프로젝트 이름:** `world_math`
- **설명:** 수학 문제 풀이 Flutter 애플리케이션입니다. 사용자 인증, 문제 풀이, 기록 확인, 랭킹 보기 등의 기능을 제공합니다.

## 2. 주요 의존성 (Dependencies)

- **상태 관리:** `provider`
- **UI:** `flutter_math_fork`, `flutter_tex` (수학 공식 렌더링), `google_fonts`
- **데이터 저장:** `sqflite` (로컬 데이터베이스)
- **기타:** `intl` (국제화), `url_launcher` (URL 실행)

## 3. 디렉토리 구조

```
/
├── lib/
│   ├── main.dart                   # 앱의 시작점
│   ├── theme.dart                  # 앱의 전반적인 테마 (색상, 폰트 등)
│   ├── models/
│   │   └── models.dart             # 데이터 모델 (User, Problem, Submission 등)
│   ├── screens/
│   │   ├── splash_screen.dart      # 스플래시 화면
│   │   ├── login_screen.dart       # 로그인 화면
│   │   ├── home_screen.dart        # 메인 홈 화면
│   │   ├── main_screen.dart        # 하단 네비게이션 바를 포함하는 메인 화면
│   │   ├── problem_detail_screen.dart # 문제 상세 및 풀이 화면
│   │   ├── problem_reveal_screen.dart # 정답 공개 화면
│   │   ├── history_screen.dart     # 문제 풀이 기록 화면
│   │   └── ranking_screen.dart     # 사용자 랭킹 화면
│   ├── services/
│   │   ├── database_service.dart   # 데이터베이스 관련 로직 처리 (CRUD)
│   │   ├── database_helper_*.dart  # 플랫폼별 (io/web) 데이터베이스 설정
│   │   └── mock_service.dart       # API 모의 서비스 (테스트용)
│   ├── utils/
│   │   └── math_syntax.dart        # 수학 공식 관련 유틸리티
│   └── widgets/                      # 공통으로 사용되는 위젯
│       ├── animated_card.dart
│       ├── app_logo.dart
│       ├── countdown_timer.dart
│       ├── custom_snackbar.dart
│       ├── heartbeat_overlay.dart
│       ├── shimmer_loading.dart
│       ├── success_animation.dart
│       ├── trembling_answer_option.dart
│       └── world_math_app_bar.dart
├── assets/
│   ├── fonts/                      # Paperlogy 폰트 파일
│   └── images/                     # 로고 등 이미지 파일
└── pubspec.yaml                    # 프로젝트 설정 및 의존성 관리
```

## 4. 주요 파일 및 기능 설명

### `lib/`

- **`main.dart`**: 앱의 진입점(Entry Point)입니다. `MaterialApp`을 초기화하고 앱의 라우팅 및 기본 테마를 설정합니다.
- **`theme.dart`**: 앱 전체에서 사용되는 색상, 글꼴 스타일 등 디자인 시스템을 정의합니다.

### `lib/models/`

- **`models.dart`**: 앱에서 사용하는 핵심 데이터 구조를 정의합니다. 예를 들어 `User`, `Problem`, `Submission`과 같은 클래스가 포함됩니다.

### `lib/screens/`

- **`splash_screen.dart`**: 앱 실행 시 가장 먼저 표시되는 화면으로, 초기 데이터 로딩 등의 작업을 수행합니다.
- **`login_screen.dart`**: 사용자 로그인 기능을 담당합니다.
- **`main_screen.dart`**: `home_screen`, `history_screen`, `ranking_screen`을 전환하는 하단 네비게이션 바를 포함하고 있습니다.
- **`home_screen.dart`**: 오늘의 문제, 추천 문제 등 메인 콘텐츠를 보여줍니다.
- **`problem_detail_screen.dart`**: 사용자가 수학 문제를 풀고 답을 제출하는 화면입니다.
- **`problem_reveal_screen.dart`**: 문제 풀이 후 정답과 해설을 보여주는 화면입니다.
- **`history_screen.dart`**: 사용자의 과거 문제 풀이 기록을 목록 형태로 보여줍니다.
- **`ranking_screen.dart`**: 사용자들의 점수를 기반으로 순위를 보여주는 랭킹 보드입니다.

### `lib/services/`

- **`database_service.dart`**: `sqflite`를 사용하여 로컬 데이터베이스에 데이터를 저장, 조회, 수정, 삭제하는 비즈니스 로직을 담당합니다.
- **`database_helper_io.dart` / `database_helper_web.dart`**: 모바일과 웹 환경에 맞는 데이터베이스 초기화 로직을 각각 구현합니다.
- **`mock_service.dart`**: 실제 백엔드 API가 없을 경우를 대비하여 가상의 데이터를 제공하는 서비스입니다. 개발 및 테스트 단계에서 유용하게 사용됩니다.

### `lib/utils/`

- **`math_syntax.dart`**: `flutter_math_fork`나 `flutter_tex`에서 사용되는 수학 공식을 파싱하거나 포맷팅하는 유틸리티 함수를 포함합니다.

### `lib/widgets/`

- 이 디렉토리에는 앱의 여러 화면에서 재사용되는 UI 컴포넌트들이 포함되어 있습니다.
- **`world_math_app_bar.dart`**: 앱 전반에 걸쳐 일관된 디자인을 제공하는 커스텀 앱 바입니다.
- **`countdown_timer.dart`**: 문제 풀이 시 제한 시간을 표시하는 타이머 위젯입니다.
- **`trembling_answer_option.dart`**: 사용자가 답을 선택할 때 상호작용 효과를 주는 위젯입니다.
- **`shimmer_loading.dart`**: 데이터를 불러오는 동안 표시되는 로딩 효과입니다.

## 5. Assets

- **`assets/fonts/`**: `Paperlogy` 폰트가 포함되어 있어 앱 전체의 텍스트 스타일에 사용됩니다.
- **`assets/images/`**: 앱 로고(`logo.png`)와 같은 정적 이미지 파일이 저장됩니다.
