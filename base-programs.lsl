#include "terminal-hud/include/utility.lsl"
#include "terminal-hud/include/tabulate.lsl"
#include "terminal-hud/include/avInfo.lsl"
#include "terminal-hud/include/avList.lsl"
#include "terminal-hud/include/avAttached.lsl"
#include "terminal-hud/include/objectDetails.lsl"
#include "terminal-hud/include/lsInv.lsl"
#include "terminal-hud/include/rez.lsl"
#include "terminal-hud/include/colortest.lsl"

printText(string raw_text)
{
    llMessageLinked(LINK_THIS, 1, raw_text, "");
}

default
{
    link_message(integer sender, integer num, string msg, key id)
    {
        list params = llParseString2List(msg, [" "], [""]);
        string param0 = llList2String(params, 0);
        string param1 = llList2String(params, 1);
        
        if(param0 == "avinfo") avInfo(params);
        else if(param0 == "avlist") avList(params);
        else if(param0 == "avattached") avAttached(params);
        else if(param0 == "details") objectDetails(params);
        else if(param0 == "colortest") colortest();
        else if(param0 == "rez") rez(params);
        else if(param0 == "lsinv") lsInv(params);
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
    }
}
