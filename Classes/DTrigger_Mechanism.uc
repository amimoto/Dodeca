class DTrigger_Mechanism extends Trigger_PawnsOnly
    implements(KFInterface_Usable);

// Mechanism Actor Object
var() DMechanismActor Mechanism;

// Whether we're active
var() bool Active;

// What the current hack amount is
var() int ActivityPercentage;

// How many points does the hack go up per tick
var() int ActivityRate;

// Usable after hack?
var() bool UsableAfterActivity;

enum EnumActivityStates {
    ACTIVITY_Untouched,
    ACTIVITY_Started,
    ACTIVITY_Complete
};

var int ActivityState;

simulated function bool GetIsUsable( Pawn User )
{
    if ( ActivityState == ACTIVITY_Untouched )
    {
        return true;
    }
    else if ( ActivityState == ACTIVITY_Complete && UsableAfterActivity )
    {
        return true;
    }

    return false;
}

function int GetInteractionIndex( Pawn User )
{
    if ( ActivityState == ACTIVITY_Untouched )
    {
        return IMT_PerformActivity;
    }
    else
    {
        return IMT_UseMechanism;
    }
}

function SetMechanismPostRender( bool bShowIcon )
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
            KFHud.SetPostRenderingFor(bShowIcon, Mechanism);
        }
    }
}

simulated event Touch(Actor Other,
                        PrimitiveComponent OtherComp,
                        vector HitLocation,
                        vector HitNormal)
{
    SetMechanismPostRender(true);

    `log("ObjKTrigger_Mechanism::Touch!");
    Super.Touch(Other, OtherComp, HitLocation, HitNormal);
    if (Role == ROLE_Authority)
    {
        class'DPlayerController'.static.UpdateInteractionMessages(Other);
    }
}

simulated event UnTouch(Actor Other)
{
    `log("ObjKTrigger_Mechanism::UnTouch!");
    super.UnTouch( Other );
    SetMechanismPostRender(false);
    if (Role == ROLE_Authority)
    {
        class'DPlayerController'.static.UpdateInteractionMessages(Other);
    }
}

function bool UsedBy(Pawn User)
{
    local KFPawn_Human KFPH;
    local KFPlayerController KFPC;

    KFPH = KFPawn_Human(User);

    if ( KFPH == none  )
    {
        return false;
    }

    KFPC = KFPlayerController(User.Controller);

    if ( KFPC != none )
    {
        DoActivating(User);
    }

    return false;
}

/* We don't immediately Emit the hacked signal. We wait till the hacking is done 
   To do so, we setup a timer that ticks down */
function DoActivating(Actor Other)
{
    if ( ActivityState == ACTIVITY_Untouched ) {
        ActivityState = Activity_Started;
        SetTimer(0.2,true,nameof(TimerActivating),self);
    }
    else if ( ActivityState == ACTIVITY_Complete )
    {
        EmitUse();
    }
}

function TimerActivating()
{
    if ( Mechanism == none ) {
        ClearTimer(nameof(TimerActivating));
        return;
    };

    // Mechanism.TakeActivatingDamage(ActivityRate);
    if ( Mechanism.IsActivated() ) {
        `log("Mechanism has been activated!");
        ActivityState = ACTIVITY_Complete;
        ClearTimer(nameof(TimerActivating));
        EmitActivated();
    }
}

function EmitActivated()
{
    local array<SequenceObject> ActivatedEvents;
    local DSeqEvent_ActivatedMechanism ActivatedEvent;
    local Sequence GameSeq;
    local int i;

    GameSeq = WorldInfo.GetGameSequence();
    if ( GameSeq != None )
    {
        GameSeq.FindSeqObjectsByClass( class'DSeqEvent_ActivatedMechanism', true, ActivatedEvents );
        for ( i=0; i<ActivatedEvents.Length; i++ )
        {
            ActivatedEvent = DSeqEvent_ActivatedMechanism(ActivatedEvents[i]);
            if (ActivatedEvent != None)
            {
                ActivatedEvent.Reset();
                ActivatedEvent.CheckActivate(self,self);
            }
        }
    }
}


function EmitUse()
{
    local array<SequenceObject> UseConsoleEvents;
    local DSeqEvent_UseConsole UseConsoleEvent;
    local Sequence GameSeq;
    local int i;

    GameSeq = WorldInfo.GetGameSequence();
    if ( GameSeq != None )
    {
        GameSeq.FindSeqObjectsByClass( class'DSeqEvent_UseMechanism', true, UseConsoleEvents );
        for ( i=0; i<UseConsoleEvents.Length; i++ )
        {
            UseConsoleEvent = DSeqEvent_UseConsole(UseConsoleEvents[i]);
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

    Active = True



    ActivityPercentage = 0
    ActivityRate = 1
    ActivityState = ACTIVITY_Untouched

    SupportedEvents.Add(class'DSeqEvent_ActivatedMechanism')
    SupportedEvents.Add(class'DSeqEvent_UseMechanism')

    UsableAfterActivity = true
}

