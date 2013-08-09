//	------------------------------------------------------------------------------------
//	Filename:		donator.deathperks.sp
//	Author:			Malachi
//	Version:		(see PLUGIN_VERSION)
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
//	------------------------------------------------------------------------------------


// INCLUDES
#include <sourcemod>
#include <donator>
#include <clientprefs>
#include <sdktools>


#pragma semicolon 1


// DEFINES
#define PLUGIN_VERSION	"0.1.10"

// These define the text players see in the donator menu
#define MENUTEXT_SPAWN_ITEM				"Spawn After-round Item On Death"
#define MENUTITLE_SPAWN_ITEM			"Donator: Change Item Spawned On Death:"
#define MENUSELECT_ITEM_NULL			"Off"
#define MENUSELECT_ITEM_PUMPKIN			"Pumpkin (exploding)"
#define MENUSELECT_ITEM_BALL			"Beach Ball (bouncing)"
#define MENUSELECT_ITEM_OILDRUM			"Barrel (exploding)"
#define MENUSELECT_ITEM_FROG			"Frog (lightning)"

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

// Model paths
#define MODEL_PATH_PUMPKIN				"models/props_halloween/pumpkin_explode.mdl"
#define MODEL_PATH_BALL					"models/props_gameplay/ball001.mdl"
#define MODEL_PATH_OILDRUM				"models/props_c17/oildrum001_explosive.mdl"
#define MODEL_PATH_FROG					"models/props_2fort/frog.mdl"
#define MODEL_PATH_PROPANETANK			"models/props_junk/propane_tank001a.mdl"	// HL2 content!

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
#define LIGHTNING_LIFE					0.5											// Time duration of the beam.
#define LIGHTNING_STARTWIDTH			20.0										// Initial beam width.
#define LIGHTNING_ENDWIDTH				10.0										// Final beam width.
#define LIGHTNING_FADELENGTH			0											// Beam fade time duration.
#define LIGHTNING_AMPLITUDE				1.0											// Beam amplitude.
#define LIGHTNING_COLOR					{255, 255, 255, 255}						// Color array (r, g, b, a).
#define LIGHTNING_SPEED					3											// Speed of the beam.

// Frog Parameters
#define FROGTIMER_SPAWN_DELAY			0.5											// How soon after player death does frog spawn.



enum _:CookieActionType
{
	Action_Null = 0,
	Action_Pumpkin = 1,
	Action_Ball = 2,
	Action_Oildrum = 3,
	Action_Frog = 4,
//	Action_Grave = 5,
//	Action_Bird = 6,
};


// GLOBALS
new Handle:g_hDeathItemCookie = INVALID_HANDLE;
new bool:g_bRoundEnded = false;
new g_iLightningSprite = 0;
//new Handle:g_hTimerHandle[MAXPLAYERS + 1] = {INVALID_HANDLE, ...};
new Handle:g_hFrogTimerHandle[MAXPLAYERS + 1] = {INVALID_HANDLE, ...};


public Plugin:myinfo = 
{
	name = "Donator Death Perks",
	author = "Malachi",
	description = "during afterround, spawns pumpkin/item on donator death",
	version = PLUGIN_VERSION,
	url = "www.necrophix.com"
}


public OnPluginStart()
{
	PrintToServer("[Donator:DeathPerks] Plugin start...");

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
		SetFailState("[Donator:DeathPerks] Unable to find plugin: Basic Donator Interface");
		
	Donator_RegisterMenuItem(MENUTEXT_SPAWN_ITEM, ChangeDeathItemCallback);
}


public OnMapStart()
{
	PrecacheModel(MODEL_PATH_OILDRUM);
	PrecacheModel(MODEL_PATH_FROG);
	g_iLightningSprite = PrecacheModel(SPRITE_PATH_LIGHTNING);
}


public DonatorMenu:ChangeDeathItemCallback(iClient) Panel_ChangeDeathItem(iClient);


public hook_Start(Handle:event, const String:name[], bool:dontBroadcast)
{
	// Cleanup all timers on map end
	for(new i = 0; i < (MAXPLAYERS + 1); i++)
	{
		if(g_hFrogTimerHandle[i] != INVALID_HANDLE)
		{
			KillTimer(g_hFrogTimerHandle[i]);
			g_hFrogTimerHandle[i] = INVALID_HANDLE;
		}
	}

	g_bRoundEnded = false;
}


