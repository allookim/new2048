import 'dart:math';

/// 타일 스폰 확률 설정.
/// 스킬(SpawnBoost 등)이 이 설정을 수정해서 확률을 변경한다.
class SpawnConfig {
  /// 4가 생성될 확률 (기본값 0.1 = 10%)
  final double fourSpawnRate;

  const SpawnConfig({this.fourSpawnRate = 0.1});

  /// 다음에 스폰할 타일 값을 반환한다. (2 또는 4)
  int nextValue(Random random) {
    return random.nextDouble() < fourSpawnRate ? 4 : 2;
  }
}
