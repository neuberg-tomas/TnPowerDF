import Toybox.Activity;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.UserProfile;

class WorkoutField extends Field {

    protected var _stepLo as Number?;
    protected var _stepHi as Number?;
    protected var _stepTargetType as WorkoutStepTargetType?;

    protected var _stepDuration as Number?;
    protected var _stepDurationType as WorkoutStepDurationType?;
    protected var _stepStartTime as Number?;

    protected var _stepNextTargetType as WorkoutStepTargetType?;
    protected var _stepNextLo as Number?;
    protected var _stepNextHi as Number?;
    
    function initialize(params as Dictionary, label as String) {
        Field.initialize(params, label);
    }

    function onWorkoutStep() as Void {
        Field.onWorkoutStep();

        var si = Activity.getCurrentWorkoutStep();
        if (si == null || !(si.step instanceof WorkoutStep)) {
            _stepTargetType = null;
            _stepNextTargetType = null;
            _stepDurationType = null;
            return;
        }

        var step = si.step as WorkoutStep;

        _stepTargetType = step.targetType;
        _stepLo = normalizeTarget(_stepTargetType, step.targetValueLow);
        _stepHi = normalizeTarget(_stepTargetType, step.targetValueHigh);
        
        _stepDurationType = step.durationType;
        _stepDuration = step.durationValue;
        _stepStartTime = Activity.getActivityInfo().timerTime;
    
        si = Activity.getNextWorkoutStep();
        if (si == null || !(si.step instanceof WorkoutStep)) {
            _stepNextTargetType = null;
        } else {
            step = si.step as WorkoutStep;
            _stepNextTargetType = step.targetType;
            _stepNextLo = normalizeTarget(_stepNextTargetType, step.targetValueLow);
            _stepNextHi = normalizeTarget(_stepNextTargetType, step.targetValueHigh);
        }
    }

    private function normalizeTarget(type as WorkoutStepTargetType?, value as Number?) as Number? {
        return value == null || type == null || type != Activity.WORKOUT_STEP_TARGET_POWER || value == 0 ? value : value - 1000; 
    }

}