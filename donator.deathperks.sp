//	------------------------------------------------------------------------------------
//	Filename:		donator.deathperks.sp
//	Author:			Malachi
//	Version:		(see PLUGIN_INFO_VERSION)
//	Description:
//					Plugin spawns various options when donator dies during afterround.
//
// * Changelog (date/version/description):
// * 2013-07-24	-	0.1.1		-	initial test version
// * 2013-07-25	-	0.1.2		-	add pumpkin spawn
// * 2013-07-25	-	0.1.3		-	find ground to spawn pumpkin on
// * 2013-07-26	-	0.1.4		-	add ball item
// * 2013-07-26	-	0.1.5		-	add exploding oildrum item, add missing donator check, change Prop_Data to Prop_Send
// * 							-	the event_player_death function is getting kinda ugly - mark for cleanup?
// * 2013-07-27	-	0.1.6		-	add frog
// * 2013-07-27	-	0.1.7		-	make frog explosive, fix ignored offset heights
// * 2013-07-27	-	0.1.8		-	add frog lightning, fix explosion keyvalues
// * 2013-07-27	-	0.1.9		-	add timer to deal with explosion causing multple death events
// * 2013-07-27	-	0.1.10		-	adjust explosion/lightning values
// * 2013-08-09	-	0.1.11		-	unused
// * 2013-08-09	-	0.1.12		-	add ghost - handle remnant particle/glow effects, use array to enable/disable
// * 2013-08-17	-	0.1.13		-	add ball scale, disable ghost until particle/glow is fixed
// * 2013-11-03	-	0.1.14		-	use newly added tfcondition ghost mode, trigger oildrum+pumpkin to explode, disable ball scale
// * 2014-02-14	-	0.1.15		-	fix ghost?
// * 2014-05-19	-	0.1.16		-	add uber, statue, improve error logging, reorganized functions, comment out ghost/uber
// * 2014-05-23	-	0.1.17		-	improve statue
//	------------------------------------------------------------------------------------


// INCLUDES
#include <sourcemod>
#include <donator>
#include <clientprefs>
#include <sdktools>
#include <tf2>							// TF2_AddCondition
#include <tf2_stocks>					// TF2_IsPlayerInCondition
#include <sdkhooks>						// SDKHooks_TakeDamage

#pragma semicolon 1


// DEFINES

// Plugin Info
#define PLUGIN_INFO_VERSION				"0.1.17"
#define PLUGIN_INFO_NAME				"Donator Death Perks"
#define PLUGIN_INFO_AUTHOR				"Malachi"
#define PLUGIN_INFO_DESCRIPTION			"handles after-round donator perks"
#define PLUGIN_INFO_URL					"http://www.necrophix.com/"
#define PLUGIN_PRINT_NAME				"[DeathPerks]"							// Used for self-identification in chat/logging

// Donator menu
#define MENUTEXT_SPAWN_ITEM				"After-round Perks"
#define MENUTITLE_SPAWN_ITEM			"Donator: Change After-round Perk:"
#define MENUSELECT_ITEM_NULL			"Disabled"
#define MENUSELECT_ITEM_PUMPKIN			"Pumpkin on Death"
#define MENUSELECT_ITEM_BALL			"Beach Ball on Death"
#define MENUSELECT_ITEM_OILDRUM			"Barrel on Death"
#define MENUSELECT_ITEM_FROG			"Frog on Death"
#define MENUSELECT_ITEM_GHOST			"Ghost Mode"
#define MENUSELECT_ITEM_UBER			"Ubered"
#define MENUSELECT_ITEM_STATUE			"Statued"

// cookie names
#define COOKIENAME_SPAWN_ITEM			"donator_deathperks"
#define COOKIEDESCRIPTION_SPAWN_ITEM	"Spawn pumpkin/misc on donator death."

// Entity names
#define ENTITY_NAME_PUMPKIN				"tf_pumpkin_bomb"
#define ENTITY_NAME_BALL				"prop_physics_multiplayer"
#define ENTITY_NAME_OILDRUM				"prop_physics"
#define ENTITY_NAME_FROG				"prop_dynamic"
#define ENTITY_NAME_PROPANETANK			""
#define ENTITY_NAME_EXPLOSION			"env_explosion"
#define ENTITY_NAME_GHOST				""

// Target Name
#define DEATHPERKS_TARGET_NAME			"donator_deathperks_entity"
#define DEATHPERKS_TARGET_KEYVALUE		"m_iName"

// Model paths
#define MODEL_PATH_PUMPKIN				"models/props_halloween/pumpkin_explode.mdl"
#define MODEL_PATH_BALL					"models/props_gameplay/ball001.mdl"
#define MODEL_PATH_OILDRUM				"models/props_c17/oildrum001_explosive.mdl"
#define MODEL_PATH_FROG					"models/props_2fort/frog.mdl"
#define MODEL_PATH_PROPANETANK			"models/props_junk/propane_tank001a.mdl"	// HL2 content!
#define MODEL_PATH_GHOST				"models/props_halloween/ghost.mdl"
//#define MODEL_PATH_GHOST				"models/props_halloween/ghost_no_hat.mdl"	// alternate ghost model

// Sprite paths
#define SPRITE_PATH_LIGHTNING			"sprites/lgtning.vmt"

// Vector angles
#define VECTOR_ANGLE_DOWN				{90.0, 0.0, 0.0}							// vector angle pointing straight down
#define VECTOR_ANGLE_PUMPKIN			{0.0, 0.0, 0.0}								// vector angle for pumpkin to spawn at
#define VECTOR_ANGLE_BALL				{0.0, 0.0, 0.0}								// vector angle for beach ball to spawn at
#define VECTOR_ANGLE_OILDRUM			{0.0, 0.0, 0.0}								// vector angle for oil drum to spawn at
#define VECTOR_ANGLE_FROG				{0.0, 0.0, 0.0}								// vector angle for frog to spawn at
#define VECTOR_ANGLE_PROPANETANK		{0.0, 0.0, 0.0}								// vector angle for propane tank to spawn at

