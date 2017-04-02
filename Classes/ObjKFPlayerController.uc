class ObjKFPlayerController extends KFGame.KFPlayerController;

var ObjKFGFxMoviePlayer_HUD ObjMyGFxHud;

function SetGFxHUD( KFGFxMoviePlayer_HUD NewGFxHud )
{
    `log("Setting the HUD to:"@NewGFxHud);
    ObjMyGFxHud = ObjKFGFxMoviePlayer_HUD(NewGFxHud);
    Super.SetGFxHUD(NewGFxHud);
}

static function UpdateInteractionMessages( Actor InteractingActor )
{
    local KFInterface_Usable UsableActor;
    local Pawn P;
    local PlayerController PC;

    `log("Calling ObjUpdateInteractionMessages with " @ InteractingActor);

    P = Pawn(InteractingActor);
    if( P != none )
    {
        PC = PlayerController( P.Controller );
        if( PC != none && PC.Role == ROLE_AUTHORITY )
        {
            UsableActor = GetCurrentUsableActor( P );
            `log("Usable Actor" @ P);
            if( UsableActor != none )
            {
                PC.SetTimer( 1.f, true, nameof(CheckCurrentUsableActor), PC );
                PC.ReceiveLocalizedMessage( class'ObjKFLocalMessage_Interaction', UsableActor.GetInteractionIndex( P ) );
            }
            else
            {
                PC.ClearTimer( nameof(CheckCurrentUsableActor), PC );
                PC.ReceiveLocalizedMessage( class'KFLocalMessage_Interaction', IMT_None );
            }
        }
    }
}



defaultproperties
{
    InputClass=class'Objectives.ObjKFPlayerInput'
}


