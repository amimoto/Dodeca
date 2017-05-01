class GO extends KFGameInfo_Survival;

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


defaultproperties
{
    PlayerControllerClass = class'Dodeca.DPlayerController'
    GameReplicationInfoClass = class'Dodeca.DGameReplicationInfo'
    GameConductorClass = class'Dodeca.DGameConductor'
    HUDType=class'Dodeca.DGFxHudWrapper'
    DefaultPawnClass=class'Dodeca.DPawn_Human'

    SpawnManagerClasses(0)=class'Dodeca.DAISpawnManager_Short'
    SpawnManagerClasses(1)=class'Dodeca.DAISpawnManager_Normal'
    SpawnManagerClasses(2)=class'Dodeca.DAISpawnManager_Long'
}
