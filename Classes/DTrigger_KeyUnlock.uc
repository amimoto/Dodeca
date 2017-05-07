class DTrigger_KeyUnlock extends Trigger_PawnsOnly
    implements(KFInterface_Usable)
    ;

// Required key colour to allow the activation of trigger
var() DKeyColours RequiredKeyColour;

// Interaction Message noun to describe to the player
// what can unlock this device
var() string InteractionKeyNoun;

// Consume the key from user's inventory after unlock
var() bool ConsumeKeyAfterUse;

// Message shown to user after key is used
var() string InteractionConsumeKey;

// Whether we're active
var() bool Active;

// Has this mechanism activated (enabled?)
var() bool Locked;

// Returns true if the playercontroller has the appropriate
// key in their inventory
function bool PlayerCanUnlock( Pawn P )
{
    local DInventoryManager Inv;
    Inv = DInventoryManager(P.InvManager);
    return Inv.HasKey(RequiredKeyColour);
}

// Returns the PlayerController for the player currently holding
// the item that can open the door. If no one is holding, returns none
function DPlayerController FindPlayerWithKey()
{
    local DPlayerController PC;
    foreach WorldInfo.AllControllers(class'DPlayerController', PC)
    {
        if ( PlayerCanUnlock(PC.UsablePawn) )
        {
            return PC;
        }
    }
    return none;
}

// Consumes the key from the pawn's inventory. Mark
// the HUD as clear of that coloured key
function ConsumeKey( Pawn P )
{
    local KFPlayerController KFPC;
    local KFGFxHudWrapper GFxHUDWrapper;
    local DGFxMoviePlayer_HUD DGFxHUD;

    DInventoryManager(P.InvManager).ConsumeKey(RequiredKeyColour);

    foreach LocalPlayerControllers(class'KFPlayerController', KFPC)
    {
        GFxHUDWrapper = KFGFxHudWrapper(KFPC.myHUD);
        DGFxHUD = DGFxMoviePlayer_HUD(GFxHUDWrapper.HudMovie);
        DGFxHUD.ShowNonCriticalMessage(InteractionConsumeKey);
        DGFxHUD.GfxDHUDPlayer.SetIndicator(RequiredKeyColour,1);
    }
}


// Returns a true value if the player has a key
// that can unlock this trigger
simulated function bool GetIsUsable( Pawn User )
{
    local bool IsUsable;
    IsUsable = PlayerCanUnlock(User);
    return IsUsable;
}

// If it's possible to unlock, perform the
// unlock of the device/door/etc (and consume
// the key if configured
function bool UsedBy(Pawn User)
{
    if ( PlayerCanUnlock(User) )
    {
        Unlock();
        if ( ConsumeKeyAfterUse )
        {
            ConsumeKey(User);
        }

        if (Role == ROLE_Authority)
        {
            // Clear any messages
            class'KFPlayerController'.static.UpdateInteractionMessages( User );
        }
        return true;
    }
    return false;
}

// Used to display what can be done to the Player
function int GetInteractionIndex( Pawn User )
{
    return IMT_UseDoor;
}

// To lock the door
function Lock()
{
    if ( !Locked )
    {
        Locked = true;
        bNoEncroachCheck = false;
        self.TriggerEventClass(class'DSeqEvent_Lock',self,-1);
    }
}

// To unlock the door
function Unlock()
{
    if ( Locked )
    {
        Locked = false;
        bNoEncroachCheck = true;
        self.TriggerEventClass(class'DSeqEvent_Unlock',self,-1);
    }
}

// Upon touch, this will typically show a message to the
// user about what can be done. Possible messages are:
// (1) User does not have the key (which key is required?)
// (2) User does does have the key
// (3) Someone else has the key
// (4) The device is unlocked
simulated event Touch(Actor Other,
                        PrimitiveComponent OtherComp,
                        vector HitLocation,
                        vector HitNormal)
{
    local Pawn P;
    local DPlayerController PC;
    local DPlayerController KeyHolderPC;

    super.Touch(Other, OtherComp, HitLocation, HitNormal);
    if (Role == ROLE_Authority)
    {
        P = Pawn(Other);
        Instigator = P;
        PC = DPlayerController( P.Controller );
        if( PC != none )
        {
            if ( !Locked )
            {
                // Clear any messages
                class'DPlayerController'.static.UpdateInteractionMessages( Other );
            }
            else if ( PlayerCanUnlock(PC.UsablePawn) )
            {
                PC.ReceiveLocalizedMessage(
                    class'DLocalMessage_Interaction',
                    IMT_Unlock,
                    ,, self
                );
            }
            else
            {
                KeyHolderPC = FindPlayerWithKey();
                PC.ReceiveLocalizedMessage(
                    class'DLocalMessage_Interaction',
                    IMT_CannotUnlock,
                    KeyHolderPC.PlayerReplicationInfo,, self
                );
            }
        }

        `log("Other: "@Other);
    }
}

simulated event UnTouch(Actor Other)
{
    super.UnTouch( Other );
    class'DPlayerController'.static.UpdateInteractionMessages( Other );
}


defaultproperties
{
    Begin Object NAME=CollisionCylinder LegacyClassName=Trigger_TriggerCylinderComponent_Class
        CollisionRadius=+00100.000000
        CollisionHeight=+00160.000000
        BlockZeroExtent=false
    End Object

    ConsumeKeyAfterUse = True
    Active = True
    bNoEncroachCheck = True
    Locked = True
    RequiredKeyColour = DKC_Red

    SupportedEvents.Add(class'DSeqEvent_Unlock')
    SupportedEvents.Add(class'DSeqEvent_Lock')

    UsableAfterActivity = true

    InteractionKeyNoun = "key"
    InteractionConsumeKey = "The key has been used."
}

