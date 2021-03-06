using Toybox.System as Sys;
using Toybox.ActivityMonitor as ActMon;
using Toybox.Activity as Act;
using Toybox.UserProfile as UP;
using Toybox.Graphics as Gfx;
using Toybox.Time as Time;
using Toybox.Application as App;

class TidyData {
  var hr = [null, null, null];
  var clockTime, zones, loc, date;
  var persistedLocation = [null, null];

  var _floorsClimbed = null;
  var _floorsClimbedGoal = null;


  var notificationCount;
  var alarmOn;
  var dndOn;
  var phoneConnected;
  var _24hr;

  var bat;

  var steps = null;
  var stepGoal = null;
  var zoneCol = [
    Gfx.COLOR_DK_GRAY,
    Gfx.COLOR_LT_GRAY,
    Gfx.COLOR_BLUE,
    Gfx.COLOR_GREEN,
    Gfx.COLOR_ORANGE,
    Gfx.COLOR_RED
  ];

  var sunData = new SunData();

  function initialize() {}

  function updateSettings() {
    persistedLocation = App.getApp().getProperty("location");

    if (persistedLocation == null) {
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

  function hrDuration() {
    try {
      return ActMon.getHeartRateHistory(new Time.Duration(4 * 60 * 60), true);
    } catch (e) {
      return null;
    }
  }

  function hrCount() {
    try {
      return ActMon.getHeartRateHistory(180, true); // 81 seconds between updates ... maybe?
    } catch (e) {
      return null;
    }
  }

  function refresh(heavyLift) {
    var settings = Sys.getDeviceSettings();
    var stats = Sys.getSystemStats();
    var info = ActMon.getInfo();
    var ai = Act.getActivityInfo();
    var ittr = null;
    var first;

    notificationCount = settings.notificationCount;

    _floorsClimbed = (info has :floorsClimbed) ? info.floorsClimbed : 1;
    _floorsClimbedGoal = (info has :floorsClimbedGoal) ? info.floorsClimbedGoal : 1;

    steps = info.steps;
    stepGoal = info.stepGoal;

    notificationCount = settings.notificationCount;
    alarmOn = settings.alarmCount != null && settings.alarmCount > 0;
    dndOn = (settings has :doNotDisturb) ? settings.doNotDisturb : false;
    phoneConnected = settings.phoneConnected;
    _24hr = settings.is24Hour;

    bat = stats.battery;
    loc = ai ? ai.currentLocation : null;

    if (loc != null &&
      loc.toRadians()[0] != null &&
      (loc.toRadians()[0] != persistedLocation[0] || loc.toRadians()[1] != persistedLocation[1])) {
      persistedLocation = loc.toRadians();
      App.getApp().setProperty("location", persistedLocation);
    }

    clockTime = Sys.getClockTime();
    zones = UP.getHeartRateZones(UP.HR_ZONE_SPORT_GENERIC);
    date = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT).day;

    // get out if we don't have time to do big stuff
    if (!heavyLift) { return; }

    sunData.calculate(persistedLocation, App.getApp().getProperty("sunupTime"), App.getApp().getProperty("sundownTime"));

    if (ActMon has :getHeartRateHistory) {
      ittr = hrDuration();
      if (ittr == null) {
        ittr = hrCount();
      }
      if (ittr == null) { return; } // bums

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

  function zoneColor(nr) {
    if (nr == null) { return zoneCol[0]; }
    if (nr <= zones[0]) { return zoneCol[0]; }
    if (nr <= zones[1]) { return zoneCol[1]; }
    if (nr <= zones[2]) { return zoneCol[2]; }
    if (nr <= zones[3]) { return zoneCol[3]; }
    if (nr <= zones[4]) { return zoneCol[4]; }
    return zoneCol[5];
  }

  function floorsClimbed() { return _floorsClimbed; }

  function floorsClimbedGoal() { return _floorsClimbedGoal; }

  /* Mock values * /
    function messages() { return 3; }
    function phone() { return true; }
    function alarm() { return settings.alarmCount != null && settings.alarmCount > 0; }
    function dnd() { return (settings has :doNotDisturb); }
    function battery() { return 47.0; }
    function gps() { return loc; }

    function mday() { return 30; }

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
    function hour() { return hourFmt(21); }

  /*/
  function messages() { return notificationCount; }

  function phone() { return phoneConnected; }

  function alarm() { return alarmOn; }

  function dnd() { return dndOn; }

  function battery() { return bat; }

  function gps() { return loc != null; }

  function mday() { return date; }

  function riseHour() { return hourFmt(sunData.sunRiseTime[0]); }

  function riseMin() { return sunData.sunRiseTime[1]; }

  function riseTomorrow() { return sunData.sunRiseTime[2] > date; }

  function setHour() { return hourFmt(sunData.sunSetTime[0]); }

  function setMin() { return sunData.sunSetTime[1]; }

  function setTomorrow() { return sunData.sunSetTime[2] > date; }

  function currentSteps() { return stepGoal == null ? null : steps; }

  function targetSteps() { return stepGoal; }

  function hrMin() { return hr[0]; }

  function hrMax() { return hr[1]; }

  function hrActual() { return hr[2]; }

  function minute() { return clockTime.min; }

  function second() { return clockTime.sec; }

  function hour() { return hourFmt(clockTime.hour); }
  /**/

  function is24Hour() { return _24hr; }

  function is12Hour() { return !_24hr; }

  function hourFmt(h) {
    if (h == null) { return null; }
    if (!_24hr) {
      if (h > 12) { h -= 12; }
      if (h == 0) { h = 12; }
    }
    return h;
  }
}