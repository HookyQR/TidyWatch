using Toybox.Graphics as Gfx;
using Toybox.Lang as Lang;
using Toybox.Application as App;

class DisplayNumber {
  var font;
  var w_h;
  var x = 0;
  var y = 0;
  var fg, bg;
  var len = 1;
  var fmt = "%i";
  var align = Gfx.TEXT_JUSTIFY_RIGHT;
  var preValue = null;
  var cb = null;
  var storedValue = null;
  function initialize(dc, options) {
    fg = App.getApp().getProperty("bgColour");
    font = options[:font];
    var dim = dc.getTextDimensions("0", font); // our height is never more than 255
    w_h = (dim[0] << 8) + dim[1];
    len = options[:length];
    fmt = Lang.format("%$1$$2$i", [options[:zero] ? "0" : "", len]);
    cb = options[:callback];
    bg = options[:color] ? options[:color] : App.getApp().getProperty("nrColour");
  }
  function changed() {
    var preValue = storedValue;
    return value() == preValue;
  }
  function join(tgt, src) {
    var keys = src.keys();
    for(var i=0; i< keys.size(); i++) {
      if(!tgt.hasKey(keys[i]) && !(src[keys[i]] instanceof Lang.Dictionary) ) {
        tgt.put(keys[i], src[keys[i]]);
      }
    }
  }

  function value() {
    storedValue = null;
    if ( cb != null) { storedValue = cb.invoke(); }
    return storedValue;
  }

  function setFG(color) { fg = color; }
  function setBG(color) { bg = color; }
  function setAlign(a) { align = a; }
  function setLeft(l) { x = l; }
  function setTop(t) { y = t; }
  function width() { return (w_h >> 8) * len; }
  function height() { return w_h & 0xff; }
  function bottom() { return y + height(); }
  function right() { return x + width(); }
  function left() { return x; }
  function top() { return y; }

  function baseline(other) {
    setTop(other.bottom() - height());
    return self;
  }
  function center(other) {
    if (other instanceof DisplayNumber) {
      setLeft(other.x + (other.width() - width())/2);
    } else {
      setLeft((other - width())/2);
    }
    return self;
  }
  function below(other, padding) {
    setTop(other.bottom() + padding);
    return self;
  }
  function above(other, padding) {
    setTop(other.top() - height() - padding);
    return self;
  }
  function rightOf(other, padding) {
    setLeft(other.right() + padding);
    return self;
  }
  function leftOf(other, padding) {
    setLeft(other.x - width() - padding);
    return self;
  }

  function partial(dc) {
    var nr = value();
    if ( preValue == nr) { return; }
    preValue = nr;
    drawFinal(dc, nr);
  }

  function format(nr) {
    var txt ="";
    if(nr == null) {
      while (txt.length() < len) { txt += " "; }
    } else if (align == Gfx.TEXT_JUSTIFY_RIGHT) {
      txt = nr.format(fmt);
    } else {
      txt = nr.format("%i");
      while (txt.length() < len) { txt += " "; }
    }
    return txt;
  }
  function draw(dc) {
    drawFinal(dc, value());
  }
  function drawFinal(dc, nr) {
    if(dc has :setClip) { dc.setClip(x, y+1, width(), height()); }
    if ( bg instanceof Lang.Method) { dc.setColor(fg, bg.invoke(nr)); }
    else { dc.setColor(fg, bg); }
    dc.drawText(x, y, font, format(nr), Gfx.TEXT_JUSTIFY_LEFT);
  }
}