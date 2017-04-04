class ObjSeqEvent_Unlock extends SequenceEvent;

var array<ObjKFDoorActor> MyDoors;

event Activated()
{
    local ObjKFDoorActor MyDoor;
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
    ObjCategory="Objectives"
}

