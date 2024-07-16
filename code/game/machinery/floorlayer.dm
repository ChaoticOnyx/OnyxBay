/obj/machinery/floorlayer

	name = "automatic floor layer"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pipe_d"
	density = 1
	var/turf/old_turf
	var/on = 0
	var/obj/item/stack/tile/T
	var/list/mode = list("dismantle"=0,"laying"=0,"collect"=0)

/obj/machinery/floorlayer/Initialize()
	. = ..()
	T = new /obj/item/stack/tile/floor(src)
	register_context()

/obj/machinery/floorlayer/Move(newloc, direct)
	. = ..()
	if(!.)
		return

	var/turf/new_turf
	if(isturf(loc))
		new_turf = loc

	if(on && istype(old_turf))
		if(mode["dismantle"])
			dismantleFloor(old_turf)

		if(mode["laying"])
			layFloor(old_turf)

		if(mode["collect"])
			CollectTiles(old_turf)

	if(istype(new_turf))
		old_turf = newloc

/obj/machinery/floorlayer/attack_hand(mob/user as mob)
	on=!on
	user.visible_message("<span class='notice'>[user] has [!on?"de":""]activated \the [src].</span>", "<span class='notice'>You [!on?"de":""]activate \the [src].</span>")
	return

/obj/machinery/floorlayer/add_context(list/context, obj/item/held_item, mob/user)
	. = NONE

	if(isnull(held_item))
		return

	if(isWrench(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Select mode"
		return CONTEXTUAL_SCREENTIP_SET

	if(isCrowbar(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Remove tiles"
		return CONTEXTUAL_SCREENTIP_SET

	if(isScrewdriver(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Select tile type"
		return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/floorlayer/attackby(obj/item/W as obj, mob/user as mob)

	if(isWrench(W))
		var/m = input("Choose work mode", "Mode") as null|anything in mode
		mode[m] = !mode[m]
		var/O = mode[m]
		user.visible_message("<span class='notice'>[usr] has set \the [src] [m] mode [!O?"off":"on"].</span>", "<span class='notice'>You set \the [src] [m] mode [!O?"off":"on"].</span>")
		return

	if(istype(W, /obj/item/stack/tile) && user.drop(T))
		to_chat(user, "<span class='notice'>\The [W] successfully loaded.</span>")
		TakeTile(T)
		return

	if(isCrowbar(W))
		if(!length(contents))
			to_chat(user, "<span class='notice'>\The [src] is empty.</span>")
		else
			var/obj/item/stack/tile/E = input("Choose remove tile type.", "Tiles") as null|anything in contents
			if(E)
				to_chat(user, "<span class='notice'>You remove the [E] from \the [src].</span>")
				E.dropInto(loc)
				T = null
		return

	if(isScrewdriver(W))
		T = input("Choose tile type.", "Tiles") as null|anything in contents
		return
	..()

/obj/machinery/floorlayer/examine(mob/user, infix)
	. = ..()

	var/dismantle = mode["dismantle"]
	var/laying = mode["laying"]
	var/collect = mode["collect"]

	. += SPAN_NOTICE("\The [src] [!T ? "don't " : ""]has [!T ? "" : "[T.get_amount()] [T] "]tile\s, dismantle is [dismantle ? "on" : "off"], laying is [laying ? "on" : "off"], collect is [collect?"on" : "off"].")

/obj/machinery/floorlayer/proc/reset()
	on=0
	return

/obj/machinery/floorlayer/proc/dismantleFloor(turf/new_turf)
	if(istype(new_turf, /turf/simulated/floor))
		var/turf/simulated/floor/T = new_turf
		if(!T.is_plating())
			T.make_plating(!(T.broken || T.burnt))
	return new_turf.is_plating()

/obj/machinery/floorlayer/proc/TakeNewStack()
	for(var/obj/item/stack/tile/tile in contents)
		T = tile
		return 1
	return 0

/obj/machinery/floorlayer/proc/SortStacks()
	for(var/obj/item/stack/tile/tile1 in contents)
		for(var/obj/item/stack/tile/tile2 in contents)
			tile2.transfer_to(tile1)

/obj/machinery/floorlayer/proc/layFloor(turf/w_turf)
	if(!T)
		if(!TakeNewStack())
			return 0
	w_turf.attackby(T , src)
	return 1

/obj/machinery/floorlayer/proc/TakeTile(obj/item/stack/tile/tile)
	if(!T)	T = tile
	tile.forceMove(src)

	SortStacks()

/obj/machinery/floorlayer/proc/CollectTiles(turf/w_turf)
	for(var/obj/item/stack/tile/tile in w_turf)
		TakeTile(tile)
