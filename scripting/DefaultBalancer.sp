#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>

Handle  g_hBalanceTeams;
ConVar	g_cvAutobalance;

public Plugin myinfo =
{
	name	=	"Default Balancer",
	author	=	"OkyHp",
	version	=	"1.0.1",
	url		=	"OkyHek#2441"
};

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] szError, int iErr_max)
{
	if(GetEngineVersion() != Engine_CSGO)
	{
		strcopy(szError, iErr_max, "This plugin works only on CS:GO!");
		return APLRes_SilentFailure;
	}
	
	return APLRes_Success;
}

public void OnPluginStart()
{
	GameData hGameData = LoadGameConfigFile("DefaultBalancer.games");
	if (!hGameData)
	{
		SetFailState("Failed to load DefaultBalancer gamedata.");
		return;
	}

	StartPrepSDKCall(SDKCall_GameRules);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CCSGameRules::BalanceTeams");
	hGameData.Close();

	g_hBalanceTeams = EndPrepSDKCall();
	if (!g_hBalanceTeams)
	{
		SetFailState("Failed to setup CCSGameRules::BalanceTeams");
		return;
	}

	HookEvent("round_prestart", Event_RoundPreStart, EventHookMode_PostNoCopy);

	g_cvAutobalance = FindConVar("mp_autoteambalance");
}

public void OnMapStart()
{
	g_cvAutobalance.IntValue = 0;
}

void Event_RoundPreStart(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	SDKCall(g_hBalanceTeams);
}
