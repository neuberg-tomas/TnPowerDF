import Toybox.Activity;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

using Toybox.Application.Properties as Prop;

class PowerField extends Field {

    const LBL = "Pwr";
    private var _nextTargetColor as Number;
    private var _valueMutedColor as Number;
    private var _gaugeColor as Number;

    private var _almostFinish as Boolean;
    private var _power as Number?;
    private var _initialized as Boolean?;
    private const _maxAvgDuration as Number = 30;
    private var _values as Array<Number> = new Array<Number>[_maxAvgDuration];
    private var _valueIdx1 as Number = 0;
    private var _valueIdx2 as Number = 0;
    private var _valuesSum as Number = 0;

    function initialize() {
        Field.initialize(LBL);
        
        _almostFinish = false;
        _nextTargetColor = Prop.getValue("nextTargetColor").toNumber();
        _valueMutedColor = Prop.getValue("valueMutedColor").toNumber();
        _gaugeColor = Prop.getValue("valueColor").toNumber();
        reset();
        
        _initialized = true;
    }

    function compute(info as Activity.Info, context as ComputeContext) as Void {
        Field.compute(info, context);       
        var v = info.currentPower == null ? null : Math.round(info.currentPower / context.envCorrection).toNumber();
        _almostFinish = _workout != null && _workout.almostFinishTime != null && context.timer >= _workout.almostFinishTime;
        var avgDuration = $.min(_maxAvgDuration, Prop.getValue("pwrAveraging") as Number);
        _label = avgDuration > 0 ? avgDuration + "s " + LBL : LBL;
        if (v == null) {
            reset();
        } else {
            if (avgDuration > 0) {
                _valueIdx2 = (_valueIdx2 + 1) % _maxAvgDuration;
                _values[_valueIdx2] = v;
                _valuesSum += v;
                var aDur = _valueIdx2 - _valueIdx1 + 1;
                if (aDur < 0) {
                    aDur += _maxAvgDuration;
                }
                while (aDur > avgDuration) {
                    _valuesSum -= _values[_valueIdx1];
                    aDur--;
                    _valueIdx1 = (_valueIdx1 + 1) % _maxAvgDuration;
                }
                _power = Math.round(_valuesSum.toFloat() / aDur).toNumber();
            } else {
                _valueIdx1 = 0;
                _valueIdx2 = -1;
                _valuesSum = 0;
                _power = v;
            }
            _value = _power.format("%d");
            var zone = context.getPowerZone(_power);
            setZone(zone);
            if (zone != null) {
                _label += " " + zone;
            }
            if (_workout != null && _workout.stepTargetType == Activity.WORKOUT_STEP_TARGET_POWER) {
                setAlert(_power < _workout.stepLo ? 1 : _power > _workout.stepHi ? 2 : 0, Prop.getValue("alertType") == 2, context);
            } else {
                clearAlert();
            }
        }
    }

    function onStart() as Void {
        reset();
        _label = LBL;
    }

    private function reset() as Void {
        _valueIdx1 = 0;
        _valueIdx2 = -1;
        _valuesSum = 0;
        _power = null;
        _value = NO_VALUE;
        setZone(null);
        clearAlert();
    }