public hook_Win(Handle:event, const String:name[], bool:dontBroadcast)
{	
	g_bRoundEnded = true;
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
			PrintToChat (iClient, "[DeathPerks] Nothing spawned.");
		}
		
		case Action_Pumpkin:
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
					new iPumpkin = CreateEntityByName(ENTITY_NAME_PUMPKIN);
					
					if(IsValidEntity(iPumpkin))
					{		
						if(GetEntityCount() < GetMaxEntities()-32)
						{
							DispatchSpawn(iPumpkin);
							vEnd[2] += OFFSET_HEIGHT_PUMPKIN;

							new Float:ModelAngle[3] = VECTOR_ANGLE_PUMPKIN;
							TeleportEntity(iPumpkin, vEnd, ModelAngle, NULL_VECTOR);
							PrintToChat (iClient, "[DeathPerks] Pumpkin spawned.");
						}
						else
						{
							PrintToChat (iClient, "[DeathPerks] ERROR - Unable to spawn pumpkin, maxEntities reached.");
						}
						
					}
					else
					{
						PrintToChat (iClient, "[DeathPerks] ERROR - Unknown error, pumpkin spawn failed.");
					}
				}
			}
			else
			{
				PrintToChat (iClient, "[DeathPerks] ERROR - Sorry, unable to locate ground!");
			}

			CloseHandle(TraceRay);
		}
		
		case Action_Ball:
		{
			new iBall = CreateEntityByName(ENTITY_NAME_BALL);
			
			if(IsValidEntity(iBall))
			{
				decl Float:vOrigin[3];
				GetClientEyePosition(iClient, vOrigin);
				
				vOrigin[2] += OFFSET_HEIGHT_BALL;

				DispatchKeyValue(iBall, "model", MODEL_PATH_BALL);
				DispatchKeyValue(iBall, "disableshadows", "1");
				DispatchKeyValue(iBall, "skin", "0");
				DispatchKeyValue(iBall, "physicsmode", "1");
				DispatchKeyValue(iBall, "spawnflags", "256");
				DispatchSpawn(iBall);
				
				new Float:ModelAngle[3] = VECTOR_ANGLE_BALL;
				TeleportEntity(iBall, vOrigin, ModelAngle, NULL_VECTOR);
				
				PrintToChat (iClient, "[DeathPerks] Ball spawned.");
			}
		}
		
		case Action_Oildrum:
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
					new iOildrum = CreateEntityByName(ENTITY_NAME_OILDRUM);
					
					if(IsValidEntity(iOildrum))
					{		
						if(GetEntityCount() < GetMaxEntities()-32)
						{
							SetEntityModel(iOildrum, MODEL_PATH_OILDRUM);
							vEnd[2] += OFFSET_HEIGHT_OILDRUM;

							DispatchSpawn(iOildrum);
							SetEntityMoveType(iOildrum, MOVETYPE_VPHYSICS);
							SetEntProp(iOildrum, Prop_Send, "m_CollisionGroup", 5);
							SetEntProp(iOildrum, Prop_Send, "m_nSolidType", 6);

							new Float:ModelAngle[3] = VECTOR_ANGLE_OILDRUM;
							TeleportEntity(iOildrum, vEnd, ModelAngle, NULL_VECTOR);
							PrintToChat (iClient, "[DeathPerks] Oildrum spawned.");
						}
						else
						{
							PrintToChat (iClient, "[DeathPerks] ERROR - Unable to spawn oildrum, maxEntities reached.");
						}
						
					}
					else
					{
						PrintToChat (iClient, "[DeathPerks] ERROR - Unknown error, oildrum spawn failed.");
					}
				}
				else
				{
					PrintToChat (iClient, "[DeathPerks] ERROR - Sorry, unable to locate ground!");
				}
			}

			CloseHandle(TraceRay);
		}

		case Action_Frog:
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
				PrintToChat (iClient, "[DeathPerks] ERROR - Sorry, unable to locate ground!");
			}

			CloseHandle(TraceRay);
		}
		
		// If we get here, the cookie hasn't been set properly - so set it!
		// (do we really need this?)
		default:
		{
			new String:iTemp[32];
			IntToString(Action_Null, iTemp, sizeof(iTemp));
			SetClientCookie(iClient, g_hDeathItemCookie, iTemp);		
			PrintToChat (iClient, "[DeathPerks] Normalizing cookie - for extra yum!");
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
	
//	PrintToChat (iClient, "[DeathPerks] Attempting to create frog at (%f, %f, %f) for client #%d.", vEnd[0], vEnd[1], vEnd[2], iClient);

	new iFrog = CreateEntityByName(ENTITY_NAME_FROG);
	
	if(IsValidEntity(iFrog))
	{		
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


			PrintToChat (iClient, "[DeathPerks] Frog spawned.");
		}
		else
		{
			PrintToChat (iClient, "[DeathPerks] ERROR - Unable to spawn frog, maxEntities reached.");
		}
		
	}
	else
	{
		PrintToChat (iClient, "[DeathPerks] ERROR - Unknown error, frog spawn failed.");
	}


	g_hFrogTimerHandle[iClient] = INVALID_HANDLE;

}


// Cleanup when player leaves
public OnClientDisconnect(client)
{
	// kill timer if we quickly disconnect
	if(g_hFrogTimerHandle[client] != INVALID_HANDLE)
	{
		KillTimer(g_hFrogTimerHandle[client]);
		g_hFrogTimerHandle[client] = INVALID_HANDLE;
	}
	
}


// Cleanup all timers on map end
public OnMapEnd()
{

	// Kill timers for all players
	for(new i = 0; i < (MAXPLAYERS + 1); i++)
	{
		if(g_hFrogTimerHandle[i] != INVALID_HANDLE)
		{
			KillTimer(g_hFrogTimerHandle[i]);
			g_hFrogTimerHandle[i] = INVALID_HANDLE;
		}
	}

}


