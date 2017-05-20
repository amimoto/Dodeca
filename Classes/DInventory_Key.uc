class DInventory_Key extends Inventory;

var() byte IndicatorIndex;
var() string PickupName;

static function string GetLocalString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2
    )
{
    return "";
}


DefaultProperties
{
    Begin Object Class=StaticMeshComponent Name=StaticMeshComponent0
        StaticMesh=StaticMesh'Dodeca_UI.Keycard'
    End Object
    PickupFactoryMesh=StaticMeshComponent0
    IndicatorIndex = 0
    PickupName = "key"
}


