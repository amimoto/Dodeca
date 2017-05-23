class DSeqAct_CountdownTimer extends SeqAct_Latent;

var DActor_CountdownTimer Timer;

event Activated()
{
    // Start
    if( InputLinks[0].bHasImpulse )
    {
        `log("DSeqAct_CountdownTimer: START");
        Timer.CountdownStart();
        OutputLinks[0].bHasImpulse = TRUE;
    }

    // Stop
    else if( InputLinks[1].bHasImpulse )
    {
        `log("DSeqAct_CountdownTimer: STOP");
        Timer.CountdownStop();
        OutputLinks[1].bHasImpulse = TRUE;
    }

    // Reset
    else if( InputLinks[2].bHasImpulse )
    {
        `log("DSeqAct_CountdownTimer: RESET");
        Timer.CountdownReset();
        OutputLinks[1].bHasImpulse = TRUE;
    }
}

event bool Update(float DT)
{
    if ( Timer.IsCompleted() )
    {
        OutputLinks[2].bHasImpulse = TRUE;
        return false;
    }
    else if ( Timer.IsStopped() )
    {
        OutputLinks[1].bHasImpulse = TRUE;
        return false;
    }
    else
    {
        return true;
    }
}

defaultproperties
{
    ObjName="Countdown Timer"
    ObjCategory="Dodeca"

    bAutoActivateOutputLinks=false

    InputLinks(0)=(LinkDesc="Start",LinkDesc="Start Timer")
    InputLinks(1)=(LinkDesc="Stop",LinkDesc="Stop Timer")
    InputLinks(2)=(LinkDesc="Reset",LinkDesc="Reset Timer and Stop")

    VariableLinks.Empty()
    VariableLinks(0)=( ExpectedType=class'SeqVar_Object', LinkDesc="Countdown Timer",PropertyName=Timer);

    OutputLinks.Empty()
    OutputLinks(0)=(LinkDesc="Countdown Start")
    OutputLinks(1)=(LinkDesc="Countdown Stop")
    OutputLinks(2)=(LinkDesc="Countdown Finished")
}


