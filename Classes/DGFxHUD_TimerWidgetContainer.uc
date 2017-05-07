class DGFxHUD_TimerWidgetContainer extends GFxObject;

var bool Visible;
var float seconds;

function InitializeWidget()
{
}

function TickHud(float DeltaTime)
{
    if ( Visible )
        SetSeconds(seconds);
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

function SetSeconds(float newSeconds)
{
    SetFloat("seconds",newSeconds);
}

defaultproperties
{
    Visible = false;
}

