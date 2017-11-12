rez(list params)
{
    vector pos;
    integer pos_index = llListFindList(params, ["-p"]);
    if(pos_index == -1)
        pos = llGetPos();
    else
        pos = (vector)llList2String(params, pos_index + 1);

    if(pos == ZERO_VECTOR || llVecDist(pos, llGetPos()) > 10)
    {
		printText("error: invalid rez position");
        return;
    }

    string object_name = llList2String(params, 1);

    if(llGetInventoryType(object_name) == INVENTORY_OBJECT)
    {
        llRezObject(object_name, pos, ZERO_VECTOR, ZERO_ROTATION, 0);
        printText("object \\\'" + object_name + "\\\' rezzed @ " + (string)pos);
    }
    else
    {
		printText("error: inventory not found");
    }
}
