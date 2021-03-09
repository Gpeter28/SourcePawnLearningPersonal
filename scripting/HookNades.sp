#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required

float CutLength = 44.0;


Handle h_freeze_timer[MAXPLAYERS + 1];

float f_freeze_distance         = 250.0;
float f_freeze_duration         =   1.5;
float f_smoke_flying_time        = 1.3;

Handle h_smoke_freeze_distance;
Handle h_smoke_freeze_duration;
Handle h_smoke_flying_time;

Handle h_fwdOnClientFreeze;
Handle h_fwdOnClientFreezed;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    h_fwdOnClientFreeze  = CreateGlobalForward("peter_OnClientFreeze",    ET_Hook, Param_Cell, Param_Cell, Param_FloatByRef);
	h_fwdOnClientFreezed = CreateGlobalForward("peter_OnClientFreezed", ET_Ignore, Param_Cell, Param_Cell, Param_Float);
}

public void OnPluginStart()
{
    RegConsoleCmd("sm_smoke", Event_GetSmokePluginsHelp, "GetSmokePluginHelp");

    h_smoke_freeze_distance = CreateConVar("peter_smoke_freeze_disctance"  ,  "250",            "This decide the distance of smoke freeze", 0, true, 50.0, true, 500.0);
    h_smoke_freeze_duration = CreateConVar("peter_smoke_freeze_duration"   ,    "1",                "This decide the freeze time of smoke", 0, true,  0.5, true,   5.0);
    h_smoke_flying_time =     CreateConVar("peter_smoke_freeze_flying_time",  "1.3", "This Controls the flying time of smokegrendae timer", 0, true,  1.0, true,   2.0);

    f_freeze_distance = GetConVarFloat(h_smoke_freeze_distance);
    f_freeze_duration = GetConVarFloat(h_smoke_freeze_duration);
    f_smoke_flying_time = GetConVarFloat(h_smoke_flying_time);

    HookConVarChange(h_smoke_freeze_distance, OnConVarChanged);
    HookConVarChange(h_smoke_freeze_duration, OnConVarChanged);
    HookConVarChange(h_smoke_flying_time, OnConVarChanged);
    // HookEvent("smokegrenade_detonate", Event_SmokeDetonate, EventHookMode_Pre);
    // RegConsoleCmd("sm_health", GetHealth, "Get Client Hp");   
}


public Action Event_GetSmokePluginsHelp(int clients, int args)
{
    if(args > 0)
    {
        ReplyToCommand(clients, "[SM] Usage: sm_smoke");
        return Plugin_Handled;
    }

    ReplyToCommand(clients, "peter_smoke_freeze_disctance   This decide the distance of smoke freeze(50~500)");
    ReplyToCommand(clients, "peter_smoke_freeze_duration    This decide the freeze time of smoke(0.5~50)");
    ReplyToCommand(clients, "peter_smoke_freeze_flying_time This Controls the flying time of smokegrendae timer(1.0~2.0)");
    return Plugin_Handled;
}

public void OnConVarChanged(Handle convar, const char[] oldValue, char[] newValue)
{
    if(convar == h_smoke_freeze_distance)
    {
        f_freeze_distance = StringToFloat(newValue);
        PrintToChatAll("[SM] FreezeDistanceHasChange: %f", f_freeze_distance);
    }else if(convar == h_smoke_freeze_duration)
    {
        f_freeze_duration = StringToFloat(newValue);
        PrintToChatAll("[SM] FreezeDurationHasChange: %f", f_freeze_duration);
    }else if(convar == h_smoke_flying_time)
    {
        f_smoke_flying_time = StringToFloat(newValue);
        PrintToChatAll("[SM] SmokeFlyingTimeHasChange: %f", f_smoke_flying_time);
    }  
}



public void OnEntityCreated(int entity, const char[] classname)
{
    if(strcmp(classname, "smokegrenade_projectile", false) == 0)
    {
        SDKHook(entity, SDKHook_SpawnPost, Grenade_SpawnPost);
    }
}

public void OnRoundStart(Handle event, const char[] name, bool dontBroadcast) 
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (h_freeze_timer[client] != INVALID_HANDLE)
	    {
		    KillTimer(h_freeze_timer[client]);
		    h_freeze_timer[client] = INVALID_HANDLE;
	    }
	}
}

public void OnClientDisconnect(int client)
{
	if (IsClientInGame(client))
		ExtinguishEntity(client);
	if (h_freeze_timer[client] != INVALID_HANDLE)
	{
		KillTimer(h_freeze_timer[client]);
		h_freeze_timer[client] = INVALID_HANDLE;
	}
}

