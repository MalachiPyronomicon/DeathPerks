//	------------------------------------------------------------------------------------
//	Filename:		condition.sp
//	Author:			Malachi
//	Version:		(see PLUGIN_VERSION)
//	Description:
//					tests/prints tf2 condition of player.
//	------------------------------------------------------------------------------------


// INCLUDES
#include <sourcemod>
#include <tf2>					// TF2_AddCondition
#include <tf2_stocks>			// TF2_IsPlayerInCondition

#pragma semicolon 1


// DEFINES
// Plugin Info
#define PLUGIN_INFO_VERSION			"0.0.2"
#define PLUGIN_INFO_NAME			"Condition"
#define PLUGIN_INFO_AUTHOR			"Malachi"
#define PLUGIN_INFO_DESCRIPTION		"prints tf2 conditions of player"
#define PLUGIN_INFO_URL				"http://www.necrophix.com/"
#define PLUGIN_PRINT_NAME			"[Condition]"			// Used for self-identification in chat/logging

#define MODEL_PATH_GHOST				"models/props_halloween/ghost.mdl"

#define CONCMD_ACTIVATE						"sm_condition"
#define CONCMD_ACTIVATE_DESCRIPTION			"sm_condition"


// Info
public Plugin:myinfo = 
{
	name = PLUGIN_INFO_NAME,
	author = PLUGIN_INFO_AUTHOR,
	description = PLUGIN_INFO_DESCRIPTION,
	version = PLUGIN_INFO_VERSION,
	url = PLUGIN_INFO_URL
}


public OnPluginStart()
{
	RegConsoleCmd(CONCMD_ACTIVATE, CallCondition,  CONCMD_ACTIVATE_DESCRIPTION);

}

	
public Action:CallCondition(iClient, args)

