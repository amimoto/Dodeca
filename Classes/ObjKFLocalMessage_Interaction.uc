//=============================================================================

class ObjKFLocalMessage_Interaction extends KFLocalMessage;

enum EInteractionMessageType
{
	IMT_None,

	// usables messaging (should always be lowest "priority")
	IMT_AcceptObjective,
	IMT_ReceiveAmmo,
	IMT_ReceiveGrenades,
	IMT_UseTrader,
	IMT_UseDoor,
	IMT_UseDoorWelded,
	IMT_RepairDoor,

	// conditional messaging
	IMT_GamepadWeaponSelectHint,
	IMT_HealSelfWarning,
	IMT_ClotGrabWarning,
	IMT_PlayerClotGrabWarning,
};

var localized string			UseTraderMessage;
var localized string			UseDoorMessage;
var localized string			EquipWelderMessage;
var localized string 			RepairDoorMessage;
var localized string			AcceptObjectiveMessage;
var localized string			ReceiveAmmoMessage;
var localized string			ReceiveGrenadesMessage;
var localized string			HealSelfWarning;
var localized string			HealSelfGamepadWarning;
var localized string 			PressToBashWarning;
var localized string 			GamepadWeaponSelectHint;
var localized string 			ZedUseDoorMessage;
var localized string 			ZedUseDoorWeldedMessage;
var localized string 			PlayerClotGrabWarningMessage;

var const string USE_COMMAND;
var const string HEAL_COMMAND;
var const string HEAL_COMMAND_CONTROLLER;
var const string BASH_COMMAND;
var const string WEAPON_SELECT_CONTROLLER;

static function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	local string MessageString;
	local KFGFxMoviePlayer_HUD GFxHud;

	if ( KFGFxHudWrapper(P.myHUD) != none )
	{
	    GFxHud = KFGFxHudWrapper(P.myHUD).HudMovie;
		if ( GFxHud != None )
		{
			MessageString = static.GetString( Switch, (RelatedPRI_1 == P.PlayerReplicationInfo), RelatedPRI_1, RelatedPRI_2, OptionalObject );	
            GFxHud.DisplayInteractionMessage( MessageString, Switch,  GetKeyBind(P, Switch), GetMessageDuration(Switch));
		}
	}
}

static function float GetMessageDuration(int Switch)
{
	switch ( Switch )
	{
		case IMT_GamepadWeaponSelectHint:
			return 2.f;
	}	

	return 0.f;
}

static function string GetKeyBind( PlayerController P, optional int Switch )
{
	local KFPlayerInput KFInput;
	local KeyBind BoundKey;
	local string KeyString;

	KFInput = KFPlayerInput(P.PlayerInput);	
	if( KFInput == none )
	{
		return "";
	}

	switch ( Switch )
	{
		// Use binding
		case IMT_UseDoorWelded:
		if(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().PlayerReplicationInfo.GetTeamNum() == 255)
		{
			KeyString = "";
			break;
		}
		case IMT_UseTrader:
		case IMT_UseDoor:
		case IMT_RepairDoor:
		case IMT_AcceptObjective:
		case IMT_ReceiveAmmo:
		case IMT_ReceiveGrenades:
			KFInput.GetKeyBindFromCommand(BoundKey, default.USE_COMMAND, false);
			KeyString = KFInput.GetBindDisplayName(BoundKey);
			break;
		case IMT_HealSelfWarning:
			if ( KFInput.bUsingGamepad )
			{
				KFInput.GetKeyBindFromCommand(BoundKey, default.HEAL_COMMAND_CONTROLLER, false);
			}
			else
			{
				KFInput.GetKeyBindFromCommand(BoundKey, default.HEAL_COMMAND, false);
			}
			
			KeyString = KFInput.GetBindDisplayName(BoundKey);
			break;
		case IMT_ClotGrabWarning:
			KFInput.GetKeyBindFromCommand(BoundKey, default.BASH_COMMAND, false);
			KeyString = KFInput.GetBindDisplayName(BoundKey);
			break;
		case IMT_GamepadWeaponSelectHint:
			KFInput.GetKeyBindFromCommand(BoundKey, default.WEAPON_SELECT_CONTROLLER, false);
			KeyString = KFInput.GetBindDisplayName(BoundKey);
			break;
	}

	return KeyString;
}

static function string GetString(
	optional int Switch,
	optional bool bPRI1HUD,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	local PlayerInput Input;
	local KFGameReplicationInfo KFGRI;
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController());
	
	switch ( Switch )
	{
		case IMT_UseTrader:
		
   			KFGRI = KFGameReplicationInfo(class'WorldInfo'.static.GetWorldInfo().GRI);
			if(KFGRI != none && KFGRI.GameClass.Name == 'KFGameInfo_Tutorial' || (KFPC != none && KFPC.bDisableAutoUpgrade) )	
			{
				return Left( default.UseTraderMessage, InStr(default.UseTraderMessage, "<%HOLD%>"));
			}
			return default.UseTraderMessage;
		case IMT_UseDoor:
			if(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().PlayerReplicationInfo.GetTeamNum() == 255)
			{
				return default.ZedUseDoorMessage;
			}
			return default.UseDoorMessage;
		case IMT_UseDoorWelded:
			if(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().PlayerReplicationInfo.GetTeamNum() == 255)
			{
				return default.ZedUseDoorWeldedMessage;
			}
			return default.EquipWelderMessage;
		case IMT_RepairDoor:
			return default.RepairDoorMessage;
		case IMT_AcceptObjective:
			return default.AcceptObjectiveMessage;
		case IMT_ReceiveAmmo:
			return default.ReceiveAmmoMessage;
		case IMT_ReceiveGrenades:
			return default.ReceiveGrenadesMessage;
		case IMT_HealSelfWarning:
			Input = class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().PlayerInput;
			return (Input != None && Input.bUsingGamepad) ? default.HealSelfGamepadWarning : default.HealSelfWarning;
		case IMT_ClotGrabWarning:
			return default.PressToBashWarning;
		case IMT_PlayerClotGrabWarning:
			return default.PlayerClotGrabWarningMessage;
		case IMT_GamepadWeaponSelectHint:
			return default.GamepadWeaponSelectHint;
		default:
			return "";
	}
}

static function float GetPos( int Switch, HUD myHUD )
{
    return 0.8;
}

// Returns a hex color code for the supplied message type
static function string GetHexColor(int Switch)
{
    return default.InteractionColor;
}

DefaultProperties
{
	Lifetime=5
	bIsConsoleMessage=false
 	bIsUnique=true
 	bIsSpecial=true
 	bBeep=true

 	USE_COMMAND="GBA_Use"
 	HEAL_COMMAND="GBA_QuickHeal"
 	HEAL_COMMAND_CONTROLLER="GBA_Reload_Gamepad"
 	BASH_COMMAND="GBA_TertiaryFire"
 	WEAPON_SELECT_CONTROLLER="GBA_WeaponSelect_Gamepad"
}

