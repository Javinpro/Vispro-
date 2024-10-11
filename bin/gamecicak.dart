import 'dart:io';
import 'dart:math';
import 'dart:async';

class CicakGame {
  final String foodSymbol;
  late List<List<int>> bodySegments;
  late int foodX;
  late int foodY;
  late int gridWidth;
  late int gridHeight;
  late String currentDirection;
  late bool isGameOver;

  CicakGame(this.foodSymbol) {
    List<int> terminalSize = _getTerminalSize();
    gridWidth = terminalSize[0];
    gridHeight = terminalSize[1];
    bodySegments = [
      [gridWidth ~/ 2, gridHeight ~/ 2], // Head
      [gridWidth ~/ 2 - 1, gridHeight ~/ 2], // Body
      [gridWidth ~/ 2 - 2, gridHeight ~/ 2], // Body
      [gridWidth ~/ 2 - 3, gridHeight ~/ 2], // Body
      [gridWidth ~/ 2 - 2, gridHeight ~/ 2], // Body
    ];
    currentDirection = 'right';
    isGameOver = false;
    _placeFoodRandomly();
  }

  List<int> _getTerminalSize() {
    try {
      ProcessResult result = Process.runSync('stty', ['size']);
      String output = result.stdout.toString().trim();
      if (output.isEmpty) {
        return [80, 24];
      }
      List<String> size = output.split(' ');
      if (size.length != 2) {
        return [80, 24];
      }
      int height = int.parse(size[0]);
      int width = int.parse(size[1]);
      return [width, height];
    } catch (e) {
      return [80, 24];
    }
  }

  void _placeFoodRandomly() {
    Random random = Random();
    do {
      foodX = random.nextInt(gridWidth);
      foodY = random.nextInt(gridHeight);
    } while (bodySegments
        .any((segment) => segment[0] == foodX && segment[1] == foodY));
  }

  void move() {
    List<int> newHead = List.from(bodySegments.first);
    switch (currentDirection) {
      case 'up':
        newHead[1] = (newHead[1] - 1 + gridHeight) % gridHeight;
        break;
      case 'down':
        newHead[1] = (newHead[1] + 1) % gridHeight;
        break;
      case 'left':
        newHead[0] = (newHead[0] - 1 + gridWidth) % gridWidth;
        break;
      case 'right':
        newHead[0] = (newHead[0] + 1) % gridWidth;
        break;
    }

    // Check for collision with itself
    if (bodySegments.sublist(1).any(
        (segment) => segment[0] == newHead[0] && segment[1] == newHead[1])) {
      isGameOver = true;
      return;
    }

    bodySegments.insert(0, newHead);

    // Check if the cicak ate the food
    if (newHead[0] == foodX && newHead[1] == foodY) {
      _placeFoodRandomly();
      // Add a new body segment
      bodySegments.insert(1, List.from(bodySegments[1]));
    } else {
      bodySegments.removeLast();
    }
  }

  void chooseDirection() {
    List<int> head = bodySegments.first;
    List<String> possibleDirections = ['up', 'down', 'left', 'right'];
    possibleDirections.remove(_oppositeDirection(currentDirection));

    possibleDirections.sort((a, b) {
      int distanceA = _getDistance(_getNextPosition(a), [foodX, foodY]);
      int distanceB = _getDistance(_getNextPosition(b), [foodX, foodY]);
      return distanceA.compareTo(distanceB);
    });

    currentDirection = possibleDirections.first;
  }

  String _oppositeDirection(String dir) {
    switch (dir) {
      case 'up':
        return 'down';
      case 'down':
        return 'up';
      case 'left':
        return 'right';
      case 'right':
        return 'left';
      default:
        return '';
    }
  }

  List<int> _getNextPosition(String dir) {
    List<int> nextPos = List.from(bodySegments.first);
    switch (dir) {
      case 'up':
        nextPos[1] = (nextPos[1] - 1 + gridHeight) % gridHeight;
        break;
      case 'down':
        nextPos[1] = (nextPos[1] + 1) % gridHeight;
        break;
      case 'left':
        nextPos[0] = (nextPos[0] - 1 + gridWidth) % gridWidth;
        break;
      case 'right':
        nextPos[0] = (nextPos[0] + 1) % gridWidth;
        break;
    }
    return nextPos;
  }

  int _getDistance(List<int> pos1, List<int> pos2) {
    return (pos1[0] - pos2[0]).abs() + (pos1[1] - pos2[1]).abs();
  }

  void draw() {
    List<List<String>> grid =
        List.generate(gridHeight, (_) => List.generate(gridWidth, (_) => ' '));

    // Draw cicak body
    for (int i = 1; i < bodySegments.length - 1; i++) {
      grid[bodySegments[i][1]][bodySegments[i][0]] = '*';
    }

    // Draw cicak head
    var head = bodySegments.first;
    grid[head[1]][head[0]] = _getHeadSymbol();

    // Draw cicak limbs
    if (bodySegments.length > 2) {
      var neck = bodySegments[1];
      _drawLimbs(grid, neck);
    }
    // Draw cicak legs
    if (bodySegments.length > 3) {
      var neck = bodySegments[bodySegments.length - 2];
      _drawLimbs(grid, neck);
    }

    // Draw food
    grid[foodY][foodX] = foodSymbol;

    print('\x1B[2J\x1B[0;0H'); // Clear screen
    for (var row in grid) {
      print(row.join());
    }
  }

  String _getHeadSymbol() {
    switch (currentDirection) {
      case 'up':
        return '^';
      case 'down':
        return 'v';
      case 'left':
        return '<';
      case 'right':
        return '>';
      default:
        return 'o';
    }
  }

  void _drawLimbs(List<List<String>> grid, List<int> neckPos) {
    var x = neckPos[0];
    var y = neckPos[1];

    // Draw arms
    if (y > 0) grid[y - 1][x] = '*';
    if (y < gridHeight - 1) grid[y + 1][x] = '*';

    // Draw legs
    if (x > 0) grid[y][x - 1] = '*';
    if (x < gridWidth - 1) grid[y][x + 1] = '*';
  }

  void start() {
    Timer.periodic(Duration(milliseconds: 200), (timer) {
      if (isGameOver) {
        timer.cancel();
        print('Game Over!');
        return;
      }

      chooseDirection();
      move();
      draw();
    });
  }
}

void main() {
  CicakGame game = CicakGame('X');
  game.start();
}
