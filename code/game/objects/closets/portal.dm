

/obj/closet/portal/proc/activate()
	src.locked=0
	machines.Add(src)
	src.icon_opened = "portalopen"
	src.icon_closed = "portal"
	if(opened)
		src.icon_state = src.icon_opened
		src.open()
	else
		src.icon_state = src.icon_closed
		src.close()




/obj/closet/portal/proc/deactivate()
	src.locked=1
	machines.Remove(src)
	src.icon_opened = "open"
	src.icon_closed = "closet"
	if(opened)
		src.icon_state = src.icon_opened
		src.open()

	else
		src.icon_state = src.icon_closed
		src.close()


/obj/closet/portal/proc/process()
	for(var/obj/O in src.loc)
		if(O!=src)
			O.loc = target
	for(var/mob/M in src.loc)
		M.loc = target
		M<<"You step through the frame of the closet."


/obj/closet/portal/open(var/s=0)
	if(s)
		return ..()
	if(!locked)
		if(!src.link.opened)
			if(src.link.can_open())
				src.opened = 1//stop infinite loop
				src.link.open()
				src.opened = 0
				return ..()
			else
				return 0

	return ..()

/obj/closet/portal/close(var/s=0)
	if(s)
		return ..()
	if(!locked)
		if(src.link.opened)
			if(src.link.can_close())
				src.opened = 0
				src.link.close()
				src.opened = 1
				return ..()
			else
				return 0
	return ..()


/obj/closet/portal/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(findtext(/obj/item/weapon/card/id,W.type))
		if(src.check_access(W))
			if(locked)
				src.link.activate()
				src.activate()
			else
				src.link.deactivate()
				src.deactivate()
	else
		..()

/obj/closet/portal/proc/LinkUp()
	for(var/obj/closet/portal/p in world)
		if(p!=src && p.id == src.id)
			src.link=p
	for(var/obj/landmark/ptarget/p in world)
		if(p.t_id == src.t_id)
			src.target=p.loc

/obj/closet/portal/New()
	spawn(1)
		LinkUp()


