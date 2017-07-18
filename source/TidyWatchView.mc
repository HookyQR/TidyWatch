using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.Activity as Act;
using Toybox.ActivityMonitor as ActMon;
using Toybox.Time as Time;

class TidyWatchView extends Ui.WatchFace {

  var fontTime, fontSec, fontSmall, fontMed;
  var seconds = true;

  var hourBox, minBox, secBox, hrMinBox, hrMaxBox, hrActualBox, stepTotalBox, stepActualBox;

  var lastTimeDisplayed = ["", ""];
  var timeWidth, timeHeight;
  var fromSleep = true;

  var hrTop, hrBottom, hrLast;
  var stepsTop, stepsNow;

  var displayedSteps = 0;

  function initialize() {
    WatchFace.initialize();
  }

  function onLayout(dc) {
    fontTime = Ui.loadResource(Rez.Fonts.time);
    fontSec = Ui.loadResource(Rez.Fonts.sec);
    fontSmall = Ui.loadResource(Rez.Fonts.xsmall);
    fontMed = Ui.loadResource(Rez.Fonts.small);

    hourBox = new FixedLengthText(dc, "00", fontTime, null, 0);
    minBox = new FixedLengthText(dc, "00", fontTime, hourBox, 6);

    if (seconds) {
      secBox = new FixedLengthText(dc, "00", fontSec, minBox, 3);
    }

    var settings = Sys.getDeviceSettings();
    var h = settings.screenHeight;
    var w = settings.screenWidth;

    var width = (seconds ? secBox : minBox).right();

    hourBox.setLeft((w - width) / 2);
    hourBox.centerY(h);
    hrMinBox = new FixedLengthText(dc, "000", fontSmall, null, 0);
    hrActualBox = new FixedLengthText(dc, "000", fontMed, hrMinBox, 1);
    hrMaxBox = new FixedLengthText(dc, "000", fontSmall, hrActualBox, 1);
    hrActualBox.setTop(hourBox.bottom() + 3);
    hrMinBox.setTop(hrActualBox.bottom() - hrMaxBox.height() );

    hrMinBox.setLeft(hourBox.left() + (hourBox.width() - hrMaxBox.right())/2);

    stepActualBox = new FixedLengthText(dc, "00000", fontMed, null, 0);
    stepTotalBox = new FixedLengthText(dc, "00000", fontSmall, stepActualBox, 1);
    stepActualBox.setTop(hourBox.bottom()+3);
    stepActualBox.setLeft(minBox.left() + (minBox.width() - hrMaxBox.right())/2);
  }

  function onShow() {}

  function location() {
    var inf = Act.getActivityInfo();
    return inf ? inf.currentLocation : null;
  }

  function clockParts() {
    var settings = Sys.getDeviceSettings();
    var clockTime = Sys.getClockTime();

    var hour = clockTime.hour;
    var min = clockTime.min.format("%02i");
    var sec = clockTime.sec.format("%02i");

    if (!settings.is24Hour) {
      if (hour > 12) {
        hour = hour - 12;
      }
      hour = hour.format("%2i");
    } else {
      hour = hour.format("%02i");
    }
    return [hour, min, sec];
  }
  // Update the view
  function onUpdate(dc) {
    var loc = location();
    dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
    dc.setClip(0,0,dc.getWidth()+1, dc.getHeight()+1);
    dc.clear();
    partialUpdate(dc, false);
    fromSleep = false;
 }

  function positionByPartial(actual, maximum, top, availableHeight) {
    if (maximum == 0) {
      return top;
    }
    var diff = actual >= maximum ? 0 : maximum - actual;
    return top + availableHeight * diff / maximum;
  }

  function floorOffset(object, top, height, data) {
    var position = positionByPartial(data[0], data[1], top, height - object.height());
    object.setTop(position);
  }

  function onPartialUpdate(dc) {
    partialUpdate(dc, true);
  }

  function clearBox(dc, box, color){
    if ( dc has :setClip) {
      dc.setClip(box.left(), box.top(), box.width(), box.height()+1);
    }
    dc.setColor(color, color);
    dc.fillRectangle(box.left(), box.top() + 1, box.width(), box.height());
  }

  function drawString(dc, box, str){
    dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
    box.write(dc, str);
  }

