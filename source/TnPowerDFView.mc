import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
using Toybox.WatchUi as Ui;
using Toybox.Application.Properties as Prop;

class TnPowerDFView extends Ui.DataField {

    private var _fields as Array<Field> = [
        new PowerField(),
        new HRField(), new PowerLapField(), new PowerAvgField(),
        new PaceAvgField(), new DistLapField(), new DistField(),
        new TimeField()
    ] as Array<Field>;

    private var _workout as WorkoutInfo?;

    private var _bgColor as Number, _lineColor as Number;
    private var _lineWidth as Number = 1;
    private var _timer as Number = 0;
    private var _timerActive as Boolean = false;
    private var _heartRateZones as Array<Number>?;
    private var _powerZones as Array<Number> = new Array<Number>[5];

    function initialize() {
        DataField.initialize();

        _bgColor = Prop.getValue("colorBg");
        _lineColor = Prop.getValue("colorLines");

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
    }

    function compute(info as Activity.Info) as Void {     
        if (_timerActive) {
            _timer += 1000;
        }

        if (_workout != null && _workout.isSet() && Activity.getCurrentWorkoutStep() == null) {
            onWorkoutStepComplete();
        }

        var context = new ComputeContext(_timer, _powerZones, _heartRateZones);

        for (var i = 0; i < _fields.size(); i++) {
            _fields[i].compute(info, context);
        }   
    }

    private function computePowerZone(ftp as Number, perc as Number) {
        return Math.round(ftp * perc / 100.0).toNumber();
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
        var fw2_1 = w1 - wo - 1;
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