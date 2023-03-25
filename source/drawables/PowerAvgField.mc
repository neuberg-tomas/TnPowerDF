import Toybox.Activity;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

using Toybox.Application.Properties as Prop;

class PowerAvgField extends Field {

    function initialize(params as Dictionary) {
        Field.initialize(params, "Avg Pwr");
    }

    function compute(info as Activity.Info) as Void {
        _value = info.averagePower ? info.averagePower : NO_VALUE;
    }

}