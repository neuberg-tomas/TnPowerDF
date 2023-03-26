import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
using Toybox.WatchUi as Ui;
using Toybox.Application.Properties as Prop;

class TnPowerDFView extends Ui.DataField {

    private var _fields as Array<Field> = [
        new PowerField(),
        new HRField(), new PowerLapField(), new PowerAvgField(),
        new PaceAvgField(), new DistField(), new DistLapField(),
        new TimeField()
    ] as Array<Field>;

    private var _workout as WorkoutInfo?;

    private var _bgColor as Number, _lineColor as Number;
    private var _lineWidth as Number = 1;
    private var _timer as Number = 0;
    private var _timerActive as Boolean = false;

    function initialize() {
        DataField.initialize();

        _bgColor = Prop.getValue("colorBg");
        _lineColor = Prop.getValue("colorLines");
    }

    function compute(info as Activity.Info) as Void {     
        if (_timerActive) {
            _timer += 1000;
        }
        if (_workout != null && _workout.isSet() && Activity.getCurrentWorkoutStep() == null) {
            onWorkoutStepComplete();
        }

        for (var i = 0; i < _fields.size(); i++) {
            _fields[i].compute(info, _timer);
        }
    }

    function onWorkoutStarted() as Void {
        _workout = new WorkoutInfo(_timer, Activity.getCurrentWorkoutStep(), Activity.getNextWorkoutStep());
        for (var i = 0; i < _fields.size(); i++) {
            _fields[i].onWorkoutStep(_workout);
        }
    }

    function onWorkoutStepComplete() as Void {
        _workout = new WorkoutInfo(_timer, Activity.getCurrentWorkoutStep(), Activity.getNextWorkoutStep());
        System.println("******** stepComplete: " + _workout.dump());
        for (var i = 0; i < _fields.size(); i++) {
            _fields[i].onWorkoutStep(_workout);
        }
    }

    function onTimerLap() as Void {
        System.println("******** lap");
        for (var i = 0; i < _fields.size(); i++) {
            _fields[i].onLap();
        }
    }

    function onTimerStart() as Void {
        _timer = 0;
        _timerActive = true;
        for (var i = 0; i < _fields.size(); i++) {
            _fields[i].onStart();
        }
    }

    function onTimerStop() as Void {
        _timerActive = false;
        for (var i = 0; i < _fields.size(); i++) {
            _fields[i].onStop();
        }
    }

    function onTimerPause() as Void {
        _timerActive = false;
    }

    function onTimerResume() as Void {
        _timerActive = true;
    }


    function onUpdate(dc as Dc) as Void {
        dc.setColor(_lineColor, _bgColor);
        dc.setPenWidth(_lineWidth);
        dc.clear();

        var w = dc.getWidth();
        var h = dc.getHeight();

        var h1 = (h / 4 * 1.1).toNumber();
        var h2 = h / 2;
        var h3 = h - h1;
        var wo = Math.round(w * 0.04).toNumber();
        var w1 = Math.round(w * 0.34).toNumber();

        dc.drawLine(wo, h1, w - wo, h1);
        dc.drawLine(0, h2, w, h2);
        dc.drawLine(wo, h3, w - wo, h3);
        dc.drawLine(w1, h1, w1, h3);
        dc.drawLine(w - w1, h1, w - w1, h3);

        var fw1 = w - 2 * wo - 1;
        var fw2_1 = w1 - wo - 1;
        var fw2_2 = w - w1 * 2 - 1;
        var fh1 = h1 - 1;
        var fh2 = h2 - h1 - 1;
        


        _fields[0].draw(dc, wo, 0, fw1, fh1);

        _fields[1].draw(dc, wo, h1 + 1, fw2_1, fh2);
        _fields[2].draw(dc, w1 + 1, h1 + 1, fw2_2, fh2);
        _fields[3].draw(dc, w - w1 + 1, h1 + 1, fw2_1, fh2);

        _fields[4].draw(dc, wo, h2 + 1, fw2_1, fh2);
        _fields[5].draw(dc, w1 + 1, h2 + 1, fw2_2, fh2);
        _fields[6].draw(dc, w - w1 + 1, h2 + 1, fw2_1, fh2);

        _fields[7].draw(dc, wo, h3 + 1, fw1, fh1);
    }

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
    
    
    }
    */
}