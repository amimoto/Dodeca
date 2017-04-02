class ObjKFTrigger_Hackable extends Trigger_PawnsOnly
    implements(KFInterface_Usable);

// Hackable Actor Object
var() ObjHackableActor Hackable;

// What the current hack amount is
var() int HackPercentage;

// How many points does the hack go up per tick
var() int HackRate;

// Usable after hack?
var() bool UsableAfterHack;

enum EnumHackStates {
    HACK_Untouched,
    HACK_Started,
    HACK_Complete
};

var int HackState;

simulated function bool GetIsUsable( Pawn User )
{
    if ( HackState == HACK_Untouched )
    {
        return true;
    }
    else if ( HackState == HACK_Complete && UsableAfterHack )
    {
        return true;
    }

    return false;
}

function int GetInteractionIndex( Pawn User )
{
    if ( HackState == HACK_Untouched )
    {
        return IMT_PerformHack;
    }
    else
    {
        return IMT_UseConsole;
    }
}

function SetHackablePostRender( bool bShowIcon )
{
    local PlayerController PC;
    local KFHUDBase KFHud;

    // final local player's hud object
    ForEach LocalPlayerControllers(class'PlayerController', PC)
    {
        KFHud = KFHUDBase(PC.MyHUD);
        if ( KFHud != None )
        {
            // Add self to player HUD PostRenderedActor list
            KFHud.SetPostRenderingFor(bShowIcon, Hackable);
        }
    }
}

simulated event Touch(Actor Other,
                        PrimitiveComponent OtherComp,
                        vector HitLocation,
                        vector HitNormal)
{
    SetHackablePostRender(true);

    `log("ObjKTrigger_Hackable::Touch!");
    Super.Touch(Other, OtherComp, HitLocation, HitNormal);
    if (Role == ROLE_Authority)
    {
        class'ObjKFPlayerController'.static.UpdateInteractionMessages(Other);
    }
}

simulated event UnTouch(Actor Other)
{
    `log("ObjKTrigger_Hackable::UnTouch!");
    super.UnTouch( Other );
    SetHackablePostRender(false);
    if (Role == ROLE_Authority)
    {
        class'ObjKFPlayerController'.static.UpdateInteractionMessages(Other);
    }
}

function bool UsedBy(Pawn User)
{
    local KFPawn_Human KFPH;
    local KFPlayerController KFPC;

    `log("KFTrigger_Hackable::UsedBy! Trader:" @ self);

    KFPH = KFPawn_Human(User);

    if ( KFPH == none  )
    {
        return false;
    }

    KFPC = KFPlayerController(User.Controller);

    if ( KFPC != none )
    {
        DoHacking(User);
    }

    return false;
}

/* We don't immediately Emit the hacked signal. We wait till the hacking is done 
   To do so, we setup a timer that ticks down */
function DoHacking(Actor Other)
{
    if ( HackState == HACK_Untouched ) {
        HackState = Hack_Started;
        SetTimer(0.2,true,nameof(TimerHacking),self);
    }
    else if ( HackState == HACK_Complete )
    {
        EmitUse();
    }
}

function TimerHacking()
{
    if ( Hackable == none ) {
        ClearTimer(nameof(TimerHacking));
        return;
    };

    Hackable.TakeHackingDamage(HackRate);
    if ( Hackable.IsHacked() ) {
        `log("Door has been hacked!");
        HackState = HACK_Complete;
        ClearTimer(nameof(TimerHacking));
        EmitHacked();
    }
}

function EmitHacked()
{
    local array<SequenceObject> HackedEvents;
    local ObjSeqEvent_Hacked HackedEvent;
    local Sequence GameSeq;
    local int i;

    GameSeq = WorldInfo.GetGameSequence();
    if ( GameSeq != None )
    {
        GameSeq.FindSeqObjectsByClass( class'ObjSeqEvent_Hacked', true, HackedEvents );
        for ( i=0; i<HackedEvents.Length; i++ )
        {
            HackedEvent = ObjSeqEvent_Hacked(HackedEvents[i]);
            if (HackedEvent != None)
            {
                HackedEvent.Reset();
                HackedEvent.CheckActivate(self,self);
            }
        }
    }
}


function EmitUse()
{
    local array<SequenceObject> UseConsoleEvents;
    local ObjSeqEvent_UseConsole UseConsoleEvent;
    local Sequence GameSeq;
    local int i;

    GameSeq = WorldInfo.GetGameSequence();
    if ( GameSeq != None )
    {
        GameSeq.FindSeqObjectsByClass( class'ObjSeqEvent_UseConsole', true, UseConsoleEvents );
        for ( i=0; i<UseConsoleEvents.Length; i++ )
        {
            UseConsoleEvent = ObjSeqEvent_UseConsole(UseConsoleEvents[i]);
            if (UseConsoleEvent != None)
            {
                UseConsoleEvent.Reset();
                UseConsoleEvent.CheckActivate(self,self);
            }
        }
    }
}


defaultproperties
{
    Begin Object NAME=CollisionCylinder LegacyClassName=Trigger_TriggerCylinderComponent_Class
        CollisionRadius=+00100.000000
        CollisionHeight=+00160.000000
        BlockZeroExtent=false
    End Object

    HackPercentage = 0
    HackRate = 1
    HackState = HACK_Untouched

    SupportedEvents.Add(class'ObjSeqEvent_Hacked')
    SupportedEvents.Add(class'ObjSeqEvent_UseConsole')

    UsableAfterHack = true
}

