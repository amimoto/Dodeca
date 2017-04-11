class DTraderTrigger extends KFTraderTrigger;

const TRADER_OPEN = 1;
const TRADER_OPEN_DURING_WAVE = 2;
const TRADER_WAVE_TARGET = 4;

var() byte TraderActiveShort[4];
var() byte TraderActiveMedium[7];
var() byte TraderActiveLong[10];

function byte TraderBehaviour(byte WaveNum,byte WaveMax)
{
    local byte Behaviour;
    Behaviour = 0;
    if ( WaveMax <= 5 ) {
        Behaviour = TraderActiveShort[WaveNum-1];
    }
    else if ( WaveMax <= 8 ) {
        Behaviour = TraderActiveMedium[WaveNum-1];
    }
    else if ( WaveMax <= 11 ) {
        Behaviour = TraderActiveLong[WaveNum-1];
    }
    return Behaviour;
}

function bool OpenDuringWave(byte WaveNum,byte WaveMax)
{
    return ((TraderBehaviour(WaveNum,WaveMax) & TRADER_OPEN_DURING_WAVE) != 0);
}


simulated function OpenTrader()
{
    local float AnimDuration;
    local Pawn P;

    SetCollision(true, false);

    if ( WorldInfo.NetMode != NM_DedicatedServer)
    {
        if ( TraderMeshActor != None && !bOpened)
        {
            TraderMeshActor.SkeletalMeshComponent.PlayAnim(OpenAnimName);
            AnimDuration = TraderMeshActor.SkeletalMeshComponent.GetAnimLength(OpenAnimName);
            // Need to run this timer on the GRI since this trigger doesn't tick on clients.
            WorldInfo.GRI.SetTimer(AnimDuration, false, nameof(StartTraderLoopAnim), self);
            TraderMeshActor.PlaySoundBase( TraderOpenSound );
        }

        ShowTraderPath();
    }

    foreach TouchingActors(class'Pawn',  P)
    {
        class'KFPlayerController'.static.UpdateInteractionMessages( P );
    }

    bOpened = true;
}

simulated function CloseTrader()
{
    local KFPlayerController KFPC;

    SetCollision(false, false);

    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
        if ( TraderMeshActor != None && bOpened )
        {
            TraderMeshActor.SkeletalMeshComponent.PlayAnim(OpenAnimName,,,,, true);
            TraderMeshActor.PlaySoundBase( TraderCloseSound );
        }
        foreach LocalPlayerControllers(class'KFPlayerController', KFPC)
        {
            KFPC.CloseTraderMenu();
            if( KFPC.Pawn != none )
            {
                class'KFPlayerController'.static.UpdateInteractionMessages( KFPC.Pawn );
            }
        }
    }

    bOpened = false;
}


