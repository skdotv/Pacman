class Cell {
  final int x;
  final int y;
  final Cell? parent;

  Cell(this.x, this.y, this.parent);

  @override
  String toString() {
    return "$x,$y";
  }
}

class ShortestPath {
  final List<int> row = [-1, 0, 0, 1];
  final List<int> col = [0, -1, 1, 0];
// n = matrix length
  bool isValid(int x, int y, int n, List<List<int>> matrix) {
    return (matrix[x][y] != -1);
  }

  // path from source to destination
  void findPath(Cell? cell, List<String> path) {
    if (cell != null) {
      findPath(cell.parent, path);
      path.add(cell.toString());
    }
  }

  findRoute(List<List<int>>? matrix, int x, int y, int xdest, int ydest) {
    List<String> path = [];

    if (matrix == null || matrix.isEmpty) {
      return path;
    }

    List<Cell> queue = [];

    Cell src = Cell(x, y, null);
    queue.add(src);

    //
    Set<String> visited = {};
    String key = "${src.x} , ${src.y}";
    visited.add(key);
    //
    while (queue.isNotEmpty) {
      Cell curr = queue.first;
      queue.remove(queue.first);

      //
      int i = curr.x, j = curr.y;
      if (i == xdest && j == ydest) {
        findPath(curr, path);
        return path;
      }

      int n = matrix[i][j];

      for (int k = 0; k < row.length; k++) {
        x = i + row[k] * n;
        y = j + col[k] * n;

        if (isValid(x, y, 0, matrix)) {
          Cell next = Cell(x, y, curr);
          key = "${next.x} , ${next.y}";
          if (!visited.contains(key)) {
            queue.add(next);
            visited.add(key);
          }
        }
      }
    }
    return path;
  }
}

// https://www.techiedelight.com/find-shortest-path-source-destination-matrix-satisfies-given-constraints/
// https://www.lavivienpost.com/shortest-path-between-cells-in-matrix-code/
