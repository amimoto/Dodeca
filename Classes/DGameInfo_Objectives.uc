class DGameInfo_Objectives extends KFGameInfo;

/*********************************************************************

  State Sequence:

    * Intro: Perform any cinematics of whatever in this state
    * PlayingChapter: Where player has control to do what they wish
    * Interlude:
    * Epilogue

  State Details:

    * BeginState
    * EndState

  Spawning:



**********************************************************************/

var() bool IntroExists;

var DAISpawnManager DSpawnManager;
var bool KillCounterEnabled;


/*********************************************************************************************
 * CD Variables
 *********************************************************************************************/

// Console/log text output facility
var CD_ConsolePrinter GameInfo_CDCP;

/*********************************************************************************************
 * Entry points
 *********************************************************************************************/
event PreBeginPlay()
{
    super.PreBeginPlay();
    InitSpawnManager();
    UpdateGameSettings();

    // FIXME: Decide what to do here.
    GameLength = GL_Normal;
    MyKFGRI.bHidePawnIcons = true;

}

event PostBeginPlay()
{
    super.PostBeginPlay();
}

/* StartMatch()
Start the game - inform all actors that the match is starting, and spawn player pawns
*/
function StartMatch()
{
    super.StartMatch();
    if ( IntroExists ) { GotoState('Intro'); }
       else            { GotoState('PlayingChapter'); }
}

/*********************************************************************************************
 * Setup Functions
 *********************************************************************************************/

/** Set up the spawning */
function InitSpawnManager()
{
    SpawnManager = new(self) class'DAISpawnManager';
    DSpawnManager = DAISpawnManager(SpawnManager);
    DSpawnManager.DInitialize( GameInfo_CDCP );
    SetTimer( 0.25f, true, nameOf(CheckZedDemographics) );
}


/*********************************************************************************************
 * Recurring events
 *********************************************************************************************/

function CheckZedDemographics()
{
    DSpawnManager.SpawnZeds();
}

/*********************************************************************************************
 * STATE Intro
 *********************************************************************************************/
State Intro
{
    function BeginState( Name PreviousStateName )
    {
    }
    function EndState( Name NextStateName )
    {
    }
}

/*********************************************************************************************
 * STATE PlayingChapter
 *********************************************************************************************/
State PlayingChapter
{
    function BeginState( Name PreviousStateName )
    {
    }
    function EndState( Name NextStateName )
    {
    }
    function bool IsWaveActive()
    {
        return true;
    }
}


/*********************************************************************************************
 * STATE Interlude
 *********************************************************************************************/
State Interlude
{
    function BeginState( Name PreviousStateName )
    {
    }
    function EndState( Name NextStateName )
    {
    }
}


/*********************************************************************************************
 * STATE Epilogue
 *********************************************************************************************/
State Epilogue
{
    function BeginState( Name PreviousStateName )
    {
    }
    function EndState( Name NextStateName )
    {
    }
}



// Stops the system from counting kills for wave-end
function StopCountingZedKills()
{
    KillCounterEnabled = false;
}

function StartCountingZedKills()
{
    KillCounterEnabled = true;
}

// Prevents the system from spawning new Zeds
function StopZedSpawning()
{
}

function StartZedSpawning()
{
}

// This huge function that was extracted allows us to manipulate how
// killed Zeds affect the counter.
function Killed(Controller Killer, Controller KilledPlayer, Pawn KilledPawn, class<DamageType> DT)
{
    Super.Killed(Killer,KilledPlayer,KilledPawn,DT);

    if( KilledPawn != none && KilledPawn.GetTeamNum() == 255 )
    {
        if( SpawnManager != None )
        {
        }
    }
}


defaultproperties
{
    PlayerControllerClass = class'Dodeca.DPlayerController'
    GameReplicationInfoClass = class'Dodeca.DGameReplicationInfo'
    GameConductorClass = class'Dodeca.DGameConductor'
    HUDType=class'Dodeca.DGFxHudWrapper'
    DefaultPawnClass=class'Dodeca.DPawn_Human'
    KillCounterEnabled = true


    Begin Object Class=CD_ConsolePrinter Name=Default_CDCP
    End Object
    GameInfo_CDCP=Default_CDCP

    // Preload content classes (by reference) to prevent load time hitches during gameplay
    // and keeps the GC happy.  This will also load client content -- via GRI.GameClass
    AIClassList(AT_Clot)=class'KFGameContent.KFPawn_ZedClot_Cyst'
    AIClassList(AT_AlphaClot)=class'KFGameContent.KFPawn_ZedClot_Alpha'
    AIClassList(AT_SlasherClot)=class'KFGameContent.KFPawn_ZedClot_Slasher'
    AIClassList(AT_Crawler)=class'KFGameContent.KFPawn_ZedCrawler'
    AIClassList(AT_GoreFast)=class'KFGameContent.KFPawn_ZedGorefast'
    AIClassList(AT_Stalker)=class'KFGameContent.KFPawn_ZedStalker'
    AIClassList(AT_Scrake)=class'KFGameContent.KFPawn_ZedScrake'
    AIClassList(AT_FleshPound)=class'KFGameContent.KFPawn_ZedFleshpound'
    AIClassList(AT_Bloat)=class'KFGameContent.KFPawn_ZedBloat'
    AIClassList(AT_Siren)=class'KFGameContent.KFPawn_ZedSiren'
    AIClassList(AT_Husk)=class'KFGameContent.KFPawn_ZedHusk'
    AIBossClassList(BAT_Hans)=class'KFGameContent.KFPawn_ZedHans'
    AIBossClassList(BAT_Patriarch)=class'KFGameContent.KFPawn_ZedPatriarch'

    NumAlwaysRelevantZeds=3
}
