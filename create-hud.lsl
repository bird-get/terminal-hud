// Create two prims and link them, then drop this script into it.

default
{
	state_entry()
	{
		llSetLinkPrimitiveParams(LINK_THIS, [
			PRIM_COLOR, <1,1,1>,
			PRIM_TEXTURE, ALL_SIDES, "5748decc-f629-461c-9a36-a35a221fe21f",
			<1,1,0>, <0,0,0>, 0]);
		
		// TODO set up prims and stuff
	}
}
