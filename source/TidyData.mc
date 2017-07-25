using Toybox.System as Sys;
using Toybox.ActivityMonitor as ActMon;
using Toybox.Activity as Act;
using Toybox.UserProfile as UP;
using Toybox.Graphics as Gfx;
using Toybox.Time;
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
    if ( App.getApp().getProperty("hrZone")) {
      zoneCol = [
        Gfx.COLOR_DK_GRAY,
        Gfx.COLOR_LT_GRAY,
        Gfx.COLOR_BLUE,
        Gfx.COLOR_GREEN,
        Gfx.COLOR_ORANGE,
        Gfx.COLOR_RED
      ];
    } else {
      zoneCol = [
        App.getApp().getProperty("hrColour"),
        App.getApp().getProperty("hrColour"),
        App.getApp().getProperty("hrColour"),
        App.getApp().getProperty("hrColour"),
        App.getApp().getProperty("hrColour"),
        App.getApp().getProperty("hrColour")
      ];
    }
  }
  function refresh(getHr) {
    settings = Sys.getDeviceSettings();
    stats = Sys.getSystemStats();
    info = ActMon.getInfo();
    var ai = Act.getActivityInfo();
    loc = ai ? ai.currentLocation : null;
    if ( loc != null && (loc.toRadians()[0] != persistedLocation[0] || loc.toRadians()[1] != persistedLocation[1])) {
      persistedLocation = loc.toRadians();
      App.getApp().setProperty("location", persistedLocation);
    } 

    clockTime = Sys.getClockTime();
    zones = UP.getHeartRateZones(UP.HR_ZONE_SPORT_GENERIC);
    date = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT).day;

    sunData.calculate(persistedLocation, App.getApp().getProperty("sunupTime"), App.getApp().getProperty("sundownTime"));

    if( getHr && (ActMon has: getHeartRateHistory)) {
      try {
        var ittr = ActMon.getHeartRateHistory(new Time.Duration(4 * 60 * 60), true);
        var first = ittr.next();
        if ((first != null) && (first.heartRate != 255)) {
          hr = [ittr.getMin(), ittr.getMax(), first.heartRate];
        } else {
          hr = [ittr.getMin(), ittr.getMax(), null];
        }
      } catch (e) { } // not worried if it doesn't work
    }
  }

  function phone() { return settings.phoneConnected; }
  function alarm() { return settings.alarmCount != null && settings.alarmCount > 0; }
  function dnd() { return (settings has :doNotDisturb) ? settings.doNotDisturb : false; }
  function battery() { return stats.battery; }
  function gps() { return loc; }

  function mday() { return date; }
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
  function riseHour() { return 3; }
  function riseMin() { return 7; }
  function setHour() { return 16; }
  function setMin() { return 52; }
  function currentSteps() { return info == null ? null : 52543;}
  function targetSteps() { return info == null ? null : 25782;}
  function hrMin() { return hr[0] ? 247 : null; }
  function hrMax() { return hr[1] ? 291 : null; }
  function hrActual() { return hr[2] ? 268 : null; }
  function minute() {return 34;}
  function second() { return 56;}
  function hour() { return 22; }
/*/
  function riseHour() { return hourFmt(sunData.sunRiseTime[0]); }
  function riseMin() { return sunData.sunRiseTime[1]; }
  function setHour() { return hourFmt(sunData.sunSetTime[0]); }
  function setMin() { return sunData.sunSetTime[1]; }

  function currentSteps() { return info == null ? null : info.steps; }
  function targetSteps() { return info == null ? null : info.stepGoal; }
  function hrMin() { return hr[0]; }
  function hrMax() { return hr[1]; }
  function hrActual() { return hr[2]; }
  function minute() {return clockTime.min; }
  function second() { return clockTime.sec; }
  function hour() { return hourFmt(clockTime.hour); }

  function hourFmt( h ) {
    if ( h == null) { return null; }
    if ( !settings.is24Hour) {
      if( h > 12 ){ h -= 12; }
      if ( h == 0){ h = 12; }
    }
    return h;
  }
  /**/
}