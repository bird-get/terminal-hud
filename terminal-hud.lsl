// TODO Make commands and output more Linux-like
//		- invalid option should show usage text
//		- add option '--help' to commands
// TODO Blinking cursor: _ or █ or |
// TODO Automatically scroll down
// TODO Hide media controls
// TODO Remove Start button when started
// TODO Add non-loaded media texture (click to use)
// TODO Reset on login
// TODO Reset on URL change
// TODO Store last login time
// TODO Colorize output
// TODO Allow putting options together (i.e. -rks)
// TODO Regularly check if URL still works

// TODO inventory stuff
// 		- workshop
// 		- 3d viewport, with camera and lighting

#define DEBUG
#define TIMEOUT 60
#define VERSION "0.01"

#include "lsl-playground/snippets/debug.lsl"
#include "lsl-playground/snippets/typeTextAnim.lsl"
#include "lsl-playground/snippets/formatDecimal.lsl"
#include "terminal-hud/include/utility.lsl"
#include "terminal-hud/include/tabulate.lsl"
#include "terminal-hud/include/help.lsl"
#include "terminal-hud/include/rez.lsl"
#include "terminal-hud/include/avInfo.lsl"
#include "terminal-hud/include/avList.lsl"
#include "terminal-hud/include/long-polling-http-in.lsl"

list text_row_objects = [];
integer link_background;
list buffer = [];
integer listener;
integer hud_hidden;

// User-tweakable
integer activeChannel = 42;
integer rows = 24;
integer columns = 80;
integer line_height = 12;
integer font_size = 12;

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
		string color_ = "color:rgb(255,255,255)";
		string row = "<tr style=\"{@2}\"><td>{@1}</td></tr>";
        string msg = "e('tbd').innerHTML += '{@0}';";
		sendMessageF(msg, [row, text, color_]);
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
    m0 = "<style>";
	m0 += "body { font-family: monospace, monospace;";
	m0 += "white-space: pre; font-size:{@1}px; line-height:{@2}px;";
	m0 += "color: white; background-color: #181818;  }";
	m0 += "td:nth-child(2) { text-align:right }";
	m0 += "</style>";
    sendMessageF(msg, [m0, font_size, line_height]);

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
		llSetLinkMedia(link, face, [
			PRIM_MEDIA_WIDTH_PIXELS, 800, 
			PRIM_MEDIA_HEIGHT_PIXELS, 400,
			PRIM_MEDIA_CONTROLS, PRIM_MEDIA_CONTROLS_MINI,
			PRIM_MEDIA_PERMS_INTERACT, PRIM_MEDIA_PERM_OWNER,
			PRIM_MEDIA_PERMS_CONTROL, PRIM_MEDIA_PERM_OWNER
			]);
		llRequestURL();
		webAppInit();

		// Setup prims
		float height = .4;
		float width = height * 2; // 2:1 ratio

		llSetLinkPrimitiveParams(1, [
			PRIM_TEXT, "", <1,1,1>, 1.0,
			PRIM_SIZE, <0.01, width, 0.02>,
			PRIM_LINK_TARGET, link_background,
			PRIM_TEXT, "", <1,1,1>, 1.0,
			PRIM_POSITION, <-0.1,0,-height/2 - 0.01>,
			PRIM_SIZE, <0.01, width, height>]);
		
        listener = llListen(activeChannel, "", llGetOwner(), "");

		// Prrint starting text
		string text;
		text += "
      __
     ( ->
     / )\\\\
    <_/_/
     \" \" \n";
		text += "Last login: Mon Nov 6 03:25:56 2017\n";
		text += "Channel: " + (string)activeChannel + "\n";
		text += "Memory: " + (string)(llGetUsedMemory()/1000) + "kb / 64 kb\n";
		text += "Version: " + (string)VERSION + "\n";
		printText(text);
    }

    http_request(key id, string method, string body)
    {
        if(method == URL_REQUEST_GRANTED)
		{
            myURL = body;
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
		else if(change & CHANGED_REGION)
            llResetScript();
    }

    listen(integer channel, string name, key id, string msg)
    {
        textAnimSpeed = .02;

		string hostname = llGetEnv("simulator_hostname");
		string user = llGetUsername(llGetOwner());
		printText(user + "@" + hostname + " > " + addSlashes(msg));

        list params = llParseString2List(msg, [" "], [""]);

        string param0 = llList2String(params, 0);
        string param1 = llList2String(params, 1);
        string param2 = llList2String(params, 2);

        if(param0 == "help")
        {
			help(param1);
        }
        else if(param0 == "set")
        {
            if(param0 == "channel")
            {
                activeChannel = (integer)param1;
                printText("Channel set to " + (string)activeChannel + ".");
                llListenRemove(listener);
                listener = llListen(activeChannel, "", llGetOwner(), "");
            }
        }
		else if(param0 == "show")
		{
			// Show hud, if not already shown
			if(hud_hidden)
			{
				hud_hidden = FALSE;
				llSetPos(llGetLocalPos() + <0,0,1>);
			}
		}
		else if(param0 == "hide")
		{
			// Hide hud, if not already hidden
			if(!hud_hidden)
			{
				hud_hidden = TRUE;
				llSetPos(llGetLocalPos() - <0,0,1>);
			}
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
		else if(param0 == "avlist")
		{
			avList(params);
		}
		else if(param0 == "siminfo")
		{
			list rows;
			rows += ["agent_limit|" + llGetEnv("agent_limit")];
			rows += ["dynamic_pathfinding|" + llGetEnv("dynamic_pathfinding")];
			rows += ["estate_id|" + llGetEnv("estate_id")];
			rows += ["estate_name|" + llGetEnv("estate_name")];
			rows += ["frame_number|" + llGetEnv("frame_number")];
			rows += ["region_cpu_ratio|" + llGetEnv("region_cpu_ratio")];
			rows += ["region_idle|" + llGetEnv("region_idle")];
			rows += ["region_product_name|" + llGetEnv("region_product_name")];
			rows += ["region_product_sku|" + llGetEnv("region_product_sku")];
			rows += ["region_start_time|" + llGetEnv("region_start_time")];
			rows += ["sim_channel|" + llGetEnv("sim_channel")];
			rows += ["sim_version|" + llGetEnv("sim_version")];
			rows += ["simulator_hostname|" + llGetEnv("simulator_hostname")];
			rows += ["region_max_prims|" + llGetEnv("region_max_prims")];
			rows += ["region_object_bonus|" + llGetEnv("region_object_bonus")];

			printText("Sim information:\n ");
			list headers = ["key", "value"];
			printText(tabulate(headers, rows));
		}
		else if(param0 == "lsinv")
		{
			// List inventory
			integer inv_count = llGetInventoryNumber(INVENTORY_ALL);
			if(inv_count > 1)
			{
				integer i;
				for(i=0; i < inv_count; i++)
				{
					string inv_name = llGetInventoryName(INVENTORY_ALL, i);
					if(inv_name != llGetScriptName())
						printText(inv_name);
					// TODO print into a table
					// TODO option: print inventory permissions
					// TODO option: print inventory description
					// TODO option: print inventory key
				}
			}
			else
			{
				printText("No items in inventory.");
			}
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
