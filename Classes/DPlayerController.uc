class DPlayerController extends KFGame.KFPlayerController;

var DGFxMoviePlayer_HUD DMyGFxHud;
var DGFxMoviePlayer_DHUD DMyGFxDHud;

function SetGFxHUD( KFGFxMoviePlayer_HUD NewGFxHud )
{
    `log("Setting the HUD to:"@NewGFxHud);
    DMyGFxHud = DGFxMoviePlayer_HUD(NewGFxHud);
    Super.SetGFxHUD(NewGFxHud);
    DMyGFxHud.CreateDHUD();
    DMyGFxDHud = DMyGFxHud.GfxDHUDPlayer;
}

function bool PerformedUseAction()
{
    return Super.PerformedUseAction();
}

static function UpdateInteractionMessages( Actor InteractingActor )
{
    local KFInterface_Usable UsableActor;
    local Pawn P;
    local PlayerController PC;

    P = Pawn(InteractingActor);
    if( P != none )
    {
        PC = PlayerController( P.Controller );
        if( PC != none && PC.Role == ROLE_AUTHORITY )
        {
            UsableActor = GetCurrentUsableActor( P );
            if( UsableActor != none )
            {
                PC.SetTimer( 1.f, true, nameof(CheckCurrentUsableActor), PC );
                PC.ReceiveLocalizedMessage( class'DLocalMessage_Interaction', UsableActor.GetInteractionIndex( P ) );
            }
            else
            {
                PC.ClearTimer( nameof(CheckCurrentUsableActor), PC );
                PC.ReceiveLocalizedMessage( class'KFLocalMessage_Interaction', IMT_None );
            }
        }
    }
}


static simulated function DInterface_Mechanism GetCurrentMechanismActor( Pawn P, optional bool bUseOnFind=false )
{
    local Actor A;
    local DInterface_Mechanism MechanismActor;

    if ( P == None ) return None;

    foreach P.TouchingActors(class'Actor', A)
    {
        MechanismActor = DInterface_Mechanism(A);
        if ( MechanismActor != None )
        {
            return MechanismActor;
        }
    }

    return None;
}

static function UpdateMechanismMessages( Actor InteractingActor )
{
    local DInterface_Mechanism MechanismActor;
    local Pawn P;
    local DPlayerController PC;

    P = Pawn(InteractingActor);
    if( P != none )
    {
        PC = DPlayerController( P.Controller );
        if( PC != none && PC.Role == ROLE_AUTHORITY )
        {
            MechanismActor = GetCurrentMechanismActor(P);
            if ( MechanismActor != none )
            {
                PC.DMyGFxDHud.ProgressWidgetContainer.Ingest(MechanismActor);
            }
            else
            {
                PC.DMyGFxDHud.ProgressWidgetContainer.Hide();
            }
        }
    }
}

defaultproperties
{
    InputClass=class'Dodeca.DPlayerInput'
}


