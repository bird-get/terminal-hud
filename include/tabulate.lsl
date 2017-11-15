string tabulate(list headers, list rows)
{
	// Format headers and rows of data into a nice looking table.
	
	string text = llDumpList2String(headers, "|") + "\n";
	
	integer i;
	integer length = llGetListLength(rows);
	for(i=0; i < length; i++)
	{
		string row_str = llList2String(rows, i);
		list row_items = llParseString2List(row_str, ["|"], []);
		text += llDumpList2String(row_items, "|") + "\n";
	}

	return text;
}

//def tabulate(words, termwidth=79, pad=3):
//    width = len(max(words, key=len)) + pad
//    ncols = max(1, termwidth // width)
//    nrows = (len(words) - 1) // ncols + 1
//    table = []
//    for i in xrange(nrows):
//        row = words[i::nrows]
//        format_str = ('%%-%ds' % width) * len(row)
//        table.append(format_str % tuple(row))
//    return '\n'.join(table)
