import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/theme_controller.dart';
import '../game/game_controller.dart';
import '../models/game_mode.dart';
import '../models/tile.dart';
import 'pixel_tile_painter.dart';

const _kGifValues = {2, 4, 8, 16, 32, 64, 128};

class TileWidget extends StatefulWidget {
  final Tile tile;
  final double size;
  final double wiperAngle; // degrees, driven by GameBoard ticker

  const TileWidget({
    super.key,
    required this.tile,
    required this.size,
    this.wiperAngle = 0.0,
  });

  @override
  State<TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _inMergeAnim = false;

  @override
  void initState() {
    super.initState();
    final animCfg = context.read<ThemeController>().theme.animationConfig;

    _controller = AnimationController(
      vsync: this,
      duration: animCfg.mergeDuration,
    );

    if (widget.tile.isNew) {
      _controller.duration = animCfg.spawnDuration;
      _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      );
      _controller.forward();
    } else if (widget.tile.isMerged) {
      _inMergeAnim = true;
      _scaleAnimation = _buildMergeScaleAnim(animCfg.mergeScalePeak);
      _controller.forward();
    } else {
      _scaleAnimation = const AlwaysStoppedAnimation(1.0);
    }
  }

  Animation<double> _buildMergeScaleAnim(double peak) {
    return TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: peak), weight: 50),
      TweenSequenceItem(tween: Tween(begin: peak, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(TileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tile.isMerged && !oldWidget.tile.isMerged) {
      final animCfg = context.read<ThemeController>().theme.animationConfig;
      _inMergeAnim = true;
      _scaleAnimation = _buildMergeScaleAnim(animCfg.mergeScalePeak);
      _controller.forward(from: 0);
      _controller.addStatusListener(_onMergeAnimStatus);
    }
  }

  void _onMergeAnimStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      if (mounted) setState(() => _inMergeAnim = false);
      _controller.removeStatusListener(_onMergeAnimStatus);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>().theme;
    final isGifMode = context.read<GameController>().gameMode == GameMode.normalTest
        && _kGifValues.contains(widget.tile.value);

    if (theme.isPixelStyle) {
      return _buildPixelTile(theme);
    }
    if (theme.tileBgAsset != null) {
      return _buildSeaTile(theme);
    }
    if (isGifMode) {
      return _buildGifTile(theme);
    }
    return _buildClassicTile(theme);
  }

  Widget _buildSeaTile(dynamic theme) {
    final hasValue = widget.tile.value > 0;
    final wiperRad = _inMergeAnim ? 0.0 : widget.wiperAngle * pi / 180;
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: _withSpecialOverlay(
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 버블 배경 (빈 타일만) — TileWidget에서는 game_board가 담당하므로 생략
              // 숫자 타일: 물고기 배경 + 외부 원형 그림자 + 숫자
              if (hasValue && theme.tileFishAsset != null) ...[
                SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: Image.asset(
                    theme.tileFishAsset!,
                    fit: BoxFit.contain,
                  ),
                ),
                Center(
                  child: Transform(
                    transform: Matrix4.rotationZ(wiperRad),
                    alignment: const Alignment(0, 1.4),
                    child: Text(
                      '${widget.tile.value}',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: theme.tileFontSize(widget.tile.value, widget.size),
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: const [
                          Shadow(
                            color: Color(0x88203968),
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGifTile(dynamic theme) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: _withSpecialOverlay(
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: theme.tileColor(widget.tile.value),
            borderRadius: BorderRadius.circular(theme.tileRadius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(theme.tileRadius),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/tiles/${widget.tile.value}.gif',
                  fit: BoxFit.cover,
                ),
                // Bubble decoration
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Color(0x40FFFFFF),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClassicTile(dynamic theme) {
    // wiper angle: suppress during merge spring
    final wiperRad = _inMergeAnim ? 0.0 : widget.wiperAngle * pi / 180;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: _withSpecialOverlay(
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: theme.tileColor(widget.tile.value),
            borderRadius: BorderRadius.circular(theme.tileRadius),
          ),
          child: Stack(
            children: [
              // Bubble decoration — top-left white circle
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Color(0x40FFFFFF),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Number text with wiper rotation
              Center(
                child: Transform(
                  transform: Matrix4.rotationZ(wiperRad),
                  alignment: const Alignment(0, 1.4),
                  child: Text(
                    '${widget.tile.value}',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: theme.tileFontSize(
                          widget.tile.value, widget.size),
                      fontWeight: FontWeight.w900,
                      color: theme.tileTextColor(widget.tile.value),
                      shadows: const [
                        Shadow(
                          color: Color(0x38000000),
                          offset: Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPixelTile(dynamic theme) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final mergeProgress = _inMergeAnim ? _controller.value : 0.0;
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: _withSpecialOverlay(
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: PixelTilePainter(
                  value: widget.tile.value,
                  tileColor: theme.tileColor(widget.tile.value),
                  textColor: theme.tileTextColor(widget.tile.value),
                  mergeProgress: mergeProgress,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _withSpecialOverlay({required Widget child}) {
    final type = widget.tile.tileType;
    if (type == TileType.normal) return child;

    return Stack(
      children: [
        child,
        if (type == TileType.ice)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0x4400BFFF),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        Positioned(
          top: 3,
          right: 3,
          child: _SpecialBadge(type: type, tileSize: widget.size),
        ),
        if (type == TileType.ice && widget.tile.frozenTurns > 0)
          Positioned(
            bottom: 4,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xCC00BFFF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${widget.tile.frozenTurns}턴',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SpecialBadge extends StatelessWidget {
  final TileType type;
  final double tileSize;

  const _SpecialBadge({required this.type, required this.tileSize});

  @override
  Widget build(BuildContext context) {
    final iconSize = (tileSize * 0.22).clamp(10.0, 18.0);
    final (icon, color) = switch (type) {
      TileType.golden => (Icons.star_rounded, const Color(0xFFFFD700)),
      TileType.bomb => (Icons.local_fire_department_rounded, const Color(0xFFFF4500)),
      TileType.ice => (Icons.ac_unit_rounded, const Color(0xFF00BFFF)),
      TileType.wild => (Icons.auto_awesome, const Color(0xFFDA70D6)),
      TileType.normal => (Icons.circle, Colors.transparent),
    };

    return Icon(
      icon,
      size: iconSize,
      color: color,
      shadows: const [Shadow(color: Colors.black45, blurRadius: 3)],
    );
  }
}
