import Toybox.Activity;
import Toybox.Attention;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

using Toybox.Application.Properties;

class Field {

    protected const NO_VALUE = "---";
    protected var _value;
    protected var _label as String;
    protected var _fonts as Array<Resource>;
    protected var _fontHeights as Array<Number>;
    protected var _lblFontHieght as Number;
    protected var _lblColor as Number;
    protected var _lblYPadding as Number;
    protected var _valueYPadding as Number;
    protected var _workout as WorkoutInfo?;
    protected var _zone as Number?;
    protected var _zoneColor as Number?;
    protected var _zoneColorAsBg as Boolean;
    protected var _alert as Number;
    protected var _valueColor as Number;
    private var   _alertDelay as Number;
    private var   _alertNextPlay as Number;
    private var _initialized as Boolean?;

    function initialize(label as String) {
        _label = label;
        _value = NO_VALUE;
        
        _fonts = [
            WatchUi.loadResource(Rez.Fonts.NumNormal), 
            WatchUi.loadResource(Rez.Fonts.NumMedium), 
            WatchUi.loadResource(Rez.Fonts.NumSmall)
        ] as Array<Resource>;
        
        _fontHeights  = new Array<Number>[_fonts.size()];
        for (var i = 0; i < _fonts.size(); i++) {
            _fontHeights[i] = Graphics.getFontHeight(_fonts[i]) - Graphics.getFontDescent(_fonts[i]);
        }

        _lblFontHieght = Graphics.getFontHeight(Graphics.FONT_SYSTEM_XTINY) - Graphics.getFontDescent(Graphics.FONT_SYSTEM_XTINY);
        _lblColor = Properties.getValue("labelColor").toNumber();
        _lblYPadding = Properties.getValue("labelYPadding").toNumber();
        _valueYPadding = Properties.getValue("valueYPadding").toNumber();
        _valueColor = Properties.getValue("valueColor") as Number;

        _alert = 0;
        _alertDelay = 0;
        _alertNextPlay = 0;

        _zoneColorAsBg = Properties.getValue("zoneColorAsBg") as Boolean;

        _initialized = true;
    }

    function onLayout(dc as Dc) as Void {
    }

    function compute(info as Activity.Info, context as ComputeContext) as Void {
    }

    function onWorkoutStep(info as WorkoutInfo) as Void {
        _workout = info;
        onLap();
    }

    function onStart() as Void {
    }

    function onStop() as Void {
    }

    function onLap() as Void {
    }

    function persistContext(context as Dictionary) {
    }

    function restoreContext(workout as WorkoutInfo?, context as Dictionary) {
        _workout = workout;
    }

    protected function setZone(zone as Number?) as Void {
        if (zone == null) {
            _zone = null;
            _zoneColor = null;
            return;
        }
        if (zone < 1) {
            zone = 1;
        } else if (zone > 5) {
            zone = 5;
        }
        if (_zone == null || _zone != zone) {
            _zone = zone;
            _zoneColor = Properties.getValue("zone" + zone + "Color") as Number;
        }
    }

    protected function clearAlert() {
        setAlert(0, false, null);
    }

    protected function setAlert(alert as Number, sound as Boolean, context as ComputeContext?) as Void {
        if (alert != _alert) {
            _alert = alert;
            switch(alert) {
                case 1:
                    _valueColor = Properties.getValue("valueLoColor") as Number;
                    break;
                case 2:
                    _valueColor = Properties.getValue("valueHiColor") as Number;
                    break;
                default:
                    _valueColor = Properties.getValue("valueColor") as Number;
                    break;
            }
            _alertDelay = Properties.getValue("alertDelaySecMin") as Number;
            _alertNextPlay = 0;

            if (sound && alert == 0) {
               Attention.playTone({:toneProfile => [
                    new ToneProfile(400,  500),
                    new ToneProfile(0,  200)
                ], :repeatCount => 2});
            }
        }
        if (sound && alert > 0 && context != null && context.timer != null && context.timer >= _alertNextPlay) {
            playAlert(context.timer);
        }
    }

