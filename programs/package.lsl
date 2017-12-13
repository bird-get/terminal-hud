key rezzer;

default
{
    on_rez(integer start_param)
    {
        list details = llGetObjectDetails(llGetKey(), [OBJECT_REZZER_KEY]);
        rezzer = llList2Key(details, 0);

        llSleep(1);
        string text = "Package has been rezzed.";
        text += "You can now place items into its inventory.";
        text += "\nC to continue, Q to quit";
        llRegionSayTo(rezzer, -42, text);
    }

    changed(integer change)
    {
        llRegionSayTo(rezzer, -42, "changed");
    }
}
