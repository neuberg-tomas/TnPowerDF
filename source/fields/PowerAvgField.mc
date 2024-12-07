import Toybox.Activity;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

using Toybox.Application.Properties as Prop;

class PowerAvgField extends Field {

    const LBL = "A/Pwr";

    private var _sum as Double = 0d;
    private var _counter as Number = 0;
    private var _prevTimer as Number = -1;

    function initialize() {
        Field.initialize(LBL);
    }

    function compute(info as Activity.Info, context as ComputeContext) as Void {
        Field.compute(info, context);
        if (context.power != null) {
            if (context.power != null && _prevTimer != context.timer) {
                _sum += context.power / context.envCorrection;
                _counter ++;
            }
            _prevTimer = context.timer;
        }

        if (_counter == 0) {
            setZone(null);
            _value = NO_VALUE;
            _label = LBL;
        } else {
            var v = Math.round(_sum / _counter).toNumber();
            _value = v.format("%d");
            var zone = context.getPowerZone(v);
            setZone(zone);
            _label = zone == null ? LBL : LBL + " " + zone;
        }
    }

   function onStop() as Void {
        Field.onStop();
        _sum = 0d;
        _counter = 0;
    }

    function persistContext(context as Dictionary) {
        Field.persistContext(context);
        context["PowerAvgField.sum"] = _sum;
        context["PowerAvgField.counter"] = _counter;
        context["PowerAvgField.prevTimer"] = _prevTimer;
    }

    function restoreContext(workout as WorkoutInfo?, context as Dictionary) {
        Field.restoreContext(workout, context);
        _sum = context["PowerAvgField.sum"] as Double;
        _counter = context["PowerAvgField.counter"] as Number;
        _prevTimer = context["PowerAvgField.prevTimer"] as Number;
   }
}