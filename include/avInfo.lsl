avInfo(list params)
{
	integer options_mask;
	if(llListFindList(params, ["-s"]) != -1) // option: script info
	{
		options_mask += 1;
	}
	if(llListFindList(params, ["-r"]) != -1) // option: render info
	{
		options_mask += 2;
	}
	if(llListFindList(params, ["-l"]) != -1) // option: language
	{
		options_mask += 4;
	}
	
	// No options given
   	if(options_mask == 0)
   	{
    	printText("error: no options given");
       	return;
    }
    
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
	printText("Avatar information for " + av_name + ":\n ");

	list rows = [];

	// [-s] option: script info
 	if(options_mask & 1)
    {
        string running_scripts = (string)llGetObjectDetails(id, [OBJECT_RUNNING_SCRIPT_COUNT]);
        string total_scripts = (string)llGetObjectDetails(id, [OBJECT_TOTAL_SCRIPT_COUNT]);
        string script_memory = (string) llRound(llList2Float(llGetObjectDetails(id, [OBJECT_SCRIPT_MEMORY]), 0) / 1024);
        float script_time = llList2Float(llGetObjectDetails(id,[OBJECT_SCRIPT_TIME]),0);
        rows += ["scr count|" + running_scripts + " / " + total_scripts + ""];
        rows += ["scr mem|" + script_memory + "kb"];
        rows += ["scr time|" + (string)((integer)((script_time*1000000))) + "μs"];
    }

	// [-r] option: render info
 	if(options_mask & 2)
    {
        float streaming_cost = llList2Float(llGetObjectDetails(id, [OBJECT_STREAMING_COST]), 0);
        rows += ["str cost|" + formatDecimal(streaming_cost, 2)];
    }

	// [-l] option: language
 	if(options_mask & 4)
	{
		string language = llGetAgentLanguage(id);
		rows += ["language|" + language];
	}

	list headers = ["key", "value"];
    printText(tabulate(headers, rows));
}
