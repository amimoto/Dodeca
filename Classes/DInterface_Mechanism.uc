interface DInterface_Mechanism;

/** Checks if this actor is presently usable */
simulated function bool CanBeActivated( Pawn User );

/* Returns the widget text that should be shown to the user */
function string ActivationString(PlayerController PC);

/* Returns the current percentage completion amount of activity */
function int ActivationPercentage();

/* Do one tick of activation work */
function DoActivationWork();

/* Returns true if the mechanism is 100% activated */
function bool IsActivated();

