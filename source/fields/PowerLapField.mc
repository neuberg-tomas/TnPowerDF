import Toybox.Activity;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

using Toybox.Application.Properties as Prop;

class PowerLapField extends Field {

    const LBL = "Lap Pwr";

    private var _powerSum as Long = 0l;
    private var _powerCount as Number = 0;
    private var _prevTimer as Number = -1;

    function initialize() {
        Field.initialize(LBL);
    }

    function compute(info as Activity.Info, context as ComputeContext) as Void {
        Field.compute(info, context);
        if (context.timer != null) {
            if (context.timer != _prevTimer && info.currentPower != null) {
                _powerSum += info.currentPower;
                _powerCount ++;
            }
            _prevTimer = context.timer;
        }
        
        if (_powerCount > 0) {
            var v = (_powerSum / _powerCount).toNumber();
            _value = v.format("%d");
            var zone = context.getPowerZone(v);
            _label = zone == null ? LBL : LBL + " " + zone;
            setZone(zone);
            if (_workout != null && _workout.stepTargetType == Activity.WORKOUT_STEP_TARGET_POWER) {
                setAlert(v < _workout.stepLo ? 1 : v > _workout.stepHi ? 2 : 0, Prop.getValue("altertType") == 1, context);
            } else {
                clearAlert();
            }

        } else {
            _value = NO_VALUE;
            clearAlert();
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