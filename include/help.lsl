#define HELP_COMMANDS 

help(string function)
{
    if(function == "rez")
    {
        printText("usage: rez [-g] [-p POS] name
 
Rez an object from inventory.
 
positional arguments:
  name          object name
 
optional arguments:
  -p POS        rez NAME at POS (max. 10m away from avatar)
  -g            align to grid
  -h, --help    show help and exit
 
ex: rez -p <118,123,100> test_cube");
    }
    else if(function == "avinfo")
    {
        printText("usage: avinfo [-h] name
 
Request info about avatar NAME.
 
positional arguments:
  name          name of avatar
 
optional arguments:
  -h, --help    show help and exit
 
ex: avinfo john.doe");
    }
    else if(function == "avlist")
    {
        printText("usage: avlist [-h] [-s] [-r]
 
Request info about all avatars in the current region.
 
optional arguments:
  -s            get script info
  -r            get render info
  -h, --help    show help and exit");
    }
    else if(function == "avattached")
    {
        printText("usage: avattached [name] [-c] [-d] [-i] [-k] [-p] [-r] [-s] [-t]
 
Request info about avatar NAME\\'s publicly visible attachments.
 
positional arguments:
  name          name of avatar
 
optional arguments:
  -c            get creator key
  -d            get object description
  -i            get inventory count
  -k            get object key
  -p            get attachment point
  -r            get render info
  -s            get script info
  -t            get temp attachment");
    }
    else if(function == "lsinv")
    {
        printText("usage: lsinv [-k] [-p]
 
List inventory.
Option -p shows permissions: cmtcmtcmtge
                            │  │  │  ││
                      Base ──┘  │  │  ││
                      Owner ────┘  │  ││
                      Next owner ──┘  ││
                      Group share ────┘│
                      Everyone copy ───┘
 
optional arguments:
  -k            get inventory key
  -p            get inventory permissions
  -h, --help    show help and exit");
    }
    else if(function == "reset")
    {
        printText("usage: reset [-a]
 
Reset the display.
 
optional arguments:
  -a            reset all, scripts");
    }
    else
    {
        printText("Type \\\'help name\\\' for more help about function NAME.
    help [name]
    set channel [channel]
    set opacity [opacity]
    set size [size]
    cls
    reset [-a]
    enable
    disable
    rez [-p pos] [name]
    lsinv [-k] [-p]
    siminfo
    details [key]
    avinfo [name]
    avattached [name] [-c] [-d] [-i] [-k] [-p] [-r] [-s] [-t]
    avlist [-s] [-r]
    colortest");
    }
}
