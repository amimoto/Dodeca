class DGFxHUD_ProgressWidgetContainer extends GFxObject;

var PlayerController PC;

var bool Visible;
var DInterface_Mechanism CurrentMechanismActor;

function InitializeWidget()
{
    Hide();
    PC = GetPC();
}

function Ingest( DInterface_Mechanism MechanismActor )
{
    if ( MechanismActor.isA('DTrigger_Mechanism') && !MechanismActor.IsActivated() )
    {
        SetPickupLabel( MechanismActor.ActivationString(PC) );
        CurrentMechanismActor = MechanismActor;
        TickHud(0);
        Show();
    }
    else {
        Hide();
    }
}

function TickHud(float DeltaTime)
{
    local int percentComplete;
    if ( CurrentMechanismActor == none ) {
        SetProgressBar(0);
        SetProgressData("0%");
    }

    // Keep updating the progress bar up until 100%
    else if ( !CurrentMechanismActor.IsActivated() )
    {
        percentComplete = CurrentMechanismActor.ActivationPercentage();
        SetProgressBar(percentComplete);
        SetProgressData(string(percentComplete)$"%");
    }

    // Hide after activation
    else
    {
        Hide();
    }
}

function Hide()
{
    if ( Visible ) {
        SetBool("show",false);
        Visible = false;
    }
}

function Show()
{
    if ( !Visible ) {
        SetBool("show",True);
        Visible = True;
    }
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
    Visible = false;
}

