import Toybox.Activity;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.UserProfile;

using Toybox.Application.Properties as Prop;

class HRField extends Field {

    const LBL = "HR";

    private var _zones as Array<Number>;
    private var _zone as Number = 0;

    function initialize(params as Dictionary) {
        Field.initialize(params, LBL);
        
        _zones = UserProfile.getHeartRateZones(UserProfile.HR_ZONE_SPORT_RUNNING);
        if (_zones == null || _zones.size() == 0) {
            _zones = UserProfile.getHeartRateZones(UserProfile.HR_ZONE_SPORT_GENERIC);
        }
    }

    function compute(info as Activity.Info) as Void {
        var v = info.currentHeartRate;
        if (v != null) {
            _value = v.format("%d");

            var zone = 0;
            if (_zones != null && _zones.size() > 0 && v >= _zones[0]) {
                zone++;
                while (zone < _zones.size() && zone < 5 && v > _zones[zone]) {
                    zone++;
                }
            }
            if (zone != _zone) {
                _zone = zone;
                _label = zone > 0 ? LBL + " " + zone : LBL;
            }
        } else {
            _value = NO_VALUE;
            _zone = 0;
            _label = LBL;
        }
    }

}