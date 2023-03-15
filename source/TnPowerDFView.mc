import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
using Toybox.WatchUi as Ui;

class TnPowerDFView extends Ui.DataField {

    hidden var mValue as Numeric;
    hidden var w as Number = 0;
    hidden var h as Number = 0;
    var numNormalFont = Ui.loadResource(Rez.Fonts.NumNormal);

    function initialize() {
        DataField.initialize();
        mValue = 0.0f;
    }

    public function onLayout( dc as Dc ) as Void {
        setLayout( $.Rez.Layouts.MainLayout( dc ) );
        w = dc.getWidth();
        h = dc.getHeight();

        var v = findDrawableById("metricR1C2") as SimpleValue;
        v.onLayout(dc);
        v.setLabel("Pwr");
    }

    function compute(info as Activity.Info) as Void {

    }

    function onUpdate(dc as Dc) as Void {

        (findDrawableById("metricR1C2") as SimpleValue).setValue("888");

        View.onUpdate( dc );

   
    /*
        var tdm = dc.getTextDimensions("000", numNormalFont);
        var fcm = Graphics.getFontDescent(numNormalFont) - 4;

        var tds = dc.getTextDimensions("000", Graphics.FONT_SMALL);
        var fcs = Graphics.getFontDescent(Graphics.FONT_SMALL) - 4;

        var tdxt = dc.getTextDimensions("0", Graphics.FONT_XTINY);
        var fcxt = Graphics.getFontDescent(Graphics.FONT_XTINY);



        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);

        var info = Activity.getActivityInfo();
        var eTime = info.timerTime / 1000;

        dc.drawText(w / 2 - tdm[0] / 2 - tds[0] / 3, h1 - tds[1] + fcs, Graphics.FONT_SMALL, eTime.format("%d"), 
            Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(w / 2, h1 - tdm[1] + fcm, numNormalFont, "311", 
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(w / 2 + tdm[0] / 2 + tds[0] / 3, h1 - tds[1] + fcs, Graphics.FONT_SMALL, "323", 
            Graphics.TEXT_JUSTIFY_LEFT);

        dc.drawText(w1 - 6, h2 - tdm[1] + fcm, numNormalFont, "182", 
            Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(w / 2, h2 - tdm[1] + fcm, numNormalFont, "315", 
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(w3 + 6, h2 - tdm[1] + fcm, numNormalFont, "318", 
            Graphics.TEXT_JUSTIFY_LEFT);

        dc.drawText(w1 - 6, h3 - tdm[1] + fcm, numNormalFont, "5:23", 
            Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(w / 2, h3 - tdm[1] + fcm, numNormalFont, "25.3", 
            Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(w3 + 6, h3 - tdm[1] + fcm, numNormalFont, "12.5", 
            Graphics.TEXT_JUSTIFY_LEFT);

        dc.drawText(w1 - 6, h3 + 3, Graphics.FONT_XTINY, "20:45", 
            Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(w / 2, h3 + 3, Graphics.FONT_SMALL, "1:10:00", 
            Graphics.TEXT_JUSTIFY_CENTER);      
        dc.drawText(w3 + 6, h3 + 3, Graphics.FONT_XTINY, "3:45:00", 
            Graphics.TEXT_JUSTIFY_LEFT);


        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);

        dc.drawText(w/2, 10, Graphics.FONT_XTINY, "Pwr", Graphics.TEXT_JUSTIFY_CENTER);

        dc.drawText(w1/2, h1, Graphics.FONT_XTINY, "HR 5", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(w/2, h1, Graphics.FONT_XTINY, "Lap pwr", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(w - w1/2, h1, Graphics.FONT_XTINY, "Avg pwr", Graphics.TEXT_JUSTIFY_CENTER);

        dc.drawText(w1/2, h2, Graphics.FONT_XTINY, "Avg pace", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(w/2, h2, Graphics.FONT_XTINY, "Dist", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(w - w1/2, h2, Graphics.FONT_XTINY, "Step dist", Graphics.TEXT_JUSTIFY_CENTER);

        dc.drawText(w/2, h - 8 - tds[1] + fcs, Graphics.FONT_XTINY, "T/Rem/Elap", Graphics.TEXT_JUSTIFY_CENTER);


        dc.setPenWidth(5);
        dc.setColor(Graphics.COLOR_PINK, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(w/2, h/2, w / 2 - 6, Graphics.ARC_COUNTER_CLOCKWISE, 50, 70);
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(w/2, h/2, w / 2 - 6, Graphics.ARC_COUNTER_CLOCKWISE, 70, 110);
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(w/2, h/2, w / 2 - 6, Graphics.ARC_COUNTER_CLOCKWISE, 110, 130);

        dc.setPenWidth(10);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(w/2, h/2, w / 2 - 8, Graphics.ARC_COUNTER_CLOCKWISE, 80, 82);

        dc.setPenWidth(5);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(w/2, h/2, w / 2 - 6, Graphics.ARC_COUNTER_CLOCKWISE, 230, 300);
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(w/2, h/2, w / 2 - 6, Graphics.ARC_COUNTER_CLOCKWISE, 300, 310);
    */
    
    }
}
