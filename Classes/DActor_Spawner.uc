class DActor_Spawner extends Actor
  placeable;

// While true, this spawner will be injecting zeds into the game
var() bool SpawnEnabeld;

// The Squads that this Spawner might use

function SpawnStart()
{
}

function SpawnZeds()
{
}

function SpawnStop()
{
}

// Stops the system from counting kills for wave-end
function StopCountingZedKills()
{
    DGameInfo_Objectives(WorldInfo.Game).StopCountingZedKills();
}

function StartCountingZedKills()
{
    DGameInfo_Objectives(WorldInfo.Game).StartCountingZedKills();
}

// Prevents the system from spawning new Zeds
function StopZedSpawning()
{
    DGameInfo_Objectives(WorldInfo.Game).StopZedSpawning();
}

function StartZedSpawning()
{
    DGameInfo_Objectives(WorldInfo.Game).StartZedSpawning();
}


defaultproperties
{
    Begin Object Class=SpriteComponent Name=Sprite
        Sprite=Texture2D'EditorResources.door'
        HiddenGame=true
        AlwaysLoadOnClient=False
        AlwaysLoadOnServer=False
        Translation=(X=40,Z=40)
    End Object
    Components.Add(Sprite)
}
