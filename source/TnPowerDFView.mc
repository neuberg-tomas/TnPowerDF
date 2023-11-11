import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Application.Properties as Prop;
using Toybox.Application.Storage;
using Toybox.System;

class TnPowerDFView extends Ui.DataField {

    private const _fields as Array<Field> = [
        new PowerField(),
        new HRField(), new PowerLapField(), new PowerAvgField(),
        new PaceAvgField(), new DistLapField(), new DistField(),
        new TimeField()
    ] as Array<Field>;

    private var _workout as WorkoutInfo?;

    private const _bgColor as Number = Prop.getValue("colorBg").toNumber();
    private const _lineColor as Number = Prop.getValue("linesColor").toNumber();
    private const _lineWidth as Number = Prop.getValue("linesWidth").toNumber();
    
    private var _timer as Number = 0;
    private var _distance as Float = 0.0;
    private var _timerActive as Boolean = false;
    private var _heartRateZones as Array<Number>?;
    private const _powerZones as Array<Number> = new Array<Number>[5];
  
    private var _initialized as Boolean?;

    function initialize() {
        DataField.initialize();

        var heartRateZones = UserProfile.getHeartRateZones(UserProfile.HR_ZONE_SPORT_RUNNING);
        if (heartRateZones == null) {
            $.log("no run specific HR zones found, using generic ones");
            heartRateZones = UserProfile.getHeartRateZones(UserProfile.HR_ZONE_SPORT_GENERIC);
        } else {
            $.log("using run specific power zones");
        }
        if (heartRateZones != null && heartRateZones.size() > 2) {
            _heartRateZones = new Array<Number>[heartRateZones.size() - 1];
            for (var i = 0; i < _heartRateZones.size(); i++) {
                _heartRateZones[i] = heartRateZones[i];
            }
        } 
        
        if (_heartRateZones == null) {
            $.log("no HR zones are set");
        } else {
            var s = "";
            for (var i = 0; i < _heartRateZones.size(); i++) {
                s += (i > 0 ? ", " : "") + (i + 1) + "=" + _heartRateZones[i];
            }
            $.log("HR zones: " + s);
        }

        var ftp = Prop.getValue("ftp") as Number;
        _powerZones[0] = computePowerZone(ftp, Prop.getValue("powerZone1PercMin") as Number);
        for (var i = 1; i < _powerZones.size(); i++) {
            _powerZones[i] = computePowerZone(ftp, Prop.getValue("powerZone" + i + "PercMax") as Number);
        }

        var context = Storage.getValue("context") as Dictionary;
        if (context != null) {
            log("restoring context");
            _timer = context["timer"] as Number; 
            _distance = context["distance"] as Float; 

            if (Activity.getCurrentWorkoutStep() != null) {
                $.log("restoring workout");
                _workout = new WorkoutInfo(_timer, _distance, Activity.getCurrentWorkoutStep(), Activity.getNextWorkoutStep());
                _workout.restoreContext(context);
            }

            for (var i = 0; i < _fields.size(); i++) {
                try {
                    _fields[i].restoreContext(_workout, context);
                } catch (ex) {
                   $.log("field." + i + " restore context exception: " + ex.getErrorMessage());
                }
            }  
        }

        _initialized = true;
    }

    function compute(info as Activity.Info) as Void {     
        try {
            if (_timerActive) {
                _timer ++;
            }
            if (info.elapsedDistance != null) {
                _distance = info.elapsedDistance;
            }
            if (_workout != null && _workout.isSet() && !_workout.isStatic() && Activity.getCurrentWorkoutStep() == null) {
                $.log("onWorkoutStepComplete wasn't call but current workout step is null");
                onWorkoutStepComplete();
            }

            var context = new ComputeContext(_timer, _powerZones, _heartRateZones, $.computeEnvCorrection(info));

            for (var i = 0; i < _fields.size(); i++) {
                try {
                    _fields[i].compute(info, context);
                } catch (ex) {
                   $.log("field." + i + " compute exception: " + ex.getErrorMessage());
                }
            }   
        } catch (ex) {
            $.log("compute exception: " + ex.getErrorMessage());
        }
    }

    private function computePowerZone(ftp as Number, perc as Number) {
        return Math.round(ftp * perc / 100.0).toNumber();
    }

    function onWorkoutStarted() as Void {
        $.log("onWorkoutStarted");
        _workout = new WorkoutInfo(_timer, _distance, Activity.getCurrentWorkoutStep(), Activity.getNextWorkoutStep());
        for (var i = 0; i < _fields.size(); i++) {
            _fields[i].onWorkoutStep(_workout);
        }
    }

    function onWorkoutStepComplete() as Void {
        $.log("onWorkoutStepComplete");

        _workout = getNextWorkout();
        for (var i = 0; i < _fields.size(); i++) {
            _fields[i].onWorkoutStep(_workout);
        }
    }

    private function getNextWorkout() {        
        var step = Activity.getCurrentWorkoutStep();
        if (step == null) {
            if (_workout != null && Prop.getValue("useLastStepTarget")) {
                return new WorkoutInfo(_timer, _distance, null, null).setStaticPowerTarget(_workout.stepLo, _workout.stepHi);
            }
            if (Prop.getValue("useStaticTarget")) {                 
                return new WorkoutInfo(_timer, _distance, null, null).setStaticPowerTarget(
                    Prop.getValue("staticTargetLo") as Number, Prop.getValue("staticTargetHi") as Number
                );
            }
        }
        return new WorkoutInfo(_timer, _distance, step, Activity.getNextWorkoutStep());
    }

