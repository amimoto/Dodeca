class DPlayerInput extends KFGame.KFPlayerInput;


exec function InteractTimer()
{
    local KFInventoryManager KFIM;
    local KFInterface_Usable UsableTrigger;

    KFIM = KFInventoryManager(Pawn.InvManager);
    if( KFIM != none && KFIM.Instigator != none )
    {
        UsableTrigger = GetCurrentUsableActor( KFIM.Instigator );
        if( UsableTrigger == none)
        {
            return;
        }
        else if(UsableTrigger.IsA('DDoorTrigger'))
        {
            // Ignore if door is locked
            if ( DDoorActor(DDoorTrigger(UsableTrigger).DoorActor).Locked )
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

