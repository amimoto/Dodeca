class DPickupFactory_KeyRed extends DPickupFactory_Key;

defaultproperties
{
    // These are the default weapons to load into an item pickup factory, more can be added on the object 
    // Weapons in this list are always loaded into memory if this actor exists in the map
    Begin Object Name=StaticMeshComponent0
        StaticMesh=StaticMesh'Dodeca_UI.KeycardRed'
    End Object
    PickupMesh=StaticMeshComponent0
    Components.Add(StaticMeshComponent0)
    InventoryType = class'Dodeca.DInventory_KeyRed'
    PickupName = "red key"
}
