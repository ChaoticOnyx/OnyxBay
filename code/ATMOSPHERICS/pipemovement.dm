obj/machinery/atmospherics/pipe/simple/relaymove(mob/user as mob,dirc)
	if(src.node1dir == dirc)
		user.loc = src.node1
	else if(src.node2dir == dirc)
		user.loc = src.node2
//obj/machinery/atmospherics/pipe/simple/verb/getin()
//	set src in view(5)
//	usr.loc = src

/obj/machinery/atmospherics/pipe/manifold/relaymove(mob/user as mob,dirc)
	if(src.node1dir == dirc)
		user.loc = src.node1
	else if(src.node2dir == dirc)
		user.loc = src.node2
	else if(src.node3dir == dirc)
		user.loc = src.node3
/obj/machinery/atmospherics/unary/relaymove(mob/user as mob,dirc)
	var/comparedir = get_dir(src,src.node)
	if(dirc == comparedir)
		user.loc = src.node

