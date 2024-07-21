abstract class UIComponent {
  float x = 0;
  float y = 0;
  void setChildrenXY(){}
  void drawChildren(){}
  abstract void drawSelf();
  UIComponent setXY(float x, float y) {
    this.x = x;
    this.y = y;
    return this;
  }
  void draw() {
    setChildrenXY();
    drawChildren();
    drawSelf();
  }
  abstract JSONObject toJSON();
  String toString() {
    return this.toJSON().toString();
  }
}
