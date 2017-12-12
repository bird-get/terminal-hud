avList(list params)
{
    // Show a list of avatars in the current region
    integer options_mask;
    list headers = ["Name"];
    if(llListFindList(params, ["-k"]) != -1) // option: key
    {
        options_mask += 1;
        headers += ["Key"];
    }
    if(llListFindList(params, ["-s"]) != -1) // option: script info
    {
        options_mask += 2;
        headers += ["Scripts", "Memory", "Time"];
    }
    if(llListFindList(params, ["-r"]) != -1) // option: render info
    {
        options_mask += 4;
        headers += ["Streaming cost"];
    }
    
    // Print agent count
    list agents = llGetAgentList(AGENT_LIST_REGION, []);
    integer agent_count = llGetListLength(agents);
    printText((string)agent_count + " avatars in current region.\n \n");
    
    list rows;

    integer i;
    for(i=0; i < agent_count; i++)
    {
        key agent_key = llList2Key(agents, i);
        string agent_name = llKey2Name(agent_key);
        list agent_info = [agent_name];

        // [-k] option: show key
        if(options_mask & 1)
        {
            agent_info += [agent_key];
        }

        // [-s] option: script info
        if(options_mask & 2)
        {
            list object_details = llGetObjectDetails(agent_key, [
                OBJECT_RUNNING_SCRIPT_COUNT, OBJECT_TOTAL_SCRIPT_COUNT,
                OBJECT_SCRIPT_MEMORY, OBJECT_SCRIPT_TIME]);
            integer running_scripts = llList2Integer(object_details, 0);
            integer total_scripts = llList2Integer(object_details, 1);
            integer script_memory = llRound(llList2Float(object_details, 2) / 1024);
            float script_time = llList2Float(object_details, 3);
            
            agent_info += [(string)running_scripts + " / " + (string)total_scripts];
            agent_info += [(string)script_memory + "kb"];
            agent_info += [(string)((integer)((script_time*1000000))) + "μs"];
        }

        // [-r] option: render info
        if(options_mask & 4)
        {
            float streaming_cost = llList2Float(llGetObjectDetails(agent_key, [OBJECT_STREAMING_COST]), 0);
            agent_info += [formatDecimal(streaming_cost, 2)];
        }
        rows += [llDumpList2String(agent_info, "|")];
    }
    printText(tabulate(headers, rows));

    exit(0);
}
