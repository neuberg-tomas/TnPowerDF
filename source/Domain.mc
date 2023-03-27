import Toybox.Activity;
import Toybox.Lang;

class WorkoutInfo {
    var stepLo as Number?;
    var stepHi as Number?;
    var stepTargetType as WorkoutStepTargetType?;

    var stepDuration as Number?;
    var stepDurationType as WorkoutStepDurationType?;
    var stepStartTime as Number;
    var almostFinishTime as Number?;

    var stepNextTargetType as WorkoutStepTargetType?;
    var stepNextLo as Number?;
    var stepNextHi as Number?;

    function initialize(timer as Number, currStep as WorkoutStepInfo?, nextStep as WorkoutStepInfo?) {
        stepStartTime = timer;

        if (currStep == null || !(currStep.step instanceof WorkoutStep)) {
            return;
        }

        var step = currStep.step as WorkoutStep;

        stepTargetType = step.targetType;
        stepLo = normalizeTarget(stepTargetType, step.targetValueLow);
        stepHi = normalizeTarget(stepTargetType, step.targetValueHigh);
        
        stepDurationType = step.durationType;
        stepDuration = step.durationValue;

        if (stepDurationType == Activity.WORKOUT_STEP_DURATION_TIME && stepDuration > 3) {
            almostFinishTime =  stepStartTime + (stepDuration - 3) * 1000;
        }
    
        if (nextStep != null && (nextStep.step instanceof WorkoutStep)) {
            step = nextStep.step as WorkoutStep;
            stepNextTargetType = step.targetType;
            stepNextLo = normalizeTarget(stepNextTargetType, step.targetValueLow);
            stepNextHi = normalizeTarget(stepNextTargetType, step.targetValueHigh);
        }
    }

    private function normalizeTarget(type as WorkoutStepTargetType?, value as Number?) as Number? {
        return value == null || type == null || type != Activity.WORKOUT_STEP_TARGET_POWER || value == 0 ? value : value - 1000; 
    }

    function isSet() as Boolean {
        return stepTargetType != null;
    }

    function dump() as String {
        return Lang.format("workout start=$1$, duration=$2$, type=$3$, lo=$4$, hi=$5$, next lo: $6$, hi: $7$", [
            stepStartTime, stepDuration, stepTargetType, stepLo, stepHi, stepNextLo, stepNextHi
        ]);
    }
}

class ComputeContext {
    private var _powerZones as Array<Number>?;
    private var _heartRateZones as Array<Number>?;
    var timer as Number?;
    var envCorrection as Float;

    function initialize(timer as Number, powerZones as Array<Number>?, heartRateZones as Array<Number>?, envCorrection as Float) {
        self.timer = timer;
        self.envCorrection = envCorrection;
        _powerZones = powerZones;
        _heartRateZones = heartRateZones;
    }

    function getHeartRateZone(value as Number?) {
        return findZone(value, _heartRateZones);
    }

    function getPowerZone(value as Number?) {
        return findZone(value, _powerZones);
    }

    private function findZone(value as Number?, zones as Array<Number>) as Number? {
        if (value == null || zones == null || zones.size() <= 1 || value < zones[0]) {
            return null;
        }
        var zone = 1;
        var s = zones.size();
        while (zone < s && value > zones[zone]) {
            zone++;
        }
        return zone;
    }
}