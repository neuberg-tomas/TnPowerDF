import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

var alertTypeLabels as Array<String> = ["Disabled", "Lap power", "Current power"] as Array<String>;

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

        addItem(new ToggleMenuItem("Environmental corrections", null, :mnuEnvCorrection,
            Properties.getValue("envCorrection"), opts));

        addItem(new MenuItem("CP/FTP", Properties.getValue("ftp").toString() + " W", :mnuFTP, opts));

        addItem(new MenuItem("Altert type", alertTypeLabels[Properties.getValue("alertType") as Number], :mnuAlertType, opts));
        
        addItem(new ToggleMenuItem("Use static target", null, :mnuUseStaticTarget,
            Properties.getValue("useStaticTarget"), opts));
        addItem(new MenuItem("Lower target", Properties.getValue("staticTargetLo").toString() + " W", :mnuStaticTargetLo, opts));
        addItem(new MenuItem("Upper target", Properties.getValue("staticTargetHi").toString() + " W", :mnuStaticTargetHi, opts));
        addItem(new ToggleMenuItem("Use last step target", null, :mnuUseLastStepTarget,
            Properties.getValue("useLastStepTarget"), opts));            

        addItem(new MenuItem("Version", Properties.getValue("appVersion").toString(), :mnuVersion, opts));
    }
}

class SettingsMenuDelegate extends Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
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
                break;
            case :mnuEnvAltSensor: 
                Properties.setValue("envCurrAltSensor", (item as ToggleMenuItem).isEnabled());
                break;                
            case :mnuAlertType:
                WatchUi.pushView(buildAltTypeMenu(), new AltTypeMenyDelegate(item), WatchUi.SLIDE_LEFT);
                break;
            case :mnuUseStaticTarget: 
                Properties.setValue("useStaticTarget", (item as ToggleMenuItem).isEnabled());
                break;           
            case :mnuStaticTargetLo:
                enterNumber(item, "staticTargetLo", "Lower target", 0, 999, 1, " W");
                break;
            case :mnuStaticTargetHi:
                enterNumber(item, "staticTargetHi", "Upper target", 0, 999, 1, " W");
                break;
            case :mnuUseLastStepTarget: 
                Properties.setValue("useLastStepTarget", (item as ToggleMenuItem).isEnabled());
                break;                
            case :mnuFTP:
                enterNumber(item, "ftp", "CP/FTP", 100, 500, 1, " W");
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
            new NumPropPickerDelegate(item, property, units), 
            WatchUi.SLIDE_LEFT
        );
    }

    private function enterAlt(item as MenuItem, property as String, title as String) as Void {    
        var factory1 = new $.NumberFactory(0, 80, 1, {});
        var factory2 = new $.NumberFactory(0, 99, 1, {:format => "%02d"});
        var alt = Properties.getValue(property) as Number;
        WatchUi.pushView(
            new Picker({
                :title => new Text({:text=>title, :locX => WatchUi.LAYOUT_HALIGN_CENTER, :locY => WatchUi.LAYOUT_VALIGN_BOTTOM, 
                                    :color => Graphics.COLOR_WHITE}), 
                :pattern => [factory1, factory2],
                :defaults =>[factory1.getIndex(alt / 100), factory2.getIndex(alt % 100)]
            }), 
            new AltPropPickerDelegate(item, property), 
            WatchUi.SLIDE_LEFT
        );
    }

    private function buildAltTypeMenu() as Menu2 {
        var menu = new Menu2({:title => "Alert type"});
        for (var i = 0; i < alertTypeLabels.size(); i++) {
            menu.addItem(new MenuItem(alertTypeLabels[i], null, i.toString(), {}));
        }
        menu.setFocus(Properties.getValue("alertType"));
        return menu;
    }
}

class NumPropPickerDelegate extends PickerDelegate {
    protected var _parentItem as MenuItem;
    protected  var _property as String;
    protected  var _units as String;

    function initialize(parentItem as MenuItem, property as String, units as String) {
        PickerDelegate.initialize();
        _parentItem = parentItem;
        _property = property;
        _units = units;
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
        return true;
    }

    protected function computeValue(values as Array) as Number {
        return values[0].toNumber();
    }
}

class AltPropPickerDelegate extends NumPropPickerDelegate {
    function initialize(parentItem as MenuItem, property as String) {
        NumPropPickerDelegate.initialize(parentItem, property, " m");
    }

    protected function computeValue(values as Array) as Number {
        return values[0].toNumber() * 100 + values[1].toNumber();
    }
}

class AltTypeMenyDelegate extends Menu2InputDelegate {
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