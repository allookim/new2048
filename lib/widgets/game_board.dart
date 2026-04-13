import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/theme/theme_controller.dart';
import '../game/board_logic.dart';
import '../game/game_controller.dart';
import '../models/tile.dart';
import 'tile_widget.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard>
    with SingleTickerProviderStateMixin {
  late AnimationController _wiperController;

  @override
  void initState() {
    super.initState();
    _wiperController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _wiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>().theme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final boardWidth = constraints.maxWidth;
        final cs = theme.cellSize(boardWidth);
        final bh = theme.boardHeight(boardWidth);

        return Consumer<GameController>(
          builder: (context, controller, _) {
            return Focus(
              autofocus: true,
              onKeyEvent: (node, event) {
                if (event is! KeyDownEvent) return KeyEventResult.ignored;
                Direction? dir;
                if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                  dir = Direction.left;
                } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                  dir = Direction.right;
                } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                  dir = Direction.up;
                } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                  dir = Direction.down;
                }
                if (dir != null) {
                  controller.move(dir);
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: GestureDetector(
                onPanEnd: (details) {
                  final velocity = details.velocity.pixelsPerSecond;
                  const threshold = 200.0;
                  if (velocity.dx.abs() > velocity.dy.abs()) {
                    if (velocity.dx > threshold) {
                      controller.move(Direction.right);
                    } else if (velocity.dx < -threshold) {
                      controller.move(Direction.left);
                    }
                  } else {
                    if (velocity.dy > threshold) {
                      controller.move(Direction.down);
                    } else if (velocity.dy < -threshold) {
                      controller.move(Direction.up);
                    }
                  }
                },
                child: Container(
                  width: boardWidth,
                  height: bh,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(theme.boardRadius),
                  ),
                  child: Stack(
                    children: [
                      // Background grid cells
                      ...List.generate(4, (r) {
                        return List.generate(4, (c) {
                          return Positioned(
                            left: theme.tileLeft(c, boardWidth),
                            top: theme.tileTop(r, boardWidth),
                            child: theme.tileBgAsset != null
                                ? _CircleImageTile(
                                    asset: theme.tileBgAsset!,
                                    size: cs,
                                    bgColor: const Color(0xFF01578E),
                                  )
                                : Container(
                                    width: cs,
                                    height: cs,
                                    decoration: BoxDecoration(
                                      color: theme.cellColor,
                                      borderRadius: BorderRadius.circular(
                                          theme.tileRadius),
                                    ),
                                  ),
                          );
                        });
                      }).expand((list) => list),

                      // Tile layer — driven by wiper ticker
                      AnimatedBuilder(
                        animation: _wiperController,
                        builder: (context, _) {
                          final wiperAngle =
                              7.0 * sin(2 * pi * _wiperController.value);
                          return Stack(
                            children: controller.board
                                .expand((row) => row)
                                .whereType<Tile>()
                                .map((tile) {
                              return AnimatedPositioned(
                                key: ValueKey(tile.id),
                                duration: theme.animationConfig.moveDuration,
                                curve: Curves.easeInOut,
                                left: theme.tileLeft(tile.col, boardWidth),
                                top: theme.tileTop(tile.row, boardWidth),
                                child: GestureDetector(
                                  onTap: controller.isTargeting
                                      ? () => controller.applyTargetedSkill(
                                          tile.row, tile.col)
                                      : null,
                                  child: Stack(
                                    children: [
                                      TileWidget(
                                        tile: tile,
                                        size: cs,
                                        wiperAngle: wiperAngle,
                                      ),
                                      if (controller.isTargeting)
                                        Container(
                                          width: cs,
                                          height: cs,
                                          decoration: BoxDecoration(
                                            color: theme.buttonColor
                                                .withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(
                                                theme.tileRadius),
                                            border: Border.all(
                                              color: theme.buttonColor
                                                  .withValues(alpha: 0.6),
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// 원형 마스크에 이미지 (그림자는 이미지에 포함)
class _CircleImageTile extends StatelessWidget {
  final String asset;
  final double size;
  final Color bgColor;
  const _CircleImageTile({required this.asset, required this.size, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: asset.endsWith('.svg')
          ? SvgPicture.asset(asset, fit: BoxFit.contain)
          : Image.asset(asset, fit: BoxFit.contain),
    );
  }
}
