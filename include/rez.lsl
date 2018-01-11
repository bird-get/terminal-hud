rez(list params)
{
    // Display help
    if(llListFindList(params, ["-h"]) != -1 ||
        llListFindList(params, ["--help"]) != -1)
    {
        printText("usage: rez [-h] [-g] [-p POS] name
 
Rez an object from inventory.
 
positional arguments:
  name          object name
 
optional arguments:
  -p POS        rez NAME at POS (max. 10m away from avatar)
  -g            align to grid
  -h, --help    show help and exit
 
ex: rez -p <118,123,100> test_cube", TRUE);
        exit(0);
        return;
    }
    
    // Parse position option
    vector pos;
    integer pos_index = llListFindList(params, ["-p"]);
    if(pos_index == -1)
        pos = llGetPos();
    else
        pos = (vector)llList2String(params, pos_index + 1);

    if(pos == ZERO_VECTOR || llVecDist(pos, llGetPos()) > 10)
    {
        printText("error: invalid rez position", TRUE);
        exit(1);
        return;
    }

    // Parse grid align option
    if(llListFindList(params, ["-g"]) > -1)
    {
        pos.x = (float)llRound(pos.x * 4) / 4;
        pos.y = (float)llRound(pos.y * 4) / 4;
        pos.z = (float)llRound(pos.z * 4) / 4;
    }

    // Get inventory list
    list inventory = [];
    integer inv_count = llGetInventoryNumber(INVENTORY_OBJECT);
    if(inv_count > 1)
    {
        integer i;
        for(i=0; i < inv_count; i++)
        {
            inventory += llGetInventoryName(INVENTORY_OBJECT, i);
        }
    }
    else
    {
        printText("error: no items in inventory", TRUE);
        exit(1);
        return;
    }
    
    // Look for autocompletions
    string object_name = llList2String(params, 1);
    list completions = autocomplete(object_name, inventory);
    integer length;
    if(llGetListLength(completions) == 0)
    {
        // No autocompletions
        printText("error: inventory not found", TRUE);
        exit(1);
        return;
    }
    else if(llGetListLength(completions) == 1)
    {
        object_name = llList2String(completions, 0);
    }
    else if(llGetListLength(completions) > 1)
    {
        // More than one autocompletion: find exact match in completions
        integer i;
        integer length = llGetListLength(completions);
        integer match;
        for(i=0; i < length; i++)
        {
            string completion = llList2String(completions, i);
            if(completion == object_name)
            {
                match = TRUE;
            }
        }
        if(!match)
        {
            printText("error: more than 1 autocompletion possible:\n" +
                llDumpList2String(completions, "\n"), FALSE);
            exit(1);
            return;
        }
    }
    
    // Rez object and print message
    llRezObject(object_name, pos, ZERO_VECTOR, ZERO_ROTATION, 0);
    printText("object \\\'" + object_name + "\\\' rezzed @ " + 
        "<" + formatDecimal(pos.x, 2) + "," + formatDecimal(pos.y, 2) +
        "," + formatDecimal(pos.z, 2) + ">", TRUE);

    exit(0);
}
