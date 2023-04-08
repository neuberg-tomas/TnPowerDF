import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

const alertTypeLabels as Array<String> = ["Disabled", "Lap power", "Current power"] as Array<String>;
const pwrAvgLabels as Dictionary<Number, String> = {
    0 => WatchUi.loadResource(Rez.Strings.settingPwrAveraging0),
    3 => WatchUi.loadResource(Rez.Strings.settingPwrAveraging3),
    5 => WatchUi.loadResource(Rez.Strings.settingPwrAveraging5),
    30 => WatchUi.loadResource(Rez.Strings.settingPwrAveraging30)
} as Dictionary<Number, String>;

class SettingsMenu extends Menu2 {
    function initialize() {
        Menu2.initialize({:title => "Settings"});

        var opts = {};

        addItem(new MenuItem("Real temperature", Properties.getValue("envCurrTmp").toString() + " °C", :mnuEnvCurrTmp, opts));
        addItem(new MenuItem("Real humidity", Properties.getValue("envCurrHum").toString() + " %", :mnuEnvCurrHum, opts));
        addItem(new MenuItem("Real altitude", Properties.getValue("envCurrAlt").toString() + " m", :mnuEnvCurrAlt, opts));
        addItem(new ToggleMenuItem("Use altitude sensor", null, :mnuEnvAltSensor,
            Properties.getValue("envCurrAltSensor"), opts));

        addItem(new MenuItem("Test temperature", Properties.getValue("envTestTmp").toString() + " °C", :mnuEnvTestTmp, opts));
        addItem(new MenuItem("Test humidity", Properties.getValue("envTestHum").toString() + " %", :mnuEnvTestHum, opts));
        addItem(new MenuItem("Test altitude", Properties.getValue("envTestAlt").toString() + " m", :mnuEnvTestAlt, opts));

        addItem(new ToggleMenuItem("Env. adjustment", null, :mnuEnvCorrection,
            Properties.getValue("envCorrection"), opts));

        addItem(new MenuItem("CP/FTP", Properties.getValue("ftp").toString() + " W", :mnuFTP, opts));

        addItem(new MenuItem("Altert type", alertTypeLabels[Properties.getValue("alertType") as Number], :mnuAlertType, opts));
        
        addItem(new ToggleMenuItem("Use static target", null, :mnuUseStaticTarget,
            Properties.getValue("useStaticTarget"), opts));
        addItem(new MenuItem("Lower target", Properties.getValue("staticTargetLo").toString() + " W", :mnuStaticTargetLo, opts));
        addItem(new MenuItem("Upper target", Properties.getValue("staticTargetHi").toString() + " W", :mnuStaticTargetHi, opts));
        addItem(new ToggleMenuItem("Use last step target", null, :mnuUseLastStepTarget,
            Properties.getValue("useLastStepTarget"), opts));            

        addItem(new MenuItem(Rez.Strings.settingPwrAveraging, pwrAvgLabels[Properties.getValue("pwrAveraging") as Number], :mnuPwrAvg, opts));

        addItem(new VersionMenuItem());
    }
}

class VersionMenuItem extends MenuItem {
    function initialize() {
        MenuItem.initialize(Rez.Strings.appVersion, null, :mnuVersion, {});
        refresh();
    }

    function refresh() as Void {
        setSubLabel("Env. adj. " + ($.computeEnvCorrection(null) * 100.0).format("%.3f") + " %");
    }
}

class SettingsMenuDelegate extends Menu2InputDelegate {
    private var _mnuVersion as VersionMenuItem;
    function initialize(menu as Menu2) {
        Menu2InputDelegate.initialize();
        _mnuVersion = menu.getItem(menu.findItemById(:mnuVersion)) as VersionMenuItem;
    }

    public function onSelect(item as MenuItem) as Void {
        switch(item.getId()) {
            case :mnuEnvCurrTmp:
                enterNumber(item, "envCurrTmp", "Real temp", -20, 50, 1, " °C");
                break;
            case :mnuEnvCurrHum:
                enterNumber(item, "envCurrHum", "Real humidity", 10, 100, 1, " %");
                break;
            case :mnuEnvCurrAlt:
                enterAlt(item, "envCurrAlt", "Real altitude");
                break;
            case :mnuEnvTestTmp:
                enterNumber(item, "envTestTmp", "Test temp", -20, 50, 1, " °C");
                break;
            case :mnuEnvTestHum:
                enterNumber(item, "envTestHum", "Test humidity", 10, 100, 1, " %");
                break;
            case :mnuEnvTestAlt:
                enterAlt(item, "envTestAlt", "Test altitude");
                break;
            case :mnuEnvCorrection: 
                Properties.setValue("envCorrection", (item as ToggleMenuItem).isEnabled());
                _mnuVersion.refresh();
                break;
            case :mnuEnvAltSensor: 
                Properties.setValue("envCurrAltSensor", (item as ToggleMenuItem).isEnabled());
                _mnuVersion.refresh();
                break;                
            case :mnuAlertType:
                WatchUi.pushView(buildAlertTypeMenu(), new AltTypeMenuDelegate(item), WatchUi.SLIDE_LEFT);
                break;
            case :mnuPwrAvg:
                WatchUi.pushView(buildPwrAvgMenu(), new PwrAvgMenuDelegate(item), WatchUi.SLIDE_LEFT);
                break;
            case :mnuUseStaticTarget: 
                Properties.setValue("useStaticTarget", (item as ToggleMenuItem).isEnabled());
                break;           
            case :mnuStaticTargetLo:
                enterPower(item, "staticTargetLo", "Lower target");
                break;
            case :mnuStaticTargetHi:
                enterPower(item, "staticTargetHi", "Upper target");
                break;
            case :mnuUseLastStepTarget: 
                Properties.setValue("useLastStepTarget", (item as ToggleMenuItem).isEnabled());
                break;                
            case :mnuFTP:
                enterPower(item, "ftp", "CP/FTP");
                break;            
        }
    }

