class DPlayerInput extends KFGame.KFPlayerInput within DPlayerController;

var() float ButtonTickerInterval;

var DTrigger_Mechanism TargetMechanism;

// This allows us to handle the "HOLD INTERACT" to
// allow task to proceed
exec function Interact()
{
    local KFInventoryManager KFIM;
    local DInterface_Mechanism MechanismTrigger;

    KFIM = KFInventoryManager(Pawn.InvManager);
    if( KFIM != none && KFIM.Instigator != none )
    {
        MechanismTrigger = GetCurrentMechanismActor( KFIM.Instigator );
        if (MechanismTrigger != none && MechanismTrigger.IsA('DTrigger_Mechanism'))
        {
            TargetMechanism = DTrigger_Mechanism(MechanismTrigger);
            `TimerHelper.SetTimer(
                ButtonTickerInterval,
                true, // Loop
                nameof(InteractTicker),
                self
            );
            return;
        }
    }

    Super.Interact();
}

exec function InteractRelease()
{
    `TimerHelper.ClearTimer( nameof(InteractTicker), self );
    Super.InteractRelease();
}

exec function InteractTicker()
{
    if ( TargetMechanism == none ) return;
    TargetMechanism.DoActivationWork();
}

exec function InteractTimer()
{
    local KFInventoryManager KFIM;
    local DInterface_Mechanism MechanismTrigger;

    KFIM = KFInventoryManager(Pawn.InvManager);
    if( KFIM != none && KFIM.Instigator != none )
    {
        MechanismTrigger = GetCurrentMechanismActor( KFIM.Instigator );
        if( MechanismTrigger == none)
        {
            return;
        }
        else if(MechanismTrigger.IsA('DDoorTrigger'))
        {
            // Ignore if door is locked
            if ( DDoorActor(DDoorTrigger(MechanismTrigger).DoorActor).Locked )
            {
                return;
            }
            Super.InteractTimer();
        }
        else {
            Super.InteractTimer();
        }
    }
}


defaultproperties
{
    ButtonTickerInterval = 0.05.
}
