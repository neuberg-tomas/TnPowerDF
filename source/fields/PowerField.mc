import Toybox.Activity;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

using Toybox.Application.Properties as Prop;

class PowerField extends Field {

    const LBL = "Pwr";

    function initialize() {
        Field.initialize(LBL);
    }

    function compute(info as Activity.Info, context as ComputeContext) as Void {
        Field.compute(info, context);
        var v = info.currentPower;
        if (v == null) {
            _label = LBL;
            _value = NO_VALUE;
            setZone(null);
            setAlert(0);
        } else {
            _value = v.format("%d");
            var zone = context.getPowerZone(v);
            setZone(zone);
            _label = zone == null ? LBL : LBL + " " + zone;
            if (_workout != null && _workout.stepTargetType == Activity.WORKOUT_STEP_TARGET_POWER) {
                setAlert(v < _workout.stepLo ? 1 : v > _workout.stepHi ? 2 : 0);
            } else {
                setAlert(0);
            }
        }
    }

    function draw(dc as Dc, x as Number, y as Number, w as Number, h as Number) as Void {
        Field.draw(dc, x, y, w, h);
    }
}