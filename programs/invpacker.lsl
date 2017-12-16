#define PACKAGE_NAME "empty_package"
#define HELP_MESSAGE "usage: invpacker [-h] [-c] [-m] [-t]
 
Create an empty package. Checks if added inventory items have the 
correct permission mask.
 
optional arguments:
  -c            set copy permission
  -m            set modify permission
  -t            set transfer permission
  -h, --help    show help and exit"

#include "terminal-hud/include/utility.lsl"

key package_key;
integer listener;
integer active;

printText(string raw_text, integer new_line)
{
    if(new_line) raw_text = raw_text + "<br>";
    llMessageLinked(LINK_THIS, 1, raw_text, "");
}

default
{
    state_entry()
    {
        llSetMemoryLimit(12000);
    }

    link_message(integer sender, integer num, string msg, key id)
    {
        if(msg == "exit" || num == 1) return;
        
        if(active)
        {
            if(msg == "q" || msg == "Q")
            {
                printText("Quitting; deleting package...", TRUE);
                llRegionSayTo(package_key, -42, "quit");
                llListenRemove(listener);
                active = FALSE;
                package_key = NULL_KEY;
                exit(0);
                return;
            }
            else if(msg == "c" || msg == "C")
            {
                llRegionSayTo(package_key, -42, "continue");
                return;
            }
        }

        list params = llParseString2List(msg, [" "], [""]);
        string param0 = llList2String(params, 0);
        string param1 = llList2String(params, 1);
        
        if(param0 == "invpacker")
        {
            integer options_mask;
            if(llListFindList(params, ["-h"]) != -1 ||
                llListFindList(params, ["--help"]) != -1)
            {
                printText(HELP_MESSAGE, TRUE);
                exit(0);
                return;
            }

            integer perm_mask;
            if(llListFindList(params, ["-c"]) != -1) perm_mask += PERM_COPY;
            if(llListFindList(params, ["-m"]) != -1) perm_mask += PERM_MODIFY;
            if(llListFindList(params, ["-t"]) != -1) perm_mask += PERM_TRANSFER;
            
            // Give error if no permissions or impossible perms are given
            if((~perm_mask & PERM_COPY && ~perm_mask & PERM_MODIFY &&
                ~perm_mask & PERM_TRANSFER) || (~perm_mask & PERM_COPY &&
                perm_mask & PERM_MODIFY && ~perm_mask & PERM_TRANSFER))
            {
                printText("error: invalid permissions", TRUE);
                exit(1);
                return;
            }

            printText("Rezzing package...", TRUE);
            llRezObject(PACKAGE_NAME, llGetPos(), ZERO_VECTOR, ZERO_ROTATION, perm_mask);
        }
    }

    object_rez(key id)
    {
        if(llKey2Name(id) == PACKAGE_NAME)
        {
            package_key = id;
            listener = llListen(-42, "", package_key, "");
            active = TRUE;
        }
    }

    listen(integer channel, string name, key id, string msg)
    {
        if(id == package_key)
        {
            if(msg == "quit")
            {
                llListenRemove(listener);
                active = FALSE;
                exit(0);
            }
            else if(msg == "done")
            {
                llListenRemove(listener);
                active = FALSE;
                package_key = NULL_KEY;
                printText("Packaging complete.", TRUE);
                exit(0);
            }
            else
            {
                printText(msg, TRUE);
            }
        }
    }
}
