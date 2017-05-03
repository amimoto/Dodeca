class DPickupFactory_Key extends DPickupFactory;

var() string PickupName;

function GiveTo( Pawn P )
{
    local string PickupMessage;
    local KFPlayerController KFPC;
    local KFGFxHudWrapper GFxHUDWrapper;
    local byte IndicatorIndex;
    local DGFxMoviePlayer_HUD DGFxHUD;
    local Inventory Inv;

    // FIXME: Maybe this should actually be in the inventory item
    Inv = spawn(InventoryType);
    if ( Inv != None )
    {
        Inv.GiveTo(P);
        Inv.AnnouncePickup(P);
    }

    PickedUpBy(P);

    PickupMessage = P.Controller.PlayerReplicationInfo.PlayerName @ " has acquired a " @ PickupName;

    IndicatorIndex = DInventory_Key(Inv).IndicatorIndex;
    foreach LocalPlayerControllers(class'KFPlayerController', KFPC)
    {
        GFxHUDWrapper = KFGFxHudWrapper(KFPC.myHUD);
        DGFxHUD = DGFxMoviePlayer_HUD(GFxHUDWrapper.HudMovie);
        DGFxHUD.ShowNonCriticalMessage(PickupMessage);
        DGFxHUD.GfxDHUDPlayer.SetIndicator(IndicatorIndex,2);
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
