class ObjKFLocalMessage_Interaction extends KFLocalMessage_Interaction;


enum ObjEInteractionMessageType {
        ObjIMT_None,

        // usables messaging (should always be lowest "priority")
        ObjIMT_AcceptObjective,
        ObjIMT_ReceiveAmmo,
        ObjIMT_ReceiveGrenades,
        ObjIMT_UseTrader,
        ObjIMT_UseDoor,
        ObjIMT_UseDoorWelded,
        ObjIMT_RepairDoor,
        ObjIMT_UseMinigame,
        ObjIMT_UseMinigameGenerator,

        // conditional messaging
        ObjIMT_GamepadWeaponSelectHint,
        ObjIMT_HealSelfWarning,
        ObjIMT_ClotGrabWarning,
        ObjIMT_PlayerClotGrabWarning,

        IMT_PerformHack,
        IMT_DoorLocked,
        IMT_Hacking,
        IMT_UseConsole,
};


var localized string      HackDeviceMessage;

static function string GetString(
    optional int Switch,
    optional bool bPRI1HUD,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    switch ( Switch )
    {
        case IMT_PerformHack:
            return "HACK TERMINAL";
        case IMT_DoorLocked:
            return "LOCKED";
        case IMT_UseConsole:
            return "USE CONSOLE";
        default:
            return Super.GetString(Switch,bPRI1HUD,RelatedPRI_1,RelatedPRI_2,OptionalObject);
    };
    return "Whut";
}

static function string GetKeyBind( PlayerController P, optional int Switch )
{
    local string KeyString;
    local KeyBind BoundKey;
    local KFPlayerInput KFInput;

    KeyString = Super.GetKeyBind(P,Switch);

    KFInput = KFPlayerInput(P.PlayerInput);

    if ( KeyString != "" || KFInput == none ) {
        return KeyString;
    };

    switch ( Switch ) {
        case IMT_DoorLocked:
            KeyString = "";
            break;
        case IMT_PerformHack:
        case IMT_UseConsole:
            KFInput.GetKeyBindFromCommand(BoundKey, default.USE_COMMAND, false);
            KeyString = KFInput.GetBindDisplayName(BoundKey);
            break;
    }

    return KeyString;
}


