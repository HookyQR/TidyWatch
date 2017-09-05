class NullBox {
  var x = 0;
  var y = 0;
  var h = 0;
  function initialize() {}

  function setFG(color) { }
  function setBG(color) { }
  function setAlign(a) { }
  function setLeft(l) { x = l; }
  function setTop(t) { y = t; }
  function setHeight(newH) { h = newH; }
  function width() { return 0; }
  function height() { return h; }
  function bottom() { return y + h; }
  function right() { return x; }
  function left() { return x; }
  function top() { return y; }

  function baseline(other) {
    y = other.bottom() - height();
    return self;
  }
  function center(other) {
    x = other.x + other.width()/2;
    return self;
  }
  function below(other, padding) {
    y = other.bottom() + padding;
    return self;
  }
  function rightOf(other, padding) {
    x = other.right() + padding;
    return self;
  }
  function leftOf(other, padding) {
    x = other.x - padding;
    return self;
  }

  function draw(dc) {}
  function partial(dc) {}
}
