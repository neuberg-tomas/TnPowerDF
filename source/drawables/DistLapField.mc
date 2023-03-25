import Toybox.Activity;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

using Toybox.Application.Properties as Prop;

class DistLapField extends Field {

    private var _startDistance as Float = 0.0;
    private var _distance as Float = 0.0;

    function initialize(params as Dictionary) {
        Field.initialize(params, "Lap Dist");
    }

    function compute(info as Activity.Info) as Void {
        if (info.elapsedDistance != null) {
            _distance = info.elapsedDistance;
            _value = (_distance - _startDistance).format("%4.1f");
        } else {
            _value = NO_VALUE;
        }
    }

    function onWorkoutStep() as Void {
        Field.onWorkoutStep();
        _startDistance = _distance;
    }
}