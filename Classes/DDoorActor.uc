class ObjKFDoorActor extends KFDoorActor;

/* There's some funny business that must be done to play with the
   AI so that it thinks that the door is locked shut. By setting
   the Door's WeldIntegrity to a non-zero value, Zed AI will
   natually perform attacks on the door.
*/


/** UI icon used for lock */
var protected Texture2D LockedIcon;

/** UI icon size */
var() int LockedIconSize;

/* If the door may not be opened by either player or Zed */
var() bool Locked;

/* If while locked, door does not take damage */
var() bool InvulnerableWhileLocked;

// FIXME Does this need to be repnotified?
var int OldWeldIntegrity;

replication
{
    if ( bNetDirty )
        Locked;
}

simulated event PostBeginPlay()
{
    /* Any "locked" doors should started locked and not open */
    if ( Locked )
    {
        Lock();
    }
    Super.PostBeginPlay();
}

simulated event ReplicatedEvent(name VarName)
{
    if (VarName == nameof(Locked))
    {
        if ( Locked ) {
            Lock();
        }
        else
        {
            UnLock();
        }
    }
    else
    {
        Super.ReplicatedEvent(VarName);
    }
}

/** Handling Toggle event from Kismet. */
simulated function OnToggle(SeqAct_Toggle action)
{
    Super.OnToggle(action);
}


function Lock()
{
    // If door has been locked, it's dirty
    bHasBeenDirtied = true;

    Locked = true;
    OldWeldIntegrity = WeldIntegrity;
    WeldIntegrity = 1;

    if ( bIsDoorOpen )
    {
       bIsDoorOpen = false;
        bForceNetUpdate = true;
        bDoorMoveCompleted = false;

        // Local (non-replicated) open flag
        bLocalIsDoorOpen = false;

        SetTickIsDisabled(false);
        MovementControl.SetSkelControlActive(false);

        if ( DoorMechanism == EDM_Hinge )
        {
            SetTimer(OpenBlendTime * 0.65, false, nameof(TryPushPawns));
        }
        else
        {
            SetTimer(OpenBlendTime * 0.5, false, nameof(TryPushPawns));
        }
    }
}

function UnLock()
{
    // If door has been unlocked, it's dirty
    bHasBeenDirtied = true;

    Locked = false;
    WeldIntegrity = OldWeldIntegrity;
}

event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
    if ( Locked && InvulnerableWhileLocked ) {
        // Don't take any damage if door is locked and shouldn't
        // take damage while locked
        return;
    }

    Super.TakeDamage(Damage,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);
}

simulated event DrawDoorHUD( HUD HUD, Canvas C )
{
    local PlayerController  PC;
    local Vector    CameraLoc, ScreenLoc;
    local Rotator   CameraRot;
    local float     X, Y;
    local float     TextureScale;
    local float DOT;

    if ( !Locked ) {
        Super.DrawDoorHUD(HUD,C);
        return;
    };

    PC = HUD.PlayerOwner;
    C.SetDrawColor(255,255,255);
    C.Font = class'KFGameEngine'.Static.GetKFCanvasFont();
    // project location onto the hud
    PC.GetPlayerViewPoint( CameraLoc, CameraRot );

    Dot = vector(CameraRot) dot (Location - CameraLoc);
    if( Dot < 0.5f )
    {
        return;
    }
    ScreenLoc = C.Project( WeldUILocation );
    if( ScreenLoc.X < 0 || ScreenLoc.X + LockedIconSize * 3 >= C.ClipX || ScreenLoc.Y < 0 && ScreenLoc.Y >= C.ClipY)
    {
        return;
    }
    TextureScale = float(LockedIconSize) / LockedIcon.SizeY;
    C.SetPos(ScreenLoc.X - LockedIconSize / 2, ScreenLoc.Y - LockedIconSize / 2, ScreenLoc.Z);
    C.DrawTexture( LockedIcon, TextureScale );

    X = ScreenLoc.X + LockedIconSize/2 + 5;
    Y = ScreenLoc.Y - LockedIconSize/2;
    C.SetPos( X, Y );
}

defaultproperties
{
    Locked = true
    InvulnerableWhileLocked = false;

    // UI
    LockedIcon=Texture2D'Dodeca_UI.locked_icon'
    LockedIconSize=32
}