  function displayHour(dc, box, str, data) {
    clearBox(dc, box, Gfx.COLOR_WHITE);
    if ( data ) {
      var position = positionByPartial(data[2] - data[1], data[0] - data[1], box.top(), box.height());
      dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_RED);
      dc.fillRectangle(box.left(), position + 1, box.width(), box.bottom() - position);
    }
    drawString(dc, box, str);
  }

  function displayMin(dc, box, str, data) {
    clearBox(dc, box, Gfx.COLOR_WHITE);
    var position = positionByPartial(data[0], data[1], box.top(), box.height());
    dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_GREEN);
    dc.fillRectangle(box.left(), position + 1, box.width(), box.bottom() - position);
    drawString(dc, box, str);
  }

  function displaySec(dc, box, str, data) {
    var top = box.top();
    var height = box.height();
    clearBox(dc, box, Gfx.COLOR_BLACK);
    floorOffset(box, box.previous().top(), box.previous().height(), data);
    if ( box.top() != top) {
      dc.fillRectangle(box.left(), top + 1, box.width(), height);
    }
    clearBox(dc, box, Gfx.COLOR_WHITE);
    drawString(dc, box, str);
  }

  function displayMaxHr(dc, box, str) {
    clearBox(dc, box, Gfx.COLOR_RED);
    drawString(dc, box, str);
  }

  function displayMinHr(dc, box, str) {
    clearBox(dc, box, Gfx.COLOR_RED);
    drawString(dc, box, str);
  }

  function displayActualHr(dc, box, str) {
    clearBox(dc, box, Gfx.COLOR_RED);
    drawString(dc, box, str);
  }
  function displayStepActual(dc, box, str){
    clearBox(dc, box, Gfx.COLOR_GREEN);
    drawString(dc, box, str);
  }
  function displayStepGoal(dc, box, str){
    clearBox(dc, box, Gfx.COLOR_GREEN);
    drawString(dc, box, str);
  }

  function partialUpdate(dc, isPartial) {
    var times = clockParts();
    var needsHours = false;
    var showMax = !isPartial && hrTop != null;
    var showMin = !isPartial && hrBottom != null;
    var showActual = !isPartial && hrLast != null;

    if ( ActMon has :getHeartRateHistory){
      if (fromSleep || times[1] == "00" || times[1] == "30" ){ // we only do this every 30 seconds, or when we wake up
        try {
          var ittr = ActMon.getHeartRateHistory(new Time.Duration(4*60*60), true);
          var first = ittr.next();
          if( (first != null) && (first.heartRate != 255 )){
            var min = ittr.getMin();
            var max = ittr.getMax();
            if ( max != hrTop ) {
              hrTop = max;
              showMax = true;
              neadsHours = true;
            }
            if ( min != hrBottom ) {
              hrBottom = min;
              showMin = true;
              neadsHours = true;
            }
            if ( first.heartRate != hrLast) {
              hrLast = first.heartRate;
              showActual = true;
              neadsHours = true;
            }
          }
        } catch(e) {
          Sys.println(Lang.format("HR FAILED: $1$", [e.getErrorMessage()]));
          e.printStackTrace();
        }
      }
    }

    if ( showMin){
      displayMinHr(dc, hrMinBox, hrBottom.format("%3i"));
    }
    if ( showActual){
      displayActualHr(dc, hrActualBox, hrLast.format("%3i"));
    }
    if( showMax){
      displayMaxHr(dc, hrMaxBox, hrTop.format("%i")+ " ");
    }
    // potentially we can just draw the difference between the existing and new tops.
    if ( needsHours || times[0] != lastTimeDisplayed[0]) {
      var data = (hrTop != null && hrBottom != null && hrLast != null) ? [hrTop, hrBottom, hrLast] : null;
      displayHour(dc, hourBox, times[0], data);
    }

    var info = ActMon.getInfo();
    if ( !isPartial || info.steps != stepsNow || info.stepGoal != stepsTop || times[1] != lastTimeDisplayed[1]) {
      if (info.steps != stepsNow || !isPartial) {
        stepsNow = info.steps;
        displayStepActual(dc, stepActualBox, stepsNow.format("%5i"));
      }
      if (info.stepGoal != stepsTop || !isPartial) {
        stepsTop = info.stepGoal;
        displayStepGoal(dc, stepTotalBox, info.stepGoal.format("%5i"));
      }
      displayMin(dc, minBox, times[1], [info.steps, info.stepGoal]);
    }

    lastTimeDisplayed = times;
    if ( !seconds ) { return; }
    var data = (info has :floorsClimbed) ? [info.floorsClimbed, info.floorsClimbedGoal] : [1, 1];
    displaySec(dc, secBox, times[2], data );
  }

  function calculateTheThing(count){
    if ( count <= 1 ){ return 1;}
    return calculateTheThing(count - 1) + calculateTheThing(count - 2);
  }
  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() {}

  // The user has just looked at their watch. Timers and animations may be started here.
  function onExitSleep() {
    fromSleep = true;
  }

  // Terminate any active timers and prepare for slow updates.
  function onEnterSleep() {
  }

}

class TWDelegate extends Ui.WatchFaceDelegate {
  function initialize() {
    Ui.WatchFaceDelegate.initialize();
  }
  // The onPowerBudgetExceeded callback is called by the system if the
  // onPartialUpdate method exceeds the allowed power budget. If this occurs,
  // the system will stop invoking onPartialUpdate each second, so we set the
  // partialUpdatesAllowed flag here to let the rendering methods know they
  // should not be rendering a second hand.
  function onPowerBudgetExceeded(powerInfo) {
    Sys.println("Average execution time: " + powerInfo.executionTimeAverage);
    Sys.println("Allowed execution time: " + powerInfo.executionTimeLimit);
  }
}