class DLocalMessage_Interaction extends KFLocalMessage_Interaction;

enum DEInteractionMessageType {
        DIMT_None,

        // usables messaging (should always be lowest "priority")
        DIMT_AcceptObjective,
        DIMT_ReceiveAmmo,
        DIMT_ReceiveGrenades,
        DIMT_UseTrader,
        DIMT_UseDoor,
        DIMT_UseDoorWelded,
        DIMT_RepairDoor,
        DIMT_UseMinigame,
        DIMT_UseMinigameGenerator,

        // conditional messaging
        DIMT_GamepadWeaponSelectHint,
        DIMT_HealSelfWarning,
        DIMT_ClotGrabWarning,
        DIMT_PlayerClotGrabWarning,

        IMT_PerformHack,
        IMT_DoorLocked,
        IMT_Hacking,
        IMT_UseConsole,

        IMT_PerformActivity,
        IMT_Activating,
        IMT_UseMechanism,

        IMT_PartyIncomplete,
        IMT_PartyComplete,
        IMT_PartyPlayerRequired,
        IMT_PartyActivating,
        IMT_PartyCannotActivate,

        IMT_Unlock,
        IMT_CannotUnlock
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
    local DTrigger_KeyUnlock DKeyTrigger;
    switch ( Switch )
    {
        case IMT_Unlock:
            return "UNLOCK";
        case IMT_CannotUnlock:
            DKeyTrigger = DTrigger_KeyUnlock(OptionalObject);
            if ( RelatedPRI_1 != none )
            {
                return "LOCKED."@RelatedPRI_1.PlayerName@"HAS THE"@Caps(DKeyTrigger.InteractionKeyNoun);
            }
            else{
                return "LOCKED. FIND"@Caps(DKeyTrigger.InteractionKeyNoun);
            }
        case IMT_DoorLocked:
            return "LOCKED";
        case IMT_UseConsole:
            return "USE CONSOLE";
        case IMT_PartyIncomplete:
            return "WAITING FOR OTHER PLAYERS";
        case IMT_PartyComplete:
            return "ALL PLAYERS PRESENT";
        case IMT_PartyPlayerRequired:
            return "JOIN YOUR TEAM";
        case IMT_PartyActivating:
            return "ACTIVATING";
        case IMT_PartyCannotActivate:
            return "WAITING FOR OTHER PLAYERS";
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

    `log("DLocalMessage_Interaction.GetKeyBind"@P);

    KeyString = Super.GetKeyBind(P,Switch);

    KFInput = KFPlayerInput(P.PlayerInput);

    if ( KeyString != "" || KFInput == none ) {
        return KeyString;
    };

    switch ( Switch ) {
        case IMT_DoorLocked:
        case IMT_PartyPlayerRequired:
        case IMT_PartyIncomplete:
            KeyString = "";
            break;
        case IMT_PerformHack:
        case IMT_UseConsole:
        case IMT_PartyComplete:
        case IMT_Unlock:
            KFInput.GetKeyBindFromCommand(BoundKey, default.USE_COMMAND, false);
            KeyString = KFInput.GetBindDisplayName(BoundKey);
            break;
    }

    return KeyString;
}


