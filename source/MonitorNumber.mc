using Toybox.Graphics as Gfx;
using Toybox.Lang as Lang;
using Toybox.Application as App;

class MonitorNumber extends DisplayNumber {
  var info;
  var mainColor;
  var fillColor;
  var topCB = null;
  var bottomCB = null;
  var actualCB = null;
  var prevPos = 0;
  var position;

  function initialize(dc, options) {
    DisplayNumber.initialize(dc, options);
    setBG(Gfx.COLOR_TRANSPARENT);
    mainColor = options[:topColor] ? options[:topColor] : App.getApp().getProperty("nrColour");
    fillColor = options[:bottomColor] ? options[:bottomColor] : App.getApp().getProperty("nrColour");

    position = options[:position] ? options[:position] : Gfx.TEXT_JUSTIFY_CENTER;
    topCB = options[:max];
    bottomCB = options[:min];
    actualCB = options[:value];

    if (options[:info]) {
      options[:info].put(:callback, options[:value]);
      if (options[:info][:max]) {
        options[:info][:max].put(:callback, options[:max]);
      }
      if (options[:info][:min]) {
        options[:info][:min].put(:callback, options[:min]);
      }
      info = new RangedNumber(dc, options[:info]);
    } else {
      info = new NullBox();
    }
  }

  function topV() {
    var v = 0;
    if (topCB != null) { v = topCB.invoke(); }
    return v ? v : 1;
  }

  function bottomV() {
    var v = 0;
    if (bottomCB != null) { v = bottomCB.invoke(); }
    return v ? v : 0;
  }

  function actualV() {
    var v = 0;
    if (actualCB != null) { v = actualCB.invoke(); }
    return v ? v : 0;
  }

  function setLeft(l) {
    DisplayNumber.setLeft(l);
    if ( position == Gfx.TEXT_JUSTIFY_CENTER) {
      info.center(self);
    } else {
      info.setLeft(left());
    }
  }

  function setTop(t) {
    DisplayNumber.setTop(t);
    info.below(self, 4);
  }

  function pos() {
    var a = actualV();
    var t = topV();

    var r = t - bottomV();
    r = r <= 0 ? 1 : r;
    r = height() * (r - a + bottomV()) / r;

    if ( r > height() ) { return height(); }
    if ( r > 0 ) { return r; }
    if ( r < 0 ) { return 0; }
    if ( a >= t ) { return 0; }
    return 1; // don't give up that last little bit
  }
  function fullHeight() {
    return height() + info.height() + 4;
  }
  function draw(dc) {
    info.draw(dc);

    if (dc has :setClip) { dc.setClip(x, y + 1, width(), height()); }
    var p = pos();
    prevPos = p;
    var c = fillColor;
    if (fillColor instanceof Lang.Method) { c = fillColor.invoke(actualV()); }
    dc.setColor(mainColor, mainColor);
    dc.fillRectangle(x, y + 1, width(), p);
    dc.setColor(c, c);
    dc.fillRectangle(x, y + p + 1, width(), height() - p);

    DisplayNumber.draw(dc);
  }

  function partial(dc) {
    info.partial(dc);
    var p = pos();
    if (p == prevPos) { return; }
    if (p < prevPos) {
      dc.setClip(x, y + 1 + p, width(), prevPos - p);
      var c = fillColor;
      if (fillColor instanceof Lang.Method) { c = fillColor.invoke(actualV()); }
      dc.setColor(c, c);
      dc.fillRectangle(x, y + 1 + p, width(), prevPos - p);
    } else {
      dc.setClip(x, y + 1 + prevPos, width(), p - prevPos);
      dc.setColor(mainColor, mainColor);
      dc.fillRectangle(x, y + 1 + prevPos, width(), p - prevPos);
    }
    prevPos = p;
    dc.setColor(fg, bg);
    dc.drawText(x, y, font, format(value()), Gfx.TEXT_JUSTIFY_LEFT);
  }
}