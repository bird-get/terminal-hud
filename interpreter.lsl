// TODO Make commands and output more Linux-like
//		- invalid option should show usage text
//		- add option '--help' to commands
// TODO Reset on login
// TODO Reset on URL change
// TODO Store last login time
// TODO Allow putting options together (i.e. -rks)
// TODO Add function to resize
// TODO Handle region change in a better way, do not just reset

// TODO inventory stuff
// 		- workshop
// 		- 3d viewport, with camera and lighting

#define DEBUG
#define TIMEOUT 60
#define VERSION "0.01"

#include "lsl-playground/snippets/debug.lsl"
#include "lsl-playground/snippets/formatDecimal.lsl"
#include "terminal-hud/include/utility.lsl"
#include "terminal-hud/include/tabulate.lsl"
#include "terminal-hud/include/help.lsl"
#include "terminal-hud/include/lsInv.lsl"
#include "terminal-hud/include/rez.lsl"
#include "terminal-hud/include/avInfo.lsl"
#include "terminal-hud/include/avList.lsl"
#include "terminal-hud/include/long-polling-http-in.lsl"

integer listener;
integer hud_hidden;

// User-tweakable
integer activeChannel = 42;

printText(string raw_text)
{
	llMessageLinked(LINK_THIS, 1, raw_text, "");
}

default
{
    state_entry()
    {
        listener = llListen(activeChannel, "", llGetOwner(), "");

		// Prrint starting text
		string text;
		text += "
      __
     ( ->
     / )\\\\
    <_/_/
     \" \" \n";
		text += "Last login: Mon Nov 6 03:25:56 2017\n";
		text += "Channel: " + (string)activeChannel + "\n";
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
		string hostname = llGetEnv("simulator_hostname");
		string user = llGetUsername(llGetOwner());
		printText(user + "@" + hostname + " > " + addSlashes(msg));

        list params = llParseString2List(msg, [" "], [""]);
        string param0 = llList2String(params, 0);
        string param1 = llList2String(params, 1);
        string param2 = llList2String(params, 2);

        if(param0 == "help") help(param1);
        else if(param0 == "rez") rez(params);
        else if(param0 == "avinfo") avInfo(params);
		else if(param0 == "avlist")	avList(params);
		else if(param0 == "lsinv") lsInv(params);
        else if(param0 == "set")
        {
            if(param0 == "channel")
            {
                activeChannel = (integer)param1;
                printText("Channel set to " + (string)activeChannel + ".");
                llListenRemove(listener);
                listener = llListen(activeChannel, "", llGetOwner(), "");
            }
        }
		else if(param0 == "show")
		{
			// Show hud, if not already shown
			if(hud_hidden)
			{
				hud_hidden = FALSE;
				llSetPos(llGetLocalPos() + <0,0,1>);
			}
		}
		else if(param0 == "hide")
		{
			// Hide hud, if not already hidden
			if(!hud_hidden)
			{
				hud_hidden = TRUE;
				llSetPos(llGetLocalPos() - <0,0,1>);
			}
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
			llResetOtherScript("display.lsl");
            llResetScript();
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
