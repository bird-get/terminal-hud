// TODO Make HUD look like terminal window
// TODO Rename to 'Jetvogel HUD Terminal'
// TODO Use one prim for llSetText per line, so we can left-justify using pos
// TODO Add command to list inventory
// TODO Blinking cursor
// TODO Move row object left and right depending on string length, to align to left
// TODO Find out length of each char
// TODO Calculate length using occurences of each char in row
// TODO Possibly overlay text over eachother for coloring?

#define DEBUG
#define TIMEOUT 60
#define VERSION "0.01"
#define HELP_COMMANDS "Command list:\n \nhelp [func]\nset channel [c]\ncls\nreset\ndisable\nenable\nset color [<col>]\nset volume [v]\nrez [name] [-p <pos>]\navinfo [name] [-s] [-r]"
#define HELP_REZ " \nRez an object from inventory.\n \n-p <x,y,z> can be added for custom position.\n \nex: \nrez tree\nrez tree -p <118,123,100>"
#define HELP_AVINFO " \nRequest info about an avatar.\n \n-s for script info.\n-r for render info.\n \nex: \navinfo john.doe -s -r"

#include "snippets/debug.lsl"
#include "snippets/typeTextAnim.lsl"
#include "snippets/formatDecimal.lsl"
#include "terminal-hud/include/setColor.lsl"
#include "terminal-hud/include/rez.lsl"
#include "terminal-hud/include/avInfo.lsl"

integer activeChannel = 42;
integer listener;
list text_row_objects = [];
integer link_background;

startText()
{
    textAnimSpeed = .02;
    textTypeAnim(4, FALSE, "> slcmd\n----------\nchannel: " + (string)activeChannel + "\nmemory left: " +
        (string)llGetFreeMemory() + "kb\nversion: v" + VERSION + "\n----------");
}

scanLinks()
{
	integer i;
	integer prim_count = llGetNumberOfPrims();
	for(i = 0; i <= prim_count; i++)
	{
		string link_name = llGetLinkName(i);
		if(link_name == "text_row")
		{
			text_row_objects += i;
		}
		else if(link_name == "background")
		{
			link_background = i;
		}
	}
}

list splitByLength(string str, integer max_length)
{
	integer string_length = llStringLength(str);
	list lines;
	integer index = 0;
	while(TRUE)
	{
		if(index + max_length >= string_length)
		{
			lines += [llGetSubString(str, index, -1)];
			return lines;
		}
		lines += [llGetSubString(str, index, index + max_length - 1)];
		index += max_length;
	}
	return [];
}

list buffer = [];

printText(string raw_text)
{
	integer columns = 30;
	integer rows = 24;
	integer i;

	list lines = splitByLength(raw_text, columns);	

	// Add lines to buffer
	for(i = 0; i < llGetListLength(lines); i++)
	{
		buffer = llList2List(buffer, 1, -1); // Remove first item
		string text = llList2String(lines, i);
		// TODO Fill text to <columns> chars
		buffer += [text];
	}

	// Refresh all lines
	for(i = 0; i < rows; i++)
	{
		string text = llList2String(buffer, i);
		integer link_num = llList2Integer(text_row_objects, i);
		llSetLinkPrimitiveParamsFast(link_num, [PRIM_TEXT, text, <1,1,1>, 1.0]);
	}
}

default
{
    state_entry()
    {
		llSetLinkPrimitiveParamsFast(LINK_SET, [PRIM_TEXT, "", <1,1,1>, 1.0]);
		scanLinks();
		
		// Populate buffer with empty lines
		integer rows = 24;
		integer i;
		for(i = 0; i <= rows; i++)
		{
			buffer += [i];
		}

		// Move text_row prims to correct positions
		for(i = 0; i < 24; i++)
		{
			vector pos = <0,0,-.05 - 0.015*i>;
			integer link_num = llList2Integer(text_row_objects, i);
			llSetLinkPrimitiveParamsFast(link_num, [PRIM_POSITION, pos]);
		}

		// Move and scale background
		llSetLinkPrimitiveParams(link_background, [PRIM_POSITION, <0.1,0,-0.2>,
			PRIM_SIZE, <0.01, 0.59, 0.40>]);

		// Scale top bar to correct size
		llSetLinkPrimitiveParams(1, [PRIM_SIZE, <0.01, 0.59, 0.02>]);
		
        listener = llListen(activeChannel, "", llGetOwner(), "");
        startText();
    }

    changed(integer change)
    {
        if(change & CHANGED_OWNER)
            llResetScript();
    }

    listen(integer channel, string name, key id, string msg)
    {
        textAnimSpeed = .02;

        printText("> " + msg);
        llSleep(.2);

        list params = llParseString2List(msg, [" "], [""]);

        string param0 = llList2String(params, 0);
        string param1 = llList2String(params, 1);
        string param2 = llList2String(params, 2);

        if(param0 == "help")
        {
            if(param1 == "rez")
                printText(HELP_REZ);
            else if(param1 == "avinfo")
                printText(HELP_AVINFO);
            else
                printText(HELP_COMMANDS);
        }
        else if(param0 == "set")
        {
            if(param1 == "color")
            {
                setColor(param2);
            }
            else if(param0 == "volume")
            {
                llSleep(.1);
                textVolume = (float)param1;
                printText("Volume set to " + (string)textVolume + ".");
            }
            else if(param0 == "channel")
            {
                llSleep(.1);
                activeChannel = (integer)param1;
                printText("Channel set to " + (string)activeChannel + ".");
                llListenRemove(listener);
                listener = llListen(activeChannel, "", llGetOwner(), "");
            }
        }

        else if(param0 == "disable")
        {
            state disabled;
        }
        else if(param0 == "cls")
        {
            // TODO Clear screen
        }
        else if(param0 == "rez")
        {
            rez(params);
        }
        else if(param0 == "avinfo")
        {
            avInfo(params);
        }
        else if(param0 == "reset")
        {
            llResetScript();
        }
        else
        {
            printText(param0 + ": command not found");
        }
    }
}

state disabled
{
    state_entry()
    {
        llSetLinkColor(LINK_SET, <1,1,1>, ALL_SIDES);
        llSetAlpha(0.25, ALL_SIDES);
        llSetText("", <1,1,1>, 0.0);
        llListen(activeChannel, "", "", "enable");
    }

    listen(integer channel, string name, key id, string msg)
    {
        if(llGetOwnerKey(id) == llGetOwner())
        {
            if(msg == "enable")
            {
                printText("> enable");
                llSetAlpha(1, ALL_SIDES);
                llSleep(1);
                state default;
            }
        }
    }
}
