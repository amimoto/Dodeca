class DGFxHUD_IndicatorWidget extends GFxObject;

function InitializeWidget()
{
}

function TickHud(float DeltaTime)
{
}

function SetIndicator(int indicatorIndex, int indicatorState)
{
    switch ( indicatorIndex )
    {
        case 0:
            SetInt("indicatorRed", indicatorState);
            break;
        case 1:
            SetInt("indicatorGreen", indicatorState);
            break;
        case 2:
            SetInt("indicatorBlue", indicatorState);
            break;
    }
}


defaultproperties
{
}


