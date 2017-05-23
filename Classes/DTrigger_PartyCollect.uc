class DTrigger_PartyCollect extends Trigger_PawnsOnly
    implements(KFInterface_Usable)
    ;

// This trigger forces the Player Party to regroup to
// be present in the same trigger

// Wait for someone to "use" this trigger before activating it
var() bool WaitForPlayerActivation;

// Returns a true value if the players can trigger
simulated function bool GetIsUsable( Pawn User )
{
    return WaitForPlayerActivation;
}

// What to do when triggered by the use command
function bool UsedBy( Pawn User )
{
    local int MessageSwitch;
    local string UsedByMessage;
    local KFPlayerController KFPC;
    local KFGFxHudWrapper GFxHUDWrapper;
    local DGFxMoviePlayer_HUD DGFxHUD;

    if ( AllPlayersPresent() )
    {
        MessageSwitch = IMT_PartyActivating;
    }
    else
    {
        MessageSwitch = IMT_PartyCannotActivate;
    }

    UsedByMessage = Class'DLocalMessage_Interaction'.static.GetString(
                        MessageSwitch
                        );

    foreach LocalPlayerControllers(class'KFPlayerController', KFPC)
    {
        GFxHUDWrapper = KFGFxHudWrapper(KFPC.myHUD);
        DGFxHUD = DGFxMoviePlayer_HUD(GFxHUDWrapper.HudMovie);
        DGFxHUD.ShowNonCriticalMessage(UsedByMessage);
    }

    EmitReady();

    return true;
}

// Used to display what can be done to the Player
function int GetInteractionIndex( Pawn User )
{
    if ( AllPlayersPresent() ) {
        return IMT_PartyComplete;
    }
    else
    {
        return IMT_PartyIncomplete;
    }
}

// Returns true if player is touching this trigger
function bool PlayerPresent( KFPawn_Human TeamMember, optional Actor ExceptMember )
{
    local KFPawn_Human Toucher;
    foreach TouchingActors(class'KFPawn_Human', Toucher)
    {
        if ( ExceptMember == none || KFPawn_Human(ExceptMember) != TeamMember )
            if ( Toucher == TeamMember )
                return true;
    }
    return false;
}

// Returns true when all players are touching this trigger
function bool AllPlayersPresent(optional Actor ExceptMember)
{
    local KFPawn_Human TeamMember;

    // Yeah, this is a terrible cartesian product. Should be
    // pretty fast though
    foreach WorldInfo.AllPawns( class'KFPawn_Human', TeamMember )
    {
        if ( !PlayerPresent(TeamMember,Exceptmember) )
            return false;
    }

    return true;
}

// Returns true when there are any players present in the
// trigger
function bool AnyPlayersPresent(optional Actor ExceptMember)
{
    local KFPawn_Human TeamMember;

    // Yeah, this is a terrible cartesian product. Should be
    // pretty fast though
    foreach WorldInfo.AllPawns( class'KFPawn_Human', TeamMember )
    {
        if ( PlayerPresent(TeamMember,ExceptMember) )
            return true;
    }

    return false;
}

function BroadcastStatus( optional Actor ExceptMember )
{
    local PlayerController PC;
    local bool AllPresent;
    local KFPawn_Human TeamMember;

    AllPresent = AllPlayersPresent(ExceptMember);

    if ( AllPresent )
        EmitPartyComplete();

    foreach WorldInfo.AllPawns( class'KFPawn_Human', TeamMember )
    {
        PC = PlayerController( TeamMember.Controller );
        if( PC != none )
        {
            if ( AllPresent )
            {
                    PC.ReceiveLocalizedMessage( class'KFLocalMessage_Interaction', IMT_None );
                    PC.ReceiveLocalizedMessage(
                        class'DLocalMessage_Interaction',
                        IMT_PartyComplete
                    );
            }
            else if ( PlayerPresent(TeamMember,ExceptMember) )
            {
                    PC.ReceiveLocalizedMessage( class'KFLocalMessage_Interaction', IMT_None );
                    PC.ReceiveLocalizedMessage(
                        class'DLocalMessage_Interaction',
                        IMT_PartyIncomplete
                    );
            }
            else
            {
                    PC.ReceiveLocalizedMessage( class'KFLocalMessage_Interaction', IMT_None );
                    PC.ReceiveLocalizedMessage(
                        class'DLocalMessage_Interaction',
                        IMT_PartyPlayerRequired
                    );
            }
        }
    }
}

simulated event Touch(Actor Other,
                        PrimitiveComponent OtherComp,
                        vector HitLocation,
                        vector HitNormal)
{
    Super.Touch(Other, OtherComp, HitLocation, HitNormal);
    if ( DPawn_Human(Other) == none )
    {
        return;
    }

    BroadcastStatus();
}

simulated event UnTouch(Actor Other)
{
    super.UnTouch( Other );
    if ( DPawn_Human(Other) == none )
    {
        return;
    }

    if ( AnyPlayersPresent( Other ) )
    {
        BroadcastStatus( Other );
    }
    else {
        class'DPlayerController'.static.BroadcastUpdateInteractionMessages(Other);
    }
}


function EmitPartyComplete()
{
    TriggerEventClass(class'DSeqEvent_PartyComplete',self,-1);
}


function EmitReady()
{
    TriggerEventClass(class'DSeqEvent_PartyReady',self,-1);
}

defaultproperties
{
    Begin Object NAME=CollisionCylinder LegacyClassName=Trigger_TriggerCylinderComponent_Class
        CollisionRadius=+00200.000000
        CollisionHeight=+00160.000000
        BlockZeroExtent=false
    End Object

    SupportedEvents.Add(class'DSeqEvent_PartyComplete')
    SupportedEvents.Add(class'DSeqEvent_PartyReady')

}