    private function playAlert(timer as Number) {
        if (_alert == 1) {
            Attention.playTone({:toneProfile=>[
                new ToneProfile(200,  400),
                new ToneProfile(900,  400),
                new ToneProfile(2800, 400)
            ]});
            Attention.vibrate([
                new VibeProfile(25, 400), new VibeProfile(50, 400), new VibeProfile(100, 400)
            ]);
        } else if (_alert == 2) {
            Attention.playTone({:toneProfile=>[
                new ToneProfile(2800,  400),
                new ToneProfile(900,  400),
                new ToneProfile(200, 400)
            ]});
            Attention.vibrate([
                new VibeProfile(100, 400), new VibeProfile(50, 400), new VibeProfile(25, 400)
            ]);
        }
        _alertNextPlay = timer + _alertDelay;
        _alertDelay = (_alertDelay * ((Properties.getValue("alertDelayMultiplier") as Number) / 100.0 + 1.0)).toNumber();
        var max = Properties.getValue("alertDelaySecMax") as Number;
        if (_alertDelay > max) {
            _alertDelay = max;
        }
    }

    function draw(dc as Dc, x as Number, y as Number, w as Number, h as Number) as Void {
        if (_initialized == null) {
            System.println(_label + ".draw: not initialized yet");
            return;
        }
        drawLabel(dc, x + w / 2, y, x, w);

        dc.setColor(_valueColor, Graphics.COLOR_TRANSPARENT);
        var fontIdx = getFontIdx(dc, _value, w, w);
        dc.drawText(x + w / 2, y + h - _fontHeights[fontIdx] - _valueYPadding, _fonts[fontIdx], _value, Graphics.TEXT_JUSTIFY_CENTER);
    }

    protected function drawLabel(dc as Dc, x as Number, y as Number, bgX as Number, bgW as Number) as Void {
        if (_label != "") { 
            if (_zoneColor != null) {
                if (_zoneColorAsBg) {
                    dc.setColor(_zoneColor, Graphics.COLOR_TRANSPARENT);
                    dc.fillRectangle(bgX, y, bgW, _lblFontHieght + 2);
                    dc.setColor(_lblColor, Graphics.COLOR_TRANSPARENT);
                } else {
                    dc.setColor(_zoneColor, Graphics.COLOR_TRANSPARENT);
                }
            } else {
                dc.setColor(_lblColor, Graphics.COLOR_TRANSPARENT);
            }
            dc.drawText(x, y - _lblYPadding, Graphics.FONT_SYSTEM_XTINY, _label, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    protected function getFontIdx(dc as Dc, text as String, width1 as Number, width2 as Number) {
        if (width1 == width2) {
            for (var i = 0; i < _fonts.size(); i++) {
                if (dc.getTextWidthInPixels(text, _fonts[i]) <= width1) {
                    return i;
                }
            }
        } else {
            var ws = width1;
            var wd = width2 - width1;
            if (wd < 0) {
                wd = -wd;
                ws = width2;
            }
            var fd = _fontHeights[0] - _fontHeights[_fontHeights.size() - 1];
            var w = ws;
            for (var i = 0; i < _fonts.size(); i++) {
                if (i > 0) {
                    w = ws + wd * (_fontHeights[0] - _fontHeights[i]) / fd;
                }
                if (dc.getTextWidthInPixels(text, _fonts[i]) <= w) {
                    return i;
                }
            }
        }
        return _fonts.size() - 1;
    }

    protected function formatTime(time as Number) as String {
        time = time <= 0 ? 0 : time.toNumber();
        var h = time / 3600;
        time %= 3600;
        var m = time / 60;
        var s = time % 60;
        return h > 0 ? 
            Lang.format("$1$:$2$:$3$", [
                h.format("%d"), m.format("%02d"), s.format("%02d")
            ]) :
            Lang.format("$1$:$2$", [
                m.format("%d"), s.format("%02d")
            ]);
    }

    protected function formatDistance(distance as Float) as String {
        return distance < 10 ? distance.format("%.2f") : distance.format("%.1f");
    }
}