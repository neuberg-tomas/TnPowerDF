import Toybox.Activity;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

using Toybox.Application.Properties as Prop;

class DistField extends Field {

    function initialize(params as Dictionary) {
        Field.initialize(params, "Dist");
    }

    function compute(info as Activity.Info) as Void {
        _value = info.elapsedDistance != null ? info.elapsedDistance.format("%4.1f") : NO_VALUE;
    }

}