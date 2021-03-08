#include <sourcemod>
#include <cstrike>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

public void OnPluginStart(){
    float a = 3.0;
    float b = SquareRoot(a);

    PrintToChatAll("%f", b);



    int count = GetClientCount(true);


    for(int i = 1; i <= count; ++i)
    {
        float origin[3];
        float nade[3];
        GetClientEyePosition(i, origin);
        if(GetDisc(origin, nade) < 200)
        {
            // 2 T  3-CT   1 for sc 0 for none
            int team = GetClientTeam(i);

            if(team == 1)
            {
                continue;
            }
            for(int j = 1; j <= count; ++j)
            {
                if(j == i)
                    continue;
                
                int _team = GetClientTeam(j);

                if(_team != team)
                {
                    PrintToChatAll("DifferTeam");
                }else{
                    PrintToChatAll("The same Team");
                }
            }
        }
    }
}



float GetDisc(float[3] origin, float[3] nadep)
{
    float num = 0.0;
    for(int i = 0; i < 3; ++i)
    {
        num += FloatAbs(origin[i] - nadep[i]);
    }   
    return num;
}