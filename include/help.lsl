#define HELP_COMMANDS 

help(string function)
{
	if(function == "rez")
	{
		printText("rez: rez [-g] [-p pos] [name]
	Rez an object from inventory.
	
	Options:
		-p pos	rez NAME at POS (max. 10m away from avatar)
		-g		align to grid
	
	ex: rez -p <118,123,100> test_cube");
	}
	else if(function == "avinfo")
	{
		printText("avinfo: avinfo [name]
	Request info about an avatar.
	
	Arguments:
		name	name of avatar
	
	ex: avinfo john.doe");
	}
	else if(function == "avlist")
	{
		printText("avlist: avlist [-s] [-r]
	Request info about all avatars in the current region.
	
	Options:
		-s		get script info
		-r		get render info");
	}
	else if(function == "lsinv")
	{
		printText("lsinv: lsinv [-k] [-p]
	List inventory.
	
	Option -p shows permissions: cmtcmtcmtge
						 	    │  │  │  ││
						  Base ──┘  │  │  ││
						  Owner ────┘  │  ││
						  Next owner ──┘  ││
						  Group share ────┘│
						  Everyone copy ───┘
	
	Options:
		-k		get inventory key
		-p		get inventory permissions");
	}
	else
	{
	    printText("Type \\\'help name\\\' for more help about function NAME.
	help [name]
	set channel [c]
	cls
	reset
	show
	hide
	rez [-p pos] [name]
	lsinv [-k] [-p]
	siminfo
	avinfo [name]
	avlist [-s] [-r]");
	}
}
