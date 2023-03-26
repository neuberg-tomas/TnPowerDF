import Toybox.Activity;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

using Toybox.Application.Properties;

class Field {

    protected const NO_VALUE = "---";
    protected var _value as String = NO_VALUE;
    protected var _label as String = "";
    protected var _fonts as Array<Resource>;
    protected var _fontHeights as Array<Number>;
    protected var _lblFontHieght as Number;
    protected var _lblColor as Number;
    protected var _lblYPadding as Number;
    protected var _valueYPadding as Number;
    protected var _workout as WorkoutInfo?;

    function initialize(label as String) {
        _label = label;

        var fonts = [Rez.Fonts.NumNormal, Rez.Fonts.NumMedium, Rez.Fonts.NumSmall];
        _fonts = new Array<Resource>[fonts.size()];
        _fontHeights = new Array<Number>[fonts.size()];
        for (var i = 0; i < fonts.size(); i++) {
            _fonts[i] = WatchUi.loadResource(fonts[i]);
            _fontHeights[i] = Graphics.getFontHeight(_fonts[i]) - Graphics.getFontDescent(_fonts[i]);
        }
        _lblFontHieght = Graphics.getFontHeight(Graphics.FONT_XTINY) - Graphics.getFontDescent(Graphics.FONT_XTINY);
        _lblColor = Properties.getValue("labelColor") as Number;
        _lblYPadding = Properties.getValue("labelYPadding") as Number;
        _valueYPadding = Properties.getValue("valueYPadding") as Number;
    }

    function onLayout(dc as Dc) as Void {
    }

    function compute(info as Activity.Info, timer as Number?) as Void {
    }

    function onWorkoutStep(info as WorkoutInfo) as Void {
        System.println(System.getClockTime().sec.format("%02d") + ": " + _label + ".onWorkoutStep, workout=" + info);

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

    function draw(dc as Dc, x as Number, y as Number, w as Number, h as Number) as Void {
        dc.setColor(_lblColor, Graphics.COLOR_TRANSPARENT);
        if (_label != "") { 
            dc.drawText(x + w / 2, y - _lblYPadding, Graphics.FONT_XTINY, _label, Graphics.TEXT_JUSTIFY_CENTER);
        }

        //System.println(_label + ": " + _value);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        var fontIdx = _fonts.size() - 1;
        for (var i = 0; i < _fonts.size(); i++) {
            if (dc.getTextWidthInPixels(_value, _fonts[i]) <= w) {
                fontIdx = i;
                break;
            }
        }
        dc.drawText(x + w / 2, y + h - _fontHeights[fontIdx] - _valueYPadding, _fonts[fontIdx], _value, Graphics.TEXT_JUSTIFY_CENTER);
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