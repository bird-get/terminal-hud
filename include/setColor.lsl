setColor(string tmp)
{
    vector c;
    if(tmp == "random") c = <llFrand(0.5) + 0.5, llFrand(0.5) + 0.5, llFrand(0.5) + 0.5>;
    else if(tmp == "black")                 c = <0.17255, 0.17255, 0.17255>;
    else if(tmp == "grey"||tmp == "gray")   c = <0.35686, 0.35686, 0.35686>;
    else if(tmp == "tan")                   c = <0.80392, 0.73333, 0.59608>;
    else if(tmp == "olive")                 c = <0.34902, 0.34510, 0.27451>;
    else if(tmp == "pink")                  c = <0.85882, 0.53333, 0.83137>;
    else if(tmp == "orange")                c = <1.0,0.5,0.0>;
    else if(tmp == "green")                 c = <0.0,0.5,0.0>;
    else if(tmp == "blue")                  c = <0.0,0.5,1.0>;
    else if(tmp == "red")                   c = <1.0,0.0,0.0>;
    else if(tmp == "yellow")                c = <1.0,1.0,0.0>;
    else if(tmp == "purple")                c = <0.5,0.0,1.0>;
    else if(tmp == "white")                 c = <1.0,1.0,1.0>;
    else
    {
        c = (vector)tmp;
        c.x = c.x / 255;
        c.y = c.y / 255;
        c.z = c.z / 255;
    }
    llSetLinkColor(LINK_SET, c, ALL_SIDES);
    textColor = c;
    llSleep(.1);
    textTypeAnim(1, TRUE, "color set to " + tmp);
}