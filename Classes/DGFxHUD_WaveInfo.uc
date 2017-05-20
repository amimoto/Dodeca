//=============================================================================
// Subclass and hide the WaveInfo widget
//=============================================================================

class DGFxHUD_WaveInfo extends KFGFxHUD_WaveInfo;

var float CurrentAlpha;

function InitializeHUD()
{
    Super.InitializeHUD();
    Hide();
}


function Hide()
{
    SetAlpha(0.0);
}

function Show()
{
    SetAlpha(1.0);
}

function SetAlpha(float alpha)
{
    local ASDisplayInfo displayInfo;

    CurrentAlpha = alpha;
    displayInfo = GetDisplayInfo();
    displayInfo.Alpha = alpha;
    SetDisplayInfo(displayInfo);
}


