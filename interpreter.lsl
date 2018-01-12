// https://github.com/bird-get/terminal-hud

#define DEBUG
#define TIMEOUT 60
#define VERSION "0.10"

#include "terminal-hud/include/utility.lsl"
#include "terminal-hud/include/tabulate.lsl"
#include "terminal-hud/include/help.lsl"
#include "terminal-hud/include/long-polling-http-in.lsl"

integer listener;
string active_program;

// User-tweakable
integer listen_channel = 42;

printText(string raw_text, integer new_line)
{
    if(new_line) raw_text = raw_text + "<br>";
    llMessageLinked(LINK_THIS, 1, raw_text, "");
}

string prompt()
{
    string hostname = llGetEnv("simulator_hostname");
    string user = llGetUsername(llGetOwner());
    string text = "<span class=\\'color_3\\'>" + user +
        "</span>@<span class=\\'color_3\\'>" + hostname +
        "</span> > ";
    
    return text;
}

list getPrograms()
{
    // Returns a list of scripts that are programs
    list programs = [];
    integer i;
    for(i=0; i < llGetInventoryNumber(INVENTORY_SCRIPT); i++)
    {
        string name = llGetInventoryName(INVENTORY_SCRIPT, i);

        if(llSubStringIndex(name, ".lslp") != -1)
        {
            programs += name;
        }
    }
    return programs;
}

default
{
    state_entry()
    {
        listener = llListen(listen_channel, "", llGetOwner(), "");

        integer program_count = llGetListLength(getPrograms());

        // Retrieve last login time
        string login_time = getKeyValue("login_time");

        // Update login time
        setKeyValue("login_time", llGetTimestamp());

        // Print starting text
        string text;
        text += "\n 
      __
     ( ->
     / )\\\\
    <_/_/
     \" \" \n";
        //text += "Last login: Mon Nov 6 03:25:56 2017\n";
        text += "Last login: " + login_time + "\n";
        text += "Channel: " + (string)listen_channel + "\n";
        text += "Memory: " + (string)(llGetUsedMemory()/1000) + "kb / 64 kb\n";
        text += "Version: " + (string)VERSION;
        printText(text, TRUE);
        
        // Print prompt
        printText(prompt(), FALSE);
    }

    changed(integer change)
    {
        if(change & CHANGED_OWNER)
            llResetScript();
    }

    listen(integer channel, string name, key id, string msg)
    {
        // Print escaped command
        if(id == llGetOwner()) printText(addSlashes(msg), TRUE);

        list params = llParseString2List(msg, [" "], [""]);
        string param0 = llList2String(params, 0);
        string param1 = llList2String(params, 1);
        string param2 = llList2String(params, 2);

        if(param0 == "help")
        {
            help(param1);
            printText(prompt(), FALSE);
        }
        else if(param0 == "echo")
        {
            params = llList2List(params, 1, -1);
            printText(llDumpList2String(params, " "), TRUE);
            printText(prompt(), FALSE);
        }
        else if(param0 == "set")
        {
            if(param1 == "channel")
            {
                listen_channel = (integer)param2;
                printText("Channel set to " + (string)listen_channel + ".", TRUE);
                llListenRemove(listener);
                listener = llListen(listen_channel, "", llGetOwner(), "");
                printText(prompt(), FALSE);
            }
            else if(param1 == "size")
            {
                llMessageLinked(LINK_THIS, 0, "size " + param2, "");
                printText("Size set to " + param2, TRUE);
                printText(prompt(), FALSE);
            }
            else if(param1 == "opacity")
            {
                llMessageLinked(LINK_THIS, 0, "opacity " + param2, "");
                printText("Opacity set to " + param2, TRUE);
                printText(prompt(), FALSE);
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
            printText(prompt(), FALSE);
        }
        else if(param0 == "reset")
        {
            if(llListFindList(params, ["-a"]) != -1) // option: key
            {
                printText("Resetting all scripts...", TRUE);
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
                printText("Resetting display...", TRUE);
                llSleep(0.5);
                llSleep(0.5);
                llResetOtherScript("display.lsl");
            }
            if(llListFindList(params, ["-i"]) != -1) // option: interpreter
            {
                printText("Resetting interpreter...", TRUE);
                llSleep(1.0);
                llResetScript();
            }
            else
            {
                printText("reset: missing arguments", TRUE);
            }
        }
        else
        {
            if(active_program != "")
            {
                // Relay message if a program is running
                llMessageLinked(LINK_THIS, 0, msg, "");
                return;
            }
            else
            {
                // Give error if command is unknown
                list programs = getPrograms();
                integer i;
                for(i=0; i < llGetListLength(programs); i++)
                {
                    string program = llList2String(programs, i);
                    string name = llGetSubString(program, 0, -6);
                    if(llSubStringIndex(name, param0) != -1)
                    {
                        llMessageLinked(LINK_THIS, 0, msg, "");
                        active_program = name;
                        return;
                    }
                }
                printText(param0 + ": command not found", TRUE);
                printText(prompt(), FALSE);
            }
        }
    }

    link_message(integer sender, integer num, string msg, key id)
    {
        if(msg == "exit")
        {
            active_program = "";

            // Print prompt
            string hostname = llGetEnv("simulator_hostname");
            string user = llGetUsername(llGetOwner());
            printText("<span class=\\'color_3\\'>" + user +
                "</span>@<span class=\\'color_3\\'>" + hostname +
                "</span> > ", FALSE);
        }
        else if(msg == "display started")
        {
            printText("Display has been restarted.", TRUE);
        }
    }
}
