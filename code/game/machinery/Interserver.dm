/obj/machinery/computer/teleporter/interserver/attack_hand()
	if(stat & (NOPOWER|BROKEN))
		return
	var/address = input("Enter address") as text
	var/response = world.Export(address+"#teleping")
	if(!response)
		for(var/mob/O in hearers(src, null))
			O.show_message("\red Error, server unreachable", 2)
		return 0
	else if(response == 2)
		for(var/mob/O in hearers(src, null))
			O.show_message("\red Error, server round has not started", 2)
		return 0
	src.addr = address
	src.add_fingerprint(usr)
	return

/obj/machinery/teleport/hub/interserver/teleport(atom/movable/M as mob|obj)
	var/atom/l = src.loc
	var/obj/machinery/computer/teleporter/interserver/com = locate(/obj/machinery/computer/teleporter, locate(l.x - 2, l.y, l.z))
	if (!com)
		return
	if (!com.addr)
		for(var/mob/O in hearers(src, null))
			O.show_message("\red Failure: Cannot authenticate locked on coordinates. Please reinstantiate coordinate matrix.")
		return
	if (teleing == 1)
		for(var/mob/O in hearers(src, null))
			O.show_message("\red Failure: Teleport in progress")
		return
	if (istype(M, /mob))
		var/savefile/F = new()
		F["s_x"] << M.x
		F["s_y"] << M.y
		F["s_z"] << M.z
		F["mob"] << M
		teleing = 1
		if(!world.Export(com.addr+"#teleplayer",F))
			teleing = 0
			usr << "Cannot contact server"
			return
		var doonce = 1
		usr << "Teleporting, please be patient, if for some reason you are not automatically redirected to " + com.addr + " please join it manually."
		spawn while(doonce)
			usr << link(com.addr)
			sleep(1)
			del M
			teleing = 0
			doonce = 0
	else
		for(var/mob/O in hearers(src, null))
			O.show_message("\red Failure: Object has no life sign.")
		return
	return

