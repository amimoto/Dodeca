class DSeqEvent_CountdownStart extends DSequenceEvent;

var DActor_CountdownTimer Timer;

event Activated()
{
    Timer.CountdownStart();
}

defaultproperties
{
    bPlayerOnly = false
    bAutoActivateOutputLinks=true

    InputLinks.Empty
    InputLinks(0)=(LinkDesc = "Countdown Start")

    // Add the target objects
    VariableLinks(1)=( ExpectedType=class'SeqVar_Object', LinkDesc="Countdown Timer",PropertyName=Timer);

    OutputLinks(0)=(LinkDesc="Countdown Started")

    ObjName = "Countdown Start"
    ObjCategory="Dodeca"
}
