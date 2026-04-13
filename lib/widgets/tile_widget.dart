import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../core/theme/theme_controller.dart';
import '../game/game_controller.dart';
import '../models/game_mode.dart';
import '../models/tile.dart';
import 'pixel_tile_painter.dart';

const _kGifValues = {2, 4, 8, 16, 32, 64, 128};

bool _isArrowType(TileType t) =>
    t == TileType.arrowLeft || t == TileType.arrowRight ||
    t == TileType.arrowUp   || t == TileType.arrowDown;

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
    final fishAsset = theme.tileFishAssetForValue(widget.tile.value);
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
              // 1. 물고기 (최하단)
              if (hasValue && fishAsset != null)
                Image.asset(fishAsset, fit: BoxFit.contain),
              // 2. 숫자
              if (hasValue)
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
              // 4. 아이템 뱃지 → _withSpecialOverlay 에서 최상단 처리
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

    final badgeSize   = widget.size * 0.35;
    // 원형 타일 45° 경계 바깥에 뱃지 중심이 오도록
    final badgeOffset = -(widget.size * 0.03);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (_isArrowType(type))
          Positioned(
            top: badgeOffset,
            right: badgeOffset,
            child: _ArrowBadge(type: type, size: badgeSize),
          ),
        if (type == TileType.lock)
          Positioned(
            top: badgeOffset,
            right: badgeOffset,
            child: _LockBadge(frozenTurns: widget.tile.frozenTurns, size: badgeSize),
          ),
      ],
    );
  }
}

// ── Arrow Badge ───────────────────────────────────────────────

const _kArrowAssets = {
  TileType.arrowLeft:  'assets/tiles/ic_item_arrow_left.svg',
  TileType.arrowRight: 'assets/tiles/ic_item_arrow_right.svg',
  TileType.arrowUp:    'assets/tiles/ic_item_arrow_up.svg',
  TileType.arrowDown:  'assets/tiles/ic_item_arrow_down.svg',
};

class _ArrowBadge extends StatelessWidget {
  final TileType type;
  final double size;
  const _ArrowBadge({required this.type, required this.size});

  @override
  Widget build(BuildContext context) {
    final asset = _kArrowAssets[type];
    if (asset == null) return const SizedBox.shrink();
    return SvgPicture.asset(asset, width: size, height: size);
  }
}

// ── Lock Badge (icon + circular progress) ────────────────────

class _LockBadge extends StatelessWidget {
  final int frozenTurns;
  final double size;
  const _LockBadge({required this.frozenTurns, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF511309),
              shape: BoxShape.circle,
            ),
          ),
          SvgPicture.asset(
            'assets/tiles/ic_item_lock.svg',
            width: size,
            height: size,
          ),
          Positioned.fill(
            child: Transform.scale(
              scaleX: -1,
              child: CircularProgressIndicator(
                value: frozenTurns / 8.0,
                strokeWidth: 2.8,
                backgroundColor: const Color(0xFF2b0802),
                valueColor: const AlwaysStoppedAnimation(Color(0xFFff5757)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
