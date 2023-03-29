import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
using Toybox.WatchUi as Ui;
using Toybox.Application.Properties as Prop;

class TnPowerDFView extends Ui.DataField {

    private const _fields as Array<Field> = [
        new PowerField(),
        new HRField(), new PowerLapField(), new PowerAvgField(),
        new PaceAvgField(), new DistLapField(), new DistField(),
        new TimeField()
    ] as Array<Field>;

    private var _workout as WorkoutInfo?;

    private const _bgColor as Number = Prop.getValue("colorBg").toNumber();
    private const _lineColor as Number = Prop.getValue("colorLines").toNumber();
    private const _lineWidth as Number = 1;
    
    private var _timer as Number = 0;
    private var _timerActive as Boolean = false;
    private var _heartRateZones as Array<Number>?;
    private const _powerZones as Array<Number> = new Array<Number>[5];

    private const _envF1 as Float = (9.80665 * 0.0289644) / (8.31432 * -0.0065);

    private var _b24 as Float; // Converted power based on altitude -- From
    private var _b7 as Float;
    private var _b9 as Float;
    private var _b38 as Float; //Hudley model percentage -- From
    private var _b39 as Float; //Hudley model percentage -- To

    
    private const _useAltSensor as Boolean = Prop.getValue("envCurrAltSensor") as Boolean;
    private const _useEnvCorrection as Boolean = Prop.getValue("envCorrection") as Boolean;

    function initialize() {
        DataField.initialize();

        var heartRateZones = UserProfile.getHeartRateZones(UserProfile.HR_ZONE_SPORT_RUNNING);
        if (heartRateZones == null) {
            System.println("no run specific HR zones found, using generic ones");
            heartRateZones = UserProfile.getHeartRateZones(UserProfile.HR_ZONE_SPORT_GENERIC);
        }
        if (heartRateZones != null && heartRateZones.size() > 2) {
            _heartRateZones = new Array<Number>[heartRateZones.size() - 1];
            for (var i = 1; i < heartRateZones.size(); i++) {
                _heartRateZones[i - 1] = heartRateZones[i];
            }
        }

        var ftp = Prop.getValue("ftp") as Number;
        _powerZones[0] = computePowerZone(ftp, Prop.getValue("powerZone1PercMin") as Number);
        for (var i = 1; i < _powerZones.size(); i++) {
            _powerZones[i] = computePowerZone(ftp, Prop.getValue("powerZone" + i + "PercMax") as Number);
        }

        // pre-compute env correction
        var b4 = Prop.getValue("envTestAlt").toNumber();
        var b6 = Prop.getValue("envTestTmp").toNumber();
        var b22 = 101325.0 * Math.pow((b6 + 273.15)/((b6 + 273.15)+(-0.0065 * b4)), _envF1) * 0.00750062;
        _b24 = (-174.1448622 + 1.0899959 * b22 + -1.5119 * 0.001 * Math.pow(b22, 2) + 0.72674 * Math.pow(10, -6) * Math.pow(b22, 3)) / 100.0;
        _b7 = Prop.getValue("envCurrTmp").toFloat();
        _b9 = Prop.getValue("envCurrHum").toFloat();

        var b8 = Prop.getValue("envTestHum").toFloat();
        var b34 = Math.ln( b8 / 100.0 * Math.pow(Math.E, (18.678 - b6/234.5)*( b6/(257.14+ b6))));
        var b36 = (257.14 * b34 / (18.678-b34)) * 1.8 + 32; 
        _b38 = (b36+b6*1.8+32) > 100 ? 0.001341 * Math.pow((b36+b6*1.8+32), 2) -0.249517 * Math.pow((b36+b6*1.8+32), 1) + 11.699986 : 0.0;

        var b35 = Math.ln(_b9 / 100.0 * Math.pow(Math.E, (18.678 -_b7/234.5)*(_b7/(257.14+_b7))));
        var b37 = (257.14 * b35 / (18.678-b35)) * 1.8 + 32;
        _b39 = (b37+_b7*1.8+32) > 100 ? 0.001341 * Math.pow((b37+_b7*1.8+32), 2) -0.249517 * Math.pow((b37+_b7*1.8+32), 1) + 11.699986 : 0.0;
    }

    function compute(info as Activity.Info) as Void {     
        if (_timerActive) {
            _timer += 1000;
        }

        if (_workout != null && _workout.isSet() && !_workout.isStatic() && Activity.getCurrentWorkoutStep() == null) {
            onWorkoutStepComplete();
        }

        var context = new ComputeContext(_timer, _powerZones, _heartRateZones, computeEnvCorrection(info));

        for (var i = 0; i < _fields.size(); i++) {
            _fields[i].compute(info, context);
        }   
    }

