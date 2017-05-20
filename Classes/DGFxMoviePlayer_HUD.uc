class DGFxMoviePlayer_HUD extends KFGFxMoviePlayer_HUD;

var DGFxMoviePlayer_DHUD GfxDHUDPlayer;
var class<DGFxMoviePlayer_DHUD> DHUDClass;

function Init(optional LocalPlayer LocPlay)
{
    Super.Init(LocPlay);
}

function CreateDHUD(optional LocalPlayer LocPlay)
{
    if(GfxDHUDPlayer == none)
    {
        `log("About to create the player with:"@DHUDClass);
        GfxDHUDPlayer = new DHUDClass(LocPlay);
        GfxDHUDPlayer.SetTimingMode(TM_Real);
        GfxDHUDPlayer.Init(class'Engine'.static.GetEngine().GamePlayers[GfxDHUDPlayer.LocalPlayerOwnerIndex]);
    }
}

event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
    `log("Called WidgetInitialized with "@WidgetName);
    switch(WidgetName)
    {
        case 'WaveInfoContainer':
            if ( WaveInfoWidget == none )
            {
                WaveInfoWidget = KFGFxHUD_WaveInfo(Widget);
                `log("WaveInfoContainer has been setup with"$Widget);
                WaveInfoWidget.InitializeHUD();
                SetWidgetPathBinding( Widget, WidgetPath );
            }
            break;

    }

    return Super.WidgetInitialized(WidgetName, WidgetPath, Widget);
}

/*
function ShowScoreboard(bool newShowScoreboard)
{
    Super.ShowScoreboard(newShowScoreboard);
    GfxDHUDPlayer.ProgressWidget.Show();
}
*/

function TickHud(float DeltaTime)
{
    Super.TickHud(DeltaTime);
    if ( GfxDHUDPlayer != none )
    {
        GfxDHUDPlayer.TickHud(DeltaTime);
    }
}


defaultproperties
{
    DHUDClass=class'DGFxMoviePlayer_DHUD'
    WidgetBindings(9) = (WidgetName="WaveInfoContainer", WidgetClass=class'DGFxHUD_WaveInfo')
}