public Action Grenade_SpawnPost(int entity)
{
    int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");

    if(client == -1)
        return;
    
    CreateTimer(f_smoke_flying_time, CreateEvent_SmokeDetonate, entity, TIMER_FLAG_NO_MAPCHANGE);
}

public void SearchFreezeClient(int client, float origin[3])
{
    int ThrowNClient = client;
    int times = 0;

    for(int i = 1; i <= GetClientCount(true); ++i)
    {
        
            // Dead
            if (GetClientHealth(i) == 0)
            {
                continue;
            }
           // Grenade himself
        //     if (i == ThrowNClient)
        //     {
        //         continue;
        //     }

        //     int iteam = GetClientTeam(ThrowNClient);
        //     int iLoopteam = GetClientTeam(i);

        //   // Same Team
        //     if(iteam == iLoopteam)
        //     {
        //         continue;
        //     }

            float AClient_Position[3];
            GetClientEyePosition(i, AClient_Position);
            AClient_Position[2] -= CutLength;

            if(GetDisctance(origin, AClient_Position) <= f_freeze_distance)
            {
                ++times;
                float s = GetDisctance(origin, AClient_Position);
                // PrintToChatAll("client is closer than %f And is %f", f_freeze_distance, s);

                char ClientName[32];
                GetClientName(i, ClientName, sizeof(ClientName));
                PrintToChatAll("这个shabee  <%s>  被逮住了 。距离雷落点距离%f", ClientName, s);
                // int client = GetEntPropEnt(entity, Prop_Send, "m_hThrower");
                Freeze(i, ThrowNClient, f_freeze_duration);
            }
    }
    if(times == 0)
    {
        char Tname[32];
        GetClientName(ThrowNClient, Tname, sizeof(Tname));     
        PrintToChatAll("会不会丢雷啊? %s在用手柄玩游戏吗? ", Tname);
    }
}

public Action CreateEvent_SmokeDetonate(Handle timer, int entity)
{
    if (!IsValidEdict(entity))
	{
		return Plugin_Stop;
	}

    char g_szClassName[64];
    GetEdictClassname(entity, g_szClassName, sizeof(g_szClassName));

    if(!strcmp(g_szClassName, "smokegrenade_projectile", false))
    {
        // float f_freeze_distance = 250.0;
        // float CutLength = 32.0 + 12.0;

        float origin[3];
        GetEntPropVector(entity, Prop_Send, "m_vecOrigin", origin);
        int client = GetEntPropEnt(entity, Prop_Send, "m_hThrower");

        SearchFreezeClient(client, origin);
        AcceptEntityInput(entity, "kill");
    }
    return Plugin_Stop;
}


public bool Freeze(int client, int attacker, float time)
{
    Action result;
    float freeze_duration = time;
    result = Forward_OnClientFreeze(client, attacker, freeze_duration);

    switch(result)
    {
        case Plugin_Handled, Plugin_Stop:{
            return false;
        }
        case Plugin_Continue:{
            freeze_duration = time;
        }
    }

    if(h_freeze_timer[client] != INVALID_HANDLE)
    {
        KillTimer(h_freeze_timer[client]);
        h_freeze_timer[client] = INVALID_HANDLE;
    }
    // PrintToChatAll("StartFreeze");
    SetEntityMoveType(client, MOVETYPE_NONE);

    h_freeze_timer[client] = CreateTimer(freeze_duration, Unfreeze, client, TIMER_FLAG_NO_MAPCHANGE);
    Forward_OnClientFreezed(client, attacker, freeze_duration);
    return true;
}

public Action Unfreeze(Handle timer, int client)
{
    char name[32];
    GetClientName(client, name, sizeof(name));
    PrintToChatAll("这个猴 <%s> 被冻了 %f 秒", name, f_freeze_duration);
    if (h_freeze_timer[client] != INVALID_HANDLE)
	{
		SetEntityMoveType(client, MOVETYPE_WALK);
		h_freeze_timer[client] = INVALID_HANDLE;
	}
    return Plugin_Handled;
}

public Action Forward_OnClientFreeze(int client, int attacker, float time)
{
	Action result;
	result = Plugin_Continue;
	
    Call_StartForward(h_fwdOnClientFreeze);
	Call_PushCell(client);
	Call_PushCell(attacker);
	Call_PushFloatRef(time);
	Call_Finish(result);
	
	return result;
}

