class DAISpawnManager extends KFAISpawnManager;

`include(ControlledDifficulty/CD_Log.uci)

/*********************************************************************************************
 * CD Variables
 *********************************************************************************************/

// Authoritative list of known SpawnCycle presets
var CD_SpawnCycleCatalog SpawnCycleCatalog;

var array<CD_AIWaveInfo> CustomWaves;

var DAISpawnSquads MySpawnSquads;

// Remaining AI from last squad
var array< class<KFPawn_Monster> > NextAIToSpawn;

/*********************************************************************************************
 * Base Functions
 *********************************************************************************************/

/*********************************************************************************************
 * Base Functions
 *********************************************************************************************/

function DInitialize( CD_ConsolePrinter NewCDCP )
{
    Initialize();

    MySpawnSquads = new class'DAISpawnSquads';
    MySpawnSquads.Initialize("4CY,1CR*_2CY_1AL*_1GF,6SL,4CY_1BL,2AL_1AL*_1SL,4CY,3CY_1AL_1GF,4CY_1BL,3AL_1SL,3CY_1CR*_1HU,3CY_1AL*_1GF,6SL,4CY_1BL,2AL_1AL*_1SL,4CY,1SI_3CY_1AL_1GF,4CY_1BL,3AL_1SL,4CY,1CR*_2CY_1AL*_1GF,4CY_1BL,3AL_1SL,1SC,4CY,3CY_1AL_2GF*,6SL,1HU_1CR*_3CY_1BL,2AL_1AL*_1SL,4CY,1SI_3CY_1AL_1GF,4CY_1BL,3AL*_1SL,4CY,1CR*_2CY_1AL_1GF",AIClassList);

    SetupNextSquad();
}

// This function is called every .25 seconds to check and see if there are
// more zeds that must be spawned.
function SpawnZeds()
{
    local DGameReplicationInfo KFGRI;
    local int ZedSlotsAvailable, SpawnMarkerIndex;
    local KFSpawnVolume SpawnVolume;
    local array< SpawnMarkerInfo > SpawnMarkerInfoList;

    KFGRI = DGameReplicationInfo(WorldInfo.GRI);
    if ( KFGRI == none || KFGRI.SpawningActive == false )
    {
        return;
    }

    ZedSlotsAvailable = SpawnManager.GetMaxMonsters() - SpawnManager.GetAIAliveCount();

    if ( NextAIToSpawn.Length <= ZedSlotsAvailable )
    {
        // Get the Monsters
        if ( SpawnVolume == none )
        {
            SpawnVolume = GetBestSpawnVolume(NextAIToSpawn);
        }

        // Spawn Zeds at each marker
        SpawnMarkerInfoList = SpawnVolume.SpawnMarkerInfoList;
        for ( SpawnMarkerIndex=0; SpawnMarkerIndex<SpawnMarkerInfoList.Length; SpawnMarkerIndex++ )
        {
            if ( NextAIToSpawn.Length == 0 )
            {
                break;
            }

            // At the volume, create the Zeds
            SpawnAI(
                NextAIToSpawn[0],
                SpawnVolume.SpawnMarkerInfoList[SpawnMarkerIndex].Location
            );

            // FIXME: Ugh, this is nasty but instead of popping off
            // the elements, it's probably better to index then remove
            NextAIToSpawn.Remove(0,1);
        }

        // Make sure we have the correct number of living things 
        RefreshMonsterAliveCount();

        // If we have finished spawning all the Zeds from this squad,
        // queue up the next one!
        if ( NextAIToSpawn.Length == 0 )
        {
            SetupNextSquad();
        }

    }
}

// Pull the next squad deifnition down from the
// Squad manager and set 'er up
function SetupNextSquad()
{
    local CD_AISpawnSquad NextSquad;
    NextSquad = MySpawnSquads.GetNextSquad();
    NextAIToSpawn = SquadMonsters(NextSquad);
    MySpawnSquads.SetupNextSquad();
}

function KFSpawnVolume GetBestSpawnVolume(
                            optional array< class<KFPawn_Monster> > AIToSpawn,
                            optional Controller OverrideController,
                            optional Controller OtherController,
                            optional bool bTeleporting,
                            optional float MinDistSquared
                        )
{
    local int VolumeIndex, ControllerIndex;
    local Controller RateController;

    if( OverrideController != none )
    {
        RateController = OverrideController;
    }
    else
    {
        // Get the Controller list ready for spawn selection
        InitControllerList();

        if( RecentSpawnSelectedHumanControllerList.Length > 0 )
        {
            // Randomly grab a Human PRI from the list to use for rating zed spawning
            ControllerIndex = Rand(RecentSpawnSelectedHumanControllerList.Length);
            RateController = RecentSpawnSelectedHumanControllerList[ControllerIndex];
            RecentSpawnSelectedHumanControllerList.Remove( ControllerIndex, 1 );
            `Log( GetFuncName()$" Rating with Controller "$RateController.PlayerReplicationInfo.PlayerName$" From RecentSpawnSelectedHumanControllerList", bLogAISpawning );
        }
    }

    // If there were no controllers to rate against, return none
    if( RateController == none )
    {
        `warn( GetFuncName()$" no controllers to rate spawning with!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!", bLogAISpawning);
        return none;
    }

    if( (OtherController == none || !OtherController.bIsPlayer) && NeedPlayerSpawnVolume() )
    {
        // Grab the first player controller
        foreach WorldInfo.AllControllers( class'Controller', OtherController )
        {
            if( OtherController.bIsPlayer )
            {
                break;
            }
        }
    }

    // pre-sort the list to reduce the number of line checks performed by IsValidForSpawn
    SortSpawnVolumes(RateController, bTeleporting, MinDistSquared);

    // Make sure we have the correct size of the squad type so
    // Volume.IsValidForSpawn doesn't choose the wrong size of volume
    SetDesiredSquadTypeForZedList(AIToSpawn);

    for ( VolumeIndex = 0; VolumeIndex < SpawnVolumes.Length; VolumeIndex++ )
    {
        if (
              SpawnVolumes[VolumeIndex].IsValidForSpawn(DesiredSquadType, OtherController)
              && SpawnVolumes[VolumeIndex].CurrentRating > 0
        ) {
            `log(GetFuncName()@"returning chosen spawn volume"@SpawnVolumes[VolumeIndex]@"with a rating of"@SpawnVolumes[VolumeIndex].CurrentRating, bLogAISpawning);
            return SpawnVolumes[VolumeIndex];
        }
    }

   //`warn(GetFuncName()$" No spawn volume with a positive rating!!!");
   return none;
}
function int SquadMonsterCount( CD_AISpawnSquad Squad )
{
    local int i;
    local int ZedCount;

    ZedCount = 0;
    for ( i=0; i<Squad.CustomMonsterList.Length; i++ )
    {
        ZedCount += Squad.CustomMonsterList[i].Num;
    }

    return ZedCount;
}

