class DSeqEvent_Unlock extends DSequenceEvent;

var array<DDoorActor> MyDoors;

event Activated()
{
    local DDoorActor MyDoor;
    `log("DSeqEvent_Unlock Instigator:"$Instigator);

    foreach MyDoors(MyDoor)
    {
        MyDoor.Unlock();
    }
}

defaultproperties
{
    InputLinks.Empty
    InputLinks(0)=(LinkDesc = "Unlock")

    bPlayerOnly = false
    bAutoActivateOutputLinks=true

    // Add the target objects
    VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Doors to Unlock",PropertyName=MyDoors);

    OutputLinks(0)=(LinkDesc="Unlocked")

    ObjName = "Unlock"
    ObjCategory="Dodeca"
}

