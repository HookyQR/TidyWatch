using Toybox.Graphics as Gfx;

class FloorNumber extends DisplayNumber {
  var info;
  var topCB = null;
  var bottomCB = null;
  var actualCB = null;
  var prevPos = 0;

  var availHeight;

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

  function initialize(dc, options) {
    DisplayNumber.initialize(dc, options);

    topCB = options[:max];
    bottomCB = options[:min];
    actualCB = options[:value];

    availHeight = options[:height];
  }

  function height() {
    return availHeight;
  }

  function pos() {
    var a = actualV();
    var t = topV();

    var r = t - bottomV();
    r = r <= 0 ? 1 : r;
    r = (height() - dim[1]) * (r - a + bottomV()) / r;
    if (r <= 0 && a < t){ r = 1; }
    return r < 0 ? 0 : r;
  }

  function draw(dc) {
    var p = pos();
    prevPos = p;
    if (dc has :setClip) { dc.setClip(x,  y + 1, width(), height()); }
    dc.setColor(fg, bg);
    dc.fillRectangle(x,  y + 1, width(), height());
    dc.drawText(x, y + p, font, format(value()), Gfx.TEXT_JUSTIFY_LEFT);
  }

  function partial(dc) {
    var p = pos();
    dc.setColor(fg, bg);
    if (p < prevPos) {
      dc.setClip(x,  y + 1 + p + dim[1], width(), prevPos - p);
      dc.fillRectangle(x, y + 1 + p + dim[1], width(), prevPos - p);
    } else if ( prevPos < p ) {
      dc.setClip(x,  y + 1 + prevPos, width(), prevPos - p);
      dc.fillRectangle(x, y + 1 + prevPos, width(), prevPos - p);
    }
    dc.setClip(x, y + p + 1, width(), dim[1]);
    prevPos = p;
    dc.drawText(x, y + p, font, format(value()), Gfx.TEXT_JUSTIFY_LEFT);
  }
}