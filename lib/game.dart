import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'components/gameinfo.dart';
import 'management/gamelogic.dart';
import 'components/board.dart';
import "package:flutter/foundation.dart";
import 'management/gametimer.dart';
import 'theme/colors.dart';

class MineSweeper extends ConsumerStatefulWidget {
  const MineSweeper({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MineSweeperState();
}

class _MineSweeperState extends ConsumerState<MineSweeper> {
  late GameTimer timer;

  void updateGame() {
    setState(() {
      if (kDebugMode) {
        ref.read(boardManager).gameover
            ? logger.log(Level.info, "Game Over!")
            : null;
        ref.read(boardManager).goodgame
            ? logger.log(Level.info, "Good Game!")
            : null;
      }
    });
  }

  void resetGame() {
    setState(() {
      ref.read(boardManager.notifier).initGame();
      // ReCreate Timer When Game Reset
      timer.stopTimer();
      timer = GameTimer(timestart: 180, refresh: updateGame);
    });
  }

  @override
  void initState() {
    super.initState();
    ref.read(boardManager.notifier).initGame();
    // Create Timer
    timer = GameTimer(timestart: 180, refresh: updateGame);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
              "MineSweeper",
          ),
          actions: [
            IconButton(
              onPressed: () {
                resetGame();
              },
              icon: const Icon(
                  Icons.refresh,
              ),
            )
          ],
        ),
        backgroundColor: backgroundcolor,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Center(
                child: Stack(children: [
                  GameBoard(refresh: updateGame),
                  GameInfo(resetGame: resetGame, time: timer),
            ])),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // reset button
                Container(
                    width: boardwidth / 2,
                    height: 22,
                    decoration: BoxDecoration(
                        color: modecolor,
                        borderRadius: const BorderRadius.only(
                            topLeft:
                                Radius.circular(cellwidth / cellroundscale),
                            bottomLeft:
                                Radius.circular(cellwidth / cellroundscale),
                        ),
                    ),
                    child: const Text(
                      "Level: Easy",
                      textAlign: TextAlign.center,
                    )),
                // The Timer
                Container(
                    width: boardwidth / 2,
                    height: 22,
                    decoration: BoxDecoration(
                        color: timercolor,
                        borderRadius: const BorderRadius.only(
                            topRight:
                                Radius.circular(cellwidth / cellroundscale),
                            bottomRight:
                                Radius.circular(cellwidth / cellroundscale),
                        ),
                    ),
                    child: Text(
                      "Timer: ${timer.getTime()}",
                      textAlign: TextAlign.center,
                    )),
              ],
            ),
          ],
        ));
  }
}
