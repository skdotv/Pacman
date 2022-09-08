import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:testgame/modules/home/widgets/ghost.dart';
import '../../../contants/directions.dart';
import '../../../contants/layout_constants.dart';
import '../../../services/shortest_path.dart';
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
  ShortestPath shortestPath = ShortestPath();
  List<String> path = [];
  int ghostX = 3;
  int ghostY = 6;

  @override
  void initState() {
    super.initState();
    initialseValue();
  }

  void initialseValue() {
    playerIndexX = row - 2;
    playerIndexY = 1;
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
    path = shortestPath.findRoute(Barrier.barrierIndexes2DArray, ghostX, ghostY,
        playerIndexX, playerIndexY);
  }

  @override
  Widget build(BuildContext context) {
    print(path);
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

      default:
        // Path has Food
        // if (mapArray[x][y] == 1) {
        //   return MyPath(
        //     innerColor: Colors.yellow[900]!,
        //     outerColor: Colors.black,
        //     child: Text(
        //       "$x,$y",
        //       style: TextStyle(fontSize: 10),
        //     ),
        //   );
        // }

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
        } else if (x == ghostX && y == ghostY) {
          {
            return const Ghost();
          }
        }

        return MyPath(
          innerColor: Colors.black,
          outerColor: Colors.black,
          child: Text(
            "$x,$y",
            style: TextStyle(fontSize: 10),
          ),
        );

      // else {
      //   // Path with no food
      //   return MyPath(
      //     innerColor: Colors.black,
      //     outerColor: Colors.black,
      //     child: Text(
      //       "$x,$y",
      //       style: TextStyle(fontSize: 10),
      //     ),
      //   );
      // }
    }
  }

  startgame() {
    setState(() {
      playerIndexX = row - 2;
      playerIndexY = 1;
      isGameStart = !isGameStart;
      // to remove intial food
      mapArray[playerIndexX][playerIndexY] = 0;
      moveGhost();
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

  moveGhost() {
    int pathIndex = 0;
    Timer timer;
    timer = Timer.periodic(const Duration(milliseconds: 180), (_) {
      List<String> currIndex = path[pathIndex].split(",");
      setState(() {
        ghostX = int.parse(currIndex[0]);
        ghostY = int.parse(currIndex[1]);
        if (pathIndex < path.length - 1) {
          pathIndex += 1;
        }
      });
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
}
