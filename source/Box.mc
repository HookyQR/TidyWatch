using Toybox.Graphics as Gfx;
using Toybox.Lang as Lang;
using Toybox.Application as App;

class Box {
  var font;
  var x = 0;
  var y = 0;
  var w_h, fg, bg, cb, op;
  var state = true;

  function initialize(dc, options) {
    bg = App.getApp().getProperty("bgColour");
    font = options[:font];
    op = options[:char] ? options[:char] : "!";
    var dim = dc.getTextDimensions(op, font); // our height is never more than 255
    w_h = (dim[0] << 8) + dim[1];
    cb = options[:callback];
    fg = options[:color] != null ? options[:color] : App.getApp().getProperty("nrColour");
  }
  function width() {
    if ( state == null || state == false) { return 0; }
    return w_h >> 8;
  }
  function changed() {
    var preState = state;
    state = true;
    if ( cb != null) { state = cb.invoke(); }
    return preState == state;
  }

  function value() { return state; }

  function setFG(color) { fg = color; }
  function setBG(color) { bg = color; }
  function setLeft(l) { x = l; }
  function setTop(t) { y = t; }
  function height() { return w_h & 0xff; }
  function bottom() { return y + height(); }
  function right() { return x + width(); }
  function left() { return x; }
  function top() { return y; }

  function rightOf(other, padding) {
    setLeft(other.right() + padding);
    return self;
  }
  function leftOf(other, padding) {
    setLeft(other.x - width() - padding);
    return self;
  }

  function draw(dc) { if ( value()) { drawFinal(dc); } }
  function partial(dc) { draw(dc); }

  function drawFinal(dc) {
    if( dc has :setClip) { dc.setClip(x, y+1, width(), height()); }
    if ( bg instanceof Lang.Method) { dc.setColor(fg, bg.invoke(nr)); }
    else { dc.setColor(fg, bg); }
    dc.drawText(x, y, font, op, Gfx.TEXT_JUSTIFY_LEFT);
  }
}