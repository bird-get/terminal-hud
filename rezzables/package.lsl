key rezzer;
list inventory_list;
integer required_perms;

checkInventory()
{
    // Find out what changed in our inventory

    list inv_list = [];
    integer inv_count = llGetInventoryNumber(INVENTORY_ALL);
    integer i;
    for(i=0; i < inv_count; i++)
    {
        string inv_name = llGetInventoryName(INVENTORY_ALL, i);
        
        if(inv_name != llGetScriptName())
        {
            integer type = llGetInventoryType(inv_name);
            string inv_type;
            if(type == INVENTORY_OBJECT) inv_type = "object";
            else if(type == INVENTORY_SCRIPT) inv_type = "script";
            else if(type == INVENTORY_NOTECARD) inv_type = "notecard";
            else if(type == INVENTORY_SOUND) inv_type = "sound";
            else if(type == INVENTORY_LANDMARK) inv_type = "landmark";
            else if(type == INVENTORY_CLOTHING) inv_type = "clothing";
            else if(type == INVENTORY_BODYPART) inv_type = "bodypart";
            else if(type == INVENTORY_ANIMATION) inv_type = "animation";
            else if(type == INVENTORY_GESTURE) inv_type = "gesture";
            else if(type == INVENTORY_TEXTURE) inv_type = "texture";
            
            integer perm_mask = llGetInventoryPermMask(inv_name, MASK_NEXT);
            string inv_perms;
            if(perm_mask & PERM_COPY) inv_perms += "c";
            if(perm_mask & PERM_MODIFY) inv_perms += "m";
            if(perm_mask & PERM_TRANSFER) inv_perms += "t";
            
            if(llListFindList(inventory_list, [inv_name]) == -1)
            {
                // New item has been added to inventory
                llRegionSayTo(rezzer, -42,
                    inv_type + " \\'" + inv_name + 
                    "\\' has been added, with perms: " + inv_perms + " (" +
                    (string)(inv_count-1) + " total)");
                
                // If inventory is a script, disable it
                if(type == INVENTORY_SCRIPT)
                {
                    llSleep(.5);
                    llSetScriptState(inv_name, FALSE);
                }
            }
            
            inv_list += [inv_name];
        }
    }
    inventory_list = inv_list;
}

integer createPackage()
{
    integer inv_count = llGetInventoryNumber(INVENTORY_ALL);
    integer i;
    for(i=0; i < inv_count; i++)
    {
        string inv_name = llGetInventoryName(INVENTORY_ALL, i);
        
        if(inv_name != llGetScriptName())
        {
            string error = "";
            integer perm_mask = llGetInventoryPermMask(inv_name, MASK_NEXT);
            
            if(required_perms & PERM_COPY && ~perm_mask & PERM_COPY)
                error = "no copy";
            else if(~required_perms & PERM_COPY && perm_mask & PERM_COPY)
                error = "copy";
            
            if(required_perms & PERM_MODIFY && ~perm_mask & PERM_MODIFY)
                error = "no modify";
            else if(~required_perms & PERM_MODIFY && perm_mask & PERM_MODIFY)
                error = "modify";
            
            if(required_perms & PERM_TRANSFER && ~perm_mask & PERM_TRANSFER)
                error = "no transfer";
            else if(~required_perms & PERM_TRANSFER && perm_mask & PERM_TRANSFER)
                error = "transfer";
            
            if(error != "")
            {
                llRegionSayTo(rezzer, -42,
                    "error: \\'" + inv_name + "\\' is " + error);
                return 1;
            }
        }
    }
    
    llRegionSayTo(rezzer, -42, "done");
    return 0;
}

unpack()
{
    list item_list;

    integer i;
    for(i = 0; i < llGetInventoryNumber(INVENTORY_ALL); i++)
    {
        string item_name = llGetInventoryName(INVENTORY_ALL, i);
        if(item_name != llGetScriptName())
        {
            item_list += item_name;
        }
    }

    if(item_list == [])
    {
        llOwnerSay("Error: No items to unpack.");
    }
    else
    {
        llGiveInventoryList(llGetOwner(), llGetObjectDesc(), item_list);
        llDie();
    }
}

default
{
    on_rez(integer start_param)
    {
        required_perms = start_param;

        list details = llGetObjectDetails(llGetKey(), [OBJECT_REZZER_KEY]);
        rezzer = llList2Key(details, 0);
        llListen(-42, "", rezzer, "");

        llSleep(1);
        string text = "Package has been rezzed.";
        text += " You can now place items into its inventory.";
        text += "\nC to continue, Q to quit";
        llRegionSayTo(rezzer, -42, text);
    }

    changed(integer change)
    {
        if(change & CHANGED_INVENTORY)
        {
            checkInventory();
        }
    }

    listen(integer channel, string name, key id, string msg)
    {
        if(msg == "quit")
        {
            llDie();
        }
        else if(msg == "continue")
        {
            if(createPackage() == 0)
            {
                state packaged;
            }
        }
    }
}

state packaged
{
    touch_start(integer num)
    {
        if(llDetectedKey(0) != llGetOwner()) return;
        unpack();
    }
}
