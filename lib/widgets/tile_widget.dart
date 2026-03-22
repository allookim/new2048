import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/theme_controller.dart';
import '../models/tile.dart';

class TileWidget extends StatefulWidget {
  final Tile tile;
  final double size;

  const TileWidget({super.key, required this.tile, required this.size});

  @override
  State<TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

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
      _scaleAnimation = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween(begin: 1.0, end: animCfg.mergeScalePeak),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: Tween(begin: animCfg.mergeScalePeak, end: 1.0),
          weight: 50,
        ),
      ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
      _controller.forward();
    } else {
      _scaleAnimation = const AlwaysStoppedAnimation(1.0);
    }
  }

  @override
  void didUpdateWidget(TileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tile.isMerged && !oldWidget.tile.isMerged) {
      final animCfg = context.read<ThemeController>().theme.animationConfig;
      _scaleAnimation = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween(begin: 1.0, end: animCfg.mergeScalePeak),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: Tween(begin: animCfg.mergeScalePeak, end: 1.0),
          weight: 50,
        ),
      ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
      _controller.forward(from: 0);
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
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: theme.tileColor(widget.tile.value),
          borderRadius: BorderRadius.circular(theme.tileRadius),
        ),
        child: Center(
          child: Text(
            '${widget.tile.value}',
            style: TextStyle(
              fontSize: theme.tileFontSize(widget.tile.value),
              fontWeight: FontWeight.bold,
              color: theme.tileTextColor(widget.tile.value),
            ),
          ),
        ),
      ),
    );
  }
}
