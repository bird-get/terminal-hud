#define PROGRAM_NAME "partgen"
#define EMITTER_NAME "particle_emitter"
#define HELP_MESSAGE "usage: partgen [-h]

A particle generator. Creates particle emitters with tweakable parameters.
 
optional arguments:
  -h, --help    show help and exit"

#define HELP_MESSAGE2 "partgen usage:

commands:
  new                   rez new emitter
  ls                    list emitters
  set [rule] [value]    set particle rule
  get [rule]            get particle rule (if rule=all, list all rules)
  on [num]              enable emitter NUM
  off [num]             disable emitter NUM
  select [num]          select emitter NUM
  del                   delete selected emitter
  align [spacing]       align emitters at owner pos with spacing
  help                  show this help message
  quit                  quit program
  export                export to LSL function"

#define PSYS ["PSYS_PART_FLAGS", 0, "PSYS_SRC_PATTERN", 9, "PSYS_PART_BLEND_FUNC_SOURCE", 24, "PSYS_PART_BLEND_FUNC_DEST", 25, "PSYS_SRC_TARGET_KEY", 20, "PSYS_SRC_TEXTURE", 12, "PSYS_SRC_BURST_PART_COUNT", 15, "PSYS_SRC_BURST_RATE", 13, "PSYS_SRC_BURST_RADIUS", 16, "PSYS_PART_MAX_AGE", 7, "PSYS_SRC_MAX_AGE", 19, "PSYS_SRC_ANGLE_BEGIN", 22, "PSYS_SRC_ANGLE_END", 23, "PSYS_SRC_BURST_SPEED_MIN", 17, "PSYS_SRC_BURST_SPEED_MAX", 18, "PSYS_PART_START_ALPHA", 2, "PSYS_PART_END_ALPHA", 4, "PSYS_PART_START_GLOW", 26, "PSYS_PART_END_GLOW", 27, "PSYS_SRC_OMEGA", 21, "PSYS_SRC_ACCEL", 8, "PSYS_PART_START_SCALE", 5, "PSYS_PART_END_SCALE", 6, "PSYS_PART_START_COLOR", 1, "PSYS_PART_END_COLOR", 3]
#define PSYS_FLAGS ["PSYS_PART_BOUNCE_MASK", 4, "PSYS_PART_EMISSIVE_MASK", 256, "PSYS_PART_FOLLOW_SRC_MASK", 16, "PSYS_PART_FOLLOW_VELOCITY_MASK", 32, "PSYS_PART_INTERP_COLOR_MASK", 1, "PSYS_PART_INTERP_SCALE_MASK", 2, "PSYS_PART_RIBBON_MASK", 1024, "PSYS_PART_TARGET_LINEAR_MASK", 128, "PSYS_PART_TARGET_POS_MASK", 64, "PSYS_PART_WIND_MASK", 8]
#define PSYS_PATTERNS ["PSYS_SRC_PATTERN_EXPLODE", 2, "PSYS_SRC_PATTERN_ANGLE_CONE", 8, "PSYS_SRC_PATTERN_ANGLE", 4, "PSYS_SRC_PATTERN_DROP", 1, "PSYS_SRC_PATTERN_ANGLE_CONE_EMPTY", 16]
#define PSYS_BLENDING ["PSYS_PART_BF_ONE", 0, "PSYS_PART_BF_ZERO", 1, "PSYS_PART_BF_DEST_COLOR", 2, "PSYS_PART_BF_SOURCE_COLOR", 3, "PSYS_PART_BF_ONE_MINUS_DEST_COLOR", 4, "PSYS_PART_BF_ONE_MINUS_SOURCE_COLOR", 5, "PSYS_PART_BF_SOURCE_ALPHA", 7, "PSYS_PART_BF_ONE_MINUS_SOURCE_ALPHA", 9]

#include "terminal-hud/include/utility.lsl"
#include "terminal-hud/include/tabulate.lsl"

list autocomplete_(string text, list items)
{
    // Find and return autocompletions for text in items
    integer length = llGetListLength(items);
    list completions = [];
    integer i;
    for(i=0; i < length; i++)
    {
        string item = llList2String(items, i);
        integer index = llSubStringIndex(item, text);
        if(index != -1)
            completions += item;
    }

    return completions;
}

printText(string raw_text, integer new_line)
{
    if(new_line) raw_text = raw_text + "<br>";
    llMessageLinked(LINK_THIS, 1, raw_text, "");
}

