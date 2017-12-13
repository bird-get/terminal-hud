key rezzer;

default
{
    on_rez(integer start_param)
    {
        list details = llGetObjectDetails(llGetKey(), [OBJECT_REZZER_KEY]);
        rezzer = llList2Key(details, 0);
        llRegionSayTo(rezzer, -42, "rezzed");
    }

    changed(integer change)
    {
        llRegionSayTo(rezzer, -42, "changed");
    }
}