// Distances
#define MAX_SPAWN_DISTANCE				1024.0										// max distance to spawn items beneath players

// Z-Axis offset heights
#define OFFSET_HEIGHT_PUMPKIN			10.0										// adjust height of pumpkins off ground
#define OFFSET_HEIGHT_BALL				-20.0										// adjust height of beach balls off ground
#define OFFSET_HEIGHT_OILDRUM			30.0										// adjust height of oildrum off ground
#define OFFSET_HEIGHT_FROG				0.0											// adjust height of propane tank off ground
#define OFFSET_HEIGHT_PROPANETANK		0.0											// adjust height of propane tank off ground

// Masks
#define MASK_PROP_SPAWN					(CONTENTS_SOLID|CONTENTS_WINDOW|CONTENTS_GRATE)		// contents mask to spawn items on

// Explosion parameters
#define EXPLOSIONKEYVALUE_MAGNITUDE			"iMagnitude"							// Key value: Magnitude
#define EXPLOSIONKEYVALUE_SPAWNFLAGS		"spawnflags"							// Key value: flags
#define EXPLOSIONKEYVALUE_RADIUS			"iRadiusOverride"						// Key value: radius
#define EXPLOSION_MAGNITUDE					"500"									// Magnitude
#define EXPLOSION_SPAWNFLAGS				"0"										// flags
#define EXPLOSION_RADIUS					"256"									// radius

// Lightning parameters
#define LIGHTNING_HALOINDEX				0											// Precached model index.
#define LIGHTNING_STARTFRAME			0											// Initital frame to render.
#define LIGHTNING_FRAMERATE				0											// Beam frame rate.
#define LIGHTNING_LIFE					0.75										// Time duration of the beam.
#define LIGHTNING_STARTWIDTH			20.0										// Initial beam width.
#define LIGHTNING_ENDWIDTH				10.0										// Final beam width.
#define LIGHTNING_FADELENGTH			0											// Beam fade time duration.
#define LIGHTNING_AMPLITUDE				1.0											// Beam amplitude.
#define LIGHTNING_COLOR					{255, 255, 255, 255}						// Color array (r, g, b, a).
#define LIGHTNING_SPEED					3											// Speed of the beam.
#define LIGHTNING_SOUND_THUNDER 		"ambient/explosions/explode_9.wav"

// Ball Parameters
#define BALLPARAM_SCALE					2.0											// Scale of ball

// Frog Parameters
#define FROGTIMER_SPAWN_DELAY			0.75										// How soon after player death does frog spawn.

// Drum Parameters
#define DRUMTIMER_EXPLODE_DELAY			1.5											// How soon after player death does drum explode.
#define DRUMTIMER_EXPLODE_DAMAGE		100.0										// Amount of damage to make drum explode.
#define DRUMKEYVALUE_MAGNITUDE			"m_explodeDamage"							// Key value: Magnitude
#define DRUM_MAGNITUDE					500.0										// Pumpkin explosion magnitude
#define DRUMKEYVALUE_RADIUS				"m_explodeRadius"							// Key value: radius
#define DRUM_RADIUS						256.0										// Pumpkin explosion radius

// Pumpkin Parameters
#define PUMPKINTIMER_EXPLODE_DELAY		1.5											// How soon after player death does drum explode.
#define PUMPKINTIMER_EXPLODE_DAMAGE		100.0										// Amount of damage to make drum explode.
#define PUMPKINKEYVALUE_MAGNITUDE		"m_explodeDamage"							// Key value: Magnitude
#define PUMPKIN_MAGNITUDE				500.0										// Pumpkin explosion magnitude
#define PUMPKINKEYVALUE_RADIUS			"m_explodeRadius"							// Key value: radius
#define PUMPKIN_RADIUS					256.0										// Pumpkin explosion radius

// Ghost Parameters
#define GHOSTPOV_DISABLE			0												// turn off third person pov
#define GHOSTPOV_ENABLE				2												// turn on third person pov
#define TFCONDITION_GHOST			TFCond_HalloweenGhostMode						// the tf condition #77 for ghost mode
#define TFCONDITION_GHOST2			TFCond_HalloweenInHell							// 2nd tf condition #76 for ghost mode
#define	SOUND_NAME_GHOST_1			"vo/halloween_boo1.wav"
#define	SOUND_NAME_GHOST_2			"vo/halloween_boo2.wav"
#define	SOUND_NAME_GHOST_3			"vo/halloween_boo3.wav"
#define	SOUND_NAME_GHOST_4			"vo/halloween_boo4.wav"
#define	SOUND_NAME_GHOST_5			"vo/halloween_boo5.wav"
#define	SOUND_NAME_GHOST_6			"vo/halloween_boo6.wav"
#define	SOUND_NAME_GHOST_7			"vo/halloween_boo7.wav"

// Uber Parameters
#define TFCONDITION_UBERCHARGED		TFCond_Ubercharged								// TF2 Condition to enable uber
#define TFCONDITION_UBER_TIME		60.0											// Float time (seconds) for condition to last
#define TFCONDITION_DAZED			TFCond_Dazed									// TF2 Condition to enable daze
#define TFSTUNFLAG_NONE		        (0 << 0)
#define TFSTUNFLAG_LOSER		 	TF_STUNFLAGS_LOSERSTATE

// Statue Parameters
#define STATUE_MOVETYPE				MOVETYPE_NONE									// movetype to use for statue
#define STATUE_COLOR_RED			92
#define STATUE_COLOR_GREEN			92
#define STATUE_COLOR_BLUE			92
#define STATUE_COLOR_ALPHA			255
#define STATUE_COLOR_RED_RESET		255
#define STATUE_COLOR_GREEN_RESET	255
#define STATUE_COLOR_BLUE_RESET		255
#define STATUE_COLOR_ALPHA_RESET	255
#define SOUND_FREEZE				"physics/glass/glass_impact_bullet4.wav"


