import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

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
        return [ new SettingsMenu(), new SettingsMenuDelegate() ] as Array<Views or InputDelegates>;
    }
}

function getApp() as TnPowerDFApp {
    return Application.getApp() as TnPowerDFApp;
}
