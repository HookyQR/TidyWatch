using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.Activity as Act;
using Toybox.ActivityMonitor as ActMon;
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
        :font => fontMed, :length => 2, :zero => false
      })
    ]);

    rise = new Row( dc, [
      new DisplayNumber(dc, {
        :callback => tidyData.method(:riseHour),
        :font => fontMed, :length => 2, :zero => tidyData.settings.is24Hour
      }),
      new DisplayNumber(dc, {
        :callback => tidyData.method(:riseMin),
        :font => fontMed, :length => 2, :zero => true
      }),
      new Box(dc, {
        :char => "!u", :callback => tidyData.method(:riseHour),
        :color => App.getApp().getProperty("sunupColour"), :font => fontMed
      })
    ]);

    set = new Row( dc, [
      new DisplayNumber(dc, {
        :callback => tidyData.method(:setHour),
        :font => fontMed, :length => 2, :zero => tidyData.settings.is24Hour
      }),
      new DisplayNumber(dc, {
        :callback => tidyData.method(:setMin),
        :font => fontMed, :length => 2, :zero => true
      }),
      new Box(dc, {
        :char => "!d", :callback => tidyData.method(:setHour),
        :color => App.getApp().getProperty("sundownColour"), :font => fontMed
      })
    ]);
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

    var h = dc.getHeight();
    var w = dc.getWidth();

    sec = new FloorNumber(dc, {
      :font => fontLg,
      :height => minute.height(),
      :value => tidyData.method(:floorsClimbed),
      :max => tidyData.method(:floorsClimbedGoal),
      :length => 2,
      :zero => true,
      :callback => tidyData.method(:second)
    });

    var top = (h - hour.height()) / 2;

    mainRow = new Row(dc, [hour, minute, sec]);
    var pad = h < 200 ? 7 : 14;

    row.center(w);
    mainRow.center(w);
    rise.center(w);
    set.center(w);

    mainRow.setTop(top + 14 - pad);
    row.above(mainRow, pad);
    rise.above(row, pad);
    set.setTop(hour.top() + hour.fullHeight() + pad*2);
  }

  function onUpdate(dc) {
    tidyData.refresh(true);
    if (rebuildRequired) { build(dc); }

    dc.setColor(App.getApp().getProperty("bgColour"), App.getApp().getProperty("bgColour"));
    if ( dc has :setClip) { dc.setClip(0, 0, dc.getWidth() + 1, dc.getHeight() + 1); }
    dc.clear();

    mainRow.draw(dc);

    row.draw(dc);
    if ( showRise ) {
      rise.draw(dc);
      set.draw(dc);
    }
  }

  function onPartialUpdate(dc) {
    tidyData.refresh(false);

    var offset = tidyData.clockTime.sec % 4;

    sec.partial(dc);

    switch(offset){
      case 0: { row.partial(dc); break; }
      case 2: { break; }
      default: { minute.partial(dc); break; }
    }
  }
}

class TWDelegate extends Ui.WatchFaceDelegate {
  function initialize() { Ui.WatchFaceDelegate.initialize(); }

  function onPowerBudgetExceeded(powerInfo) {
    Sys.println("TW Avg  time: " + powerInfo.executionTimeAverage);
    Sys.println("Allowed time: " + powerInfo.executionTimeLimit);
  }
}