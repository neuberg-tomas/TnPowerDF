import Toybox.Activity;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

using Toybox.Application.Properties as Prop;

class TimeField extends Field {

    const LBL_REM = "T/Rem/Elp";
    const LBL_LAP = "T/Lap/Elp";

    private var _elapsedTime as String;
    private var _time as String;
    private var _valueMutedColor as Number;
    private var _remValuePerc as Number?;
    private var _initialized as Boolean?;

    function initialize() {
        Field.initialize(LBL_LAP);
        _elapsedTime = "";
        _time = "";
        _valueMutedColor = Prop.getValue("valueMutedColor") as Number;
        _initialized = true;
    }

    function compute(info as Activity.Info, context as ComputeContext) as Void {
        Field.compute(info, context);
        if (_workout == null) {
            _value = NO_VALUE;
            _label = LBL_LAP;
            _remValuePerc = null;
        } else if (_workout.stepDurationType == Activity.WORKOUT_STEP_DURATION_TIME) {
            var v = _workout.stepDuration - (context.timer - _workout.stepStartTime);
            if (v < 0) {
                v = 0;
            }
            _label = LBL_REM;
            _value = formatTime(v);
            _remValuePerc =  _workout.stepDuration > 0 ? v * 100 / _workout.stepDuration : null;
            if (_remValuePerc > 100) {
                _remValuePerc = 100;
            }
        } else {
            _value = formatTime(context.timer - _workout.stepStartTime);
            _label = LBL_LAP;
            _remValuePerc = null;
        }

        _elapsedTime = formatTime(context.timer);

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
        if (_initialized == null) {
            System.println(_label + ".draw: not initialized yet");
            return;
        }

        var w2 = w / 2;
        var fw2 = Math.round(w * 0.35).toNumber();

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
            var av = Math.round(ab + (ae - ab) * (100 - _remValuePerc) / 100).toNumber();
            if (av > ab) {
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.drawArc(sw2, sh2, r, Graphics.ARC_COUNTER_CLOCKWISE, ab, av);
            }
            if (av < ae) {
                dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
                dc.drawArc(sw2, sh2, r, Graphics.ARC_COUNTER_CLOCKWISE, av, ae);
            }
        }

        dc.setColor(_lblColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x + w2, y + _fontHeights[0] - _lblYPadding, Graphics.FONT_XTINY, _label, Graphics.TEXT_JUSTIFY_CENTER);

        var pf = 0.13;

        var fw1 = Math.round((w2 - fw2 / 2) * 0.92);
        var fw1Bottom = (fw1 * 0.55).toNumber();
        var xo = w2 - fw2 / 2 - fw1 - Math.round(w * 0.016);

        dc.setColor(_valueMutedColor, Graphics.COLOR_TRANSPARENT);
        var fi = getFontIdx(dc, _time, fw1, fw1Bottom);
        var fyo = (_fontHeights[fi] * pf).toNumber();
        dc.drawText(x + xo + fw1, y - fyo, _fonts[fi], _time, Graphics.TEXT_JUSTIFY_RIGHT);

        fi = getFontIdx(dc, _elapsedTime, fw1, fw1Bottom);
        fyo = (_fontHeights[fi] * pf).toNumber();
        dc.drawText(x + w - fw1 - xo, y - fyo, _fonts[fi], _elapsedTime, Graphics.TEXT_JUSTIFY_LEFT);

/*
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        fyo = (_fontHeights[0] * pf).toNumber();
        dc.drawLine(x + w - fw1 - xo, y - fyo, x + w - fw1 - xo + fw1 , y - fyo);
        dc.drawLine(x + w - fw1 - xo, y - fyo + _fontHeights[0], x + w - fw1 - xo + fw1Bottom , y - fyo + _fontHeights[0]);
*/
        dc.setColor(_valueColor, Graphics.COLOR_TRANSPARENT);
        fi = getFontIdx(dc, _value, fw2, fw2);
        fyo = (_fontHeights[fi] * pf).toNumber();
        dc.drawText(x + w2, y - fyo, _fonts[fi], _value, Graphics.TEXT_JUSTIFY_CENTER);      
    }
}