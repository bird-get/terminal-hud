// TODO Make commands and output more Linux-like
// TODO Add command to list inventory
// TODO Blinking cursor

// TODO inventory stuff
// 		- workshop
// 		- 3d viewport, with camera and lighting

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
#include "terminal-hud/include/long-polling-http-in.lsl"

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
	integer columns = 80;
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
		// Remove first item if buffer is full
		if(llGetListLength(buffer) >= rows)
			buffer = llList2List(buffer, 1, -1);
		
		string text = llList2String(lines, i);
		buffer += [text];
	
		// Send message to media
		string row = "<tr><td>{@1}</td></tr>";
        string msg = "e('tbd').innerHTML += '{@0}';";
		sendMessageF(msg, [row, addSlashes(text)]);
	}
}

webAppInit()
{
    string msg;
    string m0;

    // First, send over a few handy function definitions:

    msg = "function $$(t) { return document.getElementsByTagName(t)[0]; };";
    msg += "function h() { return $$('head'); };";
    msg += "function b() { return $$('body'); };";
    msg += "function e(id) { return document.getElementById(id); };";
    sendMessage(msg);

    // Send some CSS. WebKit is sensitive about appending <style> elements
    // to <head>, so we'll append it to an existing <div> tag in <body> instead.

    msg = "e('dv').innerHTML += \"{@0}\";";
    m0 = "<style>body { background-color:#181818 } td:nth-child(2) { text-align:right }</style>";
    sendMessageF(msg, [m0]);

    // Write a <table> element into element div#dv. The lines of chat will
    // become rows in this table appended to tbody#tbd

    msg = "e('dv').innerHTML += \"{@0}\";";
    m0 = "<table><tbody id='tbd'></tbody></table>";
    sendMessageF(msg, [m0]);
}

default
{
    state_entry()
    {
		scanLinks();
		
		// Setup media stuff
		link = 2;
		llClearLinkMedia(link, face);
		llSetLinkMedia(link, face, [PRIM_MEDIA_WIDTH_PIXELS, 400, PRIM_MEDIA_HEIGHT_PIXELS, 600]);
		llRequestURL();
		webAppInit();

		// Move and scale background
		llSetLinkPrimitiveParams(link_background, [PRIM_POSITION, <-0.1,0,-0.2>,
			PRIM_SIZE, <0.01, 0.59, 0.40>]);

		// Scale top bar to correct size
		llSetLinkPrimitiveParams(1, [PRIM_SIZE, <0.01, 0.59, 0.02>]);
		
        listener = llListen(activeChannel, "", llGetOwner(), "");
		llSetTimerEvent(0.1);

		// Prrint starting text
    	//printText("> slcmd\n----------\nchannel: " + (string)activeChannel + "\nmemory left: " +
        //	(string)llGetFreeMemory() + "kb\nversion: v" + VERSION + "\n----------");
    }

    http_request(key id, string method, string body)
    {
        if(method == URL_REQUEST_GRANTED)
		{
            myURL = body;
            llOwnerSay("myURL=" + myURL);
            setDataURI(myURL);
        }
		else if(method == "GET")
		{
            // Either send some queued messages now with llHTTPResponse(),
            // or if there's nothing to do now, save the GET id and
            // wait for somebody to call sendMessage().
            if(llGetListLength(msgQueue) > 0)
			{
                llHTTPResponse(id, 200, popQueuedMessages());
                inId = NULL_KEY;
            }
			else
			{
                inId = id;
            }
		}
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
