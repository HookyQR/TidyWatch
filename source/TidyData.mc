using Toybox.System as Sys;
using Toybox.ActivityMonitor as ActMon;
using Toybox.Activity as Act;
using Toybox.UserProfile as UP;
using Toybox.Graphics as Gfx;
using Toybox.Time as Time;
using Toybox.Application as App;

class TidyData {
  var hr = [null, null, null];
  var settings, stats, clockTime, info, zones, loc, date;
  var persistedLocation = [null, null];

  var zoneCol = [
    Gfx.COLOR_DK_GRAY,
    Gfx.COLOR_LT_GRAY,
    Gfx.COLOR_BLUE,
    Gfx.COLOR_GREEN,
    Gfx.COLOR_ORANGE,
    Gfx.COLOR_RED
  ];

  var sunData = new SunData();

  function initialize() {
  }

  function updateSettings() {
    persistedLocation = App.getApp().getProperty("location");

    if ( persistedLocation == null) {
      persistedLocation = [null, null];
    }
    zoneCol = [
      App.getApp().getProperty("hrColour0"),
      App.getApp().getProperty("hrColour1"),
      App.getApp().getProperty("hrColour2"),
      App.getApp().getProperty("hrColour3"),
      App.getApp().getProperty("hrColour4"),
      App.getApp().getProperty("hrColour5")
    ];
  }

  function refresh(heavyLift) {
    settings = Sys.getDeviceSettings();
    stats = Sys.getSystemStats();
    info = ActMon.getInfo();
    var ai = Act.getActivityInfo();
    var ittr = null;
    var first;

    loc = ai ? ai.currentLocation : null;

    if ( loc != null &&
        loc.toRadians()[0] != null &&
      (loc.toRadians()[0] != persistedLocation[0] || loc.toRadians()[1] != persistedLocation[1])) {
      persistedLocation = loc.toRadians();
      App.getApp().setProperty("location", persistedLocation);
    }

    clockTime = Sys.getClockTime();
    zones = UP.getHeartRateZones(UP.HR_ZONE_SPORT_GENERIC);
    date = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT).day;

    // get out if we don't have time to do big stuff
    if(!heavyLift) { return; }

    sunData.calculate(persistedLocation, App.getApp().getProperty("sunupTime"), App.getApp().getProperty("sundownTime"));

    if(ActMon has :getHeartRateHistory) {
      try {
        ittr = ActMon.getHeartRateHistory(new Time.Duration(4 * 60 * 60), true);
      } catch (e) {
        // FR 235 doesn't like ghrHistory with a duration
        try {
          ittr = ActMon.getHeartRateHistory(180, true); // 81 seconds between updates ... maybe?
        } catch (ee) { }
      }
      if ( ittr == null ) { return; } // bums

      first = ittr.next();
      var min = ittr.getMin();
      var max = ittr.getMax();
      var curHr = null;
      if ((first != null) && (first.heartRate != 255)) {
        curHr = first.heartRate;
      }
      hr = [
        min != 255 ? min : null,
        max != 255 ? max : null,
        curHr
      ];
    }
  }

  function always() { return true; }
  function zoneColor(nr) {
    if ( nr == null)    { return zoneCol[0]; }
    if( nr <= zones[0]) { return zoneCol[0]; }
    if( nr <= zones[1]) { return zoneCol[1]; }
    if( nr <= zones[2]) { return zoneCol[2]; }
    if( nr <= zones[3]) { return zoneCol[3]; }
    if( nr <= zones[4]) { return zoneCol[4]; }
    return zoneCol[5];
  }
  function floorsClimbed() { return info == null ? null :((info has :floorsClimbed) ? info.floorsClimbed : 1); }
  function floorsClimbedGoal() { return info == null ? null : ((info has :floorsClimbedGoal) ? info.floorsClimbedGoal : 1); }

/* Mock values * /
  function phone() { return true; }
  function alarm() { return settings.alarmCount != null && settings.alarmCount > 0; }
  function dnd() { return (settings has :doNotDisturb); }
  function battery() { return 80.0; }
  function gps() { return loc; }

  function mday() { return date; }

  function riseHour() { return 6; }
  function riseMin() { return 7; }
  function setHour() { return hourFmt(16); }
  function setMin() { return 52; }
  function currentSteps() { return info == null ? null : 2543;}
  function targetSteps() { return info == null ? null : 5782;}
  function hrMin() { return hr[0] ? 57 : null; }
  function hrMax() { return hr[1] ? 171 : null; }
  function hrActual() { return hr[2] ? 136 : null; }
  function minute() {return 34;}
  function second() { return 56;}
  function hour() { return 12; }
/*/

  function phone() { return settings.phoneConnected; }
  function alarm() { return settings.alarmCount != null && settings.alarmCount > 0; }
  function dnd() { return (settings has :doNotDisturb) ? settings.doNotDisturb : false; }
  function battery() { return stats.battery; }
  function gps() { return loc; }

  function mday() { return date; }

  function riseHour() { return hourFmt(sunData.sunRiseTime[0]); }
  function riseMin() { return sunData.sunRiseTime[1]; }
  function riseTomorrow() { return sunData.sunRiseTime[2] > date; }
  function setHour() { return hourFmt(sunData.sunSetTime[0]); }
  function setMin() { return sunData.sunSetTime[1]; }
  function setTomorrow() { return sunData.sunSetTime[2] > date; }

  function currentSteps() { return info == null ? null : info.stepGoal == 0 ? null : info.steps; }
  function targetSteps() { return info == null ? null : info.stepGoal == 0 ? null : info.stepGoal; }

  function hrMin() { return hr[0]; }
  function hrMax() { return hr[1]; }
  function hrActual() { return hr[2]; }

  function minute() {return clockTime.min; }
  function second() { return clockTime.sec; }
  function hour() { return hourFmt(clockTime.hour); }
  /**/

  function hourFmt( h ) {
    if ( h == null) { return null; }
    if ( !settings.is24Hour) {
      if( h > 12 ){ h -= 12; }
      if ( h == 0){ h = 12; }
    }
    return h;
  }
}