using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Application as App;
using Toybox.Time as Time;
using Toybox.UserProfile as UP;

class TidyWatchView extends Ui.WatchFace {

  var fontXSm, fontSm, fontMed, fontLg, fontXLg;

  var hour, minute, sec, row, rise, set, mainRow;
  var tidyData;
  var showRise = true;
  var rebuildRequired = true;
  function clear()       { rebuildRequired = true; }
  function initialize()  { WatchFace.initialize(); }
  function setData(data) { tidyData = data; }

  function onLayout(dc) {
    tidyData.refresh(true);
    build(dc);
    rebuildRequired = false;
  }

  function build(dc){
    showRise = App.getApp().getProperty("showRise");
    tidyData.updateSettings();

    fontXSm = Ui.loadResource(Rez.Fonts.xsmall);
    fontSm = Ui.loadResource(Rez.Fonts.small);
    fontMed = Ui.loadResource(Rez.Fonts.medium);
    fontLg = Ui.loadResource(Rez.Fonts.large);
    fontXLg = Ui.loadResource(Rez.Fonts.xlarge);

    row = new Row( dc, [
      new Battery(dc, {
        :char => "p", :callback => tidyData.method(:battery),
        :color => App.getApp().getProperty("batteryColour"), :font => fontMed
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
      new Box(dc, {
        :char => "g", :callback => tidyData.method(:gps),
        :color => App.getApp().getProperty("gpsColour"), :font => fontMed
      }),
      new Box(dc, {
        :char => "!", :callback => tidyData.method(:always),
        :color => Gfx.COLOR_TRANSPARENT, :font => fontMed
      }),
      new DisplayNumber(dc, {
        :callback => tidyData.method(:mday),
        :font => fontSm, :length => 2, :zero => false
      })
    ]);

    if(App.getApp().getProperty("sideBySide")){
      rise = new Row( dc, [
        new Box(dc, {
          :char => "u!", :callback => tidyData.method(:riseHour),
          :color => App.getApp().getProperty("sunupColour"), :font => fontSm
        }),
        new DisplayNumber(dc, {
          :callback => tidyData.method(:riseHour),
          :font => fontSm, :length => 2, :zero => tidyData.settings.is24Hour
        }),
        new DisplayNumber(dc, {
          :callback => tidyData.method(:riseMin),
          :font => fontSm, :length => 2, :zero => true
        }),
        new Box(dc, {
          :char => "  ", :callback => tidyData.method(:always),
          :color => App.getApp().getProperty("sunupColour"), :font => fontSm
        }),
        new DisplayNumber(dc, {
          :callback => tidyData.method(:setHour),
          :font => fontSm, :length => 2, :zero => tidyData.settings.is24Hour
        }),
        new DisplayNumber(dc, {
          :callback => tidyData.method(:setMin),
          :font => fontSm, :length => 2, :zero => true
        }),
        new Box(dc, {
          :char => "!d", :callback => tidyData.method(:setHour),
          :color => App.getApp().getProperty("sundownColour"), :font => fontSm
        })
      ]);
      set = null;
    } else {
      rise = new Row( dc, [
        new DisplayNumber(dc, {
          :callback => tidyData.method(:riseHour),
          :font => fontSm, :length => 2, :zero => tidyData.settings.is24Hour
        }),
        new DisplayNumber(dc, {
          :callback => tidyData.method(:riseMin),
          :font => fontSm, :length => 2, :zero => true
        }),
        new Box(dc, {
          :char => "!u", :callback => tidyData.method(:riseHour),
          :color => App.getApp().getProperty("sunupColour"), :font => fontSm
        })
      ]);

      set = new Row( dc, [
        new DisplayNumber(dc, {
          :callback => tidyData.method(:setHour),
          :font => fontSm, :length => 2, :zero => tidyData.settings.is24Hour
        }),
        new DisplayNumber(dc, {
          :callback => tidyData.method(:setMin),
          :font => fontSm, :length => 2, :zero => true
        }),
        new Box(dc, {
          :char => "!d", :callback => tidyData.method(:setHour),
          :color => App.getApp().getProperty("sundownColour"), :font => fontSm
        })
      ]);
    }
    hour = new MonitorNumber(dc, {
      :font => fontXLg,
      :length => 2,
      :zero => tidyData.settings.is24Hour,
      :callback => tidyData.method(:hour),
      :topColor => App.getApp().getProperty("nrColour"),
      :bottomColor => tidyData.method(:zoneColor),
      :value => tidyData.method(:hrActual),
      :min => tidyData.method(:hrMin),
      :max => tidyData.method(:hrMax),
      :position => Gfx.TEXT_JUSTIFY_CENTER,
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

    mainRow = new Row(dc, [hour, minute, sec]);

    var h = dc.getHeight();
    var w = dc.getWidth();

    var top = (h - hour.height()) / 2;
    var pad = h < 200 ? 10 : 14;

    row.center(w);
    mainRow.center(w);

    if(App.getApp().getProperty("sideBySide")){
      top -= rise.height();
      mainRow.setTop(top + 14 - pad);
      row.above(mainRow, pad);
      rise.below(mainRow, pad * 2 + rise.height());
      rise.center(w);
    } else {
      mainRow.setTop(top + 14 - pad);
      row.above(mainRow, pad);
      rise.center(w);
      set.center(w);
      rise.above(row, pad);
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

    row.draw(dc);
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
      case 0: { row.partial(dc); break; }
      case 3: { minute.partial(dc); break; }
    }
  }
}
