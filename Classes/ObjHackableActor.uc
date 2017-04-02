class ObjHackableActor extends Actor
    placeable;

/** Amount of damage a welded door can take */
var() int MaxHackIntegrity;
/** Current integrity of a welded door */
var repnotify transient int HackIntegrity;

var protected Texture2D HackedIcon;

var() string HackedIntegrityString;
var() int HackedIconSize;
var() float HackedFontScale;


replication
{
    if ( bNetDirty )
        HackIntegrity;
}


/*********************************************************************************************
 * @name    Hacking
 ********************************************************************************************* */

function bool TakeHackingDamage ( int Damage )
{
    HackIntegrity -= Damage;
    if ( HackIntegrity < 0 ) {
        HackIntegrity = 0;
    }
    return IsHacked();
}

function bool IsHacked()
{
    return HackIntegrity <= 0;
}

/*********************************************************************************************
 * @name    HUD
 ********************************************************************************************* */

//simulated event DrawHUD( HUD HUD )
simulated event PostRenderFor( PlayerController PC, Canvas C, vector CameraPosition, vector CameraDir )
{
    local Vector    CameraLoc, ScreenLoc;
    local Rotator   CameraRot;
    local float     X, Y;
    local float     TextureScale;
    local float     DOT;
    local HUD       HUD;

    HUD = PC.myHUD;

    if ( C == none )
    {
        return;
    }
    C.SetDrawColor(255,0,0);
    C.Font = class'KFGameEngine'.Static.GetKFCanvasFont();
    // project location onto the hud
    PC.GetPlayerViewPoint( CameraLoc, CameraRot );

    Dot = vector(CameraRot) dot (Location - CameraLoc);
    if( Dot < 0.5f )
    {
        return;
    }
    ScreenLoc = C.Project( self.Location );
    if( ScreenLoc.X < 0 || ScreenLoc.X + HackedIconSize * 3 >= C.ClipX || ScreenLoc.Y < 0 && ScreenLoc.Y >= C.ClipY)
    {
        return;
    }
    TextureScale = float(HackedIconSize) / HackedIcon.SizeY;
    C.SetPos(ScreenLoc.X - HackedIconSize/2, ScreenLoc.Y - HackedIconSize/2, ScreenLoc.Z);
    C.DrawTexture( HackedIcon, TextureScale );

    X = ScreenLoc.X + HackedIconSize/2+ 5;
    Y = ScreenLoc.Y - HackedIconSize/2;
    C.SetPos( X, Y );

    DrawHackingHUD( C, HUD, X, Y );
}

simulated function DrawHackingHUD( Canvas C, HUD HUD, float PosX, float PosY )
{
    local float HackedPercentageFloat;
    local int HackedPercentage;
    local float FontScale;
    local FontRenderInfo FRI;
    local String Str;

    FRI.bClipText = true;
        // Display weld integrity as a percentage
    FontScale = class'KFGameEngine'.Static.GetKFFontScale() * HackedFontScale;
    HackedPercentageFloat = (1 - float(HackIntegrity) / float(MaxHackIntegrity)) * 100.0;
    if( HackedPercentageFloat < 1.f && HackedPercentageFloat > 0.f )
    {
        HackedPercentageFloat = 1.f;
    }
    else if( HackedPercentageFloat > 99.f && HackedPercentageFloat < 100.f )
    {
        HackedPercentageFloat = 99.f;
    }
    HackedPercentage = HackedPercentageFloat;
    Str = HackedIntegrityString@HackedPercentage$"%";
    C.DrawText( Str, TRUE, FontScale, FontScale, FRI );
}

defaultproperties
{
    Begin Object Class=SpriteComponent Name=Sprite
        Sprite=Texture2D'EditorResources.door'
        HiddenGame=true
        AlwaysLoadOnClient=False
        AlwaysLoadOnServer=False
        Translation=(X=0,Z=0)
    End Object
    Components.Add(Sprite)

    // UI
    // Risk Skull from: http://www.flaticon.com/free-icon/risk-skull_71270#term=skull&page=1&position=15
    HackedIcon=Texture2D'Teriyakisaurus.hackable_icon'
    //HackedIcon=Texture2D'Teriyakisaurus.hacked_icon'
    HackedIconSize = 40
    HackedIntegrityString="Hacked"
    HackedFontScale = 2

    // Health
    MaxHackIntegrity = 100
    HackIntegrity = 100
}


