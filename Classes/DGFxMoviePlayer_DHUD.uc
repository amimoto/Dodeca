class DGFxMoviePlayer_DHUD extends GFxMoviePlayer
    config(UI);

var GFxObject DGXHUDManager;

var DGFxHUD_PickupsWidget PickupsWidget;
var DGFxHUD_IndicatorWidget IndicatorWidget;
var DGFxHUD_ProgressWidgetContainer ProgressWidgetContainer;
var DGFxHUD_TimerWidgetContainer TimerWidgetContainer;

var float HUDScale;

function Init(optional LocalPlayer LocPlay)
{
    SetTimingMode(TM_Real);

    Super.Init(LocPlay);
    DGXHUDManager = GetVariableObject("root");

    UpdateRatio();
    //UpdateScale();
}

function SetIndicator(int indicatorIndex, int indicatorState)
{
    if ( IndicatorWidget != none )
    {
        IndicatorWidget.SetIndicator(indicatorIndex,indicatorState);
    }
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

        case ( 'IndicatorWidget' ):
            if ( IndicatorWidget == none )
            {
                SetWidgetPathBinding( Widget, WidgetPath );
                IndicatorWidget = DGFxHUD_IndicatorWidget( Widget );
                IndicatorWidget.InitializeWidget();
            }
            break;

        case ( 'PickupsWidget' ):
            if ( PickupsWidget == none )
            {
                SetWidgetPathBinding( Widget, WidgetPath );
                PickupsWidget = DGFxHUD_PickupsWidget( Widget );
                PickupsWidget.InitializeWidget();
            };
            break;

        case ( 'ProgressWidgetContainer' ):
            if ( ProgressWidgetContainer == none )
            {
                SetWidgetPathBinding( Widget, WidgetPath );
                ProgressWidgetContainer = DGFxHUD_ProgressWidgetContainer( Widget );
                ProgressWidgetContainer.InitializeWidget();
            };
            break;

        case ( 'TimerWidgetContainer' ):
            if ( TimerWidgetContainer == none )
            {
                SetWidgetPathBinding( Widget, WidgetPath );
                TimerWidgetContainer = DGFxHUD_TimerWidgetContainer( Widget );
                TimerWidgetContainer.InitializeWidget();
            };
            break;

        break;
    }

    return super.WidgetInitialized(WidgetName, WidgetPath, Widget);
}

function ShowDHUD(bool newShowDHUD)
{
}

function TickHud(float DeltaTime)
{
    if (ProgressWidgetContainer != none)
    {
        ProgressWidgetContainer.TickHUD(DeltaTime);
    }

    if (TimerWidgetContainer != none)
    {
        TimerWidgetContainer.TickHUD(DeltaTime);
    }


}

defaultproperties
{
    WidgetBindings.Add((WidgetName="IndicatorWidget",WidgetClass=class'Dodeca.DGFxHUD_IndicatorWidget'))
    WidgetBindings.Add((WidgetName="PickupsWidget",WidgetClass=class'Dodeca.DGFxHUD_PickupsWidget'))
    WidgetBindings.Add((WidgetName="ProgressWidgetContainer",WidgetClass=class'Dodeca.DGFxHUD_ProgressWidgetContainer'))
    WidgetBindings.Add((WidgetName="TimerWidgetContainer",WidgetClass=class'Dodeca.DGFxHUD_TimerWidgetContainer'))

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

