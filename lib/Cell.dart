class Cell{
  int node;
  int x;
  int y;
  double lat;
  double lng;
  final Function(double angle) move;
  bool ttsEnabled;

  Cell(this.node, this.x, this.y, this.move, this.lat, this.lng, {this.ttsEnabled = true});
}