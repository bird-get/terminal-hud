// https://github.com/bird-get/terminal-hud

#define DEBUG
#define TIMEOUT 60
#define VERSION "0.05"

#include "terminal-hud/include/utility.lsl"
#include "terminal-hud/include/tabulate.lsl"
#include "terminal-hud/include/help.lsl"
#include "terminal-hud/include/long-polling-http-in.lsl"

integer listener;

// User-tweakable
integer listen_channel = 42;

printText(string raw_text)
{
    llMessageLinked(LINK_THIS, 1, raw_text, "");
}

default
{
    state_entry()
    {
        listener = llListen(listen_channel, "", llGetOwner(), "");

        // Print starting text
        string text;
        text += "
      __
     ( ->
     / )\\\\
    <_/_/
     \" \" \n";
        text += "Last login: Mon Nov 6 03:25:56 2017\n";
        text += "Channel: " + (string)listen_channel + "\n";
        text += "Memory: " + (string)(llGetUsedMemory()/1000) + "kb / 64 kb\n";
        text += "Version: " + (string)VERSION + "\n";
        printText(text);
    }

    changed(integer change)
    {
        if(change & CHANGED_OWNER)
            llResetScript();
    }

    listen(integer channel, string name, key id, string msg)
    {
        // Print prompt + escaped command
        string hostname = llGetEnv("simulator_hostname");
        string user = llGetUsername(llGetOwner());
        printText("<span class=\\'color_3\\'>" + user +
            "</span>@<span class=\\'color_3\\'>" + hostname +
            "</span> > " + addSlashes(msg));

        list params = llParseString2List(msg, [" "], [""]);
        string param0 = llList2String(params, 0);
        string param1 = llList2String(params, 1);
        string param2 = llList2String(params, 2);

        if(param0 == "help") help(param1);
        else if(param0 == "set")
        {
            if(param1 == "channel")
            {
                listen_channel = (integer)param2;
                printText("Channel set to " + (string)listen_channel + ".");
                llListenRemove(listener);
                listener = llListen(listen_channel, "", llGetOwner(), "");
            }
            else if(param1 == "size")
            {
                llMessageLinked(LINK_THIS, 0, "size " + param2, "");
                printText("Size set to " + param2);
            }
            else if(param1 == "opacity")
            {
                llMessageLinked(LINK_THIS, 0, "opacity " + param2, "");
                printText("Opacity set to " + param2);
            }
        }
        else if(param0 == "enable")
        {
            llMessageLinked(LINK_THIS, 0, "enable", "");
        }
        else if(param0 == "disable")
        {
            llMessageLinked(LINK_THIS, 0, "disable", "");
        }
        else if(param0 == "cls")
        {
            llMessageLinked(LINK_THIS, 0, "clear screen", "");
        }
        else if(param0 == "reset")
        {
            if(llListFindList(params, ["-a"]) != -1) // option: key
            {
                printText("Resetting all scripts...");
                llSleep(0.5); // Sleep 2x, to process GET requests in between
                llSleep(0.5);
                integer script_count = llGetInventoryNumber(INVENTORY_SCRIPT);
                integer i;
                for(i=0; i < script_count; i++)
                {
                    string script_name = llGetInventoryName(INVENTORY_SCRIPT, i);
                    if(script_name != llGetScriptName())
                    {
                        llResetOtherScript(script_name);
                    }
                }
                llResetScript();
            }
            if(llListFindList(params, ["-d"]) != -1) // option: display
            {
                printText("Resetting display...");
                llSleep(0.5);
                llSleep(0.5);
                llResetOtherScript("display.lsl");
            }
            if(llListFindList(params, ["-i"]) != -1) // option: interpreter
            {
                printText("Resetting interpreter...");
                llSleep(1.0);
                llResetScript();
            }
            else
            {
                printText("reset: missing arguments");
            }
        }
        else
        {
            llMessageLinked(LINK_THIS, 0, msg, "");
            //printText(param0 + ": command not found");
        }
    }

    link_message(integer sender, integer num, string msg, key id)
    {
        if(msg == "display started")
        {
            printText("Display has been restarted.");
        }
    }
}
