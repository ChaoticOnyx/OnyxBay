/obj/structure/munitions_trolley
	name = "munitions trolley"
	icon = 'icons/obj/munitions.dmi'
	icon_state = "trolley"
	desc = "A large trolley designed for ferrying munitions around. It has slots for traditional ammo magazines as well as a rack for loading torpedoes. To load it, click and drag the desired munition onto the rack."
	anchored = FALSE
	density = TRUE
	layer = 2.9
	var/static/list/allowed = typecacheof(list(
		/obj/item/ship_weapon/ammunition
	))
	var/amount = 0 //Current number of munitions we have loaded
	var/max_capacity = 6//Maximum number of munitions we can load at once
	var/loading = FALSE //stop you loading the same torp over and over

/obj/structure/munitions_trolley/Move()
	. = ..()
	if(has_gravity())
		playsound(get_turf(src), 'sound/effects/roll.ogg', 100, 1)

/obj/structure/munitions_trolley/AltClick(mob/user)
	. = ..()
	if(!in_range(src, usr))
		return

	add_fingerprint(user)
	anchored = !anchored
	to_chat(user, SPAN_NOTICE("You toggle the brakes on [src], [anchored ? "fixing it in place" : "allowing it to move freely"]."))

/obj/structure/munitions_trolley/examine(mob/user)
	. = ..()
	if(anchored)
		. += SPAN_NOTICE("\The [src]'s brakes are enabled!")

/obj/structure/munitions_trolley/Bumped(atom/movable/AM)
	. = ..()
	load_trolley(AM)

/obj/structure/munitions_trolley/MouseDrop_T(obj/structure/A, mob/user)
	. = ..()
	if(!isliving(user))
		return FALSE

	if(istype(A, /obj/item/ship_weapon/ammunition))
		var/obj/item/ship_weapon/ammunition/M = A
		if(M.no_trolley)
			return FALSE

	if(!allowed[A.type])
		return FALSE

	if(loading)
		to_chat(user, SPAN_NOTICE("Someone is already loading something onto [src]!"))
		return FALSE
	to_chat(user, SPAN_NOTICE("You start to load [A] onto [src]..."))
	loading = TRUE
	if(do_after(user,20, target = src))
		load_trolley(A, user)
		to_chat(user, SPAN_NOTICE("You load [A] onto [src]."))
	loading = FALSE
	return TRUE

/obj/structure/munitions_trolley/attackby(obj/item/A, mob/living/user, params)
	. = ..()
	if(get_dist(A, src) > 1)
		return FALSE

	if(istype(A, /obj/item/ship_weapon/ammunition))
		var/obj/item/ship_weapon/ammunition/M = A
		if(M.no_trolley)
			return FALSE

	if(!allowed[A.type])
		return FALSE

	if(loading)
		to_chat(user, SPAN_NOTICE("Someone is already loading something onto [src]!"))
		return FALSE

	to_chat(user, SPAN_NOTICE("You start to load [A] onto [src]..."))
	loading = TRUE
	if(do_after(user,20, target = src))
		load_trolley(A, user)
		to_chat(user, SPAN_NOTICE("You load [A] onto [src]."))
	loading = FALSE
	return

/obj/structure/munitions_trolley/proc/load_trolley(atom/movable/A, mob/user)
	if(istype(A, /obj/item/ship_weapon/ammunition))
		var/obj/item/ship_weapon/ammunition/M = A
		if(M.no_trolley)
			return FALSE

	if(amount >= max_capacity)
		if(user)
			to_chat(user, SPAN_WARNING("\The [src] is fully loaded!"))
		return FALSE

	if(allowed[A.type])
		playsound(src, 'sound/effects/ship/mac_load.ogg', 100, 1)
		A.forceMove(src)
		A.pixel_y = 5+(amount*5)
		vis_contents += A
		amount++
		A.layer = VEHICLE_LOAD_LAYER
		return

/obj/structure/munitions_trolley/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MunitionsTrolley")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/structure/munitions_trolley/tgui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	var/atom/movable/target = locate(params["id"]) in contents
	switch(action)
		if("unload")
			if(!target)
				return

			unload_munition(target)
		if("unload_all")
			for(var/atom/movable/AM in contents)
				unload_munition(AM)

/obj/structure/munitions_trolley/tgui_data(mob/user)
	var/list/data = list()
	var/list/loaded = list()
	for(var/atom/movable/AS in contents)
		loaded[++loaded.len] = list("name"=AS.name, "id"="\ref[AS]")
	data["loaded"] = loaded
	return data

//Calls unload_munition if necessary to adjust visuals
/obj/structure/munitions_trolley/Exited(src)
	if(src in vis_contents)
		unload_munition(src)
	. = ..()

/obj/structure/munitions_trolley/proc/unload_munition(atom/movable/A)
	//Remove from vis_contents before moving to avoid endless loop. See /obj/structure/munitions_trolley/proc/Exited for why
	vis_contents -= A
	//This is a super weird edgecase where TGUI doesn't update quickly enough in laggy situations. Prevents the shell from being unloaded when it's not supposed to.
	if(A.loc == src)
		A.forceMove(get_turf(src))
		if(usr)
			to_chat(usr, SPAN_NOTICE("You unload [A] from [src]."))
		playsound(src, 'sound/effects/ship/mac_load.ogg', 100, 1)
	A.pixel_y = initial(A.pixel_y) //Remove our offset
	A.layer = initial(A.layer)
	if(allowed[A.type]) //If a munition, allow them to load other munitions onto us.
		amount--
	if(length(contents))
		var/count = amount
		for(var/atom/movable/AM as() in contents)
			if(allowed[AM.type])
				AM.pixel_y = count*5
				count--
