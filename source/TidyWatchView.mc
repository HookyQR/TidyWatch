using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Application as App;
using Toybox.Time as Time;
using Toybox.UserProfile as UP;

class TidyWatchView extends Ui.WatchFace {

  var fontXSm, fontSm, fontMed, fontLg, fontXLg, fontInv;

  var hour, minute, sec, indicators, rise, set, mainRow;
  var tidyData;
  var showRise = true;
  var rebuildRequired = true;
  function clear() {
    rebuildRequired = true;
    Ui.requestUpdate();
  }
  function initialize()  { Ui.WatchFace.initialize(); }
  function setData(data) { tidyData = data; }

  function onLayout(dc) {
    tidyData.refresh(true);
    build(dc);
    rebuildRequired = false;
  }

  function colourFromIndex(idx) {
    return [
      0x000000,0x000055,0x0000aa,0x0000ff,0x005500,0x005555,0x0055aa,0x0055ff,
      0x550000,0x550055,0x5500aa,0x5500ff,0x555500,0x555555,0x5555aa,0x5555ff,
      0xaa0000,0xaa0055,0xaa00aa,0xaa00ff,0xaa5500,0xaa5555,0xaa55aa,0xaa55ff,
      0xff0000,0xff0055,0xff00aa,0xff00ff,0xff5500,0xff5555,0xff55aa,0xff55ff,
      0x00aa00,0x00aa55,0x00aaaa,0x00aaff,0x00ff00,0x00ff55,0x00ffaa,0x00ffff,
      0x55aa00,0x55aa55,0x55aaaa,0x55aaff,0x55ff00,0x55ff55,0x55ffaa,0x55ffff,
      0xaaaa00,0xaaaa55,0xaaaaaa,0xaaaaff,0xaaff00,0xaaff55,0xaaffaa,0xaaffff,
      0xffaa00,0xffaa55,0xffaaaa,0xffaaff,0xffff00,0xffff55,0xffffaa,0xffffff
    ][idx];
  }

