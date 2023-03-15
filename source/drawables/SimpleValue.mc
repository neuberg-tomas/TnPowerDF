import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

using Toybox.Application.Properties as Prop;

class SimpleValue extends Drawable {

    private var _value as String = "---";
    private var _label as String = "";
    private var _x as Number, _y as Number, _width as Number, _height as Number;
    private var _fonts as Array<Resource>;
    private var _fontHeights as Array<Number>;
    private var _fontIdx as Number = -1;
    private var _lblFontHieght as Number;
    private var _labelColor as Number;

    function initialize(params as Dictionary) {
        Drawable.initialize(params);

       _labelColor = Prop.getValue("colorLabel");
 
        var fonts = [Rez.Fonts.NumNormal, Rez.Fonts.NumMedium, Rez.Fonts.NumSmall];
        _fonts = new Array<Resource>[fonts.size()];
        _fontHeights = new Array<Number>[fonts.size()];
        for (var i = 0; i < fonts.size(); i++) {
            _fonts[i] = WatchUi.loadResource(fonts[i]);
            _fontHeights[i] = Graphics.getFontHeight(_fonts[i]) - Graphics.getFontDescent(_fonts[i]);
        }
        _lblFontHieght = Graphics.getFontHeight(Graphics.FONT_XTINY) - Graphics.getFontDescent(Graphics.FONT_XTINY);

        _x = params.get(:x) as Number;
        _y = params.get(:y) as Number;
        _width = params.get(:width) as Number;
        _height = params.get(:height) as Number;
    }

    function onLayout(dc as Dc) as Void {
        _fontIdx = -1;
    }

    function setValue(value as String or Number) {
        _value = value.toString();
        _fontIdx = -1;
    }

    function setLabel(value as String) {
        _label = value;
    }

    function draw(dc as Dc) as Void {
        if (_label != "") {
            dc.setColor(_labelColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(_x + _width / 2, _y - _lblFontHieght - 2, Graphics.FONT_XTINY, _label, Graphics.TEXT_JUSTIFY_CENTER);
        }

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        if (_fontIdx < 0) {
            _fontIdx = _fonts.size() - 1;
            for (var i = 0; i < _fonts.size(); i++) {
                if (dc.getTextWidthInPixels(_value, _fonts[i]) <= _width) {
                    _fontIdx = i;
                    break;
                }
            }
        }
        dc.drawText(_x + _width / 2, _y + _height - _fontHeights[_fontIdx], _fonts[_fontIdx], _value, Graphics.TEXT_JUSTIFY_CENTER);
    }
}