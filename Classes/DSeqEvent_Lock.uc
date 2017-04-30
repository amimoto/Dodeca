class DSeqEvent_Lock extends DSequenceEvent;

var array<DDoorActor> MyDoors;

event Activated()
{
    local DDoorActor MyDoor;
    `log("DSeqEvent_Lock Instigator:"$Instigator);

    foreach MyDoors(MyDoor)
    {
        MyDoor.Lock();
    }
}

defaultproperties
{
    InputLinks.Empty
    InputLinks(0)=(LinkDesc = "Lock")

    bPlayerOnly = false
    bAutoActivateOutputLinks=true

    // Add the target objects
    VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Doors to Lock",PropertyName=MyDoors);

    OutputLinks(0)=(LinkDesc="Locked")

    ObjName = "Lock"
    ObjCategory="Dodeca"
}

