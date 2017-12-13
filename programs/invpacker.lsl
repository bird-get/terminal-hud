#define PACKAGE_NAME "empty_package"
#define HELP_MESSAGE "usage: invpacker [-c] [-m] [-t]
 
Create an empty package. Checks if added inventory items have the 
correct permission mask.
 
optional arguments:
  -c            set copy permission
  -m            set modify permission
  -t            set transfer permission"

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
    link_message(integer sender, integer num, string msg, key id)
    {
        if(msg == "exit" || num == 1) return;
        
        if(active)
        {
            if(msg == "q")
            {
                printText("Quitting; deleting package...", TRUE);
                llListenRemove(listener);
                active = FALSE;
                exit(0);
                return;
            }
            else if(msg == "c")
            {
                printText("Deleting package script...", TRUE);
                // TODO Tell package script to remove itself
                llListenRemove(listener);
                active = FALSE;
                exit(0);
                return;
            }
        }

        list params = llParseString2List(msg, [" "], [""]);
        string param0 = llList2String(params, 0);
        string param1 = llList2String(params, 1);
        
        if(param0 == "invpacker")
        {
            integer options_mask;
            if(llListFindList(params, ["-h"]) != -1)
            {
                printText(HELP_MESSAGE, TRUE);
                exit(0);
                return;
            }
            if(llListFindList(params, ["-c"]) != -1) options_mask += 1;
            if(llListFindList(params, ["-m"]) != -1) options_mask += 2;
            if(llListFindList(params, ["-t"]) != -1) options_mask += 4;
           
            printText("Rezzing package...", TRUE);
            llRezObject(PACKAGE_NAME, llGetPos(), ZERO_VECTOR, ZERO_ROTATION, 0);
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
            else
            {
                printText(msg, TRUE);
            }
        }
    }
}