{
	if (TF2_IsPlayerInCondition(iClient, TFCond_Slowed))
	{
		PrintToChat (iClient, "%s TFCond_Slowed", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_Zoomed))
	{
		PrintToChat (iClient, "%s TFCond_Zoomed", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_Disguising))
	{
		PrintToChat (iClient, "%s TFCond_Disguising", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_Disguised))
	{
		PrintToChat (iClient, "%s TFCond_Disguised", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_Cloaked))
	{
		PrintToChat (iClient, "%s TFCond_Cloaked", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_Ubercharged))
	{
		PrintToChat (iClient, "%s TFCond_Ubercharged", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_TeleportedGlow))
	{
		PrintToChat (iClient, "%s TFCond_TeleportedGlow", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_Taunting))
	{
		PrintToChat (iClient, "%s TFCond_Taunting", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_UberchargeFading))
	{
		PrintToChat (iClient, "%s TFCond_UberchargeFading", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_Unknown1))
	{
		PrintToChat (iClient, "%s TFCond_Unknown1", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_CloakFlicker))
	{
		PrintToChat (iClient, "%s TFCond_CloakFlicker", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_Teleporting))
	{
		PrintToChat (iClient, "%s TFCond_Teleporting", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_Kritzkrieged))
	{
		PrintToChat (iClient, "%s TFCond_Kritzkrieged", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_Unknown2))
	{
		PrintToChat (iClient, "%s TFCond_Unknown2", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_TmpDamageBonus))
	{
		PrintToChat (iClient, "%s TFCond_TmpDamageBonus", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_DeadRingered))
	{
		PrintToChat (iClient, "%s TFCond_DeadRingered", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_Bonked))
	{
		PrintToChat (iClient, "%s TFCond_Bonked", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_Dazed))
	{
		PrintToChat (iClient, "%s TFCond_Dazed", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_Buffed))
	{
		PrintToChat (iClient, "%s TFCond_Buffed", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_Charging))
	{
		PrintToChat (iClient, "%s TFCond_Charging", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_DemoBuff))
	{
		PrintToChat (iClient, "%s TFCond_DemoBuff", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_CritCola))
	{
		PrintToChat (iClient, "%s TFCond_CritCola", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_InHealRadius))
	{
		PrintToChat (iClient, "%s TFCond_InHealRadius", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_Healing))
	{
		PrintToChat (iClient, "%s TFCond_Healing", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_OnFire))
	{
		PrintToChat (iClient, "%s TFCond_OnFire", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_Overhealed))
	{
		PrintToChat (iClient, "%s TFCond_Overhealed", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_Jarated))
	{
		PrintToChat (iClient, "%s TFCond_Jarated", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_Bleeding))
	{
		PrintToChat (iClient, "%s TFCond_Bleeding", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_DefenseBuffed))
	{
		PrintToChat (iClient, "%s TFCond_DefenseBuffed", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_Milked))
	{
		PrintToChat (iClient, "%s TFCond_Milked", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_MegaHeal))
	{
		PrintToChat (iClient, "%s TFCond_MegaHeal", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_RegenBuffed))
	{
		PrintToChat (iClient, "%s TFCond_RegenBuffed", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_MarkedForDeath))
	{
		PrintToChat (iClient, "%s TFCond_MarkedForDeath", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_NoHealingDamageBuff))
	{
		PrintToChat (iClient, "%s TFCond_NoHealingDamageBuff", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_SpeedBuffAlly))
	{
		PrintToChat (iClient, "%s TFCond_SpeedBuffAlly", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_HalloweenCritCandy))
	{
		PrintToChat (iClient, "%s TFCond_HalloweenCritCandy", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_CritCanteen))
	{
		PrintToChat (iClient, "%s TFCond_CritCanteen", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_CritDemoCharge))
	{
		PrintToChat (iClient, "%s TFCond_CritDemoCharge", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_CritHype))
	{
		PrintToChat (iClient, "%s TFCond_CritHype", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_CritOnFirstBlood))
	{
		PrintToChat (iClient, "%s TFCond_CritOnFirstBlood", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_CritOnWin))
	{
		PrintToChat (iClient, "%s TFCond_CritOnWin", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_CritOnFlagCapture))
	{
		PrintToChat (iClient, "%s TFCond_CritOnFlagCapture", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_CritOnKill))
	{
		PrintToChat (iClient, "%s TFCond_CritOnKill", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_RestrictToMelee))
	{
		PrintToChat (iClient, "%s TFCond_RestrictToMelee", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_DefenseBuffNoCritBlock))
	{
		PrintToChat (iClient, "%s TFCond_DefenseBuffNoCritBlock", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_Reprogrammed))
	{
		PrintToChat (iClient, "%s TFCond_Reprogrammed", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_CritMmmph))
	{
		PrintToChat (iClient, "%s TFCond_CritMmmph", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_DefenseBuffMmmph))
	{
		PrintToChat (iClient, "%s TFCond_DefenseBuffMmmph", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_FocusBuff))
	{
		PrintToChat (iClient, "%s TFCond_FocusBuff", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_DisguiseRemoved))
	{
		PrintToChat (iClient, "%s TFCond_DisguiseRemoved", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_MarkedForDeathSilent))
	{
		PrintToChat (iClient, "%s TFCond_MarkedForDeathSilent", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_DisguisedAsDispenser))
	{
		PrintToChat (iClient, "%s TFCond_DisguisedAsDispenser", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_Sapped))
	{
		PrintToChat (iClient, "%s TFCond_Sapped", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_UberchargedHidden))
	{
		PrintToChat (iClient, "%s TFCond_UberchargedHidden", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_UberchargedCanteen))
	{
		PrintToChat (iClient, "%s TFCond_UberchargedCanteen", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_HalloweenBombHead))
	{
		PrintToChat (iClient, "%s TFCond_HalloweenBombHead", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_HalloweenThriller))
	{
		PrintToChat (iClient, "%s TFCond_HalloweenThriller", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_RadiusHealOnDamage))
	{
		PrintToChat (iClient, "%s TFCond_RadiusHealOnDamage", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_CritOnDamage))
	{
		PrintToChat (iClient, "%s TFCond_CritOnDamage", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_UberchargedOnTakeDamage))
	{
		PrintToChat (iClient, "%s TFCond_UberchargedOnTakeDamage", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_UberBulletResist))
	{
		PrintToChat (iClient, "%s TFCond_UberBulletResist", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_UberBlastResist))
	{
		PrintToChat (iClient, "%s TFCond_UberBlastResist", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_UberFireResist))
	{
		PrintToChat (iClient, "%s TFCond_UberFireResist", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_SmallBulletResist))
	{
		PrintToChat (iClient, "%s TFCond_SmallBulletResist", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_SmallBlastResist))
	{
		PrintToChat (iClient, "%s TFCond_SmallBlastResist", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_SmallFireResist))
	{
		PrintToChat (iClient, "%s TFCond_SmallFireResist", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_Stealthed))
	{
		PrintToChat (iClient, "%s TFCond_Stealthed", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_MedigunDebuff))
	{
		PrintToChat (iClient, "%s TFCond_MedigunDebuff", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_StealthedUserBuffFade))
	{
		PrintToChat (iClient, "%s TFCond_StealthedUserBuffFade", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_BulletImmune))
	{
		PrintToChat (iClient, "%s TFCond_BulletImmune", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_BlastImmune))
	{
		PrintToChat (iClient, "%s TFCond_BlastImmune", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_FireImmune))
	{
		PrintToChat (iClient, "%s TFCond_FireImmune", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_PreventDeath))
	{
		PrintToChat (iClient, "%s TFCond_PreventDeath", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_MVMBotRadiowave))
	{
		PrintToChat (iClient, "%s TFCond_MVMBotRadiowave", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_HalloweenSpeedBoost))
	{
		PrintToChat (iClient, "%s TFCond_HalloweenSpeedBoost", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_HalloweenQuickHeal))
	{
		PrintToChat (iClient, "%s TFCond_HalloweenQuickHeal", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_HalloweenGiant))
	{
		PrintToChat (iClient, "%s TFCond_HalloweenGiant", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_HalloweenTiny))
	{
		PrintToChat (iClient, "%s TFCond_HalloweenTiny", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_HalloweenInHell))
	{
		PrintToChat (iClient, "%s TFCond_HalloweenInHell", PLUGIN_PRINT_NAME);
	}

	if (TF2_IsPlayerInCondition(iClient, TFCond_HalloweenGhostMode))
	{
		PrintToChat (iClient, "%s TFCond_HalloweenGhostMode", PLUGIN_PRINT_NAME);
	}


	// MOVETYPE
	new MoveType:movetype = GetEntityMoveType(iClient);

	if (movetype == MOVETYPE_NONE)
	{
		PrintToChat (iClient, "%s MOVETYPE_NONE", PLUGIN_PRINT_NAME);
	}
	
	if (movetype == MOVETYPE_ISOMETRIC)
	{
		PrintToChat (iClient, "%s MOVETYPE_ISOMETRIC", PLUGIN_PRINT_NAME);
	}
	
	if (movetype == MOVETYPE_WALK)
	{
		PrintToChat (iClient, "%s MOVETYPE_WALK", PLUGIN_PRINT_NAME);
	}
	
	if (movetype == MOVETYPE_STEP)
	{
		PrintToChat (iClient, "%s MOVETYPE_STEP", PLUGIN_PRINT_NAME);
	}
	
	if (movetype == MOVETYPE_FLY)
	{
		PrintToChat (iClient, "%s MOVETYPE_FLY", PLUGIN_PRINT_NAME);
	}
	
	if (movetype == MOVETYPE_FLYGRAVITY)
	{
		PrintToChat (iClient, "%s MOVETYPE_FLYGRAVITY", PLUGIN_PRINT_NAME);
	}
	
	if (movetype == MOVETYPE_VPHYSICS)
	{
		PrintToChat (iClient, "%s MOVETYPE_VPHYSICS", PLUGIN_PRINT_NAME);
	}
	
	if (movetype == MOVETYPE_PUSH)
	{
		PrintToChat (iClient, "%s MOVETYPE_PUSH", PLUGIN_PRINT_NAME);
	}
	
	if (movetype == MOVETYPE_NOCLIP)
	{
		PrintToChat (iClient, "%s MOVETYPE_NOCLIP", PLUGIN_PRINT_NAME);
	}
	
	if (movetype == MOVETYPE_LADDER)
	{
		PrintToChat (iClient, "%s MOVETYPE_LADDER", PLUGIN_PRINT_NAME);
	}
	
	if (movetype == MOVETYPE_OBSERVER)
	{
		PrintToChat (iClient, "%s MOVETYPE_OBSERVER", PLUGIN_PRINT_NAME);
	}
	
	if (movetype == MOVETYPE_CUSTOM)
	{
		PrintToChat (iClient, "%s MOVETYPE_CUSTOM", PLUGIN_PRINT_NAME);
	}
	
}


