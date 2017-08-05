using Toybox.Graphics as Gfx;
using Toybox.Lang as Lang;
using Toybox.Application as App;

class Message extends Box {
  var innerFont;
  var innerColour;
  function initialize(dc, options) {
    Box.initialize(dc, options);
    innerFont = options[:innerFont];
    innerColour = options[:innerColour] != null ? options[:innerColour] : App.getApp().getProperty("nrColour");
  }

  function drawFinal(dc) {
    if( dc has :setClip) { dc.setClip(x, y+1, width(), height()); }
    dc.setColor(fg, bg);
    dc.drawText(x, y, font, op, Gfx.TEXT_JUSTIFY_LEFT);
    if ( innerFont ){
      dc.setColor(innerColour, Gfx.COLOR_TRANSPARENT);
      dc.drawText(x + width()/2, y + (height()+3)*3/14, innerFont, value(), Gfx.TEXT_JUSTIFY_CENTER);
    }
  }
}