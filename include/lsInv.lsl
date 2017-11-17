lsInv(list params)
{
	// List inventory
	integer options_mask;
	list headers = ["Name"];
	if(llListFindList(params, ["-k"]) != -1) // option: key
	{
		options_mask += 1;
		headers += ["Key"];
	}
	if(llListFindList(params, ["-p"]) != -1) // option: permissions
	{
		options_mask += 2;
		headers += ["Permissions"];
	}
	integer inv_count = llGetInventoryNumber(INVENTORY_ALL);
	if(inv_count > 1)
	{
		list rows = [];
		integer i;
		for(i=0; i < inv_count; i++)
		{
			string inv_name = llGetInventoryName(INVENTORY_ALL, i);
			if(inv_name != llGetScriptName())
			{
				string row;
				row += inv_name;
				if(options_mask & 1)
					row += "|" + (string)llGetInventoryKey(inv_name);
				if(options_mask & 2)
				{
					row += "|";

					// Base
					integer perms = llGetInventoryPermMask(inv_name, MASK_BASE);
					if(perms & PERM_COPY) row += "c";
					else row += "x";
					if(perms & PERM_MODIFY) row += "m";
					else row += "x";
					if(perms & PERM_TRANSFER) row += "t";
					else row += "x";
					
					// Owner
					perms = llGetInventoryPermMask(inv_name, MASK_OWNER);
					if(perms & PERM_COPY) row += "c";
					else row += "x";
					if(perms & PERM_MODIFY) row += "m";
					else row += "x";
					if(perms & PERM_TRANSFER) row += "t";
					else row += "x";
					
					// Next owner
					perms = llGetInventoryPermMask(inv_name, MASK_NEXT);
					if(perms & PERM_COPY) row += "c";
					else row += "x";
					if(perms & PERM_MODIFY) row += "m";
					else row += "x";
					if(perms & PERM_TRANSFER) row += "t";
					else row += "x";
					
					// Group
					perms = llGetInventoryPermMask(inv_name, MASK_GROUP);
					if(perms & (PERM_COPY|PERM_MODIFY)) row += "g";
					else row += "x";
					
					// Everyone
					perms = llGetInventoryPermMask(inv_name, MASK_EVERYONE);
					if(perms & PERM_COPY) row += "e";
					else row += "x";
				}
				rows += [row];
			}
			// TODO option: print inventory description
		}
		printText(tabulate(headers, rows));
	}
	else
	{
		printText("No items in inventory.");
	}
}