  function setPropertiesFromString(str) {
    var b32 = "0123456789ABCDEFGHJKMNPQRSTVWXYZ";
    var bits = str.toCharArray();
    var props = [
    "bgColour","nrColour",
    "hrColour0","hrColour1",
    "hrColour2","hrColour3",
    "hrColour4","hrColour5",
    "stepColour","batteryColour",
    "alarmColour","phoneColour",
    "dndColour","messageColour",
    "gpsColour","sunupColour",
    "sundownColour"
    ];
    var i = 0;
    var j = 0;
    for(i=0;i<props.size() && j < bits.size();i++, j++){
      var os = 0;
      if ( bits[j] == 'a') {
        j++;
        os = 32;
      }
      App.getApp().setProperty(props[i], colourFromIndex(os + b32.find(bits[j].toString())));
    }
  }
  function build(dc){
    if( App.getApp().getProperty("colourString").length() > 0){
      setPropertiesFromString(App.getApp().getProperty("colourString"));
    }

    showRise = App.getApp().getProperty("showRise");
    tidyData.updateSettings();

    fontInv = Ui.loadResource(Rez.Fonts.xsmalli);
    fontXSm = Ui.loadResource(Rez.Fonts.xsmall);
    fontSm = Ui.loadResource(Rez.Fonts.small);
    fontMed = Ui.loadResource(Rez.Fonts.medium);
    fontLg = Ui.loadResource(Rez.Fonts.large);
    fontXLg = Ui.loadResource(Rez.Fonts.xlarge);


    var h = dc.getHeight();
    var w = dc.getWidth();
    var month = new DisplayNumber(dc, {
        :callback => tidyData.method(:mday),
        :font => fontMed, :length => 2, :zero => false
      });
    month.setAlign(Gfx.TEXT_JUSTIFY_LEFT);
    indicators = new Row( dc, [
      new Battery(dc, {
        :char => "p", :callback => tidyData.method(:battery),
        :color => App.getApp().getProperty("batteryColour"), :font => fontMed,
        :innerFont => App.getApp().getProperty("batteryNumber") ? fontInv : null,
        :innerColour => App.getApp().getProperty("batteryColour")
      }),
      new Box(dc, {
        :char => "s", :callback => tidyData.method(:dnd),
        :color => App.getApp().getProperty("dndColour"), :font => fontMed
      }),
      new Box(dc, {
        :char => "b", :callback => tidyData.method(:phone),
        :color => App.getApp().getProperty("phoneColour"), :font => fontMed
      }),
      new Box(dc, {
        :char => "a", :callback => tidyData.method(:alarm),
        :color => App.getApp().getProperty("alarmColour"), :font => fontMed
      }),
      new Message(dc, {
        :char => "m", :callback => tidyData.method(:messages),
        :color => App.getApp().getProperty("messageColour"), :font => fontMed,
        :innerFont => fontInv,
        :innerColour => App.getApp().getProperty("messageColour")
      }),
      new Box(dc, {
        :char => "g", :callback => tidyData.method(:gps),
        :color => App.getApp().getProperty("gpsColour"), :font => fontMed
      }),
      new Box(dc, {
        :char => "!",
        :color => Gfx.COLOR_TRANSPARENT, :font => fontMed
      }),
      month
    ], {});

    if(App.getApp().getProperty("sideBySide")){
      rise = new Row( dc, [
        new Box(dc, {
          :char => "u!", :color => App.getApp().getProperty("sunupColour"), :font => fontSm
        }),
        new DisplayNumber(dc, {
          :callback => tidyData.method(:riseHour),
          :font => fontSm, :length => 2, :zero => tidyData.is24Hour()
        }),
        new Box(dc, {
          :char => ":", :callback => tidyData.method(:is12Hour),
          :font => fontSm
        }),
        new DisplayNumber(dc, {
          :callback => tidyData.method(:riseMin),
          :font => fontSm, :length => 2, :zero => true
        }),
        new Box(dc, {
          :char => "!!!!!!!!!!", :font => fontSm
        }),
        new DisplayNumber(dc, {
          :callback => tidyData.method(:setHour),
          :font => fontSm, :length => 2, :zero => tidyData.is24Hour()
        }),
        new Box(dc, {
          :char => ":", :callback => tidyData.method(:is12Hour),
          :font => fontSm
        }),
        new DisplayNumber(dc, {
          :callback => tidyData.method(:setMin),
          :font => fontSm, :length => 2, :zero => true
        }),
        new Box(dc, {
          :char => "!d", :callback => tidyData.method(:setHour),
          :color => App.getApp().getProperty("sundownColour"), :font => fontSm
        })
      ], { :callback => tidyData.method(:setHour) });
      set = null;
    } else {
      rise = new Row( dc, [
        new DisplayNumber(dc, {
          :callback => tidyData.method(:riseHour),
          :font => fontSm, :length => 2, :zero => tidyData.is24Hour()
        }),
        new Box(dc, {
          :char => ":", :callback => tidyData.method(:is12Hour),
          :font => fontSm
        }),
        new DisplayNumber(dc, {
          :callback => tidyData.method(:riseMin),
          :font => fontSm, :length => 2, :zero => true
        }),
        new Box(dc, {
          :char => "!u", :callback => tidyData.method(:riseHour),
          :color => App.getApp().getProperty("sunupColour"), :font => fontSm
        })
      ], { :callback => tidyData.method(:riseHour) });

      set = new Row( dc, [
        new DisplayNumber(dc, {
          :callback => tidyData.method(:setHour),
          :font => fontSm, :length => 2, :zero => tidyData.is24Hour()
        }),
        new Box(dc, {
          :char => ":", :callback => tidyData.method(:is12Hour),
          :font => fontSm
        }),
        new DisplayNumber(dc, {
          :callback => tidyData.method(:setMin),
          :font => fontSm, :length => 2, :zero => true
        }),
        new Box(dc, {
          :char => "!d", :callback => tidyData.method(:setHour),
          :color => App.getApp().getProperty("sundownColour"), :font => fontSm
        })
      ], { :callback => tidyData.method(:setHour) });
    }
    var p = (tidyData.is12Hour()) ? Gfx.TEXT_JUSTIFY_RIGHT : Gfx.TEXT_JUSTIFY_CENTER;

    hour = new MonitorNumber(dc, {
      :font => fontXLg,
      :length => 2,
      :zero => tidyData.is24Hour(),
      :callback => tidyData.method(:hour),
      :topColor => App.getApp().getProperty("nrColour"),
      :bottomColor => tidyData.method(:zoneColor),
      :value => tidyData.method(:hrActual),
      :min => tidyData.method(:hrMin),
      :max => tidyData.method(:hrMax),
      :position => p,
      :info => {
        :font => fontSm,
        :length => 3,
        :color => tidyData.method(:zoneColor),
        :min => { :font => fontXSm },
        :max => { :font => fontXSm }
      }
    });

    minute = new MonitorNumber(dc, {
      :font => fontXLg,
      :length => 2,
      :zero => true,
      :callback => tidyData.method(:minute),
      :topColor => App.getApp().getProperty("nrColour"),
      :bottomColor => App.getApp().getProperty("stepColour"),
      :value => tidyData.method(:currentSteps),
      :max => tidyData.method(:targetSteps),
      :position => Gfx.TEXT_JUSTIFY_LEFT,
      :info => {
        :font => fontSm,
        :color => App.getApp().getProperty("stepColour"),
        :length => 5,
        :max => {:font => fontXSm }
      }});

    if ( App.getApp().getProperty("showSeconds") ){
      sec = new FloorNumber(dc, {
        :font => fontLg,
        :height => minute.height(),
        :value => tidyData.method(:floorsClimbed),
        :max => tidyData.method(:floorsClimbedGoal),
        :length => 2,
        :zero => true,
        :callback => tidyData.method(:second)
      });
    } else {
      sec = new Box(dc, {:font => fontLg,:char => ""});
    }
    var colon = new Box(dc, {
          :char => ":", :callback => tidyData.method(:is12Hour), :font => fontXLg
        });
    mainRow = new Row(dc, [hour,
    colon,
    minute,
    sec], {});
    var top = (h - hour.height()) / 2;
    var pad = h < 200 ? 10 : 14;

    indicators.center(w);
    mainRow.center(w);

    if ( tidyData.is12Hour() ){
      mainRow.setLeft(mainRow.left() - colon.width() + 2);
    }
    if(App.getApp().getProperty("sideBySide")){
      top -= rise.height();
      mainRow.setTop(top + 14 - pad);
      indicators.above(mainRow, pad);
      rise.below(mainRow, pad * 2 + rise.height());
      rise.center(w);
    } else {
      mainRow.setTop(top + 14 - pad);
      indicators.above(mainRow, pad);
      rise.center(w);
      set.center(w);
      rise.above(indicators, pad);
      set.setTop(hour.top() + hour.fullHeight() + pad*2);
    }
  }

  function onUpdate(dc) {
    tidyData.refresh(true);
    if (rebuildRequired) {
      build(dc);
      rebuildRequired = false;
    }

    dc.setColor(App.getApp().getProperty("bgColour"), App.getApp().getProperty("bgColour"));
    if ( dc has :setClip) { dc.setClip(0, 0, dc.getWidth() + 1, dc.getHeight() + 1); }
    dc.clear();

    mainRow.draw(dc);

    indicators.draw(dc);
    if ( showRise ) {
      rise.draw(dc);
      if(set != null) { set.draw(dc); }
    }
  }

  function onPartialUpdate(dc) {
    if(rebuildRequired) { return; } // we're waiting for onUpdate to trigger the rebuild

    tidyData.refresh(false);

    var offset = tidyData.clockTime.sec % 6;

    sec.partial(dc);

    switch(offset){
      case 0: { indicators.partial(dc); break; }
      case 3: { minute.partial(dc); break; }
    }
  }
}
