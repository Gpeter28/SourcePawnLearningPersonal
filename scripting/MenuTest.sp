#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>

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
    RegConsoleCmd("sm_menu", Command_menu, "Displays a menu");
}

public Action Command_menu(int clients, int args)
{
    Menu menu = new Menu(Menu_CallBack);
    menu.SetTitle("Test Menu: ");
    menu.AddItem("op1", "OptionNo1");
    menu.AddItem("op2", "OptionNo2");
    menu.Display(clients, 30);

    return Plugin_Handled;
}

public int Menu_CallBack(Menu menu, MenuAction action, int param1, int param2)
{
    switch(action){
        case MenuAction_Select:
        {
            char item[32];

            menu.GetItem(param2, item, sizeof(item));


            if (StrEqual(item, "op1"))
            {
                PrintToChat(param1, "[SM] You select %s", item);
            }else if( StrEqual(item, "op2"))
            {
                PrintToChat(param1, "[SM] You select %s", item);
            }
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}

