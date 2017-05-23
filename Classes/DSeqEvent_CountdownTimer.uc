class DSeqEvent_CountdownTimer extends DSequenceEvent;

var DActor_CountdownTimer Timer;

event Activated()
{
    // Start
    if( InputLinks[0].bHasImpulse )
    {
        `log("DSeqAct_CountdownTimer: START");
        Timer.CountdownStart();
    }

    // Stop
    else if( InputLinks[1].bHasImpulse )
    {
        `log("DSeqAct_CountdownTimer: STOP");
        Timer.CountdownStop();
    }

    // Reset the timer
    else if( InputLinks[2].bHasImpulse )
    {
        `log("DSeqAct_CountdownTimer: RESET");
    }

    `log("DSeqEvent_CountdownTimer ACTIVATED");
}

defaultproperties
{
    bPlayerOnly = false
    bAutoActivateOutputLinks=false

    InputLinks.Empty()
    InputLinks(0)=(LinkDesc = "Countdown Start")
    InputLinks(1)=(LinkDesc = "Countdown Stop")
    InputLinks(2)=(LinkDesc = "Countdown Reset")

    // Add the target objects
    VariableLinks(1)=( ExpectedType=class'SeqVar_Object', LinkDesc="Countdown Timer",PropertyName=Timer);

    OutputLinks.Empty()
    OutputLinks(0)=(LinkDesc="Countdown Started")
    OutputLinks(1)=(LinkDesc="Countdown Stopped")
    OutputLinks(2)=(LinkDesc="Countdown Completed")

    ObjName = "Countdown Timer"
    ObjCategory="Dodeca"
}
