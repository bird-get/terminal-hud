avInfo(list params)
{
    string avName = llList2String(params, 1);

    list agentList = llGetAgentList(AGENT_LIST_REGION, []);

    integer i;
    for(i = 0; i < llGetListLength(agentList); i++)
    {
        key id = llList2Key(agentList, i);
        string name = llGetUsername(id);
        if(name == avName)
        {
            string info = " \n";

            if(llListFindList(params, ["-s"]) != -1) // Script info
            {
                string runningScriptCount = (string)llGetObjectDetails(id, [OBJECT_RUNNING_SCRIPT_COUNT]);
                string totalScriptCount = (string)llGetObjectDetails(id, [OBJECT_TOTAL_SCRIPT_COUNT]);
                string scriptMemory = (string) llRound(llList2Float(llGetObjectDetails(id, [OBJECT_SCRIPT_MEMORY]), 0) / 1024);
                float scriptTime = llList2Float(llGetObjectDetails(id,[OBJECT_SCRIPT_TIME]),0);
                info += "\nscr count - " + runningScriptCount + " / " + totalScriptCount;
                info += "\nscr mem - " + scriptMemory + "kb";
                info += "\nscr time - " + (string)((integer)((scriptTime*1000000)))+"μs";
            }
            if(llListFindList(params, ["-r"]) != -1) // Render info
            {
                float streamingCost = llList2Float(llGetObjectDetails(id, [OBJECT_STREAMING_COST]), 0);
                info += "\nstr cost - " + formatDecimal(streamingCost, 2);
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