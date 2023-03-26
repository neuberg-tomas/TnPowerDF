import Toybox.Activity;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

using Toybox.Application.Properties as Prop;

class PowerField extends Field {

    function initialize() {
        Field.initialize("Pwr");
    }

    function compute(info as Activity.Info, timer as Number?) as Void {
        Field.compute(info, timer);
        _value = info.currentPower ? info.currentPower.format("%d") : NO_VALUE;
    }

    function draw(dc as Dc, x as Number, y as Number, w as Number, h as Number) as Void {
        Field.draw(dc, x, y, w, h);
    }
}