avAttached(list params)
{
    // Parse arguments
    string av_name = llList2String(params, 1);
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
        headers += ["Scr.", "Mem", "Time"];
    }
    if(llListFindList(params, ["-r"]) != -1) // option: render info
    {
        options_mask += 4;
        headers += ["LI", "Server", "Stream"];
    }
    if(llListFindList(params, ["-t"]) != -1) // option: temp attached
    {
        options_mask += 8;
        headers += ["Temp"];
    }
    if(llListFindList(params, ["-i"]) != -1) // option: inventory count
    {
        options_mask += 16;
        headers += ["Inv"];
    }
    if(llListFindList(params, ["-c"]) != -1) // option: creator
    {
        options_mask += 32;
        headers += ["Creator"];
    }
    if(llListFindList(params, ["-d"]) != -1) // option: desc
    {
        options_mask += 64;
        headers += ["Desc"];
    }
    if(llListFindList(params, ["-p"]) != -1) // option: attached point
    {
        options_mask += 128;
        headers += ["Att. point"];
    }
    
    // Build a list of agent names for autocompletion 
    list agent_list = llGetAgentList(AGENT_LIST_REGION, []);
    integer length = llGetListLength(agent_list);
    list agent_names = [];
    integer i;
    for(i=0; i < length; i++)
    {
        key id = llList2Key(agent_list, i);
        agent_names += [llKey2Name(id)];
    }
    list completions = autocomplete(av_name, agent_names);

    if(llGetListLength(completions) == 0)
    {
        printText("error: avatar not found");
        return;
    }
    else if(llGetListLength(completions) > 1)
    {
        printText("error: more than 1 autocompletion possible:\n" +
            llDumpList2String(completions, "\n"));
        return;
    }

    // Get autocompleted name
    av_name = llList2String(completions, 0);
    
    // Find matching avatar key for autocompleted name
    integer index = llListFindList(agent_names, [av_name]);
    key id = llList2Key(agent_list, index);
    
    printText("Attachment information for " + av_name + ":\n ");
    
    // Get attachments and their details
    list attached = llGetAttachedList(id);
    list rows;
    length = llGetListLength(attached);
    for(i=0; i < length; i++)
    {
        key id = llList2Key(attached, i);
        string name = llGetSubString(llKey2Name(id), 0, 20);
        list row = [name];
      
        if(options_mask & 1) // [-k] option: show key
        {
            row += [id];
        }
        if(options_mask & 2) // [-s] option: script info
        {
            list object_details = llGetObjectDetails(id, [
                OBJECT_RUNNING_SCRIPT_COUNT, OBJECT_TOTAL_SCRIPT_COUNT,
                OBJECT_SCRIPT_MEMORY, OBJECT_SCRIPT_TIME]);
            integer running_scripts = llList2Integer(object_details, 0);
            integer total_scripts = llList2Integer(object_details, 1);
            integer script_memory = llRound(llList2Float(object_details, 2) / 1024);
            float script_time = llList2Float(object_details, 3);
            
            row += [(string)running_scripts + " / " + (string)total_scripts];
            row += [(string)script_memory + "kb"];
            row += [(string)((integer)((script_time*1000000))) + "μs"];
        }
        if(options_mask & 4) // [-r] option: render info
        {
            list object_details = llGetObjectDetails(id,
                [OBJECT_PRIM_EQUIVALENCE, OBJECT_SERVER_COST, 
                OBJECT_STREAMING_COST]);
            integer prims = llList2Integer(object_details, 0);
            float server_cost = llList2Float(object_details, 1);
            float streaming_cost = llList2Float(object_details, 2);
            row += [prims, formatDecimal(server_cost, 2),
                formatDecimal(streaming_cost, 2)];
        }
        if(options_mask & 8) // [-t] option: temp attached
        {
            row += llList2String(llGetObjectDetails(id, [OBJECT_TEMP_ATTACHED]), 0);
        }
        if(options_mask & 16) // [-i] option: inv count
        {
            row += llList2String(llGetObjectDetails(id, [OBJECT_TOTAL_INVENTORY_COUNT]), 0);
        }
        if(options_mask & 32) // [-c] option: creator
        {
            row += llList2String(llGetObjectDetails(id, [OBJECT_CREATOR]), 0);
        }
        if(options_mask & 64) // [-d] option: desc
        {
            row += llList2String(llGetObjectDetails(id, [OBJECT_DESC]), 0);
        }
        if(options_mask & 128) // [-p] option: attached point
        {
            row += llList2String(llGetObjectDetails(id, [OBJECT_ATTACHED_POINT]), 0);
        }

        rows += [llDumpList2String(row, "|")];
    }
    printText(tabulate(headers, rows));
}
