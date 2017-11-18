avInfo(list params)
{
    string av_name = llList2String(params, 1);
    list agent_list = llGetAgentList(AGENT_LIST_REGION, []);
	
	// Build a list of agent names for autocompletion 
	integer length = llGetListLength(agent_list);
	list agent_names = [];
	key id;
	integer i;
	for(i=0; i < length; i++)
	{
		id = llList2Key(agent_list, i);
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

	av_name = llList2String(completions, 0);
	// TODO tabulate output

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

	// [-l] option: language
	if(llListFindList(params, []) != -1)
	{
		string language = llGetAgentLanguage(id);
		info += "language - " + language;
	}

	// No options given
   	if(info == "")
   	{
    	printText("error: no parameters given");
       	return;
    }

    printText(info);
}
