/obj/item/blueprints
	name = "blueprints"
	desc = "Blueprints..."
	icon = 'icons/obj/items.dmi'
	icon_state = "blueprints"
	attack_verb = list("attacked", "bapped", "hit")
	var/const/AREA_ERRNONE = 0
	var/const/AREA_STATION = 1
	var/const/AREA_SPACE =   2
	var/const/AREA_SPECIAL = 3

	var/const/BORDER_ERROR = 0
	var/const/BORDER_NONE = 1
	var/const/BORDER_BETWEEN =   2
	var/const/BORDER_2NDTILE = 3
	var/const/BORDER_SPACE = 4

	var/const/ROOM_ERR_LOLWAT = 0
	var/const/ROOM_ERR_SPACE = -1
	var/const/ROOM_ERR_TOOLARGE = -2

/obj/item/blueprints/Initialize()
	. = ..()
	desc = "Blueprints of the [station_name()]. There is a \"Classified\" stamp and several coffee stains on it."

/obj/item/blueprints/attack_self(mob/M)
	if(!ishuman(M))
		to_chat(M, SPAN("warning", "This stack of blue paper means nothing to you."))//monkeys cannot into projecting
		return
	add_fingerprint(M)
	interact(M)

/obj/item/blueprints/Topic(href, href_list)
	if((. = ..()))
		return
	if((usr.restrained() || usr.stat))
		return
	if(!usr.is_item_in_hands(src))
		to_chat(usr, SPAN("warning", "You need to hold \the [src] in your hands!"))
		return
	switch(href_list["action"])
		if("create_area")
			if(get_area_type() != AREA_SPACE)
				interact(usr)
				return
			create_area(usr)
		if("edit_area")
			if(get_area_type() != AREA_STATION)
				interact(usr)
				return
			edit_area(usr)
		if("delete_area")
			//skip the sanity checking, delete_area() does it anyway
			delete_area(usr)

