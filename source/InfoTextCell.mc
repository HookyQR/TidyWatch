using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Graphics as Gfx;

class TextMeasure {
  var dims, fonts, cols;
  var x, y;

  function initialize(dc, main, min, actual, max, mainFont, rangeFont, actualFont, backCol, graphCol, textCol) {
    fonts = [mainFont, rangeFont, actualFont];
    cols = [backCol, graphCol, textCol];

    mDim = dc.getTextDimensions(string, aFont);
  }

  function updateAndDraw(main, min, actual, max, force) {
    
  }
  function centerY(hSpace) {
    y = (hSpace - mDim[1]) / 2;
  }

  function setLeft(val) {
    x = val;
    return self;
  }

  function setTop(val) {
    y = val;
    return self;
  }

  function left() {
    var rX = 0;
    if (x != null) {
      rX = x;
    } else if (mPrevious != null) {
      rX = mPrevious.right();
    }
    return rX;
  }

  function right() {
    return left() + mDim[0];
  }

  function top() {
    var rY = 0;
    if (y != null) {
      rY = y;
    } else if (mPrevious != null) {
      rY = mPrevious.top();
    }
    return rY;
  }

  function bottom() {
    return top() + mDim[1];
  }

  function width() {
    return mDim[0];
  }

  function height() {
    return mDim[1];
  }

  function write(dc, data) {
    dc.drawText(left(), top(), font, data, Gfx.TEXT_JUSTIFY_LEFT);
  }
}