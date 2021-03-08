#include <sourcemod>
#include <sdktools>
#include <cstrike>

#pragma semicolon 1
#pragma newdecls required


// CSWeapon_HEGRENADE
public void OnPluginStart()
{
    RegConsoleCmd("sm_health", GetHealth, "Get Client Hp");
    HookEvent("hegrenade_detonate", Event_HegrenadeBounce, EventHookMode_Pre);
    HookEvent("player_hurt", Event_BlockgrenadeDamage, EventHookMode_Pre);
}

public Action GetHealth(int clients, int args)
{
    for(int i = 2; i <= GetClientCount(true); ++i)
    {
        int iteam = GetClientTeam(1);
        int iLoopteam = GetClientTeam(i);

        // Same Team
        if(iteam == iLoopteam)
        {
            continue;
        }
        char name[32];
        GetClientName(i, name, sizeof(name));
        PrintToChatAll("%s - %d", name, GetClientHealth(i));
    }
    return Plugin_Handled;
}

public Action Event_BlockgrenadeDamage(Event event , char[] name, bool dontBroadcast)
{
    // int HurtClient = GetClientOfUserId(GetEventInt(event, "userid"));

    char weapon_name[32];
    GetEventString(event, "weapon", weapon_name, sizeof(weapon_name));

    // hegrenade
    // PrintToChatAll("%s", weapon_name);
    if(strcmp("hegrenade", weapon_name, false) == 0)
    {

        // int dmg = GetEventInt(event, "dmg_health");
        // int health = GetEventInt(event, "health");

        // PrintToChatAll("%d --- Remain: %d", dmg, health);
        // SetEventInt(event, "health", dmg+health);
        // int h2 = GetEventInt(event, "health");
        // PrintToChatAll("ActualRemain: %d  ------- ShouldBe: %d", health, h2);
        // SetEventInt(event, "dmg_health", 0);
        // SetEventInt(event, "dmg_armor", 0);
        // PrintToChatAll("DmgOfHealth: %d", GetEventInt(event, "dmg_health"));
        return Plugin_Handled;
    }
    return Plugin_Handled;
}


public Action Event_HegrenadeBounce(Event event, char[] name, bool dontBroadcast)
{
    int ThrowNclient = GetClientOfUserId(GetEventInt(event, "userid"));
 
    // int EntityInt = GetEventInt(event, "entittyid");

    float FreezeLength = 250.0;
    float origin[3];
    float CutLength = 32.0 + 12.0;
    origin[0] = GetEventFloat(event, "x");
    origin[1] = GetEventFloat(event, "y");
    origin[2] = GetEventFloat(event, "z");
    // PrintToChatAll("%d - %d  X: %f Y: %f Z: %f", ThrowNclient, EntityInt, origin[0], origin[1], origin[2]);

    /*
    
    *     EyePosition > Grenade avaverage 50 unit  
          So  EyePosition:Z - 50(32)      [Ctrl - 18 Unit]  -           12 => many times of test ?
          Will Be Better

          Many Time of Testing =>  2unit differ
    *
    *
    */
    for(int i = 1; i <= GetClientCount(true); ++i)
    {
        // Dead
        if(GetClientHealth(i) == 0)
        {
            continue;
        }

        // Grenade himself
        if(i == ThrowNclient)
        {
            continue;
        }


        int iteam = GetClientTeam(ThrowNclient);
        int iLoopteam = GetClientTeam(i);

        // Same Team
        if(iteam == iLoopteam)
        {
            continue;
        }

        float AClient_Position[3];
        GetClientEyePosition(i, AClient_Position);
        AClient_Position[2] -= CutLength;

        if(GetDisctance(origin, AClient_Position) <= FreezeLength) {
            float s = GetDisctance(origin, AClient_Position);
            PrintToChatAll("client is closer than 250 And is %f", s);

            char ClientName[32];
            GetClientName(i, ClientName, sizeof(ClientName));
            PrintToChatAll("FreezeClient %s", ClientName);
        }else{
            return Plugin_Continue;
            // PrintToChatAll("client is bigger than 200 And is %f", s);
        }
    }

    // GetClientEyeAngles(1, Aclient_EyePosition);
    // PrintToChatAll("X:%f, Y:%f, Z:%f", AClient_Position[0], AClient_Position[1], AClient_Position[2]);
    // int clientsArray[10];

    // int num = GetClientsInRange(origin, RangeType_Audibility, clientsArray, 10);

    // PrintToChatAll("nums is %d", num);
    // PrintToChatAll("%s throw nades", client);
    return Plugin_Handled;
}

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


