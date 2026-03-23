import 'dart:math' as math;
import 'package:flutter/material.dart';

// 5×7 비트맵 폰트 (0~9)
const Map<String, List<int>> _bitmapFont = {
  '0': [
    0, 1, 1, 1, 0,
    1, 0, 0, 0, 1,
    1, 0, 0, 1, 1,
    1, 0, 1, 0, 1,
    1, 1, 0, 0, 1,
    1, 0, 0, 0, 1,
    0, 1, 1, 1, 0,
  ],
  '1': [
    0, 0, 1, 0, 0,
    0, 1, 1, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 1, 0, 0,
    0, 1, 1, 1, 0,
  ],
  '2': [
    0, 1, 1, 1, 0,
    1, 0, 0, 0, 1,
    0, 0, 0, 0, 1,
    0, 0, 1, 1, 0,
    0, 1, 0, 0, 0,
    1, 0, 0, 0, 0,
    1, 1, 1, 1, 1,
  ],
  '3': [
    0, 1, 1, 1, 0,
    1, 0, 0, 0, 1,
    0, 0, 0, 0, 1,
    0, 0, 1, 1, 0,
    0, 0, 0, 0, 1,
    1, 0, 0, 0, 1,
    0, 1, 1, 1, 0,
  ],
  '4': [
    0, 0, 0, 1, 0,
    0, 0, 1, 1, 0,
    0, 1, 0, 1, 0,
    1, 0, 0, 1, 0,
    1, 1, 1, 1, 1,
    0, 0, 0, 1, 0,
    0, 0, 0, 1, 0,
  ],
  '5': [
    1, 1, 1, 1, 1,
    1, 0, 0, 0, 0,
    1, 1, 1, 1, 0,
    0, 0, 0, 0, 1,
    0, 0, 0, 0, 1,
    1, 0, 0, 0, 1,
    0, 1, 1, 1, 0,
  ],
  '6': [
    0, 0, 1, 1, 0,
    0, 1, 0, 0, 0,
    1, 0, 0, 0, 0,
    1, 1, 1, 1, 0,
    1, 0, 0, 0, 1,
    1, 0, 0, 0, 1,
    0, 1, 1, 1, 0,
  ],
  '7': [
    1, 1, 1, 1, 1,
    0, 0, 0, 0, 1,
    0, 0, 0, 1, 0,
    0, 0, 1, 0, 0,
    0, 1, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 1, 0, 0, 0,
  ],
  '8': [
    0, 1, 1, 1, 0,
    1, 0, 0, 0, 1,
    1, 0, 0, 0, 1,
    0, 1, 1, 1, 0,
    1, 0, 0, 0, 1,
    1, 0, 0, 0, 1,
    0, 1, 1, 1, 0,
  ],
  '9': [
    0, 1, 1, 1, 0,
    1, 0, 0, 0, 1,
    1, 0, 0, 0, 1,
    0, 1, 1, 1, 1,
    0, 0, 0, 0, 1,
    0, 0, 0, 1, 0,
    0, 1, 1, 0, 0,
  ],
};

const int _charW = 5;
const int _charH = 7;
const int _charGap = 1; // 글자 사이 픽셀 간격

/// 픽셀 아트 스타일 타일 렌더러.
/// - 날카로운 모서리 (borderRadius = 0)
/// - 클래식 3D 픽셀 하이라이트/섀도우 테두리
/// - 비트맵 폰트로 숫자 표시
/// - mergeProgress > 0 이면 도트 파티클 이펙트
class PixelTilePainter extends CustomPainter {
  final int value;
  final Color tileColor;
  final Color textColor;

  /// 0.0 = 이펙트 없음, 0→1: 머지 애니메이션 진행도
  final double mergeProgress;

