import Toybox.Activity;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

using Toybox.Application.Properties as Prop;

class PowerLapField extends Field {

    private var _powerSum as Long = 0l;
    private var _powerCount as Number = 0;
    private var _prevTimer as Number = -1;

    function initialize() {
        Field.initialize("Lap Pwr");
    }

    function compute(info as Activity.Info, timer as Number?) as Void {
        Field.compute(info, timer);
        if (timer != null) {
            if (timer != _prevTimer && info.currentPower != null) {
                _powerSum += info.currentPower;
                _powerCount ++;
            }
            _prevTimer = timer;
        }
        
        if (_powerCount > 0) {
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