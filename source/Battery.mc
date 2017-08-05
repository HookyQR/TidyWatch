using Toybox.Graphics as Gfx;
using Toybox.Lang as Lang;
using Toybox.Application as App;

class Battery extends Box {
  var innerFont;
  var innerColour;
  function initialize(dc, options) {
    Box.initialize(dc, options);
    innerFont = options[:innerFont];
    innerColour = options[:innerColour] != null ? options[:innerColour] : App.getApp().getProperty("nrColour");
  }

  function drawFinal(dc) {
    if( dc has :setClip) { dc.setClip(x, y+1, width(), height()); }
    dc.setColor(bg, bg);
    dc.fillRectangle(x, y+1, width(), height());
    if ( value() > 5.0) { dc.setColor(Gfx.COLOR_DK_GREEN, Gfx.COLOR_TRANSPARENT); }
    else                { dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT); }

    var v = value();
    var fillTotal = v * 2 * width() / 3 / 100 ;
    if ( fillTotal < 1) {fillTotal = 1;}
    dc.fillRectangle(x+width()/6, y+height()*3/14, fillTotal, 2 + height()/2);
    if ( v > 5.0){
      if ( fg instanceof Lang.Method) { dc.setColor(fg.invoke(nr), Gfx.COLOR_TRANSPARENT); }
      else { dc.setColor(fg, Gfx.COLOR_TRANSPARENT); }
    }
    dc.drawText(x, y, font, op, Gfx.TEXT_JUSTIFY_LEFT);
    if ( innerFont ){
      dc.setColor(innerColour, Gfx.COLOR_TRANSPARENT);
      dc.drawText(x + width()/2 - 1, y + (height()+3)*3/14, innerFont, v.toLong(), Gfx.TEXT_JUSTIFY_CENTER);
    }
  }
}