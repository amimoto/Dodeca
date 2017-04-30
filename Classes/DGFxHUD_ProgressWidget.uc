class DGFxHUD_ProgressWidget extends GFxObject;

var float CurrentAlpha;
var DInterface_Mechanism CurrentMechanismActor;

function InitializeWidget()
{
    Hide();
}

function Ingest( DInterface_Mechanism MechanismActor )
{
    if ( MechanismActor.isA('DTrigger_Mechanism') )
    {
        SetPickupLabel( MechanismActor.ActivationString() );
        CurrentMechanismActor = MechanismActor;
        TickHud(0);
        Show();
    }
}

function TickHud(float DeltaTime)
{
    local int percentComplete;
    if ( CurrentMechanismActor == none ) {
        SetProgressBar(0);
        SetProgressData("0%");
    }
    else
    {
        percentComplete = CurrentMechanismActor.ActivationPercentage();
        SetProgressBar(percentComplete);
        SetProgressData(string(percentComplete)$"%");
    }
}

function SetAlpha(float alpha)
{
    local ASDisplayInfo displayInfo;

    CurrentAlpha = alpha;
    displayInfo = GetDisplayInfo();
    displayInfo.Alpha = alpha;
    SetDisplayInfo(displayInfo);
}

function Hide()
{
    if ( CurrentAlpha == 100 )
        SetAlpha(0.0f);
    CurrentMechanismActor = none;
}

function Show()
{
    if ( CurrentAlpha == 0 )
        SetAlpha(100.0f);
}

function SetPickupLabel(string LabelMessage)
{
    SetString("progressLabel",LabelMessage);
}


function SetProgressData(string DataMessage)
{
    SetString("progressText",DataMessage);
}

function SetProgressBar(int Percent)
{
    SetInt("progressBarPercent", Percent);
}

function SetProgressBarPercentData(int Percent)
{
    SetInt("progressBarPercentData", Percent);
}

defaultproperties
{
    CurrentAlpha = 100
}