enum _:CookieActionType
{
	Action_Null = 0,
	Action_Pumpkin = 1,
	Action_Ball = 2,
	Action_Oildrum = 3,
	Action_Frog = 4,
	Action_Ghost = 5,
	Action_Uber = 6,
	Action_Statue = 7
//	Action_Grave = 6,
//	Action_Bird = 7,
};


// GLOBALS
new Handle:g_hDeathItemCookie = INVALID_HANDLE;
new bool:g_bRoundEnded = false;
new g_iLightningSprite = 0;

new Handle:g_hFrogTimerHandle[MAXPLAYERS + 1] = {INVALID_HANDLE, ...};
new Handle:g_hDrumTimerHandle[MAXPLAYERS + 1] = {INVALID_HANDLE, ...};
new Handle:g_hPumpkinTimerHandle[MAXPLAYERS + 1] = {INVALID_HANDLE, ...};

new g_hFrogEntityReference[MAXPLAYERS + 1] = {INVALID_ENT_REFERENCE, ...};
new g_hDrumEntityReference[MAXPLAYERS + 1] = {INVALID_ENT_REFERENCE, ...};
new g_hPumpkinEntityReference[MAXPLAYERS + 1] = {INVALID_ENT_REFERENCE, ...};
new g_hBallEntityReference[MAXPLAYERS + 1] = {INVALID_ENT_REFERENCE, ...};

new bool:g_StatueClient[MAXPLAYERS + 1] = {false, ...};


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
	// Advertise our presence...
	PrintToServer("%s v%s Plugin start...", PLUGIN_PRINT_NAME, PLUGIN_INFO_VERSION);

	// Cookie time
	g_hDeathItemCookie = RegClientCookie(COOKIENAME_SPAWN_ITEM, COOKIEDESCRIPTION_SPAWN_ITEM, CookieAccess_Private);

	// Event Hooks
	HookEventEx("teamplay_round_start", hook_Start, EventHookMode_PostNoCopy);
	HookEventEx("arena_round_start", hook_Start, EventHookMode_PostNoCopy);
	HookEventEx("teamplay_round_win", hook_Win, EventHookMode_PostNoCopy);
	HookEventEx("arena_win_panel", hook_Win, EventHookMode_PostNoCopy);
	HookEventEx("player_death", event_player_death, EventHookMode_Post);
}


// Required: Basic donator interface
public OnAllPluginsLoaded()
{
	if(!LibraryExists("donator.core"))
		SetFailState("%s Unable to find plugin: Basic Donator Interface", PLUGIN_PRINT_NAME);

	if(GetExtensionFileStatus("sdkhooks.ext") < 1)
		SetFailState("%s SDK Hooks is not loaded.", PLUGIN_PRINT_NAME);
		
	Donator_RegisterMenuItem(MENUTEXT_SPAWN_ITEM, ChangeDeathItemCallback);
}


public OnMapStart()
{
	PrecacheModel(MODEL_PATH_OILDRUM, true);
	PrecacheModel(MODEL_PATH_FROG, true);
	PrecacheModel(MODEL_PATH_PUMPKIN, true);
	PrecacheModel(MODEL_PATH_GHOST, true);
	PrecacheSound(SOUND_NAME_GHOST_1, true);
	PrecacheSound(SOUND_NAME_GHOST_2, true);
	PrecacheSound(SOUND_NAME_GHOST_3, true);
	PrecacheSound(SOUND_NAME_GHOST_4, true);
	PrecacheSound(SOUND_NAME_GHOST_5, true);
	PrecacheSound(SOUND_NAME_GHOST_6, true);
	PrecacheSound(SOUND_NAME_GHOST_7, true);
	PrecacheSound(LIGHTNING_SOUND_THUNDER, true);
	PrecacheSound(SOUND_FREEZE, true);
	g_iLightningSprite = PrecacheModel(SPRITE_PATH_LIGHTNING, true);
}


public DonatorMenu:ChangeDeathItemCallback(iClient) Panel_ChangeDeathItem(iClient);


public hook_Start(Handle:event, const String:name[], bool:dontBroadcast)
{
	// Cleanup all frogs
	CleanupTimerArray (g_hFrogTimerHandle);
	KillEntityReferenceArray (g_hFrogEntityReference);

	// Cleanup all drums
	CleanupTimerArray (g_hDrumTimerHandle);
	KillEntityReferenceArray (g_hDrumEntityReference);

	// Cleanup all pumpkins
	CleanupTimerArray (g_hPumpkinTimerHandle);
	KillEntityReferenceArray (g_hPumpkinEntityReference);

	// Cleanup all balls
	KillEntityReferenceArray (g_hBallEntityReference);

	// Cleanup statues
	doRemoveStatueArray (g_StatueClient);
	
	g_bRoundEnded = false;

}


// Cleanup all timers on map end
public OnMapEnd()
{
	// Cleanup all frogs
	CleanupTimerArray (g_hFrogTimerHandle);
	KillEntityReferenceArray (g_hFrogEntityReference);

	// Cleanup all drums
	CleanupTimerArray (g_hDrumTimerHandle);
	KillEntityReferenceArray (g_hDrumEntityReference);

	// Cleanup all pumpkins
	CleanupTimerArray (g_hPumpkinTimerHandle);
	KillEntityReferenceArray (g_hPumpkinEntityReference);

	// Cleanup all balls
	KillEntityReferenceArray (g_hBallEntityReference);

}


// Cleanup when player leaves
public OnClientDisconnect(iClient)
{
	// Cleanup all frogs
	CleanupTimerClient (g_hFrogTimerHandle, iClient);
	KillEntityReferenceClient (g_hFrogEntityReference, iClient);

	// Cleanup all drums
	CleanupTimerClient (g_hDrumTimerHandle, iClient);
	KillEntityReferenceClient (g_hDrumEntityReference, iClient);

	// Cleanup all pumpkins
	CleanupTimerClient (g_hPumpkinTimerHandle, iClient);
	KillEntityReferenceClient (g_hPumpkinEntityReference, iClient);

	// Cleanup all balls
	KillEntityReferenceClient (g_hBallEntityReference, iClient);

}


