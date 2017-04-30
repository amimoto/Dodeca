interface DInterface_Mechanism;

/** Checks if this actor is presently usable */
simulated function bool CanBeActivated( Pawn User );

/* Returns the widget text that should be shown to the user */
function string ActivationString();

/* Returns the current percentage completion amount of activity */
function int ActivationPercentage();

/* Do one tick of activation work */
function DoActivationWork();
