import Toybox.Activity;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

using Toybox.Application.Properties as Prop;

class PowerLapField extends Field {

    private var _powerSum as Long = 0l;
    private var _powerCount as Number = 0;

    function initialize(params as Dictionary) {
        Field.initialize(params, "Lap Pwr");
    }

    function compute(info as Activity.Info) as Void {
        if (info.timerState == Activity.TIMER_STATE_ON && info.currentPower != null) {
            _powerSum += info.currentPower;
            _powerCount ++;
            _value = (_powerSum / _powerCount).format("%d");
        } else {
            _value = NO_VALUE;
        }
    }

    function onWorkoutStep() as Void {
        Field.onWorkoutStep();
        _powerSum = 0l;
        _powerCount = 0;
    }

}