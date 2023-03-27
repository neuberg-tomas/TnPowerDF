import Toybox.Activity;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

using Toybox.Application.Properties as Prop;

class PowerAvgField extends Field {

    const LBL = "Avg Pwr";

    function initialize() {
        Field.initialize(LBL);
    }

    function compute(info as Activity.Info, context as ComputeContext) as Void {
        Field.compute(info, context);
        var v = info.averagePower == null ? null : Math.round(info.averagePower / context.envCorrection).toNumber();
        if (v == null) {
            _value = NO_VALUE;
            _label = LBL;
        } else {
            _value = v.format("%d");
            var zone = context.getPowerZone(v);
            setZone(zone);
            _label = zone == null ? LBL : LBL + " " + zone;
        }
    }

}