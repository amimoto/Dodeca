class DGFxHUD_ProgressWidget extends GFxObject;

var PlayerController PC;

var float CurrentAlpha;
var DInterface_Mechanism CurrentMechanismActor;

function InitializeWidget()
{
    PC = GetPC();
}


function Ingest( DInterface_Mechanism MechanismActor )
{
    if ( MechanismActor.isA('DTrigger_Mechanism') )
    {
        SetPickupLabel( MechanismActor.ActivationString(PC) );
        CurrentMechanismActor = MechanismActor;
        TickHud(0);
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