integer listener;
integer active;
list emitters;
key active_emitter = NULL_KEY;

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
            else if(msg == "help")
            {
                printText(HELP_MESSAGE2, TRUE);
            }
            else if(msg == "new")
            {
                // Rez new emitter
                llRezObject(EMITTER_NAME, llGetPos(), ZERO_VECTOR, ZERO_ROTATION, 1);
                integer num = llGetListLength(emitters);
                printText("Emitter " + (string)num + " rezzed.", TRUE);
            }
            else if(param0 == "del")
            {
                if(param1 == "")
                {
                    if(active_emitter == NULL_KEY)
                    {
                        printText("error: no emitter selected", TRUE);
                        return;
                    }
                
                    // Delete active emitter
                    llRegionSayTo(active_emitter, -42, "delete");
                }
                else
                {
                    // Delete emitter NUM
                    integer count = llGetListLength(emitters);
                    integer num = (integer)param1;
                    if(num < count && num >= 0)
                    {
                        key emitter = llList2Key(emitters, num);
                        llRegionSayTo(emitter, -42, "delete");
                    }
                    else
                    {
                        printText("error: invalid number", TRUE);
                    }
                }
            }
            else if(msg == "ls")
            {
                // List emitters
                list headers = ["num", "key"];
                list rows;

                integer i;
                for(i=0; i < llGetListLength(emitters); i++)
                {
                    integer color = 7;
                    if(llList2Key(emitters, i) == active_emitter) color = 4;
                    string row = "<span class=\\'color_" + (string)color +
                        "\\'>" + (string)i + "|" +
                        llList2String(emitters, i) + "</span>";
                    rows += [row];
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
                integer count = llGetListLength(emitters);
                integer num = (integer)param1;
                if(num < count && num >= 0)
                {
                    active_emitter = llList2Key(emitters, num);
                    printText("Selected emitter " + (string)num + ".", TRUE);
                }
                else
                {
                    printText("error: invalid number", TRUE);
                }
            }
            else if(param0 == "set")
            {
                if(active_emitter == NULL_KEY)
                {
                    printText("error: no emitter selected", TRUE);
                    return;
                }

                // Set particle rule for selected emitter
                string rule = param1;
                string value = param2;
                list completions = autocomplete_(llToUpper(rule), PSYS);
                integer count = llGetListLength(completions);
                if(count == 0)
                    printText("error: no autocompletions found", TRUE);
                else if(count > 1)
                    printText("error: more than one autocompletion found", TRUE);
                else
                {
                    string completed_rule = llList2String(completions, 0);
                    llRegionSayTo(active_emitter, -42, "set " + completed_rule + " " + param2);
                }
            }
            else if(param0 == "get")
            {
                if(active_emitter == NULL_KEY)
                {
                    printText("error: no emitter selected", TRUE);
                    return;
                }

                if(param1 == "all")
                {
                    llRegionSayTo(active_emitter, -42, "get all");
                }
                else
                {
                    // Get selected emitter's parameters
                    list completions = autocomplete_(llToUpper(param1), PSYS);
                    
                    if(llGetListLength(completions) == 0)
                    {
                        printText("error: no autocompletions found", TRUE);
                    }
                    else
                    {
                        // Send each completion to emitter
                        integer i;
                        for(i=0; i < llGetListLength(completions); i++)
                        {
                            string rule_name = llList2String(completions, i);
                            llRegionSayTo(active_emitter, -42, "get " + rule_name);
                        }
                    }
                }
            }
            else if(msg == "on" || msg == "off")
            {
                if(active_emitter == NULL_KEY)
                {
                    printText("error: no emitter selected", TRUE);
                    return;
                }
                
                llRegionSayTo(active_emitter, -42, msg);
            }
            else if(msg == "poof")
            {
                llRegionSay(-42, "poof");
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
                if(active_emitter == NULL_KEY)
                {
                    printText("error: no emitter selected", TRUE);
                    return;
                }
                
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
                printText("Particle generator ready. Type \\'help\\' for help.", TRUE);
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
        if(msg == "deleted")
        {
            // Remove emitter from list
            integer num = llListFindList(emitters, [id]);
            emitters = llDeleteSubList(emitters, num, num);
            if(id == active_emitter) active_emitter = NULL_KEY;
            printText("Emitter " + (string)num + " deleted.", TRUE);
        }
        else
        {
            if(id == active_emitter)
                printText(msg, TRUE);
        }
    }
}
