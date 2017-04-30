class DTrigger_Mechanism extends Trigger_PawnsOnly
implements(DInterface_Mechanism)
;

// Mechanism Actor Object
var() DActor_Mechanism Mechanism;

// Whether we're active
var() bool Active;

// How many points does the activity go up per tick
var() int ActivityRate;

// Usable after completion?
var() bool UsableAfterActivity;

// Has this mechanism activated (enabled?)
var() bool Activated;

simulated function bool CanBeActivated( Pawn User )
{
    if ( !Activated )
    {
        return true;
    }
    return false;
}

function string ActivationString()
{
    if ( Mechanism == none ) return "";
    return Mechanism.ActivityInstructions;
}

function int ActivationPercentage()
{
    if ( Mechanism == none ) return 0;
    return (
        100 - 100 * Mechanism.ActivityIntegrity
                  / Mechanism.MaxActivityIntegrity
    );
}

simulated function bool GetIsUsable( Pawn User )
{
    if ( Activated && UsableAfterActivity )
    {
        return true;
    }

    return false;
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

function DoActivationWork()
{
    if ( Mechanism == None ) return;
    Mechanism.TakeActivatingWork(ActivityRate);
    if ( Mechanism.IsActivated() ) {
        Activated = True;
        EmitActivated();
    }
}

simulated event Touch(Actor Other,
                        PrimitiveComponent OtherComp,
                        vector HitLocation,
                        vector HitNormal)
{
    SetMechanismPostRender(true);
    Super.Touch(Other, OtherComp, HitLocation, HitNormal);
    if (Role == ROLE_Authority)
    {
        class'DPlayerController'.static.UpdateMechanismMessages(Other);
    }
}

simulated event UnTouch(Actor Other)
{
    super.UnTouch( Other );
    SetMechanismPostRender(false);
    if (Role == ROLE_Authority)
    {
        class'DPlayerController'.static.UpdateMechanismMessages(Other);
    }
}

/* We don't immediately Emit the completion signal. We wait till the activity is done
   To do so, we setup a timer that ticks down */
function DoActivating(Actor Other)
{
    if ( Activated )
    {
        EmitUse();
    }
}

function EmitActivated()
{
    self.TriggerEventClass(class'DSeqEvent_ActivatedMechanism',self,-1);
}


function EmitUse()
{
    self.TriggerEventClass(class'DSeqEvent_UseMechanism',self,-1);
}


defaultproperties
{
    Begin Object NAME=CollisionCylinder LegacyClassName=Trigger_TriggerCylinderComponent_Class
        CollisionRadius=+00100.000000
        CollisionHeight=+00160.000000
        BlockZeroExtent=false
    End Object

    Active = True
    Activated = False

    ActivityRate = 1

    SupportedEvents.Add(class'DSeqEvent_ActivatedMechanism')
    SupportedEvents.Add(class'DSeqEvent_UseMechanism')

    UsableAfterActivity = true
}

