#define PSYS ["PSYS_PART_FLAGS", 0, "PSYS_SRC_PATTERN", 9, "PSYS_PART_BLEND_FUNC_SOURCE", 24, "PSYS_PART_BLEND_FUNC_DEST", 25, "PSYS_SRC_TARGET_KEY", 20, "PSYS_SRC_TEXTURE", 12, "PSYS_SRC_BURST_PART_COUNT", 15, "PSYS_SRC_BURST_RATE", 13, "PSYS_SRC_BURST_RADIUS", 16, "PSYS_PART_MAX_AGE", 7, "PSYS_SRC_MAX_AGE", 19, "PSYS_SRC_ANGLE_BEGIN", 22, "PSYS_SRC_ANGLE_END", 23, "PSYS_SRC_BURST_SPEED_MIN", 17, "PSYS_SRC_BURST_SPEED_MAX", 18, "PSYS_PART_START_ALPHA", 2, "PSYS_PART_END_ALPHA", 4, "PSYS_PART_START_GLOW", 26, "PSYS_PART_END_GLOW", 27, "PSYS_SRC_OMEGA", 21, "PSYS_SRC_ACCEL", 8, "PSYS_PART_START_SCALE", 5, "PSYS_PART_END_SCALE", 6, "PSYS_PART_START_COLOR", 1, "PSYS_PART_END_COLOR", 3]
#define PSYS_FLAGS ["PSYS_PART_BOUNCE_MASK", 4, "PSYS_PART_EMISSIVE_MASK", 256, "PSYS_PART_FOLLOW_SRC_MASK", 16, "PSYS_PART_FOLLOW_VELOCITY_MASK", 32, "PSYS_PART_INTERP_COLOR_MASK", 1, "PSYS_PART_INTERP_SCALE_MASK", 2, "PSYS_PART_RIBBON_MASK", 1024, "PSYS_PART_TARGET_LINEAR_MASK", 128, "PSYS_PART_TARGET_POS_MASK", 64, "PSYS_PART_WIND_MASK", 8]
#define PSYS_PATTERNS ["PSYS_SRC_PATTERN_EXPLODE", 2, "PSYS_SRC_PATTERN_ANGLE_CONE", 8, "PSYS_SRC_PATTERN_ANGLE", 4, "PSYS_SRC_PATTERN_DROP", 1, "PSYS_SRC_PATTERN_ANGLE_CONE_EMPTY", 16]
#define PSYS_BLENDING ["PSYS_PART_BF_ONE", 0, "PSYS_PART_BF_ZERO", 1, "PSYS_PART_BF_DEST_COLOR", 2, "PSYS_PART_BF_SOURCE_COLOR", 3, "PSYS_PART_BF_ONE_MINUS_DEST_COLOR", 4, "PSYS_PART_BF_ONE_MINUS_SOURCE_COLOR", 5, "PSYS_PART_BF_SOURCE_ALPHA", 7, "PSYS_PART_BF_ONE_MINUS_SOURCE_ALPHA", 9]

#include "terminal-hud/include/utility.lsl"
#include "terminal-hud/include/tabulate.lsl"

key rezzer;
list rules;
integer enabled = TRUE;

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
                // Return all rules
                list headers = ["rule", "value"];
                list rows;
                integer i;
                for(i=0; i < llGetListLength(rules); i+=2)
                {
                    rows += [llList2String(rules, i) + "|" +
                        llList2String(rules, i+1)];
                }
                llRegionSayTo(rezzer, -42, tabulate(headers, rows));
            }
            else
            {
                // Get rule value (ex. PSYS_SRC_PATTERN=9)
                string rule_name = param1;
                integer index = llListFindList(PSYS, [rule_name]);
                integer rule_value = llList2Integer(PSYS, index+1);

                // Find rule_value in rules and return its data
                integer i;
                for(i=0; i < llGetListLength(rules); i+=2)
                {
                    integer value = llList2Integer(rules, i);
                    if(value == rule_value)
                    {
                        string data = llList2String(rules, i+1);
                        llRegionSayTo(rezzer, -42, (string)rule_name + " | " + data);
                        return;
                    }
                }
                llRegionSayTo(rezzer, -42, "error: rule_value not found in rules");
            }
        }
        else if(param0 == "set")
        {
            // Get rule value (ex. PSYS_SRC_PATTERN=9)
            string rule_name = param1;
            integer index = llListFindList(PSYS, [rule_name]);
            integer rule_value = llList2Integer(PSYS, index+1);
            
            // Find rule_value in rules and set its data
            integer i;
            for(i=0; i < llGetListLength(rules); i+=2)
            {
                integer value = llList2Integer(rules, i);
                if(value == rule_value)
                {
                    // TODO handle param1 = +1, -1, *3, /2, etc.
                    
                    // Convert value to correct type
                    list value_ = [];
                    if(llSubStringIndex(param2, "<") != -1)
                        value_ = [(vector)param2];
                    else if(llSubStringIndex(param2, ".") != -1)
                        value_ = [(float)param2];
                    else if(llSubStringIndex(param2, "\"") != -1 ||
                        llSubStringIndex(param2, "\'") != -1)
                        value_ = [llGetSubString(param2, 1, -2)];
                    else
                        value_ = [(integer)param2];
                    
                    // Update rules and effect
                    rules = llListReplaceList(rules, value_, i+1, i+1);
                    llParticleSystem(rules);

                    // Get updated data and return it
                    string data = llList2String(rules, i+1);
                    llRegionSayTo(rezzer, -42, (string)rule_name + " | " + data);
                    return;
                }
            }
            llRegionSayTo(rezzer, -42, "error: rule_value not found in rules");
        }
        else if(param0 == "poof")
        {
            if(!enabled) return;
            llParticleSystem(rules);
            llSleep(.2);
            llParticleSystem([]);
        }
        else if(param0 == "on")
        {
            enabled = TRUE;
            llParticleSystem(rules);
        }
        else if(param0 == "off")
        {
            enabled = FALSE;
            llParticleSystem([]);
        }
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
