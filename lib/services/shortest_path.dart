class Cell {
  final int x;
  final int y;
  final int dist;
  final Cell prev;

  Cell(this.x, this.y, this.dist, this.prev);

  @override
  String toString() {
    return "$x + $y";
  }
}

class ShortestPath {
// https://www.techiedelight.com/find-shortest-path-source-destination-matrix-satisfies-given-constraints/
// https://www.lavivienpost.com/shortest-path-between-cells-in-matrix-code/
}