    private function computePowerZone(ftp as Number, perc as Number) {
        return Math.round(ftp * perc / 100.0).toNumber();
    }

    private function computeEnvCorrection(info as Activity.Info) as Float {
        if (_useEnvCorrection) {
            var b5 = info.altitude != null && _useAltSensor ? info.altitude : (Prop.getValue("envCurrAlt") as Number).toFloat();
            var b23 = 101325 * Math.pow((_b7 + 273.15)/((_b7 + 273.15)+(-0.0065 * b5)), _envF1) * 0.00750062;
            var b25 = (-174.1448622 + 1.0899959 * b23 + -1.5119*0.001 * Math.pow(b23, 2) + 0.72674 * Math.pow(10, -6) * Math.pow(b23, 3)) / 100;
            var r = 1.0 - (_b24 - b25) - (_b39 - _b38) / 100.0;
            /*
            System.println(Lang.format("env correction = $1$, alt $2$ -> $3$, temp $4$ -> $5$, humidity $6$ -> $7$", [
                r, Prop.getValue("envTestAlt"), b5.toNumber(), Prop.getValue("envTestTmp"), Prop.getValue("envCurrTmp"),
                Prop.getValue("envTestHum"), Prop.getValue("envCurrHum")
            ]));
            */
            return r;
        }
        return 1.0;
    }

    function onWorkoutStarted() as Void {
        _workout = new WorkoutInfo(_timer, Activity.getCurrentWorkoutStep(), Activity.getNextWorkoutStep());
        for (var i = 0; i < _fields.size(); i++) {
            _fields[i].onWorkoutStep(_workout);
        }
    }

    function onWorkoutStepComplete() as Void {
        _workout = getNextWorkout();
        for (var i = 0; i < _fields.size(); i++) {
            _fields[i].onWorkoutStep(_workout);
        }
    }

    private function getNextWorkout() {
        var step = Activity.getCurrentWorkoutStep();
        if (step == null) {
            if (_workout != null && Prop.getValue("useLastStepTarget")) {
                return new WorkoutInfo(_timer, null, null).setStaticPowerTarget(_workout.stepLo, _workout.stepHi);
            }
            if (Prop.getValue("useStaticTarget")) {                 
                return new WorkoutInfo(_timer, null, null).setStaticPowerTarget(
                    Prop.getValue("staticTargetLo") as Number, Prop.getValue("staticTargetHi") as Number
                );
            }
        }
        return new WorkoutInfo(_timer, step, Activity.getNextWorkoutStep());
    }

    function onTimerLap() as Void {
        if (_workout != null && _workout.isStatic()) {
            _workout.stepStartTime = _timer;
        }
        for (var i = 0; i < _fields.size(); i++) {
            _fields[i].onLap();
        }
    }

    function onTimerStart() as Void {
        _timer = 0;
        _timerActive = true;

        if ((_workout == null || !_workout.isSet()) && Prop.getValue("useStaticTarget")) {
            _workout = new WorkoutInfo(_timer, null, null).setStaticPowerTarget(
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
        _timerActive = false;
        for (var i = 0; i < _fields.size(); i++) {
            _fields[i].onStop();
        }
    }

    function onTimerPause() as Void {
        _timerActive = false;
    }

    function onTimerResume() as Void {
        _timerActive = true;
    }

    function onUpdate(dc as Dc) as Void {
        if (_lineColor == null) {
            System.println("onUpdate: _lineColor=" + _lineColor);
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

        var fw1 = w - 2 * wo - 1;
        var fw2_1 = w1 - wo;
        var fw2_2 = w - w1 * 2 - 1;
        var fh1 = h1 - 1;
        var fh2 = h2 - h1 - 1;

        // top
        _fields[0].draw(dc, wo, 0, fw1, fh1);

        // 1th row
        _fields[1].draw(dc, wo, h1 + 1, fw2_1, fh2);
        _fields[2].draw(dc, w1 + 1, h1 + 1, fw2_2, fh2);
        _fields[3].draw(dc, w - w1 + 1, h1 + 1, fw2_1, fh2);

        // 2nd row
        _fields[4].draw(dc, wo, h2 + 1, fw2_1, fh2);
        _fields[5].draw(dc, w1 + 1, h2 + 1, fw2_2, fh2);
        _fields[6].draw(dc, w - w1 + 1, h2 + 1, fw2_1, fh2);

        // bottom
        _fields[7].draw(dc, wo, h3 + 1, fw1, fh1);
    }
}