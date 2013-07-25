//	------------------------------------------------------------------------------------
//	Filename:		donator.deathperks.sp
//	Author:			Malachi
//	Version:		(see PLUGIN_VERSION)
//	Description:
//					Plugin spawns various options when donator dies during afterround.
//
// * Changelog (date/version/description):
// * 2013-07-24	-	0.1.1		-	initial test version
//	------------------------------------------------------------------------------------


// INCLUDES
#include <sourcemod>
#include <donator>
#include <clientprefs>


#pragma semicolon 1


// DEFINES
#define PLUGIN_VERSION	"0.1.1"


// These define the text players see in the donator menu
#define MENUTEXT_SPAWN_ITEM		"Spawn Item On Death"
#define MENUTITLE_SPAWN_ITEM		"Donator: Change Item Spawned On Death:"
#define COOKIENAME_SPAWN_ITEM		"donator_deathperks"
#define COOKIEDESCRIPTION_SPAWN_ITEM		"Spawn pumpkin/misc on donator death."
#define MENUSELECT_ITEM_NULL		"Off"
#define MENUSELECT_ITEM_PUMPKIN		"Pumpkin (exploding)"
#define MENUSELECT_ITEM_BALL		"Beach Ball"


enum _:CookieActionType
{
	Action_Null = 0,
	Action_Pumpkin = 1,
	Action_Ball = 2,
//	Action_Grave = 3,
//	Action_Bird = 4,
};


// GLOBALS
new Handle:g_hDeathItemCookie = INVALID_HANDLE;
new bool:g_bRoundEnded = false;


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


public DonatorMenu:ChangeDeathItemCallback(iClient) Panel_ChangeDeathItem(iClient);


public hook_Start(Handle:event, const String:name[], bool:dontBroadcast)
{
	g_bRoundEnded = false;
}


public hook_Win(Handle:event, const String:name[], bool:dontBroadcast)
{	
	g_bRoundEnded = true;
}


public Action:event_player_death(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(!g_bRoundEnded)
	{
		return Plugin_Continue;
	}
	else
	{
		new iClient = GetClientOfUserId(GetEventInt(event, "userid"));
		decl String:iTmp[32];
		new iSelected;

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
				PrintToChat (iClient, "[DeathPerks] Pumpkin spawned.");
			}
			case Action_Ball:
			{
				PrintToChat (iClient, "[DeathPerks] Ball spawned.");
			}
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

