string getDetailString(key id, integer detail)
{
    list details = llGetObjectDetails(id, [detail]);
    return llList2String(details, 0);
}

objectDetails(list params)
{
    key id = llList2Key(params, 1);
    list rows;

    // Generic object info
    rows += ["OBJECT_NAME|" + getDetailString(id, 1)];
    rows += ["OBJECT_DESC|" + getDetailString(id, 2)];
    rows += ["OBJECT_POS|" + getDetailString(id, 3)];
    rows += ["OBJECT_ROT|" + getDetailString(id, 4)];
    rows += ["OBJECT_VELOCITY|" + getDetailString(id, 5)];
    rows += ["OBJECT_PHYSICS|" + getDetailString(id, 21)];
    rows += ["OBJECT_PHANTOM|" + getDetailString(id, 22)];
    rows += ["OBJECT_TEMP_ON_REZ|" + getDetailString(id, 23)];
    rows += ["OBJECT_PRIM_COUNT|" + getDetailString(id, 30)];
    rows += ["OBJECT_OWNER|" + getDetailString(id, 6)];
    rows += ["OBJECT_GROUP|" + getDetailString(id, 7)];
    rows += ["OBJECT_CREATOR|" + getDetailString(id, 8)];
    rows += ["OBJECT_ROOT|" + getDetailString(id, 18)];
    rows += ["OBJECT_REZZER_KEY|" + getDetailString(id, 32)];
    rows += ["OBJECT_LAST_OWNER_ID|" + getDetailString(id, 27)];
    rows += ["OBJECT_CLICK_ACTION|" + getDetailString(id, 28)];
    rows += ["OBJECT_TOTAL_INVENTORY_COUNT|" + getDetailString(id, 31)];
    rows += ["OBJECT_OMEGA|" + getDetailString(id, 29)];
    rows += ["OBJECT_SELECT_COUNT|" + getDetailString(id, 37)];
    rows += ["OBJECT_CREATION_TIME|" + getDetailString(id, 36)];
    rows += ["OBJECT_SIT_COUNT|" + getDetailString(id, 38)];
    
    // Script info
    rows += ["OBJECT_RUNNING_SCRIPT_COUNT|" + getDetailString(id, 9)];
    rows += ["OBJECT_TOTAL_SCRIPT_COUNT|" + getDetailString(id, 10)];
    rows += ["OBJECT_SCRIPT_MEMORY|" + getDetailString(id, 11)];
    rows += ["OBJECT_SCRIPT_TIME|" + getDetailString(id, 12)];
    
    // Server cost info
    rows += ["OBJECT_PRIM_EQUIVALENCE|" + getDetailString(id, 13)];
    rows += ["OBJECT_SERVER_COST|" + getDetailString(id, 14)];
    rows += ["OBJECT_STREAMING_COST|" + getDetailString(id, 15)];
    rows += ["OBJECT_PHYSICS_COST|" + getDetailString(id, 16)];
    
    // Attachment
    rows += ["OBJECT_ATTACHED_POINT|" + getDetailString(id, 19)];
    rows += ["OBJECT_TEMP_ATTACHED|" + getDetailString(id, 34)];
    
    // Pathfinding
    rows += ["OBJECT_PATHFINDING_TYPE|" + getDetailString(id, 20)];
    rows += ["OBJECT_CHARACTER_TIME|" + getDetailString(id, 17)];
    
    // Avatar
    rows += ["OBJECT_RENDER_WEIGHT|" + getDetailString(id, 24)];
    rows += ["OBJECT_HOVER_HEIGHT|" + getDetailString(id, 25)];
    rows += ["OBJECT_BODY_SHAPE_TYPE|" + getDetailString(id, 26)];
    rows += ["OBJECT_ATTACHED_SLOTS_AVAILABLE|" + getDetailString(id, 35)];
    rows += ["OBJECT_GROUP_TAG|" + getDetailString(id, 33)];

    list headers = ["key", "value"];
    printText(tabulate(headers, rows));

    exit(0);
}
