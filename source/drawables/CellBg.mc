import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

using Toybox.Application.Properties as Prop;

class CellBg extends Drawable {

    private var _bgColor as Number, _lineColor as Number;
    private var _lineWidth as Number;
    private var _topHeight as Number, _leftWidth as Number;

    function initialize(params as Dictionary) {
        Drawable.initialize(params);

        _bgColor = Prop.getValue("colorBg");
        _lineColor = Prop.getValue("colorLines");
        _lineWidth = params.get(:lineWidth) as Number;
        _topHeight = params.get(:topHeight) as Number;
        _leftWidth = params.get(:leftWidth) as Number;
    }

    function draw(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var h2 = h / 2;
        var h3 = h - _topHeight;
        var w3 = w - _leftWidth;

        dc.setColor(_lineColor, _bgColor);
        dc.clear();
        dc.setPenWidth(_lineWidth);
        dc.drawLine(0, _topHeight, w, _topHeight);
        dc.drawLine(0, h2, w, h2);
        dc.drawLine(0, h3, w, h3);
        dc.drawLine(_leftWidth, _topHeight, _leftWidth, h3);
        dc.drawLine(w3, _topHeight, w3, h3);
    }
}