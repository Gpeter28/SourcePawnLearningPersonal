#include <sourcemod>
#include <sdktools>
#include <cstrike>

#pragma semicolon 1
#pragma newdecls required



public void OnPluginStart()
{
    HookEvent("hegrenade_detonate", Event_HegrenadeBounce, EventHookMode_Pre);
}


public Action Event_HegrenadeBounce(Event event, char[] name, bool dontBroadcast)
{

    // GetUserEvent  =>    WantToKnow how to -> ClientIndex
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
        if(GetClientHealth(i) == 0)
        {
            continue;
        }

        if(i == ThrowNclient)
        {
            continue;
        }
        int iteam = GetClientTeam(ThrowNclient);
        int iLoopteam = GetClientTeam(i);

        if(iteam == iLoopteam)
        {
            // PrintToChatAll("The same Team");
            continue;
        }

        float AClient_Position[3];
        GetClientEyePosition(i, AClient_Position);
    // PrintToChatAll("%d - %d  X: %f Y: %f Z: %f", client, EntityInt, AClient_Position[0], AClient_Position[1], AClient_Position[2]);
        AClient_Position[2] -= CutLength;
        if(GetDisctance(origin, AClient_Position) <= FreezeLength) {
            float s = GetDisctance(origin, AClient_Position);
            PrintToChatAll("client is closer than 200 And is %f", s);
        }else{
            float s = GetDisctance(origin, AClient_Position);
            PrintToChatAll("client is bigger than 200 And is %f", s);
        }
        // char ClientName[32];
        // GetClientName(i, ClientName, sizeof(ClientName));
        // PrintToChatAll("In Range Client name %s", ClientName);
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


