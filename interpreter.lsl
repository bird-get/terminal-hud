#define DEBUG
#define TIMEOUT 60
#define VERSION "0.05"

#include "terminal-hud/include/utility.lsl"
#include "terminal-hud/include/tabulate.lsl"
#include "terminal-hud/include/help.lsl"
#include "terminal-hud/include/lsInv.lsl"
#include "terminal-hud/include/rez.lsl"
#include "terminal-hud/include/avInfo.lsl"
#include "terminal-hud/include/avList.lsl"
#include "terminal-hud/include/avAttached.lsl"
#include "terminal-hud/include/objectDetails.lsl"
#include "terminal-hud/include/colortest.lsl"
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
        else if(param0 == "rez") rez(params);
        else if(param0 == "avinfo") avInfo(params);
        else if(param0 == "avlist") avList(params);
        else if(param0 == "avattached") avAttached(params);
        else if(param0 == "details") objectDetails(params);
        else if(param0 == "lsinv") lsInv(params);
        else if(param0 == "colortest") colortest();
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
        else if(param0 == "siminfo")
        {
            list rows;
            rows += ["agent_limit|" + llGetEnv("agent_limit")];
            rows += ["dynamic_pathfinding|" + llGetEnv("dynamic_pathfinding")];
            rows += ["estate_id|" + llGetEnv("estate_id")];
            rows += ["estate_name|" + llGetEnv("estate_name")];
            rows += ["frame_number|" + llGetEnv("frame_number")];
            rows += ["region_cpu_ratio|" + llGetEnv("region_cpu_ratio")];
            rows += ["region_idle|" + llGetEnv("region_idle")];
            rows += ["region_product_name|" + llGetEnv("region_product_name")];
            rows += ["region_product_sku|" + llGetEnv("region_product_sku")];
            rows += ["region_start_time|" + llGetEnv("region_start_time")];
            rows += ["sim_channel|" + llGetEnv("sim_channel")];
            rows += ["sim_version|" + llGetEnv("sim_version")];
            rows += ["simulator_hostname|" + llGetEnv("simulator_hostname")];
            rows += ["region_max_prims|" + llGetEnv("region_max_prims")];
            rows += ["region_object_bonus|" + llGetEnv("region_object_bonus")];

            printText("Sim information:\n ");
            list headers = ["key", "value"];
            printText(tabulate(headers, rows));
        }
        else if(param0 == "reset")
        {
            if(param1 == "-a")
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
            else
            {
                printText("Resetting display...");
                llSleep(0.5);
                llSleep(0.5);
                llResetOtherScript("display.lsl");
            }
        }
        else
        {
            printText(param0 + ": command not found");
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
