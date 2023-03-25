import Toybox.Activity;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

using Toybox.Application.Properties as Prop;

class PowerField extends WorkoutField {

    function initialize(params as Dictionary) {
        WorkoutField.initialize(params, "Pwr");
    }

    function compute(info as Activity.Info) as Void {
        _value = info.currentPower ? info.currentPower : NO_VALUE;
    }

    function draw(dc as Dc) as Void {
        Field.draw(dc);
    }
}