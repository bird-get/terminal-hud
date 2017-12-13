key rezzer;
list inventory_list;

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
                    "\\' has been added, with perms: " + inv_perms);
                
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

default
{
    on_rez(integer start_param)
    {
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
    }
}
