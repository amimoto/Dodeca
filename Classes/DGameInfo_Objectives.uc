class DGameInfo_Objectives extends CD_Survial;

// My replacement KFGRI
var DGameReplicationInfo   DMyKFGRI;

// Keep track of the wave specific traders
var array<DTraderTrigger>   DTraderList;

// If this is on, we don't have a break for Trader
var config bool NoTraderBreak;

// This allows us to create a list of all the traders in both the
// standard form but also in the wave targeted versions.
function InitTraderList()
{
    local DTraderTrigger MyTrader;

    super.InitTraderList();

    DTraderList.Remove(0, DTraderList.Length);
    DMyKFGRI.DTraderList.Remove(0, DTraderList.Length);
    foreach DynamicActors(class'DTraderTrigger', MyTrader)
    {
        DTraderList.AddItem(MyTrader);
        DMyKFGRI.DTraderList.AddItem(MyTrader);
    }
}

// This scans all the door actors on this map to 

function PreBeginPlay()
{
    Super(FrameworkGame).PreBeginPlay();

    DMyKFGRI = DGameReplicationInfo(GameReplicationInfo);
    MyKFGRI = DMyKFGRI;
    InitGRIVariables();

    CreateTeam(0);
    InitGameConductor();
    InitAIDirector();
    InitTraderList();
    ReplicateWelcomeScreen();

    WorldInfo.TWLogsInit();

`if(`notdefined(ShippingPC))
    if ( WorldInfo.NetMode == NM_ListenServer  )
    {
        WorldInfo.AddOnScreenDebugMessage(-1, 60, MakeColor(255,0,0,255), "NM_ListenServer");
    }
`endif

    InitSpawnManager();
    UpdateGameSettings();

    `log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> YAY!");
}


State PlayingWave
{
    function BeginState( Name PreviousStateName )
    {
        MyKFGRI.SetWaveActive(TRUE, GetGameIntensityForMusic());
        StartWave();

        DMyKFGRI.OpenWaveTraders();


        if ( AllowBalanceLogging() )
        {
            LogPlayersDosh(GBE_WaveStart);
        }
    }

    function bool IsWaveActive()
    {
        return true;
    }
}

function Killed(Controller Killer, Controller KilledPlayer, Pawn KilledPawn, class<DamageType> DT)
{
    local KFPlayerReplicationInfo KilledPRI;
    local KFPlayerController KFPC;
    local int PlayerScoreDelta, TeamPenalty;
    local KFPerk KFPCP;
    local KFPawn_Monster MonsterPawn;
    local class<DamageType> LastHitByDamageType;

    if( KilledPlayer != None && KilledPlayer.bIsPlayer )
    {
        // Let the game conductor know a human team player died
        if( KilledPlayer.GetTeamNum() == 0 && Killer != none && Killer.GetTeamNum() == 255 )
        {
            GameConductor.NotifyHumanTeamPlayerDeath();
        }

        KilledPRI = KFPlayerReplicationInfo( KilledPlayer.PlayerReplicationInfo );
        if( KilledPRI != none )
        {
            // Dosh penalty on death
            PlayerScoreDelta = GetAdjustedDeathPenalty( KilledPRI );
            `log("SCORING: Player" @ KilledPRI.PlayerName @ "next starting dosh =" @ PlayerScoreDelta + KilledPRI.Score, bLogScoring);
            KilledPRI.AddDosh( PlayerScoreDelta );
            TeamPenalty = GetAdjustedTeamDeathPenalty( KilledPRI );

            if( KilledPRI.Team != none )
            {
                KFTeamInfo_Human(KilledPRI.Team).AddScore( -TeamPenalty );
                `log("SCORING: Team lost" @ TeamPenalty @ "dosh for a player dying", bLogScoring);
            }

            KilledPRI.PlayerHealth = 0;
            KilledPRI.PlayerHealthPercent = 0;
        }

        KFPC = KFPlayerController( KilledPlayer );
    }

    Super(GameInfo).Killed( Killer, KilledPlayer, KilledPawn, DT );

    // Maybe do a DramaticEvent that may trigger Zedtime when someone is killed
    if( Killer != KilledPlayer )
    {
        CheckZedTimeOnKill( Killer, KilledPlayer, KilledPawn, DT );
    }

    // Update pawn counters
    if( KilledPawn != none && KilledPawn.GetTeamNum() == 255 )
    {
        if( Killer != none )
        {
            KFPC = KFPlayerController( Killer );
            if( KFPC != none )
            {
                MonsterPawn = KFPawn_Monster( KilledPawn );
                if( MonsterPawn != none )
                {
                    LastHitByDamageType = GetLastHitByDamageType( DT, MonsterPawn, Killer );

                    //Chris: We have to do it earlier here because we need a damage type
                    KFPC.AddZedKill( MonsterPawn.class, GameDifficulty, LastHitByDamageType );

                    KFPCP = KFPC.GetPerk();
                    if( KFPCP != none )
                    {
                        if( KFPCP.CanEarnSmallRadiusKillXP( LastHitByDamageType ) )
                        {
                            CheckForBerserkerSmallRadiusKill( MonsterPawn, KFPC );
                        }

                        KFPCP.AddVampireHealth( KFPC, LastHitByDamageType );
                    }
                }
            }
        }

        RefreshMonsterAliveCount();

        if( SpawnManager != None )
        {
            MyKFGRI.AIRemaining--;

            `log("@@@@ ZED COUNT DEBUG: MyKFGRI.AIRemaining =" @ MyKFGRI.AIRemaining, bLogAICount);
            `log("@@@@ ZED COUNT DEBUG: AIAliveCount =" @ AIAliveCount, bLogAICount);
        }
    }

    // if not boss wave, play progress update trader dialog
    if( !MyKFGRI.IsFinalWave() && KilledPawn.IsA('KFPawn_Monster') )
    {
        // no KFTraderDialogManager object on dedicated server, so use static function
        class'KFTraderDialogManager'.static.PlayGlobalWaveProgressDialog( MyKFGRI.AIRemaining, MyKFGRI.WaveTotalAICount, WorldInfo );
    }

    CheckWaveEnd();

}
defaultproperties
{
    PlayerControllerClass = class'Dodeca.DPlayerController'
    GameReplicationInfoClass = class'Dodeca.DGameReplicationInfo'
    GameConductorClass = class'Dodeca.DGameConductor'
    HUDType=class'Dodeca.DGFxHudWrapper'
    DefaultPawnClass=class'Dodeca.DPawn_Human'
}
