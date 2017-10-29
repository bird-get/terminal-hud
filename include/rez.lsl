rez(list params)
{
    vector pos;
    integer posParamIndex = llListFindList(params, ["-p"]);
    if(posParamIndex == -1)
        pos = llGetPos();
    else
        pos = (vector)llList2String(params, posParamIndex + 1);

    if(pos == ZERO_VECTOR || llVecDist(pos, llGetPos()) > 10)
    {
        textTypeAnim(1, TRUE, "error: invalid rez position");
        return;
    }

    string objectName = llList2String(params, 1);

    if(llGetInventoryType(objectName) == INVENTORY_OBJECT)
    {
        llRezObject(objectName, pos, ZERO_VECTOR, ZERO_ROTATION, 0);
        textTypeAnim(1, TRUE, "object '" + objectName + "' rezzed \n@ " + (string)pos);
    }
    else
    {
        textTypeAnim(1, TRUE, "error: inventory not found");
    }
}