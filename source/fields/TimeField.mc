import Toybox.Activity;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

using Toybox.Application.Properties as Prop;

class TimeField extends Field {

    const LBL_REM = "T/Rem/Elap";
    const LBL_LAP = "T/Lap/Elap";

    private var _elapsedTime as String = "";
    private var _time as String = "";
    private const _valueMutedColor as Number = Prop.getValue("valueMutedColor") as Number;
    private var _remValuePerc as Number?;

    function initialize() {
        Field.initialize(LBL_LAP);
    }

    function compute(info as Activity.Info, context as ComputeContext) as Void {
        Field.compute(info, context);
        if (_workout == null) {
            _value = NO_VALUE;
            _label = LBL_LAP;
            _remValuePerc = null;
        } else if (_workout.stepDurationType == Activity.WORKOUT_STEP_DURATION_TIME) {
            var v = _workout.stepDuration - (context.timer - _workout.stepStartTime) / 1000;
            if (v < 0) {
                v = 0;
            } else if (v > 100) {
                v = 100;
            }
            _label = LBL_REM;
            _value = formatTime(v);
            _remValuePerc =  _workout.stepDuration > 0 ? v * 100 / _workout.stepDuration : null;
        } else {
            _value = formatTime((context.timer - _workout.stepStartTime) / 1000);
            _label = LBL_LAP;
            _remValuePerc = null;
        }

        _elapsedTime = formatTime(context.timer / 1000);

        var clock = System.getClockTime();
        _time = Lang.format("$1$:$2$", [
            clock.hour.format("%02d"),
            clock.min.format("%02d")
        ]);
    }

    function onStop() as Void {
        Field.onStop();
        _elapsedTime = "";
    }

    function draw(dc as Dc, x as Number, y as Number, w as Number, h as Number) as Void {
        if (_fontHeights == null || _fontHeights[0] == null) {
            System.println(_label + ".draw: _fontHeights: " + _fontHeights);
            return;
        }

        var w2 = w / 2;
        var fw2 = Math.round(w * 0.35).toNumber();
        var fw1 = Math.round((w2 - fw2 / 2) * 0.7);
        var xo = w2 - fw2 / 2 - fw1 - Math.round(w * 0.015);

        if (_remValuePerc != null) {
            var sw2 = dc.getWidth() / 2;
            var sh2 = dc.getHeight() / 2;
            var pw = Math.round(dc.getWidth() * 0.025).toNumber();
            var r = sw2 - pw / 2;
            dc.setPenWidth(pw);
            sw2--;
            sh2--;
            var ab = 230;
            var ae = 310;
            var av = ab + (ae - ab) * (100 - _remValuePerc) / 100;
            if (av > ab) {
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.drawArc(sw2, sh2, r, Graphics.ARC_COUNTER_CLOCKWISE, ab, av);
            }
            if (av < ae) {
                dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
                dc.drawArc(sw2, sh2, r, Graphics.ARC_COUNTER_CLOCKWISE, av, ae);
            }
        }

        dc.setColor(_lblColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x + w2, y + _fontHeights[0], Graphics.FONT_XTINY, _label, Graphics.TEXT_JUSTIFY_CENTER);

        var pf = 0.1;

        dc.setColor(_valueMutedColor, Graphics.COLOR_TRANSPARENT);
        var fi = getFontIdx(dc, _time, fw1);
        if (fi == 0) {
            fi++;
        }
        var fyo = (_fontHeights[fi] * pf).toNumber();
        dc.drawText(x + xo + fw1, y - fyo, _fonts[fi], _time, Graphics.TEXT_JUSTIFY_RIGHT);

        fi = getFontIdx(dc, _elapsedTime, fw1);
        if (fi == 0) {
            fi++;
        }
        fyo = (_fontHeights[fi] * pf).toNumber();
        dc.drawText(x + w - fw1 - xo, y - fyo, _fonts[fi], _elapsedTime, Graphics.TEXT_JUSTIFY_LEFT);

        dc.setColor(_valueColor, Graphics.COLOR_TRANSPARENT);
        fi = getFontIdx(dc, _value, fw2);
        fyo = (_fontHeights[fi] * pf).toNumber();
        dc.drawText(x + w2, y - fyo, _fonts[fi], _value, Graphics.TEXT_JUSTIFY_CENTER);      
    }
}