class DGFxMoviePlayer_DHUD extends GFxMoviePlayer
    config(UI);

var GFxObject DGXHUDManager;
var DGFxHUD_KeyCard KeyCardWidget;
var float HUDScale;

function Init(optional LocalPlayer LocPlay)
{
    SetTimingMode(TM_Real);

    Super.Init(LocPlay);
    DGXHUDManager = GetVariableObject("root");

    UpdateRatio();
    //UpdateScale();
}

function UpdateRatio(optional float fScale=1.f)
{
    local GfxObject GFxStage;
    local float ScaleStage;
    if ( class'WorldInfo'.static.IsConsoleBuild(CONSOLE_Orbis))
    {
        ScaleStage = class'Engine'.static.GetTitleSafeArea();
    }
    else
    {
        ScaleStage = fScale;
    }
    GFxStage = DGXHUDManager.GetObject("stage");
    GFxStage.SetFloat("x", (GFxStage.GetFloat("width") * (1.0f - ScaleStage)) / 2 );
    GFxStage.SetFloat("y", (GFxStage.GetFloat("height") * (1.0f - ScaleStage)) / 2 );
    GFxStage.SetFloat("scaleX", ScaleStage);
    GFxStage.SetFloat("scaleY", ScaleStage);
    `log("GFxStage:"@GFxStage);
    `log("ScaleState:"@ScaleStage);
    `log("GFXStage.GetFloat(width):"@GFxStage.GetFloat("width"));
    `log("GFXStage.GetFloat(height):"@GFxStage.GetFloat("height"));
}


/* currently only set in the INI file due to Relow issues with layouts. */
function UpdateScale()
{
    if(DGXHUDManager != none)
    {
        DGXHUDManager.SetFloat("HUDScale", HUDScale * class'WorldInfo'.static.GetResolutionBasedHUDScale());
    }
}


event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
    `log("+++++++++++++++++++++++++++++++++++++++++++++++++ Initializing:"@WidgetName);
    switch (WidgetName)
    {
        case ( 'KeyCardWidget' ):
            if ( KeyCardWidget == none )
            {
                SetWidgetPathBinding( Widget, WidgetPath );
                KeyCardWidget = DGFxHUD_KeyCard( Widget );
                KeyCardWidget.InitializeWidget();
            }
        break;
    }

    return super.WidgetInitialized(WidgetName, WidgetPath, Widget);
}

function ShowDHUD(bool newShowDHUD)
{
    if (KeyCardWidget != none)
    {
        //KeyCardWidget.SetOpen(newShowDHUD);
        //DHUDWidget.bUpdateDHUD = newShowDHUD;
    }

    KeyCardWidget.SetKeycard(1,2);
}

function TickHud(float DeltaTime)
{
    if (KeyCardWidget != none)
    {
        KeyCardWidget.TickHUD(DeltaTime);
    }

}

defaultproperties
{
    WidgetBindings.Add((WidgetName="KeyCardWidget",WidgetClass=class'Dodeca.DGFxHUD_KeyCard'))
    MovieInfo=SwfMovie'Dodeca_UI.Widgets'

    Priority = 1

    bAllowFocus=false
    bIgnoreMouseInput=true
    bCaptureInput=false
    bAllowInput=false
    bDisplayWithHudOff=false
    bAutoPlay=true

    HUDScale=1
}

