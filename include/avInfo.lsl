avInfo(list params)
{
    // Show a table with information about an avatar.

    // Display help
    if(llListFindList(params, ["-h"]) != -1 ||
        llListFindList(params, ["--help"]) != -1)
    {
        printText("usage: avinfo [name] [-h]
 
Request info about avatar NAME.
 
positional arguments:
  name          name of avatar
 
optional arguments:
  -h, --help    show help and exit
 
ex: avinfo john.doe", TRUE);
        exit(0);
        return;
    }
    
    // Parse arguments
    string av_name = llList2String(params, 1);
    list agent_list = llGetAgentList(AGENT_LIST_REGION, []);
    
    // Build a list of agent names for autocompletion 
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
        printText("error: avatar not found", TRUE);
        exit(1);
        return;
    }
    else if(llGetListLength(completions) > 1)
    {
        
        printText("error: more than 1 autocompletion possible:\n" +
            llDumpList2String(completions, "\n"), FALSE);
        exit(1);
        return;
    }

    // Get autocompleted name
    av_name = llList2String(completions, 0);
    
    // Find matching avatar key for autocompleted name
    integer index = llListFindList(agent_names, [av_name]);
    key id = llList2Key(agent_list, index);
    
    printText("Avatar information for " + av_name + ":", TRUE);

    list rows = [];
    
    list details = llGetObjectDetails(id, [
        OBJECT_RENDER_WEIGHT, OBJECT_STREAMING_COST,
        OBJECT_HOVER_HEIGHT, OBJECT_BODY_SHAPE_TYPE, OBJECT_GROUP_TAG,
        OBJECT_ATTACHED_SLOTS_AVAILABLE, 
        OBJECT_RUNNING_SCRIPT_COUNT, OBJECT_TOTAL_SCRIPT_COUNT,
        OBJECT_SCRIPT_MEMORY, OBJECT_SCRIPT_TIME]);

    rows += ["display name|" + llGetDisplayName(id)];
    rows += ["username|" + llGetUsername(id)];
    rows += ["language|" + llGetAgentLanguage(id)];
    
    string group_tag = llList2String(details, 4);
    if(group_tag == "") group_tag = "none";
    rows += ["group tag|" + group_tag];
    
    float hover_height = llList2Float(details, 2);
    float body_shape = llList2Float(details, 3);
    rows += ["hover height|" + (string)hover_height];
    rows += ["body shape|" + (string)body_shape];
    
    rows += ["attached slots|" + llList2String(details, 5)];
    rows += ["size|" + (string)llGetAgentSize(id)];
    
    // Render info
    float streaming_cost = llList2Float(details, 1);
    string render_weight = llList2String(details, 0);
    rows += ["streaming cost|" + formatDecimal(streaming_cost, 2)];
    rows += ["render weight|" + (string)render_weight];
    
    string running_scripts = llList2String(details, 6);
    string total_scripts = llList2String(details, 7);
    string script_memory = (string)llRound(llList2Float(details, 8) / 1024);
    float script_time = llList2Float(details, 9);
    rows += ["script count|" + running_scripts + " / " + total_scripts + ""];
    rows += ["script memory|" + script_memory + "kb"];
    rows += ["script time|" + (string)((integer)((script_time*1000000))) + "μs"];
    
    list headers = ["key", "value"];
    printText(tabulate(headers, rows), TRUE);

    exit(0);
}
