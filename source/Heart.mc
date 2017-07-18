using Toybox.Time as Time;

using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.ActivityMonitor as ActMon;

class Heart {
  var prevMax = [];
  var prevMin = [];
  var max, min;
  var lookBack;
  var current = null;
  var lastRx = null;

  function initialize(duration) {
    lookBack = duration;
  }

  function updateFrom(ittr) {
    var then = Time.now();
    var hr;
    var c = current;
    // drop old data.
    while (prevMax.size() && prevMax[0][1].add(lookBack).lessThan(then)) {
      Sys.println(Lang.format("Then and then: $1$ $2$", [then.value(), prevMax[0][1].add(lookBack).value()]));
      prevMax.remove(prevMax[0]);
    }

    while (prevMin.size() && prevMin[0][1].add(lookBack).lessThan(then)) {
      prevMin.remove(prevMin[0]);
    }

    hr = ittr.next();
    if (hr) {
      if (prevMax.size() == 0) {
        prevMax.add([hr.heartRate, hr.when]);
      }
      if (prevMin.size() == 0) {
        prevMin.add([hr.heartRate, hr.when]);
      }
    }
    while (hr) {
      if (hr.heartRate == ActMon.INVALID_HR_SAMPLE) {
        hr = ittr.next();
        continue;
      }
      Sys.println(Lang.format("New HR: $1$ $2$", [hr.heartRate, hr.when.value()]));
      if (lastRx) {
        // ignore data we have seen
        if (hr.when.add(lookBack).lessThan(lastRx)) {
          Sys.println(Lang.format("ignored: $1$ $2$", [hr.when.value(), lastRx.value()]));
          hr = ittr.next();
          continue;
        }
      }
      c = hr.heartRate;
      for (var i = 0; i < prevMax.size(); i++) {
        if (c >= prevMax[i][0]) {
          prevMax = prevMax.slice(0, i);
          prevMax.add([c, hr.when]);
          Sys.println(Lang.format("New max: $1$", [c]));
          break;
        }
      }

      for (var i = 0; i < prevMin.size(); i++) {
        if (c <= prevMin[i][0]) {
          prevMin = prevMin.slice(0, i);
          prevMin.add([c, hr.when]);
          Sys.println(Lang.format("New min: $1$", [c]));
          break;
        }
      }
      lastRx = hr.when;
      hr = ittr.next();
    }
    current = c;
    max = prevMax[0][0];
    min = prevMin[0][0];
  }
}