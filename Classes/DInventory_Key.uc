class DInventory_Key extends Inventory;

var() byte IndicatorIndex;

DefaultProperties
{
    Begin Object Class=StaticMeshComponent Name=StaticMeshComponent0
        StaticMesh=StaticMesh'Dodeca_UI.Keycard'
    End Object
    PickupFactoryMesh=StaticMeshComponent0
    IndicatorIndex = 0
}


