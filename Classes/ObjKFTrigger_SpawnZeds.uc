class ObjKFTrigger_SpawnZeds extends Trigger_PawnsOnly;

struct StructSpawnTarget
{
    /** Name of the Zed to spawn at the target */
    var() string ZedName;
    /** The KFPathNode that this Zed should spawn */
    var() KFPathNode SpawnTarget;
};

/** A list of all the spawns */
var() array<StructSpawnTarget> SpawnTargets;

/** If the trigger is not one-shot, how long before this can reapawn (in seconds). If '0', Trigger is one-shot */
var() int CoolDown;

var bool Triggered;

/** Get a zed class from the name */
function class<KFPawn_Monster> LoadMonsterByName(string ZedName, optional bool bIsVersusPawn )
{
    local string VersusSuffix;
    local class<KFPawn_Monster> SpawnClass;

    VersusSuffix = bIsVersusPawn ? "_Versus" : "";

    // Get the correct archetype for the ZED
    if( Left(ZedName, 5) ~= "ClotA" )
    {
        SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedClot_Alpha"$VersusSuffix, class'Class'));
    }
    else if( Left(ZedName, 5) ~= "ClotS" )
    {
        SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedClot_Slasher"$VersusSuffix, class'Class'));
    }
    else if( Left(ZedName, 5) ~= "ClotC" )
    {
        SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedClot_Cyst"$VersusSuffix, class'Class'));
    }
    else if( ZedName ~= "CLOT" )
    {
        SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedClot_Cyst"$VersusSuffix, class'Class'));
    }
    else if( Left(ZedName, 3) ~= "FHa" )
    {
        SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedHansFriendlyTest"$VersusSuffix, class'Class'));
    }
    else if( Left(ZedName, 3) ~= "FHu" )
    {
        SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedHuskFriendlyTest"$VersusSuffix, class'Class'));
    }
    else if( Left(ZedName, 1) ~= "F" )
    {
        SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedFleshpound"$VersusSuffix, class'Class'));
    }
    else if( Left(ZedName, 3) ~= "GF2" )
    {
        SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedGorefastDualBlade"$VersusSuffix, class'Class'));
    }
    else if( Left(ZedName, 1) ~= "G" )
    {
        SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedGorefast"$VersusSuffix, class'Class'));
    }
    else if( Left(ZedName, 2) ~= "St" )
    {
        SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedStalker"$VersusSuffix, class'Class'));
    }
    else if( Left(ZedName, 1) ~= "B" )
    {
        SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedBloat"$VersusSuffix, class'Class'));
    }
    else if( Left(ZedName, 2) ~= "Sc" )
    {
        SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedScrake"$VersusSuffix, class'Class'));
    }
    else if( Left(ZedName, 2) ~= "Pa" )
    {
        SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedPatriarch"$VersusSuffix, class'Class'));
    }
    else if( Left(ZedName, 2) ~= "Cr" )
    {
        SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedCrawler"$VersusSuffix, class'Class'));
    }
    else if( Left(ZedName, 2) ~= "Hu" )
    {
        SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedHusk"$VersusSuffix, class'Class'));
    }
    else if( Left(ZedName, 8) ~= "TestHusk" )
    {
        SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedHusk_New"$VersusSuffix, class'Class'));
    }
    else if( Left(ZedName, 2) ~= "Ha" )
    {
        SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedHans"$VersusSuffix, class'Class'));
    }
    else if( Left(ZedName, 2) ~= "Si" )
    {
        return class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedSiren"$VersusSuffix, class'Class'));
    }
    else if( Left(ZedName, 1) ~= "P")
    {
        SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedPatriarch"$VersusSuffix, class'Class'));
    }

    if( SpawnClass != none )
    {
        SpawnClass = SpawnClass.static.GetAIPawnClassToSpawn();
    }

    if( SpawnClass == none )
    {
        return none;
    }
    return SpawnClass;
}


simulated function KFPawn SpawnZed(string ZedName, KFPathNode SpawnTarget, optional bool bNoCollisionFail)
{
    local class<KFPawn> SpawnClass;
    local vector SpawnLoc;
    local rotator SpawnRot;
    local KFPawn KFP;


    SpawnClass = LoadMonsterByName(ZedName);

    SpawnLoc = SpawnTarget.Location;
    SpawnRot.Yaw = Rotation.Yaw + 32768;

    KFP = Spawn(SpawnClass, , , SpawnLoc, SpawnRot,, bNoCollisionFail);
    if ( KFP == None )
        return KFP;

    KFP.SetPhysics(PHYS_Falling);
    KFGameInfo(WorldInfo.Game).SetMonsterDefaults( KFPawn_Monster(KFP));
    if( KFP.Controller != none && KFAIController(KFP.Controller) != none )
    {
        KFGameInfo(WorldInfo.Game).GetAIDirector().AIList.AddItem( KFAIController(KFP.Controller) );
    }

    return KFP;
}

simulated function SpawnAI(string ZedName, KFPathNode SpawnTarget)
{
    local KFPawn Zed;

    Zed = SpawnZed(ZedName,SpawnTarget);
    if ( Zed == None )
          return;

    Zed.SpawnDefaultController();
    if( KFAIController(Zed.Controller) == none )
          return;

    KFAIController( Zed.Controller ).SetTeam(1);
}

function Timer_ResetTrigger()
{
    Triggered = false;
}

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
    local StructSpawnTarget SpawnTarget;

    if ( !Triggered && Pawn(Other).Isa('KFPawn_Human') ) {

        Triggered = true;

        foreach SpawnTargets(SpawnTarget)
        {
            SpawnAI(SpawnTarget.ZedName,SpawnTarget.SpawnTarget);
        }

        if ( CoolDown > 0 ) {
            SetTimer(
                CoolDown,
                false,
                nameof(Timer_ResetTrigger),
                self
            );
        }
    }

    Super.Touch(Other, OtherComp, HitLocation, HitNormal);
}

event UnTouch(Actor Other)
{
    `log("ObjKTrigger_SpawnZeds::UnTouch!");
    super.UnTouch( Other );
}

defaultproperties
{
    Begin Object NAME=CollisionCylinder LegacyClassName=Trigger_TriggerCylinderComponent_Class
        CollisionRadius=+00400.000000
        CollisionHeight=+00160.000000
        BlockZeroExtent=false
    End Object

    OneShot = false
    Triggered = false
}




