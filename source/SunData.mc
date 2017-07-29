using Toybox.Time;
using Toybox.Math;

class SunData {
  var sinAlt = [-0.01453859, // sun
    -0.10471976, // civil
    -0.20943951, // nautical
    -0.31415927  // atstro
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
    if ( position == null || position[0] == null ) {
      sunRiseTime = [null, null];
      sunSetTime = [null, null];
      return;
    }

    var timeInfo;
    var dateString;
    var jDate;
    var now = Time.now().value();

    if ( pos[0] != position[0] ||
      pos[1] != position[1] ||
      refUp != ref[0] || //these will trigger the first run
      refDn != ref[1] ||
      sunRise <= now ||
      sunSet <= now ) {
      pos = position;
      ref[0] = refUp;
      ref[1] = refDn;
      altUp = sinAlt[refUp];
      altDn = sinAlt[refDn];
      jDate = (now / Time.Gregorian.SECONDS_PER_DAY + JUnix - J2k + pos[1]/2/Math.PI).toLong();
      sunRise = nextRise(now, jDate);
      sunSet = nextSet(now, jDate);

      timeInfo = Time.Gregorian.info(new Time.Moment(sunRise), Time.FORMAT_SHORT);
      sunRiseTime = [timeInfo.hour, timeInfo.min, timeInfo.day];
      timeInfo = Time.Gregorian.info(new Time.Moment(sunSet), Time.FORMAT_SHORT);
      sunSetTime = [timeInfo.hour, timeInfo.min, timeInfo.day];
    }
  }

  function ha(alt, dec) {
    return Math.acos((alt - Math.sin(pos[0]) * Math.sin(dec)) / Math.cos(pos[0]) / Math.cos(dec));
  }

  function nextRise(now, jDate) {
    var decAndMidday = decAndMid(jDate);
    var mom = getMoment(decAndMidday[1], - ha(altUp, decAndMidday[0]));

    if (mom <= now) {
      decAndMidday = decAndMid(jDate + 1);
      mom = getMoment(decAndMidday[1], - ha(altUp, decAndMidday[0]));
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
    var j = day + 0.5 - pos[1] / 2 / Math.PI + 0.0008;
    var M = 6.24005997 + 0.01720197 * j;
    var C = (
      1.9148 * Math.sin(M) +
      0.0200 * Math.sin(2 * M) +
      0.0003 * Math.sin(3 * M)) * Math.PI / 180.0;
    var l = M + C + Math.PI + 1.79659306;

    var dec = Math.asin(Math.sin(l) * 0.39778851);
    var J = j + 0.0053 * Math.sin(M) - 0.0069 * Math.sin(2 * l);
    return [dec, J];
  }
}