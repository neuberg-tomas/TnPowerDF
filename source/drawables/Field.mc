import Toybox.Activity;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

using Toybox.Application.Properties;

class Field extends Drawable {

    protected const NO_VALUE = "---";
    protected var _value as String = NO_VALUE;
    protected var _label as String = "";
    protected var _x as Number, _y as Number, _width as Number, _height as Number;
    protected var _fonts as Array<Resource>;
    protected var _fontHeights as Array<Number>;
    protected var _lblFontHieght as Number;
    protected var _lblColor as Number;
    protected var _lblYOffset as Number;

    function initialize(params as Dictionary, label as String) {
        Drawable.initialize(params);
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
        _lblYOffset = Properties.getValue("labelYOffset") as Number;

        _x = params.get(:x) as Number;
        _y = params.get(:y) as Number;
        _width = params.get(:width) as Number;
        _height = params.get(:height) as Number;
    }

    function onLayout(dc as Dc) as Void {
    }

    function compute(info as Activity.Info) as Void {
    }

    function onWorkoutStep() as Void {
    }

    function draw(dc as Dc) as Void {
        dc.setColor(_lblColor, Graphics.COLOR_TRANSPARENT);
        if (_label != "") {
            dc.drawText(_x + _width / 2, _y + _lblYOffset, Graphics.FONT_XTINY, _label, Graphics.TEXT_JUSTIFY_CENTER);
        }

        //System.println(_label + ": " + _value);

        /*

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        var fontIdx = _fonts.size() - 1;
        for (var i = 0; i < _fonts.size(); i++) {
            if (dc.getTextWidthInPixels(_value, _fonts[i]) <= _width) {
                fontIdx = i;
                break;
            }
        }
        dc.drawText(_x + _width / 2, _y + _height - _fontHeights[fontIdx], _fonts[fontIdx], _value, Graphics.TEXT_JUSTIFY_CENTER);
        */
    }

    protected function formatTimeMs(time as Number) as String {
        time = time <= 0 ? 0 : time.toNumber() / 1000;
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