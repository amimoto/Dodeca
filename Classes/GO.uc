class GO extends KFGameInfo_Survival;

// My replacement KFGRI
var ObjKFGameReplicationInfo   ObjMyKFGRI;

// Keep track of the wave specific traders
var array<ObjKFTraderTrigger>   ObjTraderList;

// If this is on, we don't have a break for Trader
var config bool NoTraderBreak;

// This allows us to create a list of all the traders in both the
// standard form but also in the wave targeted versions.
function InitTraderList()
{
    local ObjKFTraderTrigger MyTrader;

    super.InitTraderList();

    ObjTraderList.Remove(0, ObjTraderList.Length);
    ObjMyKFGRI.ObjTraderList.Remove(0, ObjTraderList.Length);
    foreach DynamicActors(class'ObjKFTraderTrigger', MyTrader)
    {
        `log("++++++++++++++++++++++++++++++++++++++++++++++++ Found a new ObjKFTraderTrigger");
        ObjTraderList.AddItem(MyTrader);
        ObjMyKFGRI.ObjTraderList.AddItem(MyTrader);
    }
}


function PreBeginPlay()
{
    `log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Entered PreBeginPlay");

    WorldInfo.TWApplyTweaks();

    Super(FrameworkGame).PreBeginPlay();

    ObjMyKFGRI = ObjKFGameReplicationInfo(GameReplicationInfo);
    MyKFGRI = ObjMyKFGRI;
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

    `log("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< Done PreBeginPlay");
}


State PlayingWave
{
    function BeginState( Name PreviousStateName )
    {
        `log("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! PlayingWave!");
        MyKFGRI.SetWaveActive(TRUE, GetGameIntensityForMusic());
        StartWave();

        ObjMyKFGRI.OpenWaveTraders();


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

    PlayerControllerClass = class'Objectives.ObjKFPlayerController'
    GameReplicationInfoClass = class'Objectives.ObjKFGameReplicationInfo'
    GameConductorClass = class'Objectives.ObjKFGameConductor'

    SpawnManagerClasses(0)=class'Objectives.ObjKFAISpawnManager_Short'
    SpawnManagerClasses(1)=class'Objectives.ObjKFAISpawnManager_Normal'
    SpawnManagerClasses(2)=class'Objectives.ObjKFAISpawnManager_Long'

}
