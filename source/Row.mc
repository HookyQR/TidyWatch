using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;

class Row {
  var elem;
  var state = [];
  var fg = App.getApp().getProperty("bgColour");
  var dim = [0,0];
  var x, y;
  function initialize(dc, elements) {
    elem = elements;
    var w = 0;
    var h = 0;
    for(var i=0; i< elem.size(); i++) {
      w += elem[i].width();
      h = elem[i].height() > h ? elem[i].height() : h;
      elem[i].fixValue();
      state.add(null);
    }
    dim = [w, h];
  }

  function setFG(color) { fg = color; }
  function setBG(color) { bg = color; }
  function setLeft(l) { x = l; }
  function setTop(t) {
    y = t;
    for(var i=0; i< elem.size(); i++) { elem[i].setTop(y + (dim[1] - elem[i].height())/2); }
  }
  function above(other, padding) {
    setTop(other.top() - height() - padding);
    return self;
  }
  function below(other, padding) {
    setTop(other.bottom() + padding);
    return self;
  }
  function center(other) {
    setLeft((other - width())/2);
    return self;
  }
  function height() { return dim[1]; }
  function width() { return dim[0]; }
  function bottom() { return y + height(); }
  function right() { return x + width(); }
  function left() { return x; }
  function top() { return y; }

  function doDraw(dc, partial) {
    var w = 0;
    var good = true;
    var i;
    for(i=0; i < elem.size(); i++) {
      good = good && elem[i].fixValue() == state[i];
      w += elem[i].width();
    }

    if(good && partial) { return; }
    dc.setColor(fg, fg);
    if ( dc has :setClip) { dc.setClip(left(), top(), width(), height()); }
    dc.fillRectangle(left(), top(), width(), height());

    var p = (dim[0] - w)/2;
    for(i=0; i < elem.size(); i++) {
      elem[i].setLeft(x+p);
      elem[i].draw(dc);
      p += elem[i].width();
      state[i] = elem[i].value();
    }
  }

  function draw(dc) { doDraw(dc, false); }
  function partial(dc) { doDraw(dc, true); }
}