    function onTimerLap() as Void {
        $.log("onTimerLap");

        if (_workout != null && _workout.isStatic()) {
            _workout.stepStartTime = _timer;
            _workout.stepStartDistance = _distance;
        }
        for (var i = 0; i < _fields.size(); i++) {
            _fields[i].onLap();
        }
    }

    function onTimerStart() as Void {
        $.log("onTimerStart");

        _timerActive = true;

        if ((_workout == null || !_workout.isSet()) && Prop.getValue("useStaticTarget")) {
            _workout = new WorkoutInfo(_timer, _distance, null, null).setStaticPowerTarget(
                    Prop.getValue("staticTargetLo") as Number, Prop.getValue("staticTargetHi") as Number
                );
            for (var i = 0; i < _fields.size(); i++) {
                _fields[i].onWorkoutStep(_workout);
            }
        }

        for (var i = 0; i < _fields.size(); i++) {
            _fields[i].onStart();
        }
    }

    function onTimerStop() as Void {
        $.log("onTimerStop");        
        _timerActive = false;

        var context = {"timer" => _timer, "distance" => _distance};
        if (_workout != null) {
            _workout.persistContext(context);
        }
        for (var i = 0; i < _fields.size(); i++) {
            _fields[i].persistContext(context);
        }

        Storage.setValue("context", context);
    }

    function onTimerPause() as Void {
        $.log("onTimerPause");
        _timerActive = false;
    }

    function onTimerResume() as Void {
        $.log("onTimerResume");
        _timerActive = true;
    }

    function onTimerReset() as Void {
        $.log("onTimerReset");
        _timer = 0;
        _timerActive = false;

        for (var i = 0; i < _fields.size(); i++) {
            _fields[i].onStop();
        }

        Storage.deleteValue("context");
    }

    function onUpdate(dc as Dc) as Void {
        try {
            if (_initialized == null) {
                $.log("onUpdate: not initialized yet");
                return;
            }
            dc.setColor(_lineColor, _bgColor);
            dc.clear();

            var w = dc.getWidth();
            var h = dc.getHeight();

            var h1 = (h / 4 * 1.1).toNumber();
            var h2 = h / 2;
            var h3 = h - h1;
            var wo = Math.round(w * 0.05).toNumber();
            var w1 = Math.round(w * 0.34).toNumber();

            dc.setPenWidth(_lineWidth);
            dc.drawLine(wo, h1, w - wo, h1);
            dc.drawLine(0, h2, w, h2);
            dc.drawLine(wo, h3, w - wo, h3);
            dc.drawLine(w1, h1, w1, h3);
            dc.drawLine(w - w1, h1, w - w1, h3);

            var fw1 = w - 2 * wo - _lineWidth;
            var fw2_1 = w1 - wo;
            var fw2_2 = w - w1 * 2 - _lineWidth;
            var fh1 = h1 - _lineWidth;
            var fh2 = h2 - h1 - _lineWidth;

            // top
            try {
                _fields[0].draw(dc, wo, 0, fw1, fh1);
            } catch (ex) {
               $.log("field0.onUpdate exception: " + ex.getErrorMessage());
            }

            // 1th row
            try {
                _fields[1].draw(dc, wo, h1 + _lineWidth, fw2_1, fh2);
            } catch (ex) {
               $.log("field1.onUpdate exception: " + ex.getErrorMessage());
            }
            try {
                _fields[2].draw(dc, w1 + _lineWidth, h1 + _lineWidth, fw2_2, fh2);
            } catch (ex) {
               $.log("field2.onUpdate exception: " + ex.getErrorMessage());
            }
            try {
                _fields[3].draw(dc, w - w1 + _lineWidth, h1 + _lineWidth, fw2_1, fh2);
            } catch (ex) {
               $.log("field3.onUpdate exception: " + ex.getErrorMessage());
            }

            // 2nd row
            try {
                _fields[4].draw(dc, wo, h2 + _lineWidth, fw2_1, fh2);
            } catch (ex) {
               $.log("field4.onUpdate exception: " + ex.getErrorMessage());
            }
            try {
                _fields[5].draw(dc, w1 + _lineWidth, h2 + _lineWidth, fw2_2, fh2);
            } catch (ex) {
               $.log("field5.onUpdate exception: " + ex.getErrorMessage());
            }
            try {
                _fields[6].draw(dc, w - w1 + _lineWidth, h2 + _lineWidth, fw2_1, fh2);
            } catch (ex) {
               $.log("field6.onUpdate exception: " + ex.getErrorMessage());
            }

            // bottom
            try {
                _fields[7].draw(dc, wo, h3 + _lineWidth, fw1, fh1);
            } catch (ex) {
               $.log("field7.onUpdate exception: " + ex.getErrorMessage());
            }
        } catch (ex) {
            $.log("onUpdate exception: " + ex.getErrorMessage());
        }
    }
}

function log(msg as String) as Void {
    var t = System.getClockTime();
    System.println(t.hour.format("%02d") + ":" + t.min.format("%02d") + ":" + t.sec.format("%02d") + " - " + msg);
}
