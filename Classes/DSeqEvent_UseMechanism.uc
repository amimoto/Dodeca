class DSeqEvent_UseMechanism extends DSequenceEvent;

event Activated()
{
    `log("DSeqEvent_UseMechanism Instigator:"$Instigator);
}

defaultproperties
{
    bPlayerOnly = false

    OutputLinks(0)=(LinkDesc="UseMechanism")

    ObjName = "Use Mechanism"
    ObjCategory="Dodeca"
}
