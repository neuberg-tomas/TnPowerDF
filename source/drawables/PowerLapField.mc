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

    function compute(info as Activity.Info, timer as Number) as Void {
        Field.compute(info, timer);
        if (info.timerState == Activity.TIMER_STATE_ON && info.currentPower != null) {
            _powerSum += info.currentPower;
            _powerCount ++;
            _value = (_powerSum / _powerCount).format("%d");
        } else {
            _value = NO_VALUE;
        }
    }

    function onStop() as Void {
        Field.onStop();
        reset();
    }

    function onLap() as Void {
        Field.onLap();
        reset();
    }

    private function reset() as Void {
        _powerSum = 0l;
        _powerCount = 0;
    }
}