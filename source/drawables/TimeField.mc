import Toybox.Activity;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

using Toybox.Application.Properties as Prop;

class TimeField extends WorkoutField {

    private var _elapsedTime as String = "";
    private var _time as String = "";

    function initialize(params as Dictionary) {
        WorkoutField.initialize(params, "T/Rem/Elap");
    }

    function compute(info as Activity.Info) as Void {
        if (_stepDurationType == Activity.WORKOUT_STEP_DURATION_TIME) {
            _value = formatTimeMs(_stepDuration * 1000 - (info.timerTime - _stepStartTime));
        } else if (_stepStartTime != null) {
            _value = formatTimeMs(info.timerTime - _stepStartTime);
        } else {
            _value = NO_VALUE;
        }

        _elapsedTime = formatTimeMs(info.timerTime);

        var clock = System.getClockTime();
        _time = Lang.format("$1$:$2$", [
            clock.hour.format("%02d"),
            clock.min.format("%02d")
        ]);
    }

    function draw(dc as Dc) as Void {
        Field.draw(dc);

        System.println(_time + " / " + _value + " / " + _elapsedTime);
    }
}