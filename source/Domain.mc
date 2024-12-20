import Toybox.Activity;
import Toybox.Lang;

class WorkoutInfo {
    var stepLo as Number?;
    var stepHi as Number?;
    var stepTargetType as WorkoutStepTargetType?;

    var stepDuration as Number?;
    var stepDurationType as WorkoutStepDurationType?;
    var stepStartTime as Number;
    var stepStartDistance as Float;
    var almostFinishTime as Number?;

    var stepNextTargetType as WorkoutStepTargetType?;
    var stepNextLo as Number?;
    var stepNextHi as Number?;

    private var _static as Boolean = false;

    function initialize(timer as Number, distance as Float, currStep as WorkoutStepInfo?, nextStep as WorkoutStepInfo?) {
        stepStartTime = timer;
        stepStartDistance = distance;

        if (currStep == null || !(currStep.step instanceof WorkoutStep)) {
            return;
        }

        var step = currStep.step as WorkoutStep;

        stepTargetType = step.targetType;
        stepLo = normalizeTarget(stepTargetType, step.targetValueLow);
        if (stepLo != null && stepLo < 10) {
            stepLo = 0;
        }
        stepHi = normalizeTarget(stepTargetType, step.targetValueHigh);
        
        stepDurationType = step.durationType;
        stepDuration = step.durationValue;

        if (stepDurationType == Activity.WORKOUT_STEP_DURATION_TIME && stepDuration > 10) {
            almostFinishTime =  stepStartTime + stepDuration - 4;
        } else {
            almostFinishTime = null;
        }
    
        if (nextStep != null && (nextStep.step instanceof WorkoutStep)) {
            step = nextStep.step as WorkoutStep;
            stepNextTargetType = step.targetType;
            stepNextLo = normalizeTarget(stepNextTargetType, step.targetValueLow);
            stepNextHi = normalizeTarget(stepNextTargetType, step.targetValueHigh);
        }
    }

    function setStaticPowerTarget(lo as Number, hi as Number) as WorkoutInfo {
        stepLo = lo;
        stepHi = hi;
        stepTargetType = Activity.WORKOUT_STEP_TARGET_POWER;
        stepDurationType = Activity.WORKOUT_STEP_DURATION_OPEN;
        _static = true;
        return self;
    }

    private function normalizeTarget(type as WorkoutStepTargetType?, value as Number?) as Number? {
        return value == null || type == null || type != Activity.WORKOUT_STEP_TARGET_POWER || value == 0 ? value : value - 1000; 
    }

    function isSet() as Boolean {
        return stepTargetType != null;
    }

    function isStatic() as Boolean {
        return _static;
    }

    function dump() as String {
        return Lang.format("workout start=$1$, duration=$2$, type=$3$, lo=$4$, hi=$5$, next lo: $6$, hi: $7$", [
            stepStartTime + "/" + stepStartDistance, stepDuration, stepTargetType, stepLo, stepHi, stepNextLo, stepNextHi
        ]);
    }

    function persistContext(context as Dictionary) {
        context["workout.stepStartTime"] = stepStartTime;
        context["workout.stepStartDistance"] = stepStartDistance;
        context["workout.almostFinishTime"] = almostFinishTime;
    }

    function restoreContext(context as Dictionary) {
        stepStartTime = context["workout.stepStartTime"] as Number;
        stepStartDistance = context["workout.stepStartDistance"] as Float;
        almostFinishTime = context["workout.almostFinishTime"] as Number;
    }
}

class ComputeContext {
    private var _powerZones as Array<Number>?;
    private var _heartRateZones as Array<Number>?;
    var timer as Number?;
    var envCorrection as Float;
    var power as Float;

    function initialize(timer as Number, powerZones as Array<Number>?, heartRateZones as Array<Number>?, envCorrection as Float, power as Float) {
        self.timer = timer;
        self.envCorrection = envCorrection;
        self.power = power;
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