public hook_Win(Handle:event, const String:name[], bool:dontBroadcast)
{	
	g_bRoundEnded = true;
	
	// Handle Ghost, Uber
	for (new iClient = 1; iClient <= MaxClients; iClient++)
	{
		// Is client in game?
		if (IsClientInGame(iClient))
		{
			// Is this client fake?
			if (!IsFakeClient(iClient))
			{
				// Is player alive?
				if (IsPlayerAlive(iClient))
				{
					// Is this client a donator?
					if (IsPlayerDonator(iClient))
					{
						decl String:iTmp[32];
						new iSelected;

						GetClientCookie(iClient, g_hDeathItemCookie, iTmp, sizeof(iTmp));
						iSelected = StringToInt(iTmp);

						if (_:iSelected == Action_Ghost)
						{
	//						doCreateGhost(iClient);
							PrintToChat (iClient, "%s Sorry, Ghost currently disabled.", PLUGIN_PRINT_NAME);
						}
						else
						if (_:iSelected == Action_Uber)
						{
	//						doCreateUber(iClient);
							PrintToChat (iClient, "%s Sorry, Uber currently disabled.", PLUGIN_PRINT_NAME);
						}
						else
						if (_:iSelected == Action_Statue)
						{
							doCreateStatue(iClient);
						}
						
					}
				}
			}
		}
	}

}


public Action:event_player_death(Handle:event, const String:name[], bool:dontBroadcast)
{
	// Round ended check
	if(!g_bRoundEnded)
		return Plugin_Continue;

	new iClient = GetClientOfUserId(GetEventInt(event, "userid"));
		
	// Donator check
	if (!IsPlayerDonator(iClient)) 
		return Plugin_Continue;
		
	decl String:iTmp[32];
	new iSelected;

	// Get player's choice of item to spawn
	GetClientCookie(iClient, g_hDeathItemCookie, iTmp, sizeof(iTmp));	
	iSelected = StringToInt(iTmp);

	switch (iSelected)
	{
		case Action_Null:
		{
			PrintToChat (iClient, "%s No perks selected.", PLUGIN_PRINT_NAME);
		}
		
		case Action_Pumpkin:
		{
			doCreatePumpkin(iClient);
		}
		
		case Action_Ball:
		{
			doCreateBall(iClient);
		}
		
		case Action_Oildrum:
		{
			doCreateOildrum(iClient);
		}

		case Action_Frog:
		{
			doCreateFrog(iClient);
		}

/*		case Action_Ghost:
		{
			//PrintToChat (iClient, "%s Ghost spawned.", PLUGIN_PRINT_NAME);
		}
*/
/*		case Action_Uber:
		{
			//PrintToChat (iClient, "%s Uber spawned.", PLUGIN_PRINT_NAME);
		}
*/
		case Action_Statue:
		{
			//PrintToChat (iClient, "%s Statue spawned.", PLUGIN_PRINT_NAME);
		}
		
		// If we get here, the cookie hasn't been set properly - so set it!
		// (do we really need this?)
		default:
		{
			new String:iTemp[32];
			IntToString(Action_Null, iTemp, sizeof(iTemp));
			SetClientCookie(iClient, g_hDeathItemCookie, iTemp);		
			PrintToChat (iClient, "%s Normalizing cookie - for extra yum!", PLUGIN_PRINT_NAME);
		}
		
	}

	
	return Plugin_Continue;
}


// Create Menu 
public Action:Panel_ChangeDeathItem(iClient)
{
	new Handle:menu = CreateMenu(DeathItemMenuHandler);
	decl String:iTmp[32];
	new iSelected;

	SetMenuTitle(menu, MENUTITLE_SPAWN_ITEM);

	GetClientCookie(iClient, g_hDeathItemCookie, iTmp, sizeof(iTmp));
	iSelected = StringToInt(iTmp);

	if (_:iSelected == Action_Null)
	{
		new String:iCompare[32];
		IntToString(Action_Null, iCompare, sizeof(iCompare));
		AddMenuItem(menu, iCompare, MENUSELECT_ITEM_NULL, ITEMDRAW_DISABLED);
	}
	else
	{
		new String:iCompare[32];
		IntToString(Action_Null, iCompare, sizeof(iCompare));
		AddMenuItem(menu, iCompare, MENUSELECT_ITEM_NULL, ITEMDRAW_DEFAULT);
	}
	
	// Exploding pumpkin
	if (_:iSelected == Action_Pumpkin)
	{
		new String:iCompare[32];
		IntToString(Action_Pumpkin, iCompare, sizeof(iCompare));
		AddMenuItem(menu, iCompare, MENUSELECT_ITEM_PUMPKIN, ITEMDRAW_DISABLED);
	}
	else
	{
		new String:iCompare[32];
		IntToString(Action_Pumpkin, iCompare, sizeof(iCompare));
		AddMenuItem(menu, iCompare, MENUSELECT_ITEM_PUMPKIN, ITEMDRAW_DEFAULT);
	}
	
	// Ball
	if (_:iSelected == Action_Ball)
	{
		new String:iCompare[32];
		IntToString(Action_Ball, iCompare, sizeof(iCompare));
		AddMenuItem(menu, iCompare, MENUSELECT_ITEM_BALL, ITEMDRAW_DISABLED);
	}
	else
	{
		new String:iCompare[32];
		IntToString(Action_Ball, iCompare, sizeof(iCompare));
		AddMenuItem(menu, iCompare, MENUSELECT_ITEM_BALL, ITEMDRAW_DEFAULT);
	}
	
	// Oildrum
	if (_:iSelected == Action_Oildrum)
	{
		new String:iCompare[32];
		IntToString(Action_Oildrum, iCompare, sizeof(iCompare));
		AddMenuItem(menu, iCompare, MENUSELECT_ITEM_OILDRUM, ITEMDRAW_DISABLED);
	}
	else
	{
		new String:iCompare[32];
		IntToString(Action_Oildrum, iCompare, sizeof(iCompare));
		AddMenuItem(menu, iCompare, MENUSELECT_ITEM_OILDRUM, ITEMDRAW_DEFAULT);
	}
	
	// Frog
	if (_:iSelected == Action_Frog)
	{
		new String:iCompare[32];
		IntToString(Action_Frog, iCompare, sizeof(iCompare));
		AddMenuItem(menu, iCompare, MENUSELECT_ITEM_FROG, ITEMDRAW_DISABLED);
	}
	else
	{
		new String:iCompare[32];
		IntToString(Action_Frog, iCompare, sizeof(iCompare));
		AddMenuItem(menu, iCompare, MENUSELECT_ITEM_FROG, ITEMDRAW_DEFAULT);
	}
	
/*	// Ghost
	if (_:iSelected == Action_Ghost)
	{
		new String:iCompare[32];
		IntToString(Action_Ghost, iCompare, sizeof(iCompare));
		AddMenuItem(menu, iCompare, MENUSELECT_ITEM_GHOST, ITEMDRAW_DISABLED);
	}
	else
	{
		new String:iCompare[32];
		IntToString(Action_Ghost, iCompare, sizeof(iCompare));
		AddMenuItem(menu, iCompare, MENUSELECT_ITEM_GHOST, ITEMDRAW_DEFAULT);
	}
*/
/*	// Uber
	if (_:iSelected == Action_Uber)
	{
		new String:iCompare[32];
		IntToString(Action_Uber, iCompare, sizeof(iCompare));
		AddMenuItem(menu, iCompare, MENUSELECT_ITEM_UBER, ITEMDRAW_DISABLED);
	}
	else
	{
		new String:iCompare[32];
		IntToString(Action_Uber, iCompare, sizeof(iCompare));
		AddMenuItem(menu, iCompare, MENUSELECT_ITEM_UBER, ITEMDRAW_DEFAULT);
	}
*/	
	// Statue
	if (_:iSelected == Action_Statue)
	{
		new String:iCompare[32];
		IntToString(Action_Statue, iCompare, sizeof(iCompare));
		AddMenuItem(menu, iCompare, MENUSELECT_ITEM_STATUE, ITEMDRAW_DISABLED);
	}
	else
	{
		new String:iCompare[32];
		IntToString(Action_Statue, iCompare, sizeof(iCompare));
		AddMenuItem(menu, iCompare, MENUSELECT_ITEM_STATUE, ITEMDRAW_DEFAULT);
	}
	
	DisplayMenu(menu, iClient, 20);
}


