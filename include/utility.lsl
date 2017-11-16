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
