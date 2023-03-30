import Toybox.Activity;
import Toybox.Attention;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

using Toybox.Application.Properties;

class Field {

    protected const NO_VALUE = "---";
    protected var _value as String = NO_VALUE;
    protected var _label as String = "";
    protected const _fonts as Array<Resource> = [
        WatchUi.loadResource(Rez.Fonts.NumNormal), 
        WatchUi.loadResource(Rez.Fonts.NumMedium), 
        WatchUi.loadResource(Rez.Fonts.NumSmall)
        ] as Array<Resource>;
    protected const _fontHeights as Array<Number> = [
        Graphics.getFontHeight(_fonts[0]) - Graphics.getFontDescent(_fonts[0]),
        Graphics.getFontHeight(_fonts[1]) - Graphics.getFontDescent(_fonts[1]),
        Graphics.getFontHeight(_fonts[2]) - Graphics.getFontDescent(_fonts[2])
    ] as Array<Number>;
    protected const _lblFontHieght as Number = Graphics.getFontHeight(Graphics.FONT_XTINY) - Graphics.getFontDescent(Graphics.FONT_XTINY);
    protected const _lblColor as Number = Properties.getValue("labelColor") as Number;
    protected const _lblYPadding as Number = Properties.getValue("labelYPadding") as Number;
    protected const _valueYPadding as Number = Properties.getValue("valueYPadding") as Number;
    protected var _workout as WorkoutInfo?;
    protected var _zone as Number?;
    protected var _zoneColor as Number?;
    protected const _zoneColorAsBg as Boolean = Properties.getValue("zoneColorAsBg") as Boolean;
    protected var _alert as Number = 0;
    protected var _valueColor as Number = Properties.getValue("valueColor") as Number;
    private var   _alertDelay as Number = 0;
    private var   _alertNextPlay as Number = 0;

    function initialize(label as String) {
        _label = label;
    }

    function onLayout(dc as Dc) as Void {
    }

    function compute(info as Activity.Info, context as ComputeContext) as Void {
    }

    function onWorkoutStep(info as WorkoutInfo) as Void {
        System.println(System.getClockTime().sec.format("%02d") + ": " + _label + ".onWorkoutStep, workout=" + info.dump());

        _workout = info;
        onLap();
    }

    function onStart() as Void {
        System.println(System.getClockTime().sec.format("%02d") + ": " + _label + ".onStart");
    }

    function onStop() as Void {
        System.println(System.getClockTime().sec.format("%02d") + ": " + _label + ".onStop");
    }

    function onLap() as Void {
        System.println(System.getClockTime().sec.format("%02d") + ": " + _label + ".onLap");
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
                    new ToneProfile(0,  300)
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
                new ToneProfile(400,  400),
                new ToneProfile(900,  400),
                new ToneProfile(1400, 400)
            ]});
            Attention.vibrate([
                new VibeProfile(100, 1000), new VibeProfile(0, 750), new VibeProfile(100, 1000)
            ]);
        } else if (_alert == 2) {
            Attention.playTone({:toneProfile=>[
                new ToneProfile(1400,  400),
                new ToneProfile(900,  400),
                new ToneProfile(400, 400)
            ]});
            Attention.vibrate([
                new VibeProfile(100, 1500)
            ]);
        }
        _alertNextPlay = timer + _alertDelay * 1000;
        _alertDelay = (_alertDelay * ((Properties.getValue("alertDelayMultiplier") as Number) / 100.0 + 1.0)).toNumber();
        var max = Properties.getValue("alertDelaySecMax") as Number;
        if (_alertDelay > max) {
            _alertDelay = max;
        }
    }

    function draw(dc as Dc, x as Number, y as Number, w as Number, h as Number) as Void {
        if (_lblColor == null) {
            System.println(_label + ".draw: _lblColor is null !!!");
            return;
        }
        drawLabel(dc, x + w / 2, y, x, w);

        dc.setColor(_valueColor, Graphics.COLOR_TRANSPARENT);
        var fontIdx = getFontIdx(dc, _value, w);
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
            dc.drawText(x, y - _lblYPadding, Graphics.FONT_XTINY, _label, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    protected function getFontIdx(dc as Dc, text as String, width as Number) {
        for (var i = 0; i < _fonts.size(); i++) {
            if (dc.getTextWidthInPixels(text, _fonts[i]) <= width) {
                return i;
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
}