// Menu Handler
public DeathItemMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	decl String:iSelected[32];
	GetMenuItem(menu, param2, iSelected, sizeof(iSelected));

	switch (action)
	{
		case MenuAction_Select:
		{
			SetClientCookie(param1, g_hDeathItemCookie, iSelected);
		}
//		case MenuAction_Cancel: ;
		case MenuAction_End: CloseHandle(menu);
	}
}


public bool:TraceRayProp(entityhit, mask)
{
	if (entityhit == 0)												// I only want it to hit terrain, no models or debris
	{
		return true;
	}
	return false;
}


// timer: spawn donator frog/lightning/explosion
public Action:CallSpawnFrog(Handle:Timer, Handle:pack)
{
	// Set to the beginning and unpack it
	ResetPack(pack);
	new iClient = ReadPackCell(pack);

	decl Float:vEnd[3];
	vEnd[0] = ReadPackFloat(pack);
	vEnd[1] = ReadPackFloat(pack);
	vEnd[2] = ReadPackFloat(pack);
	
//	PrintToChat (iClient, "%s Attempting to create frog at (%f, %f, %f) for client #%d.", PLUGIN_PRINT_NAME, vEnd[0], vEnd[1], vEnd[2], iClient);

	new iFrog = CreateEntityByName(ENTITY_NAME_FROG);
	
	if(IsValidEntity(iFrog))
	{	
		// Save ent index as guaranteed reference for later
		g_hFrogEntityReference[iClient] = EntIndexToEntRef(iFrog);
	
		if(GetEntityCount() < GetMaxEntities()-32)
		{
			SetEntityModel(iFrog, MODEL_PATH_FROG);
			DispatchSpawn(iFrog);
			vEnd[2] += OFFSET_HEIGHT_FROG;

			new Float:ModelAngle[3] = VECTOR_ANGLE_FROG;
			TeleportEntity(iFrog, vEnd, ModelAngle, NULL_VECTOR);

			// Explosion
			new hExplosion = CreateEntityByName(ENTITY_NAME_EXPLOSION);
			DispatchKeyValue(hExplosion, EXPLOSIONKEYVALUE_MAGNITUDE, EXPLOSION_MAGNITUDE);
			DispatchKeyValue(hExplosion, EXPLOSIONKEYVALUE_SPAWNFLAGS, EXPLOSION_SPAWNFLAGS);
			DispatchKeyValue(hExplosion, EXPLOSIONKEYVALUE_RADIUS, EXPLOSION_RADIUS);

			if ( DispatchSpawn(hExplosion) )
			{
				ActivateEntity(hExplosion);
				TeleportEntity(hExplosion, vEnd, NULL_VECTOR, NULL_VECTOR);
				AcceptEntityInput(hExplosion, "Explode");
				AcceptEntityInput(hExplosion, "Kill");
			}


			PrintToChat (iClient, "%s Frog spawned.", PLUGIN_PRINT_NAME);
		}
		else
		{
			PrintToChat (iClient, "%s ERROR - Unable to spawn frog, maxEntities reached.", PLUGIN_PRINT_NAME);
			LogError ("%s ERROR - Unable to spawn frog, maxEntities reached.", PLUGIN_PRINT_NAME);
		}
		
	}
	else
	{
		PrintToChat (iClient, "%s ERROR - Unknown error, frog spawn failed.", PLUGIN_PRINT_NAME);
		LogError ("%s ERROR - Unknown error, frog spawn failed.", PLUGIN_PRINT_NAME);
	}


	g_hFrogTimerHandle[iClient] = INVALID_HANDLE;

}


