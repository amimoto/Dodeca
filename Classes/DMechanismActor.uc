class DMechanismActor extends Actor
  placeable;


/** Amount of damage a welded door can take */
var() int MaxActivityIntegrity;
/** Current integrity of a welded door */
var repnotify transient int ActivityIntegrity;

var protected Texture2D ActivityIcon;

var() string ActivityIntegrityString;
var() int ActivityIconSize;
var() float ActivityFontScale;


replication
{
    if ( bNetDirty )
        ActivityIntegrity;
}


/*********************************************************************************************
 * @name    Activating
 ********************************************************************************************* */

function bool TakeActivatingDamage ( int Damage )
{
    ActivityIntegrity -= Damage;
    if ( ActivityIntegrity < 0 ) {
        ActivityIntegrity = 0;
    }
    return IsActivated();
}

function bool IsActivated()
{
    return ActivityIntegrity <= 0;
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
    if( ScreenLoc.X < 0 || ScreenLoc.X + ActivityIconSize * 3 >= C.ClipX || ScreenLoc.Y < 0 && ScreenLoc.Y >= C.ClipY)
    {
        return;
    }
    TextureScale = float(ActivityIconSize) / ActivityIcon.SizeY;
    C.SetPos(ScreenLoc.X - ActivityIconSize/2, ScreenLoc.Y - ActivityIconSize/2, ScreenLoc.Z);
    C.DrawTexture( ActivityIcon, TextureScale );

    X = ScreenLoc.X + ActivityIconSize/2+ 5;
    Y = ScreenLoc.Y - ActivityIconSize/2;
    C.SetPos( X, Y );

    DrawActivatingHUD( C, HUD, X, Y );
}

simulated function DrawActivatingHUD( Canvas C, HUD HUD, float PosX, float PosY )
{
    local float ActivatedPercentageFloat;
    local int ActivatedPercentage;
    local float FontScale;
    local FontRenderInfo FRI;
    local String Str;

    FRI.bClipText = true;
        // Display weld integrity as a percentage
    FontScale = class'KFGameEngine'.Static.GetKFFontScale() * ActivityFontScale;
    ActivatedPercentageFloat = (1 - float(ActivityIntegrity) / float(MaxActivityIntegrity)) * 100.0;
    if( ActivatedPercentageFloat < 1.f && ActivatedPercentageFloat > 0.f )
    {
        ActivatedPercentageFloat = 1.f;
    }
    else if( ActivatedPercentageFloat > 99.f && ActivatedPercentageFloat < 100.f )
    {
        ActivatedPercentageFloat = 99.f;
    }
    ActivatedPercentage = ActivatedPercentageFloat;
    Str = ActivityIntegrityString@ActivatedPercentage$"%";
    C.DrawText( Str, TRUE, FontScale, FontScale, FRI );
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

    // UI
    // Risk Skull from: http://www.flaticon.com/free-icon/risk-skull_71270#term=skull&page=1&position=15
    ActivityIcon=Texture2D'Dodeca_UI.hackable_icon'
    ActivityIconSize = 40
    ActivityIntegrityString="Activity"
    ActivityFontScale = 2

    // Health
    MaxActivityIntegrity = 100
    ActivityIntegrity = 100
}