  const PixelTilePainter({
    required this.value,
    required this.tileColor,
    required this.textColor,
    this.mergeProgress = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawBitmapNumber(canvas, size);
    if (mergeProgress > 0.01 && mergeProgress < 0.99) {
      _drawMergeParticles(canvas, size);
    }
  }

  void _drawBackground(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 메인 타일 배경
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = tileColor,
    );

    // 스캔라인 (CRT/픽셀 그리드 느낌): 짝수 행에 반투명 어두운 줄
    final scanPaint = Paint()
      ..color = const Color.fromRGBO(0, 0, 0, 0.08);
    const scanStep = 4.0;
    for (double y = 0; y < h; y += scanStep * 2) {
      canvas.drawRect(Rect.fromLTWH(0, y, w, scanStep), scanPaint);
    }

    // 픽셀 하이라이트 (좌·상단 테두리, 2px)
    final highlight = Color.lerp(tileColor, Colors.white, 0.4)!;
    final hlPaint = Paint()..color = highlight;
    canvas.drawRect(Rect.fromLTWH(0, 0, w - 2, 2), hlPaint);
    canvas.drawRect(Rect.fromLTWH(0, 2, 2, h - 4), hlPaint);

    // 픽셀 섀도우 (우·하단 테두리, 2px)
    final shadow = Color.lerp(tileColor, Colors.black, 0.45)!;
    final shPaint = Paint()..color = shadow;
    canvas.drawRect(Rect.fromLTWH(2, h - 2, w - 2, 2), shPaint);
    canvas.drawRect(Rect.fromLTWH(w - 2, 2, 2, h - 4), shPaint);
  }

  void _drawBitmapNumber(Canvas canvas, Size size) {
    final text = '$value';
    final charCount = text.length;
    final totalPixelCols = charCount * _charW + (charCount - 1) * _charGap;

    // 타일 너비의 60% 에 맞게 픽셀 크기 결정
    final rawPixelSize = (size.width * 0.60) / totalPixelCols;
    final pixelSize = rawPixelSize.clamp(2.0, 9.0);

    final totalW = totalPixelCols * pixelSize;
    final totalH = _charH * pixelSize;

    final startX = (size.width - totalW) / 2;
    final startY = (size.height - totalH) / 2;

    final paint = Paint()..color = textColor;
    // 텍스트에도 살짝 픽셀 간격 (0.5px 갭)
    const gap = 0.5;

    for (int ci = 0; ci < charCount; ci++) {
      final bitmap = _bitmapFont[text[ci]];
      if (bitmap == null) continue;

      final ox = startX + ci * (_charW + _charGap) * pixelSize;

      for (int row = 0; row < _charH; row++) {
        for (int col = 0; col < _charW; col++) {
          if (bitmap[row * _charW + col] == 1) {
            canvas.drawRect(
              Rect.fromLTWH(
                ox + col * pixelSize + gap,
                startY + row * pixelSize + gap,
                pixelSize - gap * 2,
                pixelSize - gap * 2,
              ),
              paint,
            );
          }
        }
      }
    }
  }

  /// 머지 이펙트: 도트(픽셀)들이 퍼졌다가 다시 모이는 효과
  void _drawMergeParticles(Canvas canvas, Size size) {
    // sin(progress × π) → 0.5 지점에서 최대 산포
    final scatter = math.sin(mergeProgress * math.pi);
    if (scatter < 0.01) return;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxR = size.width * 0.75 * scatter;

    // value를 seed로 사용 → 매 프레임 동일한 파티클 패턴
    final rng = math.Random(value * 31 + 7);
    const count = 20;

    for (int i = 0; i < count; i++) {
      final angle = rng.nextDouble() * 2 * math.pi;
      final radFrac = rng.nextDouble() * 0.5 + 0.5;
      final pSize = (rng.nextDouble() * 2.5 + 1.5) *
          (size.width / 56).clamp(1.0, 3.5);

      final px = cx + math.cos(angle) * maxR * radFrac;
      final py = cy + math.sin(angle) * maxR * radFrac;

      // 산포 시 점차 투명해짐
      final alpha = (1.0 - scatter * 0.6).clamp(0.0, 1.0);
      // 색상: 타일 컬러보다 약간 밝게
      final baseColor = Color.lerp(tileColor, Colors.white, 0.3)!;
      final pColor = baseColor.withValues(alpha: alpha);

      canvas.drawRect(
        Rect.fromLTWH(px - pSize / 2, py - pSize / 2, pSize, pSize),
        Paint()..color = pColor,
      );
    }
  }

  @override
  bool shouldRepaint(PixelTilePainter old) =>
      old.mergeProgress != mergeProgress ||
      old.value != value ||
      old.tileColor != tileColor ||
      old.textColor != textColor;
}
