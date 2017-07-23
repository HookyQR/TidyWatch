using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Graphics as Gfx;

class FixedLengthText {
  protected  var mPrevious;
  protected  var mDim;
  protected  var x, y;
  var font;
  var padding = 0;
  function previous() {
    return mPrevious;
  }

  function initialize(dc, string, aFont, previous, pad) {
    mPrevious = previous;
    font = aFont;
    mDim = dc.getTextDimensions(string, aFont);
    padding = pad;
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
      rX = mPrevious.right() + padding;
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