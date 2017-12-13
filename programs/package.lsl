key rezzer;

default
{
    on_rez(integer start_param)
    {
        list details = llGetObjectDetails(llGetKey(), [OBJECT_REZZER_KEY]);
        rezzer = llList2Key(details, 0);
        llListen(-42, "", rezzer, "");

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

    listen(integer channel, string name, key id, string msg)
    {
        if(msg == "quit")
        {
            llDie();
        }
    }
}
