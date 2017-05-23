class DSeqAct_SpawnZeds extends SequenceAction;

// The squads of Zeds to spawn. Use the ControlledDifficulty syntax.
var() string SpawnSquads;

// If this should be a one shot spawn
var() bool OneShot;

// If this should recycle squads once used
var() bool RecycleSquads;

// Leave 0 for default, set to affect the max zed count multiplier
var() float MaxZedMultiplier;

event Activated()
{
    local SeqVar_Object ObjVar;
    local KFTraderTrigger Trader;
    local DGameInfo_Objectives DGI;

    // Start
    if( InputLinks[0].bHasImpulse )
    {
        DGI = DGameInfo_Objectives( class'WorldInfo'.static.GetWorldInfo().Game );
        if( DGI != none )
        {
            DGI.StartZedSpawning();
        }
    }

    // Stop
    else if( InputLinks[1].bHasImpulse )
    {
        DGI = DGameInfo_Objectives( class'WorldInfo'.static.GetWorldInfo().Game );
        if( DGI != none )
        {
            DGI.StopZedSpawning();
        }
    }

}



defaultproperties
{
    ObjName="Spawn Zeds"
    ObjCategory="Dodeca"

    InputLinks(0)=(LinkDesc="Start")
    InputLinks(1)=(LinkDesc="Stop")

    VariableLinks.Empty()
    VariableLinks(0)=(ExpectedType=class'SeqVar_ObjectList',LinkDesc="Spawn Volumes")
}


