list autocomplete(string text, list items)
{
    // Find and return autocompletions for text in items
    integer length = llGetListLength(items);
    list completions = [];
    integer i;
    for(i=0; i < length; i++)
    {
        string item = llList2String(items, i);
        integer index = llSubStringIndex(item, text);
        if(index == 0)
            completions += item;
    }

    return completions;
}

string formatDecimal(float number, integer precision)
{
    float roundingValue = llPow(10, -precision) * .5;
    float rounded;
    if (number < 0) rounded = number - roundingValue;
    else rounded = number + roundingValue;

    if(precision < 1) // Rounding integer value
    {
        integer intRounding = (integer)llPow(10, -precision);
        rounded = (integer)rounded / intRounding * intRounding;
        precision = -1; // Don't truncate integer value
    }

    string strNumber = (string)rounded;
    return llGetSubString(strNumber, 0, llSubStringIndex(strNumber, ".") + precision);
}

string removeTags(string str)
{
    // Takes a string, and returns it with all HTML tags removed.
    list parsed = llParseString2List(str, [""], ["<", ">"]);
    integer index;
    for(index=0; index < llGetListLength(parsed); index++)
    {
        if(llList2String(parsed, index) == "<"
            && llList2String(parsed, index+2) == ">")
        {
            parsed = llListReplaceList(parsed, ["", "", ""], index, index+2);
        }
    }
    return llDumpList2String(parsed, "");
}

float max(float x, float y)
{
    if( y > x ) return y;
    return x;
}

float min(float x, float y)
{
    if( y < x ) return y;
    return x;
}
