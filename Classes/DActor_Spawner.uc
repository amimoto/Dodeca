class DActor_Spawner extends Actor
  placeable;

// While true, this spawner will be injecting zeds into the game
var() bool Enabled;


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
