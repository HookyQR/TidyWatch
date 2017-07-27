using Toybox.Graphics as Gfx;
using Toybox.Lang as Lang;

class Battery extends Box {
  function initialize(dc, options) {
    Box.initialize(dc, options);
  }

  function drawFinal(dc) {
    if( dc has :setClip) { dc.setClip(x, y+1, width(), height()); }
    dc.setColor(fg, fg);
    dc.fillRectangle(x, y+1, width(), height());
    if ( value() > 5.0) { dc.setColor(Gfx.COLOR_DK_GREEN, Gfx.COLOR_TRANSPARENT); }
    else                { dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT); }

    var fillTotal = 1 + value() / 6;
    dc.fillRectangle(x+5, y+height()/3, fillTotal, height()/3+1);
    if ( value() > 5.0){
      if ( bg instanceof Lang.Method) { dc.setColor(bg.invoke(nr), Gfx.COLOR_TRANSPARENT); }
      else { dc.setColor(bg, Gfx.COLOR_TRANSPARENT); }
    }
    dc.drawText(x, y, font, op, Gfx.TEXT_JUSTIFY_LEFT);
  }
}