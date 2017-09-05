using Toybox.Graphics as Gfx;

class RangedNumber extends DisplayNumber {
  var minBox;
  var maxBox;

  function initialize(dc, options) {
    DisplayNumber.initialize(dc, options);
    setAlign(Gfx.TEXT_JUSTIFY_LEFT);
    if(options[:max] != null)
    {
      join(options[:max], options);
      maxBox = new DisplayNumber(dc, options[:max] );
      maxBox.setAlign(Gfx.TEXT_JUSTIFY_RIGHT);
    }
    else { maxBox = new NullBox(); }
    if(options[:min] != null) {
      join(options[:min], options);
      minBox = new DisplayNumber(dc, options[:min]);
      minBox.setAlign(Gfx.TEXT_JUSTIFY_RIGHT);
    }
    else {
      minBox = new NullBox();
      if(options[:max] != null) { minBox.setHeight(maxBox.height());}
      else { minBox.setHeight(actualBox.height()); }
    }
    if( options[:max] == null && options[:min] != null ) {
      maxBox.setHeight(minBox.height());
    }
  }

  function pad() {
    if ( minBox.width() != 0 ) { return 3; }
    if ( maxBox.width() != 0 ) { return 3; }
    return 0;
  }

  function width() {
    return DisplayNumber.width() + pad() + maxBox.width();
  }

  function setLeft(l) {
    DisplayNumber.setLeft(maxBox.width() + pad() + l);
    maxBox.leftOf(self, pad());
    minBox.leftOf(self, pad());
    return self;
  }

  function setTop(t) {
    maxBox.setTop(t);
    minBox.below(maxBox, 2);
    DisplayNumber.setTop((maxBox.top() + minBox.bottom() - DisplayNumber.height())/2);
    return self;
  }
  function below(other, pad) {
    return setTop(other.bottom() + pad);
  }
  function center(other) {
    return setLeft((other.left() + other.right() - width()) / 2);
  }
  function setRight(p) {
    return setLeft(p - width());
  }

  function setFG(col) {
    DisplayNumber.setFG(col);
    maxBox.setFG(col);
    minBox.setFG(col);
  }

  function setBG(col) {
    DisplayNumber.setBG(col);
    maxBox.setBG(col);
    minBox.setBG(col);
  }

  function draw(dc) {
    DisplayNumber.draw(dc);
    minBox.draw(dc);
    maxBox.draw(dc);
  }

  function partial(dc) {
    DisplayNumber.partial(dc);
    minBox.partial(dc);
    maxBox.partial(dc);
  }
}