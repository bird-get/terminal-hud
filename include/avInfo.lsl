avInfo(list params)
{
    string av_name = llList2String(params, 1);

    list agent_list = llGetAgentList(AGENT_LIST_REGION, []);

    integer i;
    for(i = 0; i < llGetListLength(agent_list); i++)
    {
        key id = llList2Key(agent_list, i);
        string name = llGetUsername(id);
        if(name == av_name)
        {
            string info = " \n";

            if(llListFindList(params, ["-s"]) != -1) // Script info
            {
                string running_scripts = (string)llGetObjectDetails(id, [OBJECT_RUNNING_SCRIPT_COUNT]);
                string total_scripts = (string)llGetObjectDetails(id, [OBJECT_TOTAL_SCRIPT_COUNT]);
                string script_memory = (string) llRound(llList2Float(llGetObjectDetails(id, [OBJECT_SCRIPT_MEMORY]), 0) / 1024);
                float script_time = llList2Float(llGetObjectDetails(id,[OBJECT_SCRIPT_TIME]),0);
                info += "\nscr count - " + running_scripts + " / " + total_scripts;
                info += "\nscr mem - " + script_memory + "kb";
                info += "\nscr time - " + (string)((integer)((script_time*1000000)))+"μs";
            }
            if(llListFindList(params, ["-r"]) != -1) // Render info
            {
                float streaming_cost = llList2Float(llGetObjectDetails(id, [OBJECT_STREAMING_COST]), 0);
                info += "\nstr cost - " + formatDecimal(streaming_cost, 2);
            }
            if(info == "")
            {
                textTypeAnim(1, TRUE, "error: no parameters given");
                return;
            }

            textTypeAnim(1, TRUE, info);
            return;
        }
    }

    textTypeAnim(1, TRUE, "error: avatar not found");
    return;
}
