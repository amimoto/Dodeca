class DPickupFactory_Key extends DPickupFactory;

var() string PickupName;

function GiveTo( Pawn P )
{
    local string PickupMessage;
    local KFPlayerController KFPC;
    local KFGFxHudWrapper GFxHUDWrapper;

    Super.GiveTo(P);

    PickupMessage = P.Controller.PlayerReplicationInfo @ " has acquired a " @ PickupName;

    foreach LocalPlayerControllers(class'KFPlayerController', KFPC)
    {
        GFxHUDWrapper = KFGFxHudWrapper(KFPC.myHUD);
        GFxHUDWrapper.HudMovie.ShowNonCriticalMessage(PickupMessage);
    }
}

defaultproperties
{
    // These are the default weapons to load into an item pickup factory, more can be added on the object 
    // Weapons in this list are always loaded into memory if this actor exists in the map
    Begin Object Class=StaticMeshComponent Name=StaticMeshComponent0
        StaticMesh=StaticMesh'Dodeca_UI.Keycard'
        bCastDynamicShadow=FALSE
        CollideActors=true
        // Translation=(Z=-50)
    End Object
    PickupMesh=StaticMeshComponent0
    InventoryType = class'Dodeca.DInventory_Key'
    PickupName = "key"
}
