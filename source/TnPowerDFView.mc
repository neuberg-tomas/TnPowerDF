import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
using Toybox.WatchUi as Ui;

class TnPowerDFView extends Ui.DataField {

    private var _fields as Array<Field> = new Array<Field>[8];
    private var _workout as WorkoutInfo?;
    private var _timer as Number = 0;
    private var _timerActive as Boolean = false;

    function initialize() {
        DataField.initialize();
    }

    function onLayout( dc as Dc ) as Void {
        setLayout( $.Rez.Layouts.MainLayout( dc ) );

        for (var i = 1; i <= _fields.size(); i++) {
            var f = findDrawableById("field" + i) as Field;
            _fields[i - 1] = f;
            f.onLayout(dc);
        }
    }

    function compute(info as Activity.Info) as Void {     
        if (_timerActive) {
            _timer++;
        }
        if (_fields[0] != null) {
            for (var i = 0; i < _fields.size(); i++) {
                _fields[i].compute(info, _timer);
            }
        }
    }

    function onWorkoutStarted() as Void {
        _workout = new WorkoutInfo(_timer, Activity.getCurrentWorkoutStep(), Activity.getNextWorkoutStep());
        for (var i = 0; i < _fields.size(); i++) {
            _fields[i].onWorkoutStep(_workout);
        }
    }

    function onWorkoutStepComplete() as Void {
        _workout = new WorkoutInfo(_timer, Activity.getCurrentWorkoutStep(), Activity.getNextWorkoutStep());
        for (var i = 0; i < _fields.size(); i++) {
            _fields[i].onWorkoutStep(_workout);
        }
    }

    function onTimerLap() as Void {
        for (var i = 0; i < _fields.size(); i++) {
            _fields[i].onLap();
        }
    }

    function onTimerStart() as Void {
        _timer = 0;
        _timerActive = true;
        for (var i = 0; i < _fields.size(); i++) {
            _fields[i].onStart();
        }
    }

    function onTimerPause() as Void {
        _timerActive = false;
    }

    function onTimerResume() as Void {
        _timerActive = true;
    }

    function onTimerStop() as Void {
        for (var i = 0; i < _fields.size(); i++) {
            _fields[i].onStop();
        }
        if (_workout != null) {
            _workout = new WorkoutInfo(_timer, null, null);
            for (var i = 0; i < _fields.size(); i++) {
                _fields[i].onWorkoutStep(_workout);
            }
        }
    }


