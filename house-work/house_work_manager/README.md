# 🏠 HouseWork Manager

집안일 Todo List 관리 애플리케이션

## 📱 프로젝트 개요

HouseWork Manager는 Flutter로 개발된 집안일 Todo List 관리 애플리케이션입니다. 일상적인 집안일을 체계적으로 관리하고 완료 이력을 추적할 수 있습니다.

## ✨ 주요 기능

### 📋 Todo List 관리

- **할일 등록**: 제목, 설명, 카테고리, 우선순위 설정
- **우선순위**: 긴급/보통/낮음 3단계 우선순위
- **카테고리**: 요리, 청소, 빨래, 쇼핑, 기타
- **반복 일정**: 매일/매주/매월 반복 설정
- **완료 체크**: 할일 완료 시 체크박스로 상태 관리

### 📊 이력 관리

- **완료 이력**: 과거 완료된 할일들의 날짜별 조회
- **소요 시간**: 할일 완료까지 걸린 시간 추적
- **날짜별 그룹화**: 완료된 할일들을 날짜별로 정리

### 📈 통계 대시보드

- **완료율**: 오늘/이번 주/이번 달 완료율 표시
- **카테고리별 통계**: 파이 차트로 카테고리별 분포 시각화
- **최근 활동**: 최근 완료된 할일 목록

## 🛠 기술 스택

- **Flutter**: 크로스 플랫폼 개발 프레임워크
- **Dart**: 프로그래밍 언어
- **SQLite**: 로컬 데이터베이스
- **Riverpod**: 상태 관리
- **FL Chart**: 차트 라이브러리
- **Intl**: 국제화 및 날짜 포맷팅

## 📁 프로젝트 구조

```
lib/
├── main.dart                 # 앱 진입점
├── models/                   # 데이터 모델
│   ├── todo.dart            # Todo 모델
│   └── history.dart         # History 모델
├── screens/                  # 화면
│   ├── home_screen.dart     # 홈 화면
│   ├── add_todo_screen.dart # 할일 추가 화면
│   ├── history_screen.dart  # 이력 화면
│   └── statistics_screen.dart # 통계 화면
├── widgets/                  # 재사용 가능한 위젯
│   └── todo_item.dart       # Todo 아이템 위젯
├── services/                 # 서비스 레이어
│   ├── database_service.dart # 데이터베이스 서비스
│   └── todo_provider.dart   # 상태 관리 Provider
└── utils/                    # 유틸리티
    └── constants.dart       # 상수 정의
```

## 🚀 설치 및 실행

### 필수 요구사항

- Flutter SDK (3.8.1 이상)
- Dart SDK
- Android Studio / Xcode (모바일 개발용)

### 설치 방법

1. **저장소 클론**

   ```bash
   git clone <repository-url>
   cd house_work_manager
   ```

2. **의존성 설치**

   ```bash
   flutter pub get
   ```

3. **앱 실행**

   ```bash
   # iOS 시뮬레이터
   flutter run -d ios

   # Android 에뮬레이터
   flutter run -d android

   # macOS 데스크톱
   flutter run -d macos

   # 웹 브라우저
   flutter run -d chrome
   ```

## 📱 사용 방법

### 1. 할일 추가

- 홈 화면의 '+' 버튼을 탭하여 새 할일 추가
- 제목, 설명, 카테고리, 우선순위, 날짜/시간 설정
- 반복 일정이 필요한 경우 반복 설정 활성화

### 2. 할일 관리

- 할일 목록에서 체크박스를 탭하여 완료 처리
- 할일을 길게 누르거나 메뉴 버튼을 탭하여 편집/삭제
- 우선순위와 카테고리별로 색상 구분

### 3. 이력 확인

- 상단 앱바의 히스토리 아이콘을 탭하여 완료 이력 확인
- 날짜별로 그룹화된 완료된 할일 목록
- 소요 시간 및 완료 시간 정보 표시

### 4. 통계 보기

- 상단 앱바의 차트 아이콘을 탭하여 통계 화면 이동
- 완료율, 카테고리별 통계, 최근 활동 확인
- 기간별 필터링 (오늘/이번 주/이번 달)

## 🎨 UI/UX 특징

- **직관적인 디자인**: 깔끔하고 사용하기 쉬운 인터페이스
- **색상 팔레트**:
  - Primary: #4A90E2 (파란색)
  - Secondary: #F5A623 (주황색)
  - Success: #7ED321 (초록색)
- **카드 기반 레이아웃**: 모던한 카드 디자인
- **반응형 UI**: 다양한 화면 크기에 대응
- **한국어 지원**: 모든 텍스트가 한국어로 표시

## 🔧 개발 정보

### 버전

- 현재 버전: 1.0.0+1

### 지원 플랫폼

- iOS 12.0 이상
- Android API 21 이상
- macOS 10.14 이상
- 웹 브라우저 (Chrome, Firefox, Safari, Edge)

### 의존성 패키지

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0 # SQLite 데이터베이스
  path: ^1.8.3 # 파일 경로 관리
  riverpod: ^2.4.9 # 상태 관리
  flutter_riverpod: ^2.4.9 # Flutter Riverpod
  intl: ^0.18.1 # 날짜 포맷팅
  fl_chart: ^0.65.0 # 차트 라이브러리
  shared_preferences: ^2.2.2 # 설정 저장
  flutter_local_notifications: ^16.3.0 # 로컬 알림
```

## 🚧 향후 개발 계획

### Phase 2: 고급 기능

- [ ] 알림 기능 구현
- [ ] 검색 기능 추가
- [ ] 데이터 백업/복원
- [ ] 다크모드 지원

### Phase 3: 통계 및 개선

- [ ] 성취감 시스템 (배지, 연속 완료)
- [ ] 더 상세한 통계 분석
- [ ] 성능 최적화
- [ ] 접근성 개선

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참조하세요.

## 📞 문의

프로젝트에 대한 문의사항이나 버그 리포트는 이슈를 통해 제출해 주세요.

---

**HouseWork Manager** - 집안일을 체계적으로 관리하세요! 🏠✨
