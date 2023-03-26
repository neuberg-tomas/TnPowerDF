import Toybox.Activity;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

using Toybox.Application.Properties as Prop;

class TimeField extends Field {

    private var _elapsedTime as String = "";
    private var _time as String = "";

    function initialize() {
        Field.initialize("T/Rem/Elap");
    }

    function compute(info as Activity.Info, timer as Number?) as Void {
        Field.compute(info, timer);
        if (_workout == null) {
            _value = NO_VALUE;
        } else if (_workout.stepDurationType == Activity.WORKOUT_STEP_DURATION_TIME) {
            _value = formatTime(_workout.stepDuration - (timer - _workout.stepStartTime) / 1000);
        } else {
            _value = formatTime((timer - _workout.stepStartTime) / 1000);
        }

        _elapsedTime = formatTime(timer / 1000);

        var clock = System.getClockTime();
        _time = Lang.format("$1$:$2$", [
            clock.hour.format("%02d"),
            clock.min.format("%02d")
        ]);
    }

    function onStop() as Void {
        Field.onStop();
        _elapsedTime = "";
    }

    function draw(dc as Dc, x as Number, y as Number, w as Number, h as Number) as Void {
        Field.draw(dc, x, y, w, h);
    }
}