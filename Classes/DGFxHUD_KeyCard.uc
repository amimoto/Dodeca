class DGFxHUD_KeyCard extends GFxObject;

function InitializeWidget()
{
}

function TickHud(float DeltaTime)
{
}

function SetKeycard(int cardIndex, int cardState)
{
    switch ( cardIndex )
    {
        case 0:
            SetInt("keycardRed", cardState);
            break;
        case 1:
            SetInt("keycardGreen", cardState);
            break;
        case 2:
            SetInt("keycardBlue", cardState);
            break;
    }
}

defaultproperties
{
}

