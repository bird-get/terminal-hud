#include "terminal-hud/include/utility.lsl"
#include "terminal-hud/include/tabulate.lsl"

key rezzer;
list rules;

default
{
    state_entry()
    {
        rules = [PSYS_PART_FLAGS, 0, 
            PSYS_SRC_PATTERN, 4, 
            PSYS_PART_BLEND_FUNC_SOURCE, 7, 
            PSYS_PART_BLEND_FUNC_DEST, 9, 
            PSYS_SRC_TARGET_KEY, (key)"", 
            PSYS_SRC_TEXTURE, "00000000-0000-0000-0000-000000000000", 
            PSYS_SRC_BURST_PART_COUNT, 1, 
            PSYS_SRC_BURST_RATE, 1.000000, 
            PSYS_SRC_BURST_RADIUS, 0.000000, 
            PSYS_PART_MAX_AGE, 1.000000, 
            PSYS_SRC_MAX_AGE, 0.000000, 
            PSYS_SRC_ANGLE_BEGIN, 0.000000, 
            PSYS_SRC_ANGLE_END, 0.000000, 
            PSYS_SRC_BURST_SPEED_MIN, 0.000000, 
            PSYS_SRC_BURST_SPEED_MAX, 0.000000, 
            PSYS_PART_START_ALPHA, 1.000000, 
            PSYS_PART_END_ALPHA, 1.000000, 
            PSYS_PART_START_GLOW, 0.000000, 
            PSYS_PART_END_GLOW, 0.000000, 
            PSYS_SRC_OMEGA, <0.000000, 0.000000, 0.000000>, 
            PSYS_SRC_ACCEL, <0.000000, 0.000000, 0.000000>, 
            PSYS_PART_START_SCALE, <0.500000, 0.500000, 0.000000>, 
            PSYS_PART_END_SCALE, <0.500000, 0.500000, 0.000000>, 
            PSYS_PART_START_COLOR, <1.000000, 1.000000, 1.000000>, 
            PSYS_PART_END_COLOR, <1.000000, 1.000000, 1.000000>];
        llParticleSystem(rules);
    }

    on_rez(integer start_param)
    {
        list details = llGetObjectDetails(llGetKey(), [OBJECT_REZZER_KEY]);
        rezzer = llList2Key(details, 0);
        llListen(-42, "", rezzer, "");
    }

    listen(integer channel, string name, key id, string msg)
    {
        list params = llParseString2List(msg, [" "], [""]);
        string param0 = llList2String(params, 0);
        string param1 = llList2String(params, 1);
        string param2 = llList2String(params, 2);
        
        if(msg == "quit")
        {
            llDie();
        }
        else if(param0 == "get")
        {
            if(param1 == "all")
            {
                list headers = ["rule", "value"];
                list rows;
                integer i;
                for(i=0; i < llGetListLength(rules); i+=2)
                {
                    rows += [llList2String(rules, i) + "|" + llList2String(rules, i+1)];
                }
                llRegionSayTo(rezzer, -42, tabulate(headers, rows));
            }
            else
            {
                llRegionSayTo(rezzer, -42, "just one rule and its value");
                //if param in rules:
                //    return rule, value
                //else
                //    llRegionSayTo(rezzer, -42, "error: invalid rule");
            }
        }
        else if(param0 == "set")
        {
            llRegionSayTo(rezzer, -42, "rule is set");
            //if param in rules:
            //    return rule, value
            //else
            //    llRegionSayTo(rezzer, -42, "error: invalid rule");
        }
        else if(param0 == "poof")
        {
            llParticleSystem(rules);
            llSleep(.2);
            llParticleSystem([]);
        }
        else if(param0 == "on") llParticleSystem(rules);
        else if(param0 == "off") llParticleSystem([]);
        else if(param0 == "delete")
        {
            llRegionSayTo(rezzer, -42, "deleted");
            llSleep(.2);
            llDie();
        }
        else if(param0 == "setpos")
        {
            params = llDeleteSubList(params, 0, 0);
            vector pos = (vector)llDumpList2String(params, "");
            llSetRegionPos(pos);
        }
        else if(param0 == "export")
        {
            llRegionSayTo(rezzer, -42, "exported rules");
        }
    }
}
