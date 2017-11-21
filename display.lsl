// TODO Blinking cursor: _ or █ or |
// TODO Hide media controls
// TODO Add non-loaded media texture (click to use)
// TODO Attempt to get rid of Start button (make it fill entire screen?)
// TODO Automatically scroll down
// TODO Regularly check if URL still works
// TODO Colorize output (split strings AFTER processing color escape characters)
// TODO Catch all input on media prim, print to last row in table, submit on enter

#include "terminal-hud/include/long-polling-http-in.lsl"

integer link_background;
list buffer = [];
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

clearScreen()
{
    string msg = "e('tbd').innerHTML = [];";
    sendMessage(msg);
}

default
{
    state_entry()
    {
        scanLinks();
        
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

        // Setup prims
        float height = .4;
        float width = .615;

        llSetLinkPrimitiveParams(1, [
            PRIM_TEXT, "", <1,1,1>, 1.0,
            PRIM_SIZE, <0.01, width, 0.02>,
            PRIM_LINK_TARGET, link_background,
            PRIM_TEXT, "", <1,1,1>, 1.0,
            PRIM_POSITION, <-0.1,0,-height/2 - 0.01>,
            PRIM_SIZE, <0.01, width, height>]);
    }

    link_message(integer sender, integer num, string msg, key id)
    {
        if(num == 1)
        {
            printText(msg);
        }
        else
        {
            if(msg == "clear screen")
            {
                clearScreen();
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
