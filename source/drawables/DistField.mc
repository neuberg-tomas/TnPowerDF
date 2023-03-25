import Toybox.Activity;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

using Toybox.Application.Properties as Prop;

class DistField extends Field {

    function initialize(params as Dictionary) {
        Field.initialize(params, "Dist");
    }

    function compute(info as Activity.Info, timer as Number) as Void {
        Field.compute(info, timer);
        _value = info.elapsedDistance != null ? (info.elapsedDistance / 1000).format("%.1f") : NO_VALUE;
    }

}