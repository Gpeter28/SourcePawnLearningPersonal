#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required


// CSWeapon_HEGRENADE

public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
    int attackerUserId = attacker;
	int victimUserId = victim;

    char WeaponCallBack[32];
	GetEdictClassname(inflictor, WeaponCallBack, sizeof(WeaponCallBack));

    if( (attackerUserId == victimUserId) || (GetClientTeam(victimUserId) == GetClientTeam(attackerUserId)) )
    {
        return Plugin_Continue;
    }

    if(strcmp(WeaponCallBack, "hegrenade_projectile", false))
    {
        return Plugin_Continue;
    }else{
        // in This Section . We cancel the damage of Grenade
        return Plugin_Handled;
    }
}