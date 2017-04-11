class DTrigger_TrapDart extends Trigger_PawnsOnly;

/** reference to actor to play open/close animations */
var() SkeletalMeshActor TrapMeshActor;

var() float Cooldown;
var() int RoundsFired;
var KFWeap_Bow_Crossbow XBow;


function class<Projectile> GetProjectileClass()
{
    return class'KFProj_Bolt_Crossbow';
}

simulated function Projectile ProjectileFire()
{
    local vector        StartTrace, RealStartLoc, AimDir;
    // local vector EndTrace;
    //local ImpactInfo    TestImpact;
    local Projectile    SpawnedProjectile;

    if( Role == ROLE_Authority )
    {
        // This is where we would start an instant trace. (what CalcWeaponFire uses)
        //StartTrace = P.GetWeaponStartTraceLocation();
        StartTrace = TrapMeshActor.Location;
        AimDir = StartTrace;

        // this is the location where the projectile is spawned.
        // RealStartLoc = GetPhysicalFireStartLoc(AimDir);
        RealStartLoc = AimDir;

        // Spawn projectile
        SpawnedProjectile = Spawn(GetProjectileClass(), Self,, RealStartLoc);
        if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
        {
            SpawnedProjectile.Init( AimDir );
        }

        // Return it up the line
        return SpawnedProjectile;
    }

    return None;
}


event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
    local Pawn P;
    local PlayerController PC;

    `log("DTrapTrigger_Dart::Touch!");
    Super.Touch(Other, OtherComp, HitLocation, HitNormal);

    P = Pawn(Other);
    if( P != none )
    {
        Instigator = P;
        PC = PlayerController( P.Controller );
        ProjectileFire();
        if( PC != none && PC.Role == ROLE_AUTHORITY )
        {
            //PC.SetTimer( 1.f, true, nameof(CheckCurrentUsableActor), PC );
            PC.ReceiveLocalizedMessage(
                class'KFLocalMessage_Interaction',
                IMT_AcceptObjective
            );
        }
    }
}

/** HUD */
event UnTouch(Actor Other)
{
    `log("DTrapTrigger_Dart::UnTouch!");
    super.UnTouch( Other );
    class'KFPlayerController'.static.UpdateInteractionMessages( Other );
}


defaultproperties
{
    Begin Object NAME=CollisionCylinder LegacyClassName=Trigger_TriggerCylinderComponent_Class
        CollisionRadius=+00400.000000
        CollisionHeight=+00160.000000
        BlockZeroExtent=false
    End Object
}