    function draw(dc as Dc, x as Number, y as Number, w as Number, h as Number) as Void {
        if (_initialized == null) {
            System.println(_label + ".draw: not initialized yet");
            return;
        }

        var w2 = w / 2;
        var fw2 = Math.round(w * 0.35).toNumber();

        drawLabel(dc, x + w2, y + h - _fontHeights[0] - _lblFontHieght - _valueYPadding, x + w2 - fw2 / 2, fw2);

        var lo = "", hi = "";

        if (_workout != null) {

            if (_workout.isSet() && _workout.stepTargetType == Activity.WORKOUT_STEP_TARGET_POWER && _power != null) {

                var sw2 = dc.getWidth() / 2;
                var sh2 = dc.getHeight() / 2;
                var pw = Math.round(dc.getWidth() * 0.03).toNumber();
                var r = sw2 - pw / 2;
                dc.setPenWidth(pw);
                sw2--;
                sh2--;

                var a0 = 45, a1 = 70, a2 = 110, a3 = 135;
                var vlo = _workout.stepLo;
                var vhi = _workout.stepHi;
                var range = vhi - vlo;
                if (range < 20) {
                    range = 20;
                }
                var min = vlo - range;
                if (min < 0) {
                    min = 0;
                }
                var max = vhi + range;
                var a = _power <= min ? a3 + 5 : 
                    _power <= vlo ? a3 - (a3 - a2) * (_power - min) / (vlo - min) :
                    _power <= vhi ? a2 - (a2 - a1) * (_power - vlo) / (vhi - vlo) :
                    _power <= max ? a1 - (a1 - a0) * (_power - vhi) / (max - vhi) : 
                    a0 - 5;


                dc.setPenWidth(pw);
                dc.setColor(Graphics.COLOR_PINK, Graphics.COLOR_TRANSPARENT);
                dc.drawArc(sw2, sh2, r, Graphics.ARC_COUNTER_CLOCKWISE, a0, a1);
                dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
                dc.drawArc(sw2, sh2, r, Graphics.ARC_COUNTER_CLOCKWISE, a1, a2);
                dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
                dc.drawArc(sw2, sh2, r, Graphics.ARC_COUNTER_CLOCKWISE, a2, a3);

                dc.setPenWidth(pw * 2);
                dc.setColor(_gaugeColor, Graphics.COLOR_TRANSPARENT);
                dc.drawArc(sw2, sh2, r - pw / 2, Graphics.ARC_COUNTER_CLOCKWISE, a-1, a+1);

            }                        

            if (_workout.stepNextTargetType != null && _workout.stepNextTargetType == Activity.WORKOUT_STEP_TARGET_POWER && _almostFinish) {
                lo = _workout.stepNextLo.format("%d");
                hi = _workout.stepNextHi.format("%d");
                dc.setColor(_nextTargetColor, Graphics.COLOR_TRANSPARENT);
            } else if (_workout.isSet() && _workout.stepTargetType == Activity.WORKOUT_STEP_TARGET_POWER) {
                lo = _workout.stepLo.format("%d");
                hi = _workout.stepHi.format("%d");
                dc.setColor(_valueMutedColor, Graphics.COLOR_TRANSPARENT);
            }
        }


        if (lo != "") {
            var fw1 = Math.round((w2 - fw2 / 2) * 0.82);
            var fw1Top = (fw1 * 0.55).toNumber();
            var xo = w2 - fw2 / 2 - fw1 - Math.round(w * 0.016);

            var fi = getFontIdx(dc, lo, fw1Top, fw1);
            dc.drawText(x + xo + fw1, y + h - _fontHeights[fi] - _valueYPadding, _fonts[fi], lo, Graphics.TEXT_JUSTIFY_RIGHT);

            fi = getFontIdx(dc, hi, fw1Top, fw1);
            dc.drawText(x + w - fw1 - xo, y + h - _fontHeights[fi] - _valueYPadding, _fonts[fi], hi, Graphics.TEXT_JUSTIFY_LEFT);
/*
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(x + w - fw1 - xo, y + h - _fontHeights[0] - _valueYPadding, x + w - fw1 - xo + fw1Top, y + h - _fontHeights[0] - _valueYPadding);
            dc.drawLine(x + w - fw1 - xo, y + h - _valueYPadding, x + w - fw1 - xo + fw1, y + h -_valueYPadding);
*/
        }

        dc.setColor(_valueColor, Graphics.COLOR_TRANSPARENT);
        var fi = getFontIdx(dc, _value, fw2, fw2);
        dc.drawText(x + w2, y + h - _fontHeights[fi] - _valueYPadding, _fonts[fi], _value, Graphics.TEXT_JUSTIFY_CENTER);      

    }
}