    private function enterNumber(item as MenuItem, property as String, title as String, min as Number, max as Number, step as Number,
            units as String) as Void {
        
        var factory = new $.NumberFactory(min, max, step, {});
        WatchUi.pushView(
            new Picker({
                :title => new Text({:text=>title, :locX => WatchUi.LAYOUT_HALIGN_CENTER, :locY => WatchUi.LAYOUT_VALIGN_BOTTOM, 
                                    :color => Graphics.COLOR_WHITE}), 
                :pattern => [factory],
                :defaults =>[factory.getIndex(Properties.getValue(property))]
            }), 
            new NumPropPickerDelegate(item, property, units, _mnuVersion), 
            WatchUi.SLIDE_LEFT
        );
    }

    private function enterPower(item as MenuItem, property as String, title as String) as Void {
        enterBigNum(item, property, title, 999, " W", null);
    }

    private function enterAlt(item as MenuItem, property as String, title as String) as Void {
        enterBigNum(item, property, title, 8000, " m", _mnuVersion);
    }

    private function enterBigNum(item as MenuItem, property as String, title as String, max as Number, units as String, mnuVersion as VersionMenuItem?) as Void {
        var factory1 = new $.NumberFactory(0, max / 100, 1, {});
        var factory2 = new $.NumberFactory(0, 99, 1, {:format => "%02d"});
        var v = Properties.getValue(property) as Number;
        WatchUi.pushView(
            new Picker({
                :title => new Text({:text=>title, :locX => WatchUi.LAYOUT_HALIGN_CENTER, :locY => WatchUi.LAYOUT_VALIGN_BOTTOM, 
                                    :color => Graphics.COLOR_WHITE}), 
                :pattern => [factory1, factory2],
                :defaults =>[factory1.getIndex(v / 100), factory2.getIndex(v % 100)]
            }), 
            new BigNumPropPickerDelegate(item, property, units, mnuVersion), 
            WatchUi.SLIDE_LEFT
        );
    }

    private function buildAlertTypeMenu() as Menu2 {
        var menu = new Menu2({:title => "Alert type"});
        for (var i = 0; i < alertTypeLabels.size(); i++) {
            menu.addItem(new MenuItem(alertTypeLabels[i], null, i.toString(), {}));
        }
        menu.setFocus(Properties.getValue("alertType"));
        return menu;
    }

    private function buildPwrAvgMenu() as Menu2 {
        var menu = new Menu2({:title => Rez.Strings.settingPwrAveraging});
        var values = pwrAvgLabels.keys();
        for (var i = 0; i < values.size(); i++) {
            menu.addItem(new MenuItem(pwrAvgLabels[values[i]], null, values[i].toString(), {}));
        }
        menu.setFocus(menu.findItemById(Properties.getValue("pwrAveraging").toString()));
        return menu;
    }
}

class NumPropPickerDelegate extends PickerDelegate {
    protected var _parentItem as MenuItem;
    protected var _property as String;
    protected var _units as String;
    protected var _mnuVersion as VersionMenuItem?;

    function initialize(parentItem as MenuItem, property as String, units as String, mnuVersion as VersionMenuItem?) {
        PickerDelegate.initialize();
        _parentItem = parentItem;
        _property = property;
        _units = units;
        _mnuVersion = mnuVersion;
    }    

    public function onCancel() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

    public function onAccept(values as Array) as Boolean {
        var v = computeValue(values);
        Properties.setValue(_property, v);
        _parentItem.setSubLabel(v + _units);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        if (_mnuVersion != null) {
            _mnuVersion.refresh();
        }
        return true;
    }

    protected function computeValue(values as Array) as Number {
        return values[0].toNumber();
    }
}

class BigNumPropPickerDelegate extends NumPropPickerDelegate {
    function initialize(parentItem as MenuItem, property as String, units as String, mnuVersion as VersionMenuItem?) {
        NumPropPickerDelegate.initialize(parentItem, property, units, mnuVersion);
    }

    protected function computeValue(values as Array) as Number {
        return values[0].toNumber() * 100 + values[1].toNumber();
    }
}

class AltTypeMenuDelegate extends Menu2InputDelegate {
    private var _parentItem as MenuItem;

    function initialize(parentItem as MenuItem) {
        Menu2InputDelegate.initialize();
        _parentItem = parentItem;
    }

    public function onSelect(item as MenuItem) as Void {
        var type = item.getId().toNumber();
        Properties.setValue("alertType", type);
        _parentItem.setSubLabel(alertTypeLabels[type]);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}

class PwrAvgMenuDelegate extends Menu2InputDelegate {
    private var _parentItem as MenuItem;

    function initialize(parentItem as MenuItem) {
        Menu2InputDelegate.initialize();
        _parentItem = parentItem;
    }

    public function onSelect(item as MenuItem) as Void {
        var avg = item.getId().toNumber();
        Properties.setValue("pwrAveraging", avg);
        _parentItem.setSubLabel(pwrAvgLabels[avg]);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}