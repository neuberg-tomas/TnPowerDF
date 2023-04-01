import Toybox.Activity;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

using Toybox.Application.Properties as Prop;

class PaceAvgField extends Field {

    function initialize() {
        Field.initialize("A/Pace");
    }

    function compute(info as Activity.Info, context as ComputeContext) as Void {
        Field.compute(info, context);
          if (info.elapsedDistance != null && info.elapsedDistance > 0) {
            var pace = (info.timerTime / info.elapsedDistance).toNumber();
            _value = Lang.format("$1$:$2$", [ pace / 60, (pace % 60).format("%02d")]);
        } else {
            _value = NO_VALUE;
        }
    }

}