import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../contants/directions.dart';
import '../../../contants/layout_constants.dart';
import '../widgets/path.dart';
import '../widgets/pixel.dart';
import '../widgets/player.dart';
import '../widgets/score.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static late int numbersInRow;
  late int numberOfSquare;
  late int player;
  late bool isGameStart;
  late int quarterTurns;
  late bool mouthClose;
  late List<int> pacManFood;
  late int ghost;
  int score = 0;
  late int maxScore = -1;
  Timer? ghosTimer;
  Timer? timer;
  late List<int> pathArray = [];
  int row = Barrier.barrierIndexes2DArray.length;
  int col = Barrier.barrierIndexes2DArray[0].length;
  List<List<int>> mapArray = Barrier.barrierIndexes2DArray;
  int testNumber = 0;
  int playerIndexX = -1;
  int playerIndexY = -1;

  @override
  void initState() {
    super.initState();
    initialseValue();
  }

  void initialseValue() {
    numbersInRow = 11;
    player = numbersInRow * 15 + 1;
    ghost = numbersInRow * 7 + 4;
    numberOfSquare = numbersInRow * 17;
    isGameStart = false;
    quarterTurns = 0;
    mouthClose = false;
    pacManFood = [];
    score = 0;
    pathArray.add(player);
    pathArray.add(ghost);
    calcMaxScore();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (RawKeyEvent event) {
          rawKeyEventListener(event);
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Column(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  color: Colors.black,
                  child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: row * col,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: col),
                      itemBuilder: (BuildContext context, int index) {
                        int x, y = 0;
                        x = (index / col).floor();
                        y = (index % col);
                        return _buildGridItems(x, y);
                      }),
                ),
              ),
              Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Score(score: score),
                        InkWell(
                          onTap: () {
                            // startGame();
                            startgame();
                          },
                          child: !isGameStart
                              ? Image.asset(
                                  'assets/images/game_start.png',
                                  height: 60,
                                )
                              : const Text("End"),
                        ),
                        isGameStart
                            ? Column(
                                children: [
                                  IconButton(
                                      icon: const Icon(
                                        Icons.arrow_upward,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => userInput(Direction.up)),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.arrow_back,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                        onPressed: () =>
                                            userInput(Direction.left),
                                      ),
                                      const SizedBox(
                                        width: 40,
                                      ),
                                      IconButton(
                                          icon: const Icon(
                                            Icons.arrow_forward,
                                            size: 20,
                                            color: Colors.white,
                                          ),
                                          onPressed: () =>
                                              userInput(Direction.right)),
                                    ],
                                  ),
                                  IconButton(
                                      icon: const Icon(
                                        Icons.arrow_downward,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                      onPressed: () =>
                                          userInput(Direction.down)),
                                ],
                              )
                            : const SizedBox.shrink()
                      ],
                    ),
                  ))
            ],
          ),
        ));
  }

  Widget _buildGridItems(int x, int y) {
    switch (mapArray[x][y]) {
      // Barrier
      case -1:
        return MyPixel(
          innerColor: Colors.deepPurple[900]!,
          outerColor: Colors.deepPurple[800]!,
        );
      // Path has Food
      case 1:
        return MyPath(
          innerColor: Colors.yellow[900]!,
          outerColor: Colors.black,
        );

      default:
        if (score == maxScore) {
          gameStop();
          // showFinalScore();
        }

        if (x == playerIndexX && y == playerIndexY) {
          return RotatedBox(
              quarterTurns: quarterTurns,
              child: Player(
                closeMouth: mouthClose,
              ));
        } else {
          // Path with no food
          return const MyPath(
            innerColor: Colors.black,
            outerColor: Colors.black,
          );
        }
    }
  }

  startgame() {
    setState(() {
      playerIndexX = row - 2;
      playerIndexY = 1;
      isGameStart = !isGameStart;
      // to remove intial food
      mapArray[playerIndexX][playerIndexY] = 0;
    });
  }

  userInput(Direction direction) {
    if (timer != null && timer!.isActive) {
      timer!.cancel();
    }
    timer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      switch (direction) {
        case Direction.up:
          moveUp();
          break;
        case Direction.down:
          moveDown();
          break;
        case Direction.left:
          moveLeft();
          break;
        case Direction.right:
          moveRight();
          break;
        default:
      }
    });
    // }
  }

  void gameStop() {}

  //

  eatFood(int x, int y) {
    if (mapArray[playerIndexX][playerIndexY] == 1) {
      score += 1;
      mapArray[playerIndexX][playerIndexY] = 0;
    }
  }

  closeMouth() {
    mouthClose = !mouthClose;
  }

  calcMaxScore() {
    int count = -1;
    for (var elements in mapArray) {
      for (var element in elements) {
        if (element == 1) {
          count += 1;
        }
      }
    }
    setState(() {
      maxScore = count;
    });
  }

  // for keyboard arrow input
  void rawKeyEventListener(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey.keyId == LogicalKeyboardKey.arrowUp.keyId) {
        userInput(Direction.up);
      } else if (event.logicalKey.keyId == LogicalKeyboardKey.arrowDown.keyId) {
        userInput(Direction.down);
      } else if (event.logicalKey.keyId == LogicalKeyboardKey.arrowLeft.keyId) {
        userInput(Direction.left);
      } else if (event.logicalKey.keyId ==
          LogicalKeyboardKey.arrowRight.keyId) {
        userInput(Direction.right);
      }
    }
  }

  moveUp() {
    setState(() {
      if (mapArray[playerIndexX - 1][playerIndexY] != -1) {
        playerIndexX -= 1;
        quarterTurns = 3;
      }
      eatFood(playerIndexX, playerIndexY);
    });
  }

  moveDown() {
    setState(() {
      if (mapArray[playerIndexX + 1][playerIndexY] != -1) {
        playerIndexX += 1;
        quarterTurns = 1;
      }
      eatFood(playerIndexX, playerIndexY);
    });
  }

  moveLeft() {
    setState(() {
      if (mapArray[playerIndexX][playerIndexY - 1] != -1) {
        playerIndexY -= 1;
        quarterTurns = 2;
      }
      eatFood(playerIndexX, playerIndexY);
    });
  }

  moveRight() {
    setState(() {
      if (mapArray[playerIndexX][playerIndexY + 1] != -1) {
        playerIndexY += 1;
        quarterTurns = 0;
      }
      eatFood(playerIndexX, playerIndexY);
    });
  }

// Future<void> showFinalScore() async {
  //   await showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           // backgroundColor: Colors.deepPurpleAccent,
  //           title: Text(
  //             "Winner ",
  //             style: TextStyle(
  //               fontSize: 20,
  //               fontWeight: FontWeight.bold,
  //               color: Colors.yellow.shade800,
  //             ),
  //           ),
  //           actionsAlignment: MainAxisAlignment.center,
  //           actions: [
  //             TextButton(
  //               style: ButtonStyle(
  //                 backgroundColor: MaterialStateProperty.all(Colors.green),
  //               ),
  //               onPressed: () {
  //                 Navigator.pop(context);
  //                 startgame();
  //               },
  //               child: const Text(
  //                 "Restart",
  //                 style: TextStyle(
  //                   fontSize: 18,
  //                 ),
  //               ),
  //             ),
  //             TextButton(
  //               style: ButtonStyle(
  //                 backgroundColor: MaterialStateProperty.all(Colors.red),
  //               ),
  //               onPressed: () {
  //                 Navigator.pop(context);
  //               },
  //               child: const Text(
  //                 "Close",
  //                 style: TextStyle(
  //                   fontSize: 18,
  //                 ),
  //               ),
  //             )
  //           ],
  //         );
  //       });
  // }

}
