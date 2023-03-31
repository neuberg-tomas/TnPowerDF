import Toybox.Activity;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

using Toybox.Application.Properties as Prop;

class DistLapField extends Field {

    private var _startDistance as Float?;

    function initialize() {
        Field.initialize("L/Dist");
    }

    function compute(info as Activity.Info, context as ComputeContext) as Void {
        Field.compute(info, context);
        if (info.elapsedDistance != null) {
            var distance = info.elapsedDistance / 1000;
            if (_startDistance == null) {
                _startDistance = distance;
            }
            _value = (distance - _startDistance).format("%.1f");
        } else {
            _value = NO_VALUE;
        }
    }

    function onStart() as Void {
        Field.onStart();
        _startDistance = null;
    }

    function onStop() as Void {
        Field.onStop();
        _startDistance = null;
    }

    function onLap() as Void {
        Field.onLap();
        _startDistance = null;
    }
}