public void Forward_OnClientFreezed(int client, int attacker, float time)
{
    Call_StartForward(h_fwdOnClientFreezed);
	Call_PushCell(client);
	Call_PushCell(attacker);
	Call_PushFloat(time);
	Call_Finish();
}

// public Action Event_SmokeDetonate(Event event, char[] name, bool dontBroadcast)
// {
//     PrintToChatAll("EventSmokeDetonate");
//     int ThrowNClient = GetClientOfUserId(GetEventInt(event, "userid"));

//     float f_freeze_distance = 250.0;
//     float origin[3];
//     float CutLength = 32.0 + 12.0;
//     origin[0] = GetEventFloat(event, "x");
//     origin[1] = GetEventFloat(event, "y");
//     origin[2] = GetEventFloat(event, "z");
//     // PrintToChatAll("%d - %d  X: %f Y: %f Z: %f", ThrowNClient, EntityInt, origin[0], origin[1], origin[2]);

//     /*
    
//     *     EyePosition > Grenade avaverage 50 unit  
//           So  EyePosition:Z - 50(32)      [Ctrl - 18 Unit]  -           12 => many times of test ?
//           Will Be Better

//           Many Time of Testing =>  2unit differ
//     *
//     *
//     */
//     for(int i = 1; i <= GetClientCount(true); ++i)
//     {
//         // Dead
//         if(GetClientHealth(i) == 0)
//         {
//             continue;
//         }
//         // Grenade himself
//         if(i == ThrowNClient)
//         {
//             continue;
//         }

//         int iteam = GetClientTeam(ThrowNClient);
//         int iLoopteam = GetClientTeam(i);

//         // Same Team
//         if(iteam == iLoopteam)
//         {
//             continue;
//         }

//         float AClient_Position[3];
//         GetClientEyePosition(i, AClient_Position);
//         AClient_Position[2] -= CutLength;

//         if(GetDisctance(origin, AClient_Position) <= f_freeze_distance) {
//             float s = GetDisctance(origin, AClient_Position);
//             PrintToChatAll("client is closer than %f And is %f", f_freeze_distance, s);

//             char ClientName[32];
//             GetClientName(i, ClientName, sizeof(ClientName));
//             PrintToChatAll("FreezeClient %s", ClientName);
//         }else{
//             float s = GetDisctance(origin, AClient_Position);
//             PrintToChatAll("Not Close %f", s);
//             return Plugin_Continue;
//         }
//     }
//     return Plugin_Handled;
// }

public float GetDisctance(float[3] nade, float[3] clientEye)
{
    float count = 0.0;

    for(int i = 0; i < 3; ++i)
    {
        float Abs = FloatAbs(nade[i] - clientEye[i]);
        count += Abs * Abs;
    }
    return SquareRoot(count);
}


// public Action Event_BlockgrenadeDamage(Event event , char[] name, bool dontBroadcast)
// {
//     // int HurtClient = GetClientOfUserId(GetEventInt(event, "userid"));

//     char weapon_name[32];
//     GetEventString(event, "weapon", weapon_name, sizeof(weapon_name));

//     // hegrenade
//     // PrintToChatAll("%s", weapon_name);
//     if(strcmp("hegrenade", weapon_name, false) == 0)
//     {

//         // int dmg = GetEventInt(event, "dmg_health");
//         // int health = GetEventInt(event, "health");

//         // PrintToChatAll("%d --- Remain: %d", dmg, health);
//         // SetEventInt(event, "health", dmg+health);
//         // int h2 = GetEventInt(event, "health");
//         // PrintToChatAll("ActualRemain: %d  ------- ShouldBe: %d", health, h2);
//         // SetEventInt(event, "dmg_health", 0);
//         // SetEventInt(event, "dmg_armor", 0);
//         // PrintToChatAll("DmgOfHealth: %d", GetEventInt(event, "dmg_health"));
//         return Plugin_Handled;
//     }
//     return Plugin_Handled;
// }

// public Action GetHealth(int clients, int args)
// {
//     for(int i = 2; i <= GetClientCount(true); ++i)
//     {
//         int iteam = GetClientTeam(1);
//         int iLoopteam = GetClientTeam(i);

//         // Same Team
//         if(iteam == iLoopteam)
//         {
//             continue;
//         }
//         char name[32];
//         GetClientName(i, name, sizeof(name));
//         PrintToChatAll("%s - %d", name, GetClientHealth(i));
//     }
//     return Plugin_Handled;
// }
