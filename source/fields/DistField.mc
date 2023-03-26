import Toybox.Activity;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

using Toybox.Application.Properties as Prop;

class DistField extends Field {

    function initialize() {
        Field.initialize("Dist");
    }

    function compute(info as Activity.Info, context as ComputeContext) as Void {
        Field.compute(info, context);
        _value = info.elapsedDistance != null ? (info.elapsedDistance / 1000).format("%.1f") : NO_VALUE;
    }

}