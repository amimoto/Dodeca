class DGFxMoviePlayer_HUD extends KFGFxMoviePlayer_HUD;

var DGFxMoviePlayer_DHUD GfxDHUDPlayer;
var class<DGFxMoviePlayer_DHUD> DHUDClass;

function CreateDHUD()
{
    if(GfxDHUDPlayer == none)
    {
        `log("About to create the player with:"@DHUDClass);
        GfxDHUDPlayer = new DHUDClass;
        GfxDHUDPlayer.SetTimingMode(TM_Real);
        GfxDHUDPlayer.Init(class'Engine'.static.GetEngine().GamePlayers[GfxDHUDPlayer.LocalPlayerOwnerIndex]);
    }
}

event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
    `log("Called WidgetInitialized with "@WidgetName);
    return Super.WidgetInitialized(WidgetName, WidgetPath, Widget);
}

function ShowDHUD(bool newShowDHUD )
{
    if ( GfxDHUDPlayer == none )
    {
        CreateDHUD();
    }

    if ( GfxDHUDPlayer != none )
    {
        GfxDHUDPlayer.ShowDHUD(newShowDHUD);
    }
}


function CreateScoreboard()
{
    ShowDHUD(false);
}

function TickHud(float DeltaTime)
{
      Super.TickHud(DeltaTime);
      if ( GfxDHUDPlayer != none )
      {
          GfxDHUDPlayer.TickHud(DeltaTime);
      }
}

// FIXME: For now...
function UpdateWaveCount()
{
    Super.UpdateWaveCount();
}


defaultproperties
{
    DHUDClass=class'DGFxMoviePlayer_DHUD'
}
