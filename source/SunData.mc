using Toybox.Time;
using Toybox.Math;
using Toybox.System as Sys;
using Toybox.Lang;

class SunData {
  var sinAlt = [-0.01453808, // sun
    -0.10452846, // civil
    -0.20791169, // nautical
    -0.30901699  // atstro
  ];
  var JUnix = 2440587.5;
  var J2k =   2451545.5;

  var altUp;
  var altDn;
  var pos = [0,100];
  var ref = [0,0];
  var twentyFour;

  var sunRise = 0;
  var sunSet = 0;
  var sunRiseTime = [null, null];
  var sunSetTime = [null, null];

  function initialize() {
  }

  function calculate(position, refUp, refDn) {
    Sys.println("Calc");
    if ( position == null || position[0] == null ) {
      sunRiseTime = [null, null];
      sunSetTime = [null, null];
      return;
    }

    var timeInfo;
    var dateString;
    var jDate;
    var now = Time.now().value();
    var day = Time.Gregorian.info(new Time.Moment(now), Time.FORMAT_SHORT).day;
    if ( pos[0] != position[0] ||
      pos[1] != position[1] ||
      refUp != ref[0] ||
      refDn != ref[1] ||
      sunRise <= now ||
      sunSet <= now ) {
      pos = position;
      ref[0] = refUp;
      ref[1] = refDn;
      altUp = sinAlt[refUp];
      altDn = sinAlt[refDn];
      jDate = (now / Time.Gregorian.SECONDS_PER_DAY + JUnix - J2k - 0.0008 + pos[0]/2/Math.PI + 0.5).toLong();
      sunRise = nextRise(now, jDate);
      sunSet = nextSet(now, jDate);
    }
    timeInfo = Time.Gregorian.info(new Time.Moment(sunRise), Time.FORMAT_SHORT);
    sunRiseTime = [timeInfo.hour, timeInfo.min];
    timeInfo = Time.Gregorian.info(new Time.Moment(sunSet), Time.FORMAT_SHORT);
    sunSetTime = [timeInfo.hour, timeInfo.min];
  }

  function ha(alt, dec) {
    return Math.acos((alt - Math.sin(pos[0]) * Math.sin(dec)) / Math.cos(pos[0]) / Math.cos(dec));
  }

  function nextRise(now, jDate) {
    var decAndMidday = decAndMid(jDate);
    var mom = getMoment(
      decAndMidday[1], - ha(altUp, decAndMidday[0]));

    if (mom <= now) {
      decAndMidday = decAndMid(jDate + 1);
      mom = getMoment(decAndMidday[1],  - ha(altUp, decAndMidday[0]));
    }
    return mom;
  }

  function nextSet(now, jDate) {
    var decAndMidday = decAndMid(jDate);
    var mom = getMoment(decAndMidday[1], ha(altDn, decAndMidday[0]));

    if (mom < now) {
      decAndMidday = decAndMid(jDate + 1);

      mom = getMoment(decAndMidday[1], ha(altDn, decAndMidday[0]));
    }
    return mom;
  }

  function getMoment(midday, offset) {
    return fromJ(midday + offset / 2 / Math.PI);
  }

  function fromJ(j) {
    return (j + J2k - JUnix) * Time.Gregorian.SECONDS_PER_DAY;
  }

  function decAndMid(day) {
    var j = day + 0.5 - pos[1] / 2 / Math.PI;
    var M = 6.24005997 + 0.01720197 * j;
    var C = (
      1.9148 * Math.sin(M) +
      0.0200 * Math.sin(2 * M) +
      0.0003 * Math.sin(3 * M)) * Math.PI / 180;
    var l = M + C + Math.PI + 1.79659306;

    var dec = Math.asin(Math.sin(l) * 0.39778851);
    var J = j + 0.0053 * Math.sin(M) - 0.0069 * Math.sin(2 * l) + 0.0001;
    return [dec, J];
  }
}