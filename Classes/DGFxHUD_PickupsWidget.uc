class DGFxHUD_PickupsWidget extends GFxObject;

function InitializeWidget()
{
}

function TickHud(float DeltaTime)
{
}

function SetPickupLabel(string LabelMessage)
{
    SetString("pickupLabel",LabelMessage);
}


function SetPickupData(string DataMessage)
{
    SetString("pickupData",DataMessage);
}

defaultproperties
{
}

