class DTrigger_KeyUnlock extends Trigger_PawnsOnly;

enum DKeyColours {
    DKC_Red,
    DKC_Green,
    DKC_Blue,
};

// Required key colour to allow the activation of trigger
var() DKeyColours RequiredKeyColour;

// Consume the key from user's inventory after unlock
var() bool ConsumeKey;

// Whether we're active
var() bool Active;

// Has this mechanism activated (enabled?)
var() bool Unlocked;

simulated event Touch(Actor Other,
                        PrimitiveComponent OtherComp,
                        vector HitLocation,
                        vector HitNormal)
{
    super.Touch(Other, OtherComp, HitLocation, HitNormal);
    if (Role == ROLE_Authority)
    {
        `log("Other: "@Other);
    }
}

simulated event UnTouch(Actor Other)
{
    super.UnTouch( Other );
}


defaultproperties
{
    Begin Object NAME=CollisionCylinder LegacyClassName=Trigger_TriggerCylinderComponent_Class
        CollisionRadius=+00100.000000
        CollisionHeight=+00160.000000
        BlockZeroExtent=false
    End Object

    Active = True

    SupportedEvents.Add(class'DSeqEvent_Unlock')
    SupportedEvents.Add(class'DSeqEvent_Lock')

    UsableAfterActivity = true
}

