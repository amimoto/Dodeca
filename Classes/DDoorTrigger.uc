class ObjKFDoorTrigger extends KFDoorTrigger;

function int GetInteractionIndex( Pawn User )
{
    local ObjKFDoorActor MyDoor;

    MyDoor = ObjKFDoorActor(DoorActor);

    if ( DoorActor.bIsDestroyed )
    {
        return IMT_RepairDoor;
    }
    else if( MyDoor.Locked )
    {
        return INDEX_NONE;
    }
    else if( DoorActor.WeldIntegrity > 0 )
    {
        if( User.Weapon != none && User.Weapon.Class.Name == 'KFWeap_Welder' )
        {
            return INDEX_NONE;
        }

        return IMT_UseDoorWelded;
    }
    else
    {
        return IMT_UseDoor;
    }
}


