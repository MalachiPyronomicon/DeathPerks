//	------------------------------------------------------------------------------------
//	Filename:		testghost.sp
//	Author:			Malachi
//	Version:		(see PLUGIN_VERSION)
//	Description:
//					Plugin spawns various options when donator dies during afterround.
//	------------------------------------------------------------------------------------


// INCLUDES
#include <sourcemod>
#include <tf2>					// TF2_AddCondition
#include <tf2_stocks>			// TF2_IsPlayerInCondition

#pragma semicolon 1


// DEFINES
// Plugin Info
#define PLUGIN_INFO_VERSION			"0.0.3"
#define PLUGIN_INFO_NAME			"Test plugin"
#define PLUGIN_INFO_AUTHOR			"Malachi"
#define PLUGIN_INFO_DESCRIPTION		"Test plugin"
#define PLUGIN_INFO_URL				"http://www.necrophix.com/"
#define PLUGIN_PRINT_NAME			"[Test Plugin]"			// Used for self-identification in chat/logging

#define MODEL_PATH_GHOST				"models/props_halloween/ghost.mdl"

// Ghost Parameters
#define TFCONDITION_HALLOWEEN_BOMB				TFCond_HalloweenBombHead					// 2nd tf condition #
#define TFCONDITION_HALLOWEEN_THRILLR			TFCond_HalloweenThriller					// 2nd tf condition #
#define TFCONDITION_HALLOWEEN_SPEEDB			TFCond_HalloweenSpeedBoost					// 2nd tf condition #
#define TFCONDITION_HALLOWEEN_GIANT				TFCond_HalloweenGiant						// 2nd tf condition #
#define TFCONDITION_HALLOWEEN_TINY				TFCond_HalloweenTiny						// 2nd tf condition #
#define TFCONDITION_HALLOWEEN_GHOSTHELL			TFCond_HalloweenInHell						// 2nd tf condition #76 for ghost mode [Non-Holiday: <nothing>; Holiday: <nothing>]
#define TFCONDITION_HALLOWEEN_GHOST				TFCond_HalloweenGhostMode					// the tf condition #77 for ghost mode [Non-Holiday: spawns, but invisible?; Holiday: ]
#define TFCONDITION_UBERCHARGED					TFCond_Ubercharged

#define	SOUND_NAME_GHOST_1			"vo/halloween_boo1.wav"
#define	SOUND_NAME_GHOST_2			"vo/halloween_boo2.wav"
#define	SOUND_NAME_GHOST_3			"vo/halloween_boo3.wav"
#define	SOUND_NAME_GHOST_4			"vo/halloween_boo4.wav"
#define	SOUND_NAME_GHOST_5			"vo/halloween_boo5.wav"
#define	SOUND_NAME_GHOST_6			"vo/halloween_boo6.wav"
#define	SOUND_NAME_GHOST_7			"vo/halloween_boo7.wav"


#define CONCMD_ACTIVATE						"sm_testghost"
#define CONCMD_ACTIVATE_DESCRIPTION			"sm_testghost"


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
	RegConsoleCmd(CONCMD_ACTIVATE, CallMakeGhost,  CONCMD_ACTIVATE_DESCRIPTION);

}


public OnMapStart()
{
	PrecacheModel(MODEL_PATH_GHOST, true);
	PrecacheSound(SOUND_NAME_GHOST_1, true);
	PrecacheSound(SOUND_NAME_GHOST_2, true);
	PrecacheSound(SOUND_NAME_GHOST_3, true);
	PrecacheSound(SOUND_NAME_GHOST_4, true);
	PrecacheSound(SOUND_NAME_GHOST_5, true);
	PrecacheSound(SOUND_NAME_GHOST_6, true);
	PrecacheSound(SOUND_NAME_GHOST_7, true);
}



public Action:CallMakeGhost(iClientIdx, args)

{
	// apparently will crash server if you try to set this twice (like on plr_hightower_event)
	if (!TF2_IsPlayerInCondition(iClientIdx, TFCONDITION_UBERCHARGED))
	{
		PrintToChat (iClientIdx, "%s Ghost spawned.", PLUGIN_PRINT_NAME);
		
		// native TF2_AddCondition(client, TFCond:condition, Float:duration=TFCondDuration_Infinite, inflictor=0);
		TF2_AddCondition(iClientIdx, TFCONDITION_UBERCHARGED, 60.0, 0);
		
		SetEntityRenderMode(iClientIdx, RENDER_TRANSALPHA);
		
		// stock SetEntityRenderColor(entity, r=255, g=255, b=255, a=255)
		SetEntityRenderColor(iClientIdx, 255, 255, 255, 255);
	}
	else
	{
		PrintToChat (iClientIdx, "%s ERROR - Already a ghost.", PLUGIN_PRINT_NAME);
	}

}


