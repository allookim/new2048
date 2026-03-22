# 로드맵

## ✅ Phase 1 - MVP (완료)

| 단계 | 내용 | 관련 파일 |
|------|------|-----------|
| Step 1 | Tile immutable 변경 | `models/tile.dart`, `game/board_logic.dart` |
| Step 2 | 인라인 색상 정리 | 모든 위젯 파일 |
| Step 3 | AppTheme → GameThemeData 동적 전환 | `core/theme/` 전체 |
| Step 4 | Dark Neon 테마 + ThemeScreen | `themes/dark_neon_theme.dart`, `screens/theme_screen.dart` |
| Step 5 | Undo 히스토리 스택 (최대 5회) | `game/board_snapshot.dart`, `game/game_controller.dart` |
| Step 6 | 스킬 시스템 (RemoveTile, UpgradeTile) | `skills/` 전체, `widgets/skill_bar.dart` |
| Step 7 | MainMenuScreen + 네비게이션 | `screens/main_menu_screen.dart`, `main.dart` |

---

## 🔲 Phase 2 - 서비스 기능

### Step 8: Profile + Settings (로컬)
- [ ] `lib/core/settings/settings_controller.dart` - 사운드, 진동 등
- [ ] `lib/screens/profile_screen.dart` - 닉네임, 통계 (bestScore, 게임수)
- [ ] `lib/screens/settings_screen.dart` - 설정 화면
- [ ] `MainMenuScreen`에 Profile, Settings 버튼 추가

### Step 9: Supabase 인증 + 클라우드 동기화
- [ ] `supabase_flutter` 의존성 추가
- [ ] Supabase 프로젝트 생성 + `profiles` 테이블 생성
- [ ] `lib/core/auth/auth_controller.dart`
- [ ] `lib/core/data/user_profile.dart`
- [ ] `lib/core/data/user_repository.dart`
- [ ] `lib/screens/login_screen.dart`
- [ ] 게임 종료 시 bestScore 동기화

### Step 10: Shop + 결제 스캐폴딩
- [ ] `lib/core/purchase/purchase_controller.dart`
- [ ] `lib/screens/shop_screen.dart`
- [ ] `in_app_purchase` 패키지 (실제 결제는 별도 작업)

---

## 🔲 Phase 3 - 고도화

### 테마 확장
- [ ] 우주 테마 (space) - 어두운 배경, 별빛 효과
- [ ] 물속 테마 (ocean) - 파란 계열
- [ ] 숲 테마 (forest) - 초록 계열
- [ ] 각 테마: `themes/xxx_theme.dart` 1개 파일 + registry 등록

### 스킬 확장
- [ ] SpawnBoostSkill - 4 생성 확률 50%로 증가 (5턴간)
- [ ] ShuffleSkill - 타일 위치 랜덤 재배치
- [ ] FreezeSkill - 다음 이동 시 새 타일 스폰 없음

### 게임플레이
- [ ] 사운드 시스템 (audioplayers 패키지)
- [ ] 테마별 배경음악 / 효과음
- [ ] 햅틱 피드백

### 서비스
- [ ] 리더보드 (Supabase PostgreSQL 쿼리)
- [ ] 광고 시스템 (google_mobile_ads)
- [ ] 광고 제거 IAP
- [ ] Rule modifier (테마별 규칙 변경, ex: 3x3 보드, 목표값 변경)

---

## Supabase profiles 테이블 (Step 9 참고)

```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  nickname TEXT,
  best_score INT DEFAULT 0,
  total_games_played INT DEFAULT 0,
  unlocked_themes TEXT[] DEFAULT '{classic}',
  active_theme_id TEXT DEFAULT 'classic',
  settings JSONB DEFAULT '{}',
  purchase_state JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT now(),
  last_played_at TIMESTAMPTZ DEFAULT now()
);

-- Row-level security: 본인 데이터만 읽기/쓰기
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage own profile"
  ON profiles FOR ALL USING (auth.uid() = id);
```