/obj/item/blueprints/interact(mob/user)
	var/area/A = get_area()
	var/text = {"<HTML><meta charset=\"utf-8\"><head><title>[src]</title></head><BODY>
<h2>[station_name()] blueprints</h2>
<small>Property of [GLOB.using_map.company_name]. For heads of staff only. Store in high-secure storage.</small><hr>
"}
	switch (get_area_type())
		if(AREA_SPACE)
			text += {"
<p>According the blueprints, you are now in <b>outer space</b>.  Hold your breath.</p>
<p><a href='?src=\ref[src];action=create_area'>Mark this place as new area.</a></p>
"}
		if(AREA_STATION)
			if(A.apc)
				text += {"
<p>According the blueprints, you are now in <b>\"[A.name]\"</b>.</p>
<p>You may <a href='?src=\ref[src];action=edit_area'>
move an amendment</a> to the drawing.</p>
<p>You can't erase this area, because it has an APC.</p>
"}
			else
				text += {"
<p>According the blueprints, you are now in <b>\"[A.name]\"</b>.</p>
<p>You may <a href='?src=\ref[src];action=edit_area'>
move an amendment</a> to the drawing, or <a href='?src=\ref[src];action=delete_area'>erase part of it</a>.</p>
"}
		if(AREA_SPECIAL)
			text += {"
<p>This place isn't noted on the blueprint.</p>
"}
		else
			return
	text += "</BODY></HTML>"
	show_browser(user, text, "window=blueprints")
	onclose(user, "blueprints")


/obj/item/blueprints/proc/get_area()
	var/turf/T = get_turf(usr)
	var/area/A = T.loc
	return A

/obj/item/blueprints/proc/get_area_type(area/A = get_area())
	if(istype(A, /area/space))
		return AREA_SPACE

	var/list/SPECIALS = list(/area/shuttle)

	if(is_type_in_list(A, SPECIALS))
		return AREA_SPECIAL

	if(A.z in GLOB.using_map.station_levels)
		return AREA_STATION

	return AREA_SPECIAL

/obj/item/blueprints/proc/create_area(mob/user)
	if(!user)
		return
	var/res = detect_room(get_turf(usr))
	if(!istype(res,/list))
		switch(res)
			if(ROOM_ERR_SPACE)
				to_chat(user, SPAN("warning", "The new area must be completely airtight!"))
				return
			if(ROOM_ERR_TOOLARGE)
				to_chat(user, SPAN("warning", "The new area too large!"))
				return
			else
				to_chat(user, SPAN("warning", "Error! Please notify administration!"))
				return
	var/list/turf/turfs = res
	var/str = sanitizeSafe(input(user, "New area name:","Blueprint Editing", ""), MAX_NAME_LEN)
	if(!str || !length(str))
		return
	if(length(str) > 50)
		to_chat(user, SPAN("warning", "Name too long."))
		return
	var/area/A = new
	A.SetName(str)
	A.power_equip = 0
	A.power_light = 0
	A.power_environ = 0
	A.always_unpowered = 0
	move_turfs_to_area(turfs, A)

	A.always_unpowered = 0

	addtimer(CALLBACK(src, .proc/interact), 10)

/obj/item/blueprints/proc/move_turfs_to_area(list/turf/turfs, area/A)
	A.contents.Add(turfs)
		//oldarea.contents.Remove(usr.loc) // not needed
		//T.loc = A //error: cannot change constant value

/obj/item/blueprints/proc/edit_area(mob/user)
	if(!user)
		return
	var/area/A = get_area()
//	log_debug(edit_area")

	var/prevname = "[A.name]"
	var/str = sanitizeSafe(input("New area name:","Blueprint Editing", prevname), MAX_NAME_LEN)
	if(!str || !length(str) || str==prevname) //cancel
		return
	if(length(str) > 50)
		to_chat(usr, SPAN("warning", "Text too long."))
		return
	set_area_machinery_title(A,str,prevname)
	A.SetName(str)
	to_chat(usr, SPAN("notice", "You set the area '[prevname]' title to '[str]'."))
	interact()
	return

/obj/item/blueprints/proc/delete_area(mob/user)
	if(!user)
		return
	var/area/A = get_area()
	if(get_area_type(A) != AREA_STATION || A.apc) //let's just check this one last time, just in case
		interact()
		return
	to_chat(user, SPAN("notice", "You instructed nano-machines to remove [A.name] from the blueprint. You just have to wait."))
	log_and_message_admins("deleted area [A.name] via station blueprints.")
	qdel(A)
	interact(user)

/obj/item/blueprints/proc/set_area_machinery_title(area/A,title,oldtitle)
	if(!oldtitle) // or replacetext goes to infinite loop
		return

	for(var/obj/machinery/alarm/M in A)
		M.SetName(replacetext(M.name,oldtitle,title))
	for(var/obj/machinery/power/apc/M in A)
		M.SetName(replacetext(M.name,oldtitle,title))
	for(var/obj/machinery/atmospherics/unary/vent_scrubber/M in A)
		M.SetName(replacetext(M.name,oldtitle,title))
	for(var/obj/machinery/atmospherics/unary/vent_pump/M in A)
		M.SetName(replacetext(M.name,oldtitle,title))
	for(var/obj/machinery/door/M in A)
		M.SetName(replacetext(M.name,oldtitle,title))
	//TODO: much much more. Unnamed airlocks, cameras, etc.

/obj/item/blueprints/proc/check_tile_is_border(turf/T2, dir)
	if(istype(T2, /turf/space))
		return BORDER_SPACE //omg hull breach we all going to die here
	if(istype(T2, /turf/simulated/shuttle))
		return BORDER_SPACE
	if(get_area_type(T2.loc)!=AREA_SPACE)
		return BORDER_BETWEEN
	if(istype(T2, /turf/simulated/wall))
		return BORDER_2NDTILE
	if(!istype(T2, /turf/simulated))
		return BORDER_BETWEEN

	for (var/obj/structure/window/W in T2)
		if(turn(dir,180) == W.dir)
			return BORDER_BETWEEN
		if(W.dir in list(NORTHEAST,SOUTHEAST,NORTHWEST,SOUTHWEST))
			return BORDER_2NDTILE
	for(var/obj/machinery/door/window/D in T2)
		if(turn(dir,180) == D.dir)
			return BORDER_BETWEEN
	if(locate(/obj/machinery/door) in T2)
		return BORDER_2NDTILE

	return BORDER_NONE

/obj/item/blueprints/proc/detect_room(turf/first)
	var/list/turf/found = new
	var/list/turf/pending = list(first)
	while(pending.len)
		if(found.len+pending.len > 300)
			return ROOM_ERR_TOOLARGE
		var/turf/T = pending[1] //why byond havent list::pop()?
		pending -= T
		for (var/dir in GLOB.cardinal)
			var/skip = 0
			for (var/obj/structure/window/W in T)
				if(dir == W.dir || (W.dir in list(NORTHEAST,SOUTHEAST,NORTHWEST,SOUTHWEST)))
					skip = 1; break
			if(skip)
				continue
			for(var/obj/machinery/door/window/D in T)
				if(dir == D.dir)
					skip = 1; break
			if(skip)
				continue

			var/turf/NT = get_step(T,dir)
			if(!isturf(NT) || (NT in found) || (NT in pending))
				continue

			switch(check_tile_is_border(NT,dir))
				if(BORDER_NONE)
					pending+=NT
				if(BORDER_BETWEEN)
					//do nothing, may be later i'll add 'rejected' list as optimization
				if(BORDER_2NDTILE)
					found+=NT //tile included to new area, but we dont seek more
				if(BORDER_SPACE)
					return ROOM_ERR_SPACE
		found+=T
	return found
