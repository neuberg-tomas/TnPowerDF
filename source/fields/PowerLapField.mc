import Toybox.Activity;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

using Toybox.Application.Properties as Prop;

class PowerLapField extends Field {

    const LBL = "L/Pwr";

    private var _powerSum as Double = 0d;
    private var _powerCount as Number = 0;
    private var _prevTimer as Number = -1;

    function initialize() {
        Field.initialize(LBL);
    }

    function compute(info as Activity.Info, context as ComputeContext) as Void {
        Field.compute(info, context);
        if (context.timer != null) {
            if (context.timer != _prevTimer && info.currentPower != null) {
                _powerSum += info.currentPower / context.envCorrection;
                _powerCount ++;
            }
            _prevTimer = context.timer;
        }
        
        if (_powerCount > 0) {
            var v = Math.round(_powerSum / _powerCount).toNumber();
            _value = v.format("%d");
            var zone = context.getPowerZone(v);
            _label = zone == null ? LBL : LBL + " " + zone;
            setZone(zone);
            if (_workout != null && _workout.stepTargetType == Activity.WORKOUT_STEP_TARGET_POWER) {
                setAlert(v < _workout.stepLo ? 1 : v > _workout.stepHi ? 2 : 0, Prop.getValue("alertType") == 1, context       );
            } else {
                clearAlert();
            }

        } else {
            _value = NO_VALUE;
            _label = LBL;
            setZone(null);
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
        _powerSum = 0d;
        _powerCount = 0;
    }

    function persistContext(context as Dictionary) {
        Field.persistContext(context);
        context["PowerLapField.sum"] = _powerSum;
        context["PowerLapField.counter"] = _powerCount;
        context["PowerLapField.prevTimer"] = _prevTimer;
    }

    function restoreContext(workout as WorkoutInfo?, context as Dictionary) {
        Field.restoreContext(workout, context);
        _powerSum = context["PowerLapField.sum"] as Double;
        _powerCount = context["PowerLapField.counter"] as Number;
        _prevTimer = context["PowerLapField.prevTimer"] as Number;
    }
}