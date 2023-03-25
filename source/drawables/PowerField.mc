import Toybox.Activity;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

using Toybox.Application.Properties as Prop;

class PowerField extends Field {

    function initialize(params as Dictionary) {
        Field.initialize(params, "Pwr");
    }

    function compute(info as Activity.Info, timer as Number) as Void {
        Field.compute(info, timer);
        _value = info.currentPower ? info.currentPower.format("%d") : NO_VALUE;
    }

    function draw(dc as Dc) as Void {
        Field.draw(dc);
    }
}