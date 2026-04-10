# Num Loop 개발 플랜

---

## Phase 1 — 게임 완성도 (현재 · 윈도우 가능)

**레이아웃 & UI**
- [ ] 현재 레이아웃 마무리 (패딩, 정렬, 폰트)
- [ ] 게임오버/타임업 오버레이 개선
- [ ] 드로어 메뉴 정리

**게임 모드 디벨롭**
- [ ] Normal 모드 룰 확정
- [ ] Item 모드 룰 확정 (스킬 밸런싱)
- [ ] Speed 모드 룰 확정 (타이머, 콤보 시스템)
- [ ] 모드별 UI 차별화

---

## Phase 2 — 테마 확장 (윈도우 가능)

**테마 추가**
- [ ] Sea 테마 완성 (현재 진행 중)
- [ ] 신규 테마 발굴 및 디자인
- [ ] 테마별 타일 에셋 제작
- [ ] 테마별 배경 (이미지/영상)
- [ ] 테마 잠금/해금 시스템 정비

**사운드**
- [ ] 테마별 BGM
- [ ] 타일 합치기 효과음
- [ ] 게임오버/클리어 효과음
- [ ] 사운드 on/off 설정 연동

**햅틱**
- [ ] 타일 이동 햅틱
- [ ] 합치기 햅틱 (강도 차별화)
- [ ] 게임오버 햅틱
- [ ] 햅틱 on/off 설정 연동

---

## Phase 3 — 설정 완성 (윈도우 가능)

- [ ] 사운드 볼륨/on·off
- [ ] 햅틱 on·off
- [ ] 언어 설정 (한/영)
- [ ] 기록 초기화
- [ ] 앱 버전 표시
- [ ] 개인정보처리방침 링크

---

## Phase 4 — 서버 & 소셜 (윈도우 가능)

> **DB 선택: Supabase** (Postgres 기반, Flutter 공식 지원, SQL 랭킹 쿼리 적합)
> **분석/푸시: Firebase** (Crashlytics + Analytics + FCM) — Supabase와 병행 사용, 충돌 없음
> 역할 분리: Supabase = DB·인증·랭킹 / Firebase = 크래시·분석·푸시

**Supabase 셋업**
- [ ] Supabase 프로젝트 생성
- [ ] `users` 테이블 설계 (id, apple_id, nickname, created_at)
- [ ] `scores` 테이블 설계 (id, user_id, mode, score, created_at)
- [ ] Flutter `supabase_flutter` 패키지 연동
- [ ] 랭킹 조회 쿼리 구현 (모드별 TOP 100)

**인증**
- [ ] Sign in with Apple 연동 (Supabase Auth)
- [ ] 익명 게스트 플레이 지원 여부 결정

**Firebase (분석·푸시, 추후 추가)**
- [ ] Firebase 프로젝트 생성
- [ ] Crashlytics 연동 (앱 크래시 자동 기록)
- [ ] Analytics 연동 (유저 행동, 모드별 플레이 통계)
- [ ] FCM 푸시 알림 (필요 시)

**소셜**
- [ ] Game Center 연동 준비 (iOS 전용, 맥 필요)

---

## Phase 5 — iOS 배포 (맥 필요)

- [ ] Xcode 프로젝트 설정
- [ ] Apple Developer 인증서
- [ ] Game Center 활성화
- [ ] Sign in with Apple
- [ ] TestFlight 내부 테스트
- [ ] App Store 심사 제출

---

> **현재 위치**: Phase 1~2 진행 중
> **다음 스텝**: 게임 모드 룰 확정 → 테마 확장 → 사운드/햅틱
