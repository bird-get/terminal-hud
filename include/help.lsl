#define HELP_COMMANDS 

help(string function)
{
    if(function == "reset")
    {
        printText("usage: reset [-a] [-i] [-d]
 
Reset scripts inside inventory.
 
optional arguments:
  -a            reset all scripts
  -i            reset interpreter
  -d            reset display", TRUE);
    }
    else if(function == "echo")
    {
        printText("usage: echo [arg ...]
 
Write arguments to output.", TRUE);
    }
    else
    {
        printText("These commands are defined internally.
Type \\\'help name\\\' for more help about function NAME.
    help [name]
    set channel [channel]
    set opacity [opacity]
    set size [size]
    set vocal [true|false]
    cls
    echo [arg ...]
    reset [-a] [-i] [-d]
    enable
    disable
    
The following commands are defined by base-programs.lsl.
    rez [-h] [-p pos] [name]
    lsinv [-h] [-k] [-p]
    siminfo
    details [key]
    avinfo [name] [-h]
    avattached [name] [-h] [-c] [-d] [-i] [-k] [-p] [-r] [-s] [-t]
    avlist [-h] [-s] [-r]
    colortest", TRUE);
    }
}
