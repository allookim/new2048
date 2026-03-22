# Flutter 2048 확장 프로젝트 - 마스터 플랜

## 프로젝트 개요
기존 Flutter 2048 게임을 로그라이크 스킬 시스템, 테마 시스템, 메뉴/로그인/DB 구조로 확장.
경로: `/Users/MongLue/Claude/flutter_2048/`

---

## 아키텍처 결정

### 상태관리: Provider (ChangeNotifier)
- 기존 코드가 이미 Provider로 동작
- Flutter 초보자에게 가장 쉬운 mental model
- 이 규모에서 Riverpod 전환 불필요

### MultiProvider 구조 (main.dart)
```
MultiProvider
├── ThemeController  - 현재 테마, 사용 가능 테마, 잠금 해제 상태
├── GameController   - 보드, 점수, 히스토리, 스킬 인벤토리
└── (Phase 2) AuthController, SettingsController
```

### DB: Supabase
- PostgreSQL 기반 → 리더보드 쿼리 용이
- 무료 티어 충분 (50K MAU, 500MB)
- 이메일 + OAuth 내장
- `supabase_flutter` 패키지 성숙

---

## 개발 단계

### ✅ Phase 1 - MVP (완료)
1. **Tile immutable** - 모든 필드 `final`, copyWith() 사용
2. **인라인 색상 정리** - AppTheme에 통합
3. **AppTheme → GameThemeData** - 동적 테마 전환 가능한 구조
4. **Dark Neon 테마 + ThemeScreen** - 테마 선택 화면
5. **Undo 히스토리** - 최대 5회, BoardSnapshot 기반
6. **스킬 시스템** - RemoveTile(x2), UpgradeTile(x1), 타겟팅 모드
7. **MainMenuScreen** - 메뉴 → 게임/테마 네비게이션

### 🔲 Phase 2 - 서비스 기능
8. Profile + Settings 화면 (로컬 데이터)
9. Supabase 인증 + 클라우드 동기화
10. Shop + 결제 스캐폴딩

### 🔲 Phase 3 - 고도화
- 사운드 시스템 (테마별 사운드)
- 추가 스킬 (SpawnBoost, Shuffle)
- 리더보드
- 광고 + IAP

---

## 확장 전략
- **테마 추가** = `lib/core/theme/themes/` 에 파일 1개 + `theme_registry.dart` 등록 1줄
- **스킬 추가** = `lib/skills/implementations/` 에 파일 1개 + GameController 등록
- **화면 추가** = `lib/screens/` 에 파일 1개 + MainMenuScreen에 버튼 추가
