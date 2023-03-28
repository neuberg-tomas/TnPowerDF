import Toybox.Activity;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.UserProfile;

using Toybox.Application.Properties as Prop;

class HRField extends Field {

    const LBL = "HR";

    function initialize() {
        Field.initialize(LBL);
    }

    function compute(info as Activity.Info, context as ComputeContext) as Void {
        Field.compute(info, context);
        var v = info.currentHeartRate;
        if (v != null) {
            _value = v.format("%d");
            var zone = context.getHeartRateZone(v);
            setZone(zone);
            _label = zone == null ? LBL : LBL + " " + zone;
        } else {
            _value = NO_VALUE;
            _label = LBL;
            setZone(null);
        }
    }

}