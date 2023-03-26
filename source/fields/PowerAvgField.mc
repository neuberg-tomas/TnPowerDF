import Toybox.Activity;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

using Toybox.Application.Properties as Prop;

class PowerAvgField extends Field {

    function initialize() {
        Field.initialize("Avg Pwr");
    }

    function compute(info as Activity.Info, timer as Number?) as Void {
        Field.compute(info, timer);
        _value = info.averagePower ? info.averagePower.format("%d") : NO_VALUE;
    }

}