function array< class<KFPawn_Monster> > SquadMonsters( CD_AISpawnSquad Squad )
{
    local AISquadElement Monsters;
    local int i, j;
    local array< class<KFPawn_Monster> > SquadMonsters;
    local class<KFPawn_Monster> MonsterClass;

    for ( i=0; i<Squad.CustomMonsterList.Length; i++ )
    {
        Monsters = Squad.CustomMonsterList[i];
        for ( j=0; j<Monsters.Num; j++ )
        {
            MonsterClass = Monsters.CustomClass != None
                            ? Monsters.CustomClass
                            : AIClassList[Monsters.Type];
            SquadMonsters.AddItem(MonsterClass);
        }
    }

    return SquadMonsters;
}

simulated function KFPawn SpawnZed(
                      class<KFPawn_Monster> SpawnClass,
                      vector SpawnLoc,
                      optional bool bNoCollisionFail
                  )
{
    local rotator SpawnRot;
    local KFPawn KFP;

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

simulated function SpawnAI(
                class<KFPawn_Monster> SpawnClass,
                vector SpawnTarget
            )
{
    local KFPawn Zed;

    Zed = SpawnZed(SpawnClass,SpawnTarget);
    if ( Zed == None ) {
          `log("Was unable to spawn "$SpawnClass$" at "$SpawnTarget);
          return;
    }

    Zed.SpawnDefaultController();
    if( KFAIController(Zed.Controller) == none ) {
          `log("Could not attach controller to "$SpawnClass$" with AI "$Zed.Controller);
          return;
    };

    KFAIController( Zed.Controller ).SetTeam(1);
}