// timer: Remove Stun
public Action:CallRemoveStun(Handle:Timer, Handle:pack)
{
	// Set to the beginning and unpack it
	ResetPack(pack);
	new iClient = ReadPackCell(pack);

//	TF2_RemoveCondition(iClient, TFCONDITION_DAZED);
	TF2_AddCondition(iClient, TFCond_MegaHeal, TFCONDITION_UBER_TIME, 0);
	TF2_AddCondition(iClient, TFCONDITION_UBERCHARGED, TFCONDITION_UBER_TIME, 0);
	
}


// timer: explode drum
public Action:CallExplodeDrum(Handle:Timer, Handle:pack)
{
	// Set to the beginning and unpack it
	ResetPack(pack);
	new iClient = ReadPackCell(pack);
	new iOildrum = ReadPackCell(pack);
	
	// will this cover if the oil drum is already exploded by a player?	
	if ( IsValidEntity(iOildrum) )
	{	
		SDKHooks_TakeDamage(iOildrum, iClient, iClient, DRUMTIMER_EXPLODE_DAMAGE, DMG_GENERIC);
	}
	else
	{
		PrintToServer ("%s CATCH - Oildrum no longer exists.", PLUGIN_PRINT_NAME);
	}

	g_hDrumTimerHandle[iClient] = INVALID_HANDLE;

}


// timer: explode pumpkin
public Action:CallExplodePumpkin(Handle:Timer, Handle:pack)
{
	// Set to the beginning and unpack it
	ResetPack(pack);
	new iClient = ReadPackCell(pack);
	new iPumpkin = ReadPackCell(pack);

	// will this cover if the pumpkin is already exploded by a player?	
	if ( IsValidEntity(iPumpkin) )
	{	
		SDKHooks_TakeDamage(iPumpkin, iClient, iClient, PUMPKINTIMER_EXPLODE_DAMAGE, DMG_GENERIC);
	}
	else
	{
		PrintToServer ("%s CATCH - Pumpkin no longer exists.", PLUGIN_PRINT_NAME);
	}
	
	g_hPumpkinTimerHandle[iClient] = INVALID_HANDLE;

}


doCreateGhost(iClient)
{
	// apparently will crash server if you try to set this twice (like on plr_hightower_event)
/*	if (!TF2_IsPlayerInCondition(iClient, TFCONDITION_GHOST) && !TF2_IsPlayerInCondition(iClient, TFCONDITION_GHOST2))
	{
		PrintToChat (iClient, "%s Ghost spawned.", PLUGIN_PRINT_NAME);
		TF2_AddCondition(iClient, TFCONDITION_GHOST, 60.0, 0);
	}
	else
	{
		PrintToChat (iClient, "%s ERROR - Already a ghost.", PLUGIN_PRINT_NAME);
	}
*/
	PrintToChat (iClient, "%s Ghost temporarily disabled, sorry.", PLUGIN_PRINT_NAME);
}


doCreateUber(iClient)
{
	// native TF2_AddCondition(client, TFCond:condition, Float:duration=TFCondDuration_Infinite, inflictor=0);
	// If set to TFCondDuration_Infinite, player loses uber on medic heal.
	// Doesnt work after round end on losing team?
//	TF2_RemoveCondition(iClient, TFCONDITION_DAZED);
//	TF2_StunPlayer(iClient, TFCONDITION_UBER_TIME, 0.0, TFSTUNFLAG_NONE, 0);
//	TF2_StunPlayer(iClient, 0.1, 0.0, TFSTUNFLAG_LOSER, 0);
//	TF2_AddCondition(iClient, TFCONDITION_UBERCHARGED, TFCONDITION_UBER_TIME, 0);

	new Handle:pack;
	CreateDataTimer(0.1, CallRemoveStun, pack, TIMER_FLAG_NO_MAPCHANGE);

	WritePackCell(pack, iClient);
	
	PrintToChat (iClient, "%s Ubered.", PLUGIN_PRINT_NAME);

}


doCreateStatue(iClient)
{
	// Remember who we made into a statue
	g_StatueClient[iClient] = true;

	SDKHook(iClient, SDKHook_OnTakeDamage, BlockClientDamage);
	
	SetEntityMoveType(iClient, STATUE_MOVETYPE);
	SetEntityRenderColor(iClient, STATUE_COLOR_RED, STATUE_COLOR_GREEN, STATUE_COLOR_BLUE, STATUE_COLOR_ALPHA);

	new Float:vec[3];
	GetClientEyePosition(iClient, vec);
	EmitAmbientSound(SOUND_FREEZE, vec, iClient, SNDLEVEL_RAIDSIREN);

	// Kill animation playing
//	SetVariantString("idle");
//	AcceptEntityInput(iClient , "SetAnimation", -1, -1, 0);

	PrintToChat (iClient, "%s Turned you into a statue.", PLUGIN_PRINT_NAME);
}


doRemoveStatueArray(bool:iClient[])
{
	// For each client, undo statue
	for(new i = 0; i < (MAXPLAYERS + 1); i++)
	{

		// Remember who we made into a statue
		if (iClient[i] == true)
		{
			SDKUnhook(i, SDKHook_OnTakeDamage, BlockClientDamage);
			
			SetEntityRenderColor(i, STATUE_COLOR_RED_RESET, STATUE_COLOR_GREEN_RESET, STATUE_COLOR_BLUE_RESET, STATUE_COLOR_ALPHA_RESET);
		}
		
		// zero everyone out
		iClient[i] = false;
	}
}


public Action:BlockClientDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3], damagecustom)
{
	if (g_StatueClient[victim] == true)
	{
		if (g_bRoundEnded == true)
		{
			damage = 0.0;
			return Plugin_Changed;
		}
	}
	
	PrintToServer ("%s CATCH - BlockClientDamage: not a statue and/or not round end.", PLUGIN_PRINT_NAME);
	
	return Plugin_Continue;
}


