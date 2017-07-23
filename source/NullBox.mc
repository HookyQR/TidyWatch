class NullBox {
  var x = 0;
  var y = 0;
  var dim = [0,0];

  function initialize() {}

  function setFG(color) { }
  function setBG(color) { }
  function setAlign(a) { }
  function setLeft(l) { x = l; }
  function setTop(t) { y = t; }
  function width() { return dim[0]; }
  function height() { return dim[1]; }
  function bottom() { return y + height(); }
  function right() { return x + width(); }
  function left() { return x; }
  function top() { return y; }

  function baseline(other) {
    y = other.bottom() - height();
    return self;
  }
  function center(other) {
    x = other.x + (other.width() - width())/2;
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
    x = other.x - width() - padding;
    return self;
  }

  function draw(dc) {}
  function partial(dc) {}
}
