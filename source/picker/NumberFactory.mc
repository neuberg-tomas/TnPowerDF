import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class NumberFactory extends PickerFactory {
    private var _start as Number;
    private var _stop as Number;
    private var _increment as Number;
    private var _formatString as String;
    private var _font as FontDefinition;
    private var _size as Number;
    private var _zeroIdx as Number?;

    public function initialize(start as Number, stop as Number, increment as Number, options as {
        :font as FontDefinition,
        :format as String
    }) {
        PickerFactory.initialize();

        _start = start;
        _stop = stop;
        _increment = increment;

        var format = options.get(:format);
        if (format != null) {
            _formatString = format;
        } else {
            _formatString = "%d";
        }

        var font = options.get(:font);
        if (font != null) {
            _font = font;
        } else {
            _font = Graphics.FONT_NUMBER_MEDIUM;
        }

        _size = (_stop - _start) / _increment + (_start < 0 ? 2 : 1);
        _zeroIdx = _start >= 0 ? null : -_start;
    }

    public function getIndex(value as Number, wholeValue as Number) as Number {
        var idx = (value / _increment) - _start;
        return _zeroIdx == null || value < 0 ? idx : value == 0 && wholeValue < 0 ? _zeroIdx : idx + 1;
    }

    public function getDrawable(index as Number, selected as Boolean) as Drawable? {
        var value = getValue(index);
        var text = "No item";
        if (value instanceof Number) {
            text = value.format(_formatString);
        } else if (value == '-') {
            text = "-0";
        }
        return new WatchUi.Text({:text=>text, :color=>Graphics.COLOR_WHITE, :font=>_font,
            :locX=>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_CENTER});
    }

    public function getValue(index as Number) as Object? {
        var v = _start + (index * _increment);
        return _zeroIdx == null || index < _zeroIdx ? v : index == _zeroIdx ? '-' : v - 1;
    }


    public function getSize() as Number {
        return _size;
    }

}