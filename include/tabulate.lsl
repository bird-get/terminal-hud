string tabulate(list headers, list rows)
{
	// Format headers and rows of data into a nice looking table.

	// Name               | Scripts   | Memory  | Time  | Streaming cost
	// -------------------|-----------|---------|-------|--------------
	// Bridget Littlebird | 15 / 15   | 960kb   | 172μs | 175.30
	// jasecool Resident  | 320 / 325 | 20094kb | 423μs | 159.09

	integer num_of_rows = llGetListLength(rows);
	integer num_of_columns = llGetListLength(headers);

	// Add header to rows
	rows = llDumpList2String(headers, "|") + rows;

	list formatted_rows = [];
	list column_widths = [];

	// Determine the width of each column
	integer i;
	for(i=0; i < num_of_columns; i++)
	{
		integer width;
		integer ii;
		for(ii=0; ii < num_of_rows; ii++)
		{
			list row_items = llParseString2List(llList2String(rows, ii), ["|"], [""]);
			string item = llList2String(row_items, i);

			integer length = llStringLength(item);
			if(length > width)
				width = length;
		}
		column_widths += width;
	}

	// Go through each row, and fill each item to the correct width
	for(i=0; i < num_of_rows; i++)
	{
		string row = llList2String(rows, i);
		list row_items = llParseString2List(row, ["|"], [""]);
		list formatted_row_items = [];
		string formatted_row;

		// Fill items in row to correct width
		integer ii;
		for(ii=0; ii < num_of_columns; ii++)
		{
			string item = llList2String(row_items, ii);
			
			while(llStringLength(item) < llList2Integer(column_widths, ii))
			{
				item += " ";
			}
			formatted_row_items += [item];
		}
		formatted_rows += llDumpList2String(formatted_row_items, " | ");
	}

	// Add separator
	list parts;
	for(i=0; i < num_of_columns; i++)
	{
		string part;
		while(llStringLength(part) < llList2Integer(column_widths, i))
		{
			part += "-";
		}
		parts += [part];
	}
	string separator = llDumpList2String(parts, "-|-");
	formatted_rows = llListInsertList(formatted_rows, [separator], 1);

	return llDumpList2String(formatted_rows, "\n");
}
