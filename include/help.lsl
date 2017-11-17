#define HELP_COMMANDS 

help(string function)
{
	if(param1 == "rez")
	{
		printText("rez: rez [-g] [-p pos] [name]
			Rez an object from inventory.
			
			Options:
				-p pos	rez NAME at POS (max. 10m away from avatar)
				-g		align to grid
			
			ex: rez -p <118,123,100> test_cube");
	}
	else if(param1 == "avinfo")
	{
		printText("avinfo: avinfo [-s] [-r] [name]
			Request info about an avatar.
			
			Arguments:
				name	name of avatar
			
			Options:
				-s		get script info
				-r		get render info
			
			ex: avinfo john.doe -s -r");
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
			lsinv
			avinfo [-s] [-r] [name]
			avlist [-s] [-r]");
	}
}
