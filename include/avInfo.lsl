avInfo(list params)
{
    string av_name = llList2String(params, 1);

    list agent_list = llGetAgentList(AGENT_LIST_REGION, []);

	// Check if avatar is in current region
    integer i;
    for(i = 0; i < llGetListLength(agent_list); i++)
    {
        key id = llList2Key(agent_list, i);
        string name = llGetUsername(id);
        if(name == av_name)
        {
			// Avatar is in current region; retrieve info

            string info;

			// [-s] option: script info
            if(llListFindList(params, ["-s"]) != -1)
            {
                string running_scripts = (string)llGetObjectDetails(id, [OBJECT_RUNNING_SCRIPT_COUNT]);
                string total_scripts = (string)llGetObjectDetails(id, [OBJECT_TOTAL_SCRIPT_COUNT]);
                string script_memory = (string) llRound(llList2Float(llGetObjectDetails(id, [OBJECT_SCRIPT_MEMORY]), 0) / 1024);
                float script_time = llList2Float(llGetObjectDetails(id,[OBJECT_SCRIPT_TIME]),0);
                info += "scr count - " + running_scripts + " / " + total_scripts + "\n";
                info += "scr mem - " + script_memory + "kb\n";
                info += "scr time - " + (string)((integer)((script_time*1000000))) + "μs\n";
            }

			// [-r] option: render info
            if(llListFindList(params, ["-r"]) != -1)
            {
                float streaming_cost = llList2Float(llGetObjectDetails(id, [OBJECT_STREAMING_COST]), 0);
                info += "str cost - " + formatDecimal(streaming_cost, 2) + "\n";
            }

			// No options given
            if(info == "")
            {
                printText("error: no parameters given");
                return;
            }

            printText(info);
            return;
        }
    }

    printText("error: avatar not found");
    return;
}
