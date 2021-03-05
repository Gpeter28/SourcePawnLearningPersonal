#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>

public Plugin myinfo = 
{
        name =          "MenuTest",
        author =        "peter/28",
        description =   "First try of Menu",
        version =       "1.0",
        url =           "https://github.com/Gpeter28/SourcePawnLearningPersonal/"
}

public void OnPluginStart()
{
    RegConsoleCmd("sm_sb", Commnad_sb);


}

public Action Commnad_sb(int client, int args)
{
    if(args > 0)
    {
        ReplyToCommand(client, "[SM] Usage: sm_sb");
        return Plugin_Handled;
    }

    char[] names = new char[64];

    GetClientName(client, names, 64);

    PrintToChatAll("%s:你在用手柄玩游戏?", names);
    PrintToChatAll("%s:你在用手柄玩游戏?", names);
    PrintToChatAll("%s:你在用手柄玩游戏?", names);
    return Plugin_Handled;
}