doCreatePumpkin(iClient)
{
	decl Float:vOrigin[3];
	GetClientEyePosition(iClient, vOrigin);
	decl Handle:TraceRay;
	new Float:Angles[3] = VECTOR_ANGLE_DOWN;

	TraceRay = TR_TraceRayFilterEx(vOrigin, Angles, MASK_PROP_SPAWN, RayType_Infinite, TraceRayProp);

	if (TR_DidHit(TraceRay))
	{
		decl Float:Distance;
		decl Float:vEnd[3];
		TR_GetEndPosition(vEnd, TraceRay);
		Distance = (GetVectorDistance(vOrigin, vEnd));

		if (Distance < MAX_SPAWN_DISTANCE)
		{
			new iPumpkin = CreateEntityByName(ENTITY_NAME_PUMPKIN);
			
			if(IsValidEntity(iPumpkin))
			{		
				// Save ent index as guaranteed reference for later
				g_hPumpkinEntityReference[iClient] = EntIndexToEntRef(iPumpkin);
				
				if(GetEntityCount() < GetMaxEntities()-32)
				{
					PrintToChat (iClient, "%s Pumpkin spawned.", PLUGIN_PRINT_NAME);
					
					DispatchSpawn(iPumpkin);
					vEnd[2] += OFFSET_HEIGHT_PUMPKIN;

					new Float:ModelAngle[3] = VECTOR_ANGLE_PUMPKIN;
					TeleportEntity(iPumpkin, vEnd, ModelAngle, NULL_VECTOR);

					// Set explosion amount
//					SetEntPropFloat(iPumpkin, Prop_Data, PUMPKINKEYVALUE_MAGNITUDE, PUMPKIN_MAGNITUDE);
					
					// Set explosion size
//					SetEntPropFloat(iPumpkin, Prop_Data, PUMPKINKEYVALUE_RADIUS, PUMPKIN_RADIUS);

					// explode pumpkin
					new Handle:pack;
					
					g_hPumpkinTimerHandle[iClient] = CreateDataTimer(PUMPKINTIMER_EXPLODE_DELAY, CallExplodePumpkin, pack);
					
					WritePackCell(pack, iClient);
					WritePackCell(pack, iPumpkin);
					
				}
				else
				{
					PrintToChat (iClient, "%s ERROR - Unable to spawn pumpkin, maxEntities reached.", PLUGIN_PRINT_NAME);
					LogError ("%s ERROR - Unable to spawn pumpkin, maxEntities reached.", PLUGIN_PRINT_NAME);
				}
				
			}
			else
			{
				PrintToChat (iClient, "%s ERROR - Unknown error, pumpkin spawn failed.", PLUGIN_PRINT_NAME);
				LogError ("%s ERROR - Unknown error, pumpkin spawn failed.", PLUGIN_PRINT_NAME);
			}
		}
	}
	else
	{
		PrintToChat (iClient, "%s ERROR - Sorry, unable to locate ground!", PLUGIN_PRINT_NAME);
	}

	CloseHandle(TraceRay);
}


doCreateBall(iClient)
{
	new iBall = CreateEntityByName(ENTITY_NAME_BALL);
	
	if(IsValidEntity(iBall))
	{
		// Save ent index as guaranteed reference for later
		g_hBallEntityReference[iClient] = EntIndexToEntRef(iBall);
	
		decl Float:vOrigin[3];
		GetClientEyePosition(iClient, vOrigin);
		
		vOrigin[2] += OFFSET_HEIGHT_BALL;

		DispatchKeyValue(iBall, "model", MODEL_PATH_BALL);
		DispatchKeyValue(iBall, "disableshadows", "1");
		DispatchKeyValue(iBall, "skin", "0");
		DispatchKeyValue(iBall, "physicsmode", "1");
		DispatchKeyValue(iBall, "spawnflags", "256");
		DispatchSpawn(iBall);

		// Set ball size
		//SetEntPropFloat(iBall, Prop_Send, "m_flModelScale", BALLPARAM_SCALE);
		
		new Float:ModelAngle[3] = VECTOR_ANGLE_BALL;
		TeleportEntity(iBall, vOrigin, ModelAngle, NULL_VECTOR);
		
		PrintToChat (iClient, "%s Ball spawned.", PLUGIN_PRINT_NAME);
	}
}


doCreateOildrum(iClient)
{
	decl Float:vOrigin[3];
	GetClientEyePosition(iClient, vOrigin);
	decl Handle:TraceRay;
	new Float:Angles[3] = VECTOR_ANGLE_DOWN;								// down

	TraceRay = TR_TraceRayFilterEx(vOrigin, Angles, MASK_PROP_SPAWN, RayType_Infinite, TraceRayProp);

	if (TR_DidHit(TraceRay))
	{
		decl Float:Distance;
		decl Float:vEnd[3];
		TR_GetEndPosition(vEnd, TraceRay);
		Distance = (GetVectorDistance(vOrigin, vEnd));

		if (Distance < MAX_SPAWN_DISTANCE)
		{
			new iDrum = CreateEntityByName(ENTITY_NAME_OILDRUM);
			
			if(IsValidEntity(iDrum))
			{		
				// Save ent index as guaranteed reference for later
				g_hDrumEntityReference[iClient] = EntIndexToEntRef(iDrum);
				
				if(GetEntityCount() < GetMaxEntities()-32)
				{
					PrintToChat (iClient, "%s Oildrum spawned.", PLUGIN_PRINT_NAME);

					SetEntityModel(iDrum, MODEL_PATH_OILDRUM);
					vEnd[2] += OFFSET_HEIGHT_OILDRUM;

					DispatchSpawn(iDrum);
					SetEntityMoveType(iDrum, MOVETYPE_VPHYSICS);
					SetEntProp(iDrum, Prop_Send, "m_CollisionGroup", 5);
					SetEntProp(iDrum, Prop_Send, "m_nSolidType", 6);

					new Float:ModelAngle[3] = VECTOR_ANGLE_OILDRUM;
					TeleportEntity(iDrum, vEnd, ModelAngle, NULL_VECTOR);
					
					// Set explosion amount
					SetEntPropFloat(iDrum, Prop_Data, DRUMKEYVALUE_MAGNITUDE, DRUM_MAGNITUDE);
					
					// Set explosion size
					SetEntPropFloat(iDrum, Prop_Data, DRUMKEYVALUE_RADIUS, DRUM_RADIUS);


					// explode drum
					new Handle:pack;
					g_hDrumTimerHandle[iClient] = CreateDataTimer(DRUMTIMER_EXPLODE_DELAY, CallExplodeDrum, pack);
										
					WritePackCell(pack, iClient);
					WritePackCell(pack, iDrum);

				}
				else
				{
					PrintToChat (iClient, "%s ERROR - Unable to spawn oildrum, maxEntities reached.", PLUGIN_PRINT_NAME);
					LogError ("%s ERROR - Unable to spawn oildrum, maxEntities reached.", PLUGIN_PRINT_NAME);
				}
				
			}
			else
			{
				PrintToChat (iClient, "%s ERROR - Unknown error, oildrum spawn failed.", PLUGIN_PRINT_NAME);
				LogError ("%s ERROR - Unknown error, oildrum spawn failed.", PLUGIN_PRINT_NAME);
			}
		}
		else
		{
			PrintToChat (iClient, "%s ERROR - Sorry, unable to locate ground!", PLUGIN_PRINT_NAME);
		}
	}

	CloseHandle(TraceRay);		
}