  /*
    function onUpdate(dc as Dc) as Void {

        //(findDrawableById("metricR1C2") as SimpleValue).onUp("888");

        View.onUpdate( dc );

   
  
        var tdm = dc.getTextDimensions("000", numNormalFont);
        var fcm = Graphics.getFontDescent(numNormalFont) - 4;

        var tds = dc.getTextDimensions("000", Graphics.FONT_SMALL);
        var fcs = Graphics.getFontDescent(Graphics.FONT_SMALL) - 4;

        var tdxt = dc.getTextDimensions("0", Graphics.FONT_XTINY);
        var fcxt = Graphics.getFontDescent(Graphics.FONT_XTINY);



        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);

        var info = Activity.getActivityInfo();
        var eTime = info.timerTime / 1000;

        dc.drawText(w / 2 - tdm[0] / 2 - tds[0] / 3, h1 - tds[1] + fcs, Graphics.FONT_SMALL, eTime.format("%d"), 
            Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(w / 2, h1 - tdm[1] + fcm, numNormalFont, "311", 
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(w / 2 + tdm[0] / 2 + tds[0] / 3, h1 - tds[1] + fcs, Graphics.FONT_SMALL, "323", 
            Graphics.TEXT_JUSTIFY_LEFT);

        dc.drawText(w1 - 6, h2 - tdm[1] + fcm, numNormalFont, "182", 
            Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(w / 2, h2 - tdm[1] + fcm, numNormalFont, "315", 
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(w3 + 6, h2 - tdm[1] + fcm, numNormalFont, "318", 
            Graphics.TEXT_JUSTIFY_LEFT);

        dc.drawText(w1 - 6, h3 - tdm[1] + fcm, numNormalFont, "5:23", 
            Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(w / 2, h3 - tdm[1] + fcm, numNormalFont, "25.3", 
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(w3 + 6, h3 - tdm[1] + fcm, numNormalFont, "12.5", 
            Graphics.TEXT_JUSTIFY_LEFT);

        dc.drawText(w1 - 6, h3 + 3, Graphics.FONT_XTINY, "20:45", 
            Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(w / 2, h3 + 3, Graphics.FONT_SMALL, "1:10:00", 
            Graphics.TEXT_JUSTIFY_CENTER);      
        dc.drawText(w3 + 6, h3 + 3, Graphics.FONT_XTINY, "3:45:00", 
            Graphics.TEXT_JUSTIFY_LEFT);


        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);

        dc.drawText(w/2, 10, Graphics.FONT_XTINY, "Pwr", Graphics.TEXT_JUSTIFY_CENTER);

        dc.drawText(w1/2, h1, Graphics.FONT_XTINY, "HR 5", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(w/2, h1, Graphics.FONT_XTINY, "Lap pwr", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(w - w1/2, h1, Graphics.FONT_XTINY, "Avg pwr", Graphics.TEXT_JUSTIFY_CENTER);

        dc.drawText(w1/2, h2, Graphics.FONT_XTINY, "Avg pace", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(w/2, h2, Graphics.FONT_XTINY, "Dist", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(w - w1/2, h2, Graphics.FONT_XTINY, "Step dist", Graphics.TEXT_JUSTIFY_CENTER);

        dc.drawText(w/2, h - 8 - tds[1] + fcs, Graphics.FONT_XTINY, "T/Rem/Elap", Graphics.TEXT_JUSTIFY_CENTER);


        dc.setPenWidth(5);
        dc.setColor(Graphics.COLOR_PINK, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(w/2, h/2, w / 2 - 6, Graphics.ARC_COUNTER_CLOCKWISE, 50, 70);
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(w/2, h/2, w / 2 - 6, Graphics.ARC_COUNTER_CLOCKWISE, 70, 110);
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(w/2, h/2, w / 2 - 6, Graphics.ARC_COUNTER_CLOCKWISE, 110, 130);

        dc.setPenWidth(10);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(w/2, h/2, w / 2 - 8, Graphics.ARC_COUNTER_CLOCKWISE, 80, 82);

        dc.setPenWidth(5);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(w/2, h/2, w / 2 - 6, Graphics.ARC_COUNTER_CLOCKWISE, 230, 300);
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(w/2, h/2, w / 2 - 6, Graphics.ARC_COUNTER_CLOCKWISE, 300, 310);
    
    
    }
    */
}

class WorkoutInfo {
    var stepLo as Number?;
    var stepHi as Number?;
    var stepTargetType as WorkoutStepTargetType?;

    var stepDuration as Number?;
    var stepDurationType as WorkoutStepDurationType?;
    var stepStartTime as Number;

    var stepNextTargetType as WorkoutStepTargetType?;
    var stepNextLo as Number?;
    var stepNextHi as Number?;

    function initialize(timer as Number, currStep as WorkoutStepInfo?, nextStep as WorkoutStepInfo?) {
        stepStartTime = timer;

        if (currStep == null || !(currStep.step instanceof WorkoutStep)) {
            stepTargetType = null;
            stepNextTargetType = null;
            stepDurationType = null;
            return;
        }

        var step = currStep.step as WorkoutStep;

        stepTargetType = step.targetType;
        stepLo = normalizeTarget(stepTargetType, step.targetValueLow);
        stepHi = normalizeTarget(stepTargetType, step.targetValueHigh);
        
        stepDurationType = step.durationType;
        stepDuration = step.durationValue;
    
        if (nextStep == null || !(nextStep.step instanceof WorkoutStep)) {
            stepNextTargetType = null;
        } else {
            step = nextStep.step as WorkoutStep;
            stepNextTargetType = step.targetType;
            stepNextLo = normalizeTarget(stepNextTargetType, step.targetValueLow);
            stepNextHi = normalizeTarget(stepNextTargetType, step.targetValueHigh);
        }
    }

    private function normalizeTarget(type as WorkoutStepTargetType?, value as Number?) as Number? {
        return value == null || type == null || type != Activity.WORKOUT_STEP_TARGET_POWER || value == 0 ? value : value - 1000; 
    }

    function isSet() as Boolean {
        return stepTargetType != null;
    }
}