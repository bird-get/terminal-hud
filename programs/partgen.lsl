#define PROGRAM_NAME "partgen"
#define EMITTER_NAME "particle_emitter"
#define HELP_MESSAGE "usage: partgen [-h]

A particle generator. Creates particle emitters with tweakable parameters.
 
optional arguments:
  -h, --help    show help and exit
  
built-in commands:
  new                   rez new emitter
  ls                    list emitters
  set [rule] [value]    set particle rule
  get [rule]            get particle rule (if rule=all, list all rules)
  quit                  quit program
  export                export to LSL function"

#include "terminal-hud/include/utility.lsl"
#include "terminal-hud/include/tabulate.lsl"

printText(string raw_text, integer new_line)
{
    if(new_line) raw_text = raw_text + "<br>";
    llMessageLinked(LINK_THIS, 1, raw_text, "");
}

integer listener;
integer active;
list emitters;
key active_emitter;

default
{
    state_entry()
    {
        //llSetMemoryLimit(12000);
    }

    link_message(integer sender, integer num, string msg, key id)
    {
        if(msg == "exit" || num == 1 || id != (key)PROGRAM_NAME) return;
        
        msg = llToLower(msg);
        list params = llParseString2List(msg, [" "], [""]);
        string param0 = llList2String(params, 0);
        string param1 = llList2String(params, 1);
        string param2 = llList2String(params, 2);
        
        if(active)
        {
            if(msg == "quit")
            {
                // Delete all emitters and quit
                printText("Quitting; deleting particle emitters...", TRUE);
                
                integer i;
                for(i=0; i < llGetListLength(emitters); i++)
                {
                    llRegionSayTo(llList2Key(emitters, i), -42, "quit");
                }
                llListenRemove(listener);
                active = FALSE;
                active_emitter = NULL_KEY;
                emitters = [];
                exit(0);
            }
            else if(msg == "new")
            {
                // Rez new emitter
                llRezObject(EMITTER_NAME, llGetPos(), ZERO_VECTOR, ZERO_ROTATION, 1);
                integer num = llGetListLength(emitters);
                printText("Emitter " + (string)num + " rezzed.", TRUE);
            }
            else if(msg == "del")
            {
                // Delete active emitter
                llRegionSayTo(active_emitter, -42, "delete");
            }
            else if(msg == "ls")
            {
                // List emitters
                list headers = ["num", "key"];
                list rows;

                integer i;
                for(i=0; i < llGetListLength(emitters); i++)
                {
                    rows += [(string)i + "|" + llList2String(emitters, i)];
                }

                printText(tabulate(headers, rows), TRUE);
                // num | key
                // ----|-------------------------------------
                // 0   | 00000000-0000-0000-0000-000000000000
                // 1   | 00000000-0000-0000-0000-000000000000
            }
            else if(param0 == "select")
            {
                // Select emitter
                // TODO Check if param1 is valid
                integer num = (integer)param1;
                active_emitter = llList2Key(emitters, num);
                printText("Selected emitter " + (string)num + ".", TRUE);
            }
            else if(param0 == "set")
            {
                // Set parameter for active emitter
                llRegionSayTo(active_emitter, -42, "set " + param1 + param2);
            }
            else if(param0 == "get")
            {
                // TODO autocomplete param1
                // Get active emitter's parameters
                if(param1 != "")
                {
                    llRegionSayTo(active_emitter, -42, "get " + param1);
                }
                else
                {
                    llRegionSayTo(active_emitter, -42, "get all");
                }
            }
            else if(msg == "poof" || msg == "on" || msg == "off")
            {
                llRegionSayTo(active_emitter, -42, msg);
            }
            else if(param0 == "align")
            {
                float spacing = (float)param1;
                integer i;
                for(i=0; i < llGetListLength(emitters); i++)
                {
                    key emitter = llList2Key(emitters, i);
                    vector pos = llGetPos() + <0,0,spacing*i>;
                    llRegionSayTo(emitter, -42, "setpos " + (string)pos);
                }
                printText("Emitters aligned.", TRUE);
            }
            else if(msg == "export")
            {
                // Export active emitter's parameters to a LSL function
                llRegionSayTo(active_emitter, -42, "export");
            }
            else
            {
                printText("error: invalid command", TRUE);
            }
        }
        else
        {
            if(param0 == "partgen")
            {
                if(llListFindList(params, ["-h"]) != -1 ||
                    llListFindList(params, ["--help"]) != -1)
                {
                    printText(HELP_MESSAGE, TRUE);
                    exit(0);
                    return;
                }
                
                active = TRUE;
                listener = llListen(-42, "", "", "");
                printText("Particle generator ready. Type \\'partgen -h\\' for help.", TRUE);
            }
        }
    }
    
    object_rez(key id)
    {
        if(llKey2Name(id) == EMITTER_NAME)
        {
            emitters += [id];
        }
    }
    
    listen(integer channel, string name, key id, string msg)
    {
        if(id == active_emitter)
        {
            if(msg == "quit")
            {
                //llListenRemove(listener);
                //active = FALSE;
                //exit(0);
            }
            else if(msg == "deleted")
            {
                // Remove emitter from list
                integer num = llListFindList(emitters, [id]);
                emitters = llDeleteSubList(emitters, num, num);
                if(id == active_emitter) active_emitter = NULL_KEY;
                printText("Emitter " + (string)num + " deleted.", TRUE);
            }
            else
            {
                printText(msg, TRUE);
            }
        }
    }
}