doCreateFrog(iClient)
{
	decl Float:vOrigin[3];
	GetClientEyePosition(iClient, vOrigin);
	decl Handle:TraceRay;
	new Float:Angles[3] = VECTOR_ANGLE_DOWN;								// down

	TraceRay = TR_TraceRayFilterEx(vOrigin, Angles, MASK_PROP_SPAWN, RayType_Infinite, TraceRayProp);

	if (TR_DidHit(TraceRay))
	{
		decl Float:Distance;
		decl Float:vEnd[3];
		TR_GetEndPosition(vEnd, TraceRay);
		Distance = (GetVectorDistance(vOrigin, vEnd));

		if (Distance < MAX_SPAWN_DISTANCE)
		{
			// define where the lightning strike starts
			new Float:vStart[3];
			vStart[0] = vEnd[0] + GetRandomInt(-500, 500);
			vStart[1] = vEnd[1] + GetRandomInt(-500, 500);
			vStart[2] = vEnd[2] + 800;
			
			// define the color of the strike
			new aColor[4] = LIGHTNING_COLOR;
											
			TE_SetupBeamPoints(		vStart, 
									vEnd, 
									g_iLightningSprite, 
									LIGHTNING_HALOINDEX, 
									LIGHTNING_STARTFRAME, 
									LIGHTNING_FRAMERATE, 
									LIGHTNING_LIFE, 
									LIGHTNING_STARTWIDTH, 
									LIGHTNING_ENDWIDTH, 
									LIGHTNING_FADELENGTH, 
									LIGHTNING_AMPLITUDE, 
									aColor, 
									LIGHTNING_SPEED
														);
			TE_SendToAll();

			// Lightning sound
			EmitSoundToAll(LIGHTNING_SOUND_THUNDER, iClient, SNDCHAN_AUTO, SNDLEVEL_GUNFIRE, SND_NOFLAGS, SNDVOL_NORMAL);

			// spawn frog
			new Handle:pack;
			
			g_hFrogTimerHandle[iClient] = CreateDataTimer(FROGTIMER_SPAWN_DELAY, CallSpawnFrog, pack);
			
			WritePackCell(pack, iClient);
			WritePackFloat(pack, vEnd[0]);
			WritePackFloat(pack, vEnd[1]);
			WritePackFloat(pack, vEnd[2]);
		}
	}
	else
	{
		PrintToChat (iClient, "%s ERROR - Sorry, unable to locate ground!", PLUGIN_PRINT_NAME);
	}

	CloseHandle(TraceRay);
}


// Cleanup all timers
CleanupTimerArray (Handle:hTimer[])
{
	// For each player, kill the timers
	for(new i = 0; i < (MAXPLAYERS + 1); i++)
	{
		if(hTimer[i] != INVALID_HANDLE)
		{
			KillTimer(hTimer[i]);
			hTimer[i] = INVALID_HANDLE;
		}
	}
}


// Cleanup single timer
CleanupTimerClient (Handle:hTimer[], iClient)
{
	if(hTimer[iClient] != INVALID_HANDLE)
	{
		KillTimer(hTimer[iClient]);
		hTimer[iClient] = INVALID_HANDLE;
	}
}


// Cleanup all entities
KillEntityReferenceArray(iEntity[])
{
	// For each entity, kill it
	for(new i = 0; i < (MAXPLAYERS + 1); i++)
	{

		new index = EntRefToEntIndex(iEntity[i]);
		 
		if (index == INVALID_ENT_REFERENCE)
		{
//			PrintToServer ("%s CATCH - Entity no longer exists.", PLUGIN_PRINT_NAME);
		}
		else
		{
			if (IsValidEntity(index))
			{
				PrintToServer ("%s Entity deleted.", PLUGIN_PRINT_NAME);
				AcceptEntityInput(index, "kill");
			}
			else
			{
				PrintToServer ("%s CATCH - Entity exists but not valid.", PLUGIN_PRINT_NAME);
			}
		}

		// Invalidate 
		iEntity[i] = INVALID_ENT_REFERENCE;
	}
}


// Cleanup single entity
KillEntityReferenceClient(iEntity[], iClient)
{
	new index = EntRefToEntIndex(iEntity[iClient]);
	 
	if (index == INVALID_ENT_REFERENCE)
	{
		PrintToServer ("%s CATCH - Entity no longer exists.", PLUGIN_PRINT_NAME);
	}
	else
	{
		if (IsValidEntity(index))
		{
			PrintToServer ("%s Entity deleted.", PLUGIN_PRINT_NAME);
			AcceptEntityInput(index, "kill");
		}
		else
		{
			PrintToServer ("%s CATCH - Entity exists but not valid.", PLUGIN_PRINT_NAME);
		}
	}

	// Invalidate 
	iEntity[iClient] = INVALID_ENT_REFERENCE;
}

