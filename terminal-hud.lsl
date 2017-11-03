// TODO Make commands and output more Linux-like
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
integer rows = 24;
list buffer = [];

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

printText(string raw_text)
{
	integer columns = 30;
	integer i;
	list lines;

	// Split raw_text at newline characters
    list long_lines = llParseString2List(raw_text, ["\n"], [""]);
    
	// Split lines longer than 80 chars
	for(i = 0; i < llGetListLength(long_lines); i++)
	{
		string text = llList2String(long_lines, i);
		lines += splitByLength(text, columns);
	}

	// Add lines to buffer
	for(i = 0; i < llGetListLength(lines); i++)
	{
		if(llGetListLength(buffer) >= rows)
			buffer = llList2List(buffer, 1, -1); // Remove first item
		
		string text = llList2String(lines, i);
		buffer += [text];
		refresh();
	}
}

refresh()
{
	// Refresh all lines
	
	list prim_params = [];

	integer i;
	for(i = 0; i < rows; i++)
	{
		string text = llList2String(buffer, i);
		integer ii;
		integer length = llStringLength(text);
		list chars_by_length = ["IJ.,;:'ijl|", "[]()-\\/frt ", "\"!", "?_*`cskFLP", "EKRYT{}abnopquvxyzdgh", "ABCHNSUVXZe", "DGMOQw^&=+~<>", "m%W", "@"];
		string chars = 
		"IJ.,;:'ijl|[]()-\\/frt \"!?_*`cskFLPEKRYT{}abnopquvxyzdghABCHNSUVXZeDGMOQw^&=+~<>m%W@";
	
		// Calculate approximate line length
		float line_length;
		for(ii = 0; ii < length; ii++)
		{
			// TODO optimize
			string char = llGetSubString(text, ii, ii);
			integer index = llSubStringIndex(chars, char);
			
			if(index == -1) line_length += 0; // TODO error, char length not known
			else if(index < 11) line_length += .0044;
			else if(index < 22) line_length += .0039;
			else if(index < 24) line_length += .0034;
			else if(index < 34) line_length += .0024;
			else if(index < 55) line_length += .0019;
			else if(index < 66) line_length += .0014;
			else if(index < 79) line_length += .0005;
			else if(index < 82) line_length += .0051;
		}
		text += " " + (string)line_length;
		
		// Update prim parameters
		float offset = line_length;

		integer link_num = llList2Integer(text_row_objects, i);
		prim_params += [PRIM_LINK_TARGET, link_num, PRIM_TEXT, text, <1,1,1>, 0.9,
		PRIM_POSITION, <0, -offset,-.05 - 0.015*i>];
	}
	
	llSetLinkPrimitiveParamsFast(LINK_THIS, prim_params);

	//llSetLinkPrimitiveParamsFast(link_num, [PRIM_TEXT, text, <1,1,1>, 0.9,
	//	PRIM_POSITION, <0, -offset,-.05 - 0.015*i>]);
}

default
{
    state_entry()
    {
		llSetLinkPrimitiveParamsFast(LINK_SET, [PRIM_TEXT, "", <1,1,1>, 1.0]);
		scanLinks();
		
		integer i;

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

		// Prrint starting text
    	printText("> slcmd\n----------\nchannel: " + (string)activeChannel + "\nmemory left: " +
        	(string)llGetFreeMemory() + "kb\nversion: v" + VERSION + "\n----------");
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
