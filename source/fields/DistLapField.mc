import Toybox.Activity;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

using Toybox.Application.Properties as Prop;

class DistLapField extends Field {

    private var _startDistance as Float = 0.0;
    private var _distance as Float = 0.0;

    function initialize() {
        Field.initialize("Lap Dist");
    }

    function compute(info as Activity.Info, timer as Number?) as Void {
        Field.compute(info, timer);
        if (info.elapsedDistance != null) {
            _distance = info.elapsedDistance / 1000;
            _value = (_distance - _startDistance).format("%.1f");
        } else {
            _value = NO_VALUE;
        }
    }

    function onStart() as Void {
        Field.onStart();
        _startDistance = 0.0;
        _distance = 0.0;
    }

    function onStop() as Void {
        Field.onStop();
        var info = Activity.getActivityInfo();
        _startDistance = info == null ? _distance : info.elapsedDistance;
    }

    function onLap() as Void {
        Field.onLap();
        _startDistance = _distance;
    }
}