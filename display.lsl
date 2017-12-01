#include "terminal-hud/include/long-polling-http-in.lsl"

integer link_background;
integer connected;

// User-tweakable
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
        if(link_name == "background")
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
    
    // Split lines longer than 80 chars, excluding HTML tags
    for(i = 0; i < llGetListLength(long_lines); i++)
    {
        string text = llList2String(long_lines, i);
        
        // Get total length of all HTML tags
        list parsed = llParseString2List(text, [""], ["<", ">"]);
        integer length;
        integer index;
        for(index=0; index < llGetListLength(parsed); index++)
        {
            if(llList2String(parsed, index) == "<"
                && llList2String(parsed, index+2) == ">")
            {
                string tag = llList2String(parsed, index+1);
                length += llStringLength(tag) + 2;
            }
        }
        lines += splitByLength(text, columns + length);
    }

    // Print all lines
    for(i = 0; i < llGetListLength(lines); i++)
    {
        // Create table row and add to table
        string text = llList2String(lines, i);
        string row = "<tr><td>{@1}</td></tr>";
        string msg = "e('tbd').innerHTML += '{@0}'; scrollToBottom();";
        sendMessageF(msg, [row, text]);
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
    msg += "function scrollToBottom() { b().scrollTop = b().scrollHeight; };";
    sendMessage(msg);

    // Send some CSS. WebKit is sensitive about appending <style> elements
    // to <head>, so we'll append it to an existing <div> tag in <body> instead.

    msg = "e('dv').innerHTML += \"{@0}\";";
    m0 = "<style>";
    m0 += "body { font-family: monospace, monospace;";
    m0 += "white-space: pre; font-size:{@1}px; line-height:{@2}px;";
    m0 += "color: white; background-color: #181818;  }";
    m0 += "td:nth-child(2) { text-align:right }";
    m0 += ".color_0 { color:#181818; }";
    m0 += ".color_1 { color:#ab4642; }";
    m0 += ".color_2 { color:#a1b56c; }";
    m0 += ".color_3 { color:#f7ca88; }";
    m0 += ".color_4 { color:#7cafc2; }";
    m0 += ".color_5 { color:#ba8baf; }";
    m0 += ".color_6 { color:#86c1b9; }";
    m0 += ".color_7 { color:#d8d8d8; }";
    m0 += ".color_8 { color:#585858; }";
    m0 += ".color_9 { color:#ab4642; }";
    m0 += ".color_10 { color:#a1b56c; }";
    m0 += ".color_11 { color:#f7ca88; }";
    m0 += ".color_12 { color:#7cafc2; }";
    m0 += ".color_13 { color:#ba8baf; }";
    m0 += ".color_14 { color:#86c1b9; }";
    m0 += ".color_15 { color:#f8f8f8; }";
    m0 += "</style>";
    sendMessageF(msg, [m0, font_size, line_height]);

    // Write a <table> element into element div#dv. The lines of chat will
    // become rows in this table appended to tbody#tbd

    msg = "e('dv').innerHTML += \"{@0}\";";
    m0 = "<table><tbody id='tbd'></tbody></table>";
    sendMessageF(msg, [m0]);
}

clearScreen()
{
    // Remove all items from the HTML table, to clear the screen
    string msg = "e('tbd').innerHTML = [];";
    sendMessage(msg);
}

setOpacity(float opacity)
{
    llSetLinkPrimitiveParams(link_background, [
        PRIM_COLOR, ALL_SIDES, <1,1,1>, opacity]);
}

resize(float size)
{
    float height = .4 * size;
    float width = .615 * size;
    llSetLinkPrimitiveParams(1, [
        PRIM_TEXT, "", <1,1,1>, 1.0,
        PRIM_SIZE, <0.01, width, 0.02>,
        PRIM_LINK_TARGET, link_background,
        PRIM_TEXT, "", <1,1,1>, 1.0,
        PRIM_POSITION, <-0.1,0,-height/2 - 0.01>,
        PRIM_SIZE, <0.01, width, height>]);
}

integer hidden;
integer disabled;

show()
{
    if(hidden && !disabled)
    {
        hidden = FALSE;
        llSetPos(llGetLocalPos() + <0,0,1>);
    }
}

hide()
{
    if(!hidden && !disabled)
    {
        hidden = TRUE;
        llSetPos(llGetLocalPos() - <0,0,1>);
    }
}

disable()
{
    hide();
    disabled = TRUE;
}

enable()
{
    show();
    disabled = FALSE;
}

default
{
    state_entry()
    {
        scanLinks();
        llSetTimerEvent(.5);

        // Announce script start
        llMessageLinked(LINK_THIS, 2, "display started", "");

        // Setup media stuff
        link = 2;
        llClearLinkMedia(link, face);
        llSetLinkMedia(link, face, [
            PRIM_MEDIA_WIDTH_PIXELS, 600 + 15, // +15 for scrollbar
            PRIM_MEDIA_HEIGHT_PIXELS, 400,
            PRIM_MEDIA_CONTROLS, PRIM_MEDIA_CONTROLS_MINI,
            PRIM_MEDIA_PERMS_INTERACT, PRIM_MEDIA_PERM_OWNER,
            PRIM_MEDIA_PERMS_CONTROL, PRIM_MEDIA_PERM_OWNER
            ]);
        llRequestURL();
        webAppInit();
    }

    timer()
    {
        if(llGetAgentInfo(llGetOwner()) & AGENT_MOUSELOOK)
        {
            hide();
        }
        else
        {
            show();
        }
    }

    link_message(integer sender, integer num, string msg, key id)
    {
        if(num == 1)
        {
            printText(msg);
        }
        else
        {
            list params = llParseString2List(msg, [" "], [""]);
            string param0 = llList2String(params, 0);
            string param1 = llList2String(params, 1);
            
            if(msg == "clear screen")
            {
                clearScreen();
            }
            else if(param0 == "disable")
            {
                disable();
            }
            else if(param0 == "enable")
            {
                enable();
            }
            else if(param0 == "size")
            {
                resize((float)param1);
            }
            else if(param0 == "opacity")
            {
                setOpacity((float)param1);
            }
        }
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
            if(!connected)
            {
                // Connection has been established, remove the start button
                connected = TRUE;
                sendMessage("e('btn').outerHTML = \"\";delete e('btn');");
            }
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
}
