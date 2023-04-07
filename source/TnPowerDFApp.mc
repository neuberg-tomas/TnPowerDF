import Toybox.Application;
import Toybox.Activity;
import Toybox.Lang;
import Toybox.Math;
import Toybox.WatchUi;
using Toybox.Application.Properties as Prop;

typedef Numeric as Number or Float or Long or Double;

const _envF1 as Float = (9.80665 * 0.0289644) / (8.31432 * -0.0065);

class TnPowerDFApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    //! Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        return [ new TnPowerDFView() ] as Array<Views or InputDelegates>;
    }

    function getSettingsView() as Array<Views or InputDelegates>? {
        var menu = new SettingsMenu();
        return [ menu, new SettingsMenuDelegate(menu) ] as Array<Views or InputDelegates>;
    }
}

function getApp() as TnPowerDFApp {
    return Application.getApp() as TnPowerDFApp;
}

function abs(a as Numeric) as Numeric {
    return a < 0 ? -a : a;
}

function max(a as Numeric, b as Numeric) as Numeric {
    return a < b ? b : a;
}

function min(a as Numeric, b as Numeric) as Numeric {
    return a < b ? a : b;
}

function computeEnvCorrection(info as Activity.Info?) as Float {
    if (Prop.getValue("envCorrection")) {
        var b4 = Prop.getValue("envTestAlt").toNumber();
        var b6 = Prop.getValue("envTestTmp").toNumber();
        var b22 = 101325.0 * Math.pow((b6 + 273.15)/((b6 + 273.15)+(-0.0065 * b4)), _envF1) * 0.00750062;
        var b24 = (-174.1448622 + 1.0899959 * b22 + -1.5119 * 0.001 * Math.pow(b22, 2) + 0.72674 * Math.pow(10, -6) * Math.pow(b22, 3)) / 100.0;
        var b7 = Prop.getValue("envCurrTmp").toFloat();
        var b9 = Prop.getValue("envCurrHum").toFloat();

        var b8 = Prop.getValue("envTestHum").toFloat();
        var b34 = Math.ln( b8 / 100.0 * Math.pow(Math.E, (18.678 - b6/234.5)*( b6/(257.14+ b6))));
        var b36 = (257.14 * b34 / (18.678-b34)) * 1.8 + 32; 
        var b38 = (b36+b6*1.8+32) > 100 ? 0.001341 * Math.pow((b36+b6*1.8+32), 2) -0.249517 * Math.pow((b36+b6*1.8+32), 1) + 11.699986 : 0.0;

        var b35 = Math.ln(b9 / 100.0 * Math.pow(Math.E, (18.678 -b7/234.5)*(b7/(257.14+b7))));
        var b37 = (257.14 * b35 / (18.678-b35)) * 1.8 + 32;
        var b39 = (b37+b7*1.8+32) > 100 ? 0.001341 * Math.pow((b37+b7*1.8+32), 2) -0.249517 * Math.pow((b37+b7*1.8+32), 1) + 11.699986 : 0.0;

        var b5 = info != null && info.altitude != null && Prop.getValue("envCurrAltSensor") ? info.altitude : Prop.getValue("envCurrAlt").toFloat();
        var b23 = 101325 * Math.pow((b7 + 273.15)/((b7 + 273.15)+(-0.0065 * b5)), _envF1) * 0.00750062;
        var b25 = (-174.1448622 + 1.0899959 * b23 + -1.5119*0.001 * Math.pow(b23, 2) + 0.72674 * Math.pow(10, -6) * Math.pow(b23, 3)) / 100;
        var r = 1.0 - (b24 - b25) - (b39 - b38) / 100.0;
        
        /*
        System.println(Lang.format("env correction = $1$, alt $2$ -> $3$, temp $4$ -> $5$, humidity $6$ -> $7$", [
            r, Prop.getValue("envTestAlt"), b5.toNumber(), Prop.getValue("envTestTmp"), Prop.getValue("envCurrTmp"),
            Prop.getValue("envTestHum"), Prop.getValue("envCurrHum")
        ]));
        */
        return r;
    }
    return 1.0;
}
