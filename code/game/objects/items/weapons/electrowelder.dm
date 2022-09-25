/obj/item/weldingtool/electrowelder
	name = "electronic welding tool"
	desc = ""
	icon = 'icons/obj/tools.dmi'
	icon_state = "exwelder"
	item_state = "exwelder"
	item_flags = ITEM_FLAG_IS_BELT
	tank = null
	matter = list(MATERIAL_STEEL = 50, MATERIAL_GLASS = 50)
	origin_tech = list(TECH_ENGINEERING = 4, TECH_POWER = 3)
	var/obj/item/cell/cell = null

/obj/item/weldingtool/electrowelder/Initialize()
	cell = new(src)
	. = ..()

/obj/item/weldingtool/electrowelder/Destroy()
	QDEL_NULL(cell)
	return ..()

/obj/item/weldingtool/electrowelder/proc/add_cell(mob/user, obj/item/cell/C)
	if(cell)
		to_chat(user, SPAN("warning", "\The [cell] is already attached to [src]!"))
		return
	user.remove_from_mob(C)
	cell = C
	C.forceMove(src)
	to_chat(user, SPAN("notice", "You attach \the [cell] to \the [src]."))
	update_icon()

/obj/item/weldingtool/electrowelder/proc/remove_cell(mob/user)
	if(!cell)
		to_chat(user, SPAN("warning", "There is no cell attached!"))
		return
	var/turf/location = get_turf(loc)
	cell.forceMove(location)
	cell = null
	to_chat(user, SPAN("notice", "You deattach \the [cell] from \the [src]."))
	update_icon()

/obj/item/weldingtool/electrowelder/attackby(obj/item/I, mob/user)
	if(welding)
		return
	if(isScrewdriver(I))
		remove_cell(user)
		return
	if(istype(I, /obj/item/pipe))
		return
	if(istype(I, /obj/item/welder_tank))
		to_chat(user, SPAN("warning", "\The [src] does not support regular fuel tanks!"))
		return
	if(istype(I, /obj/item/cell))
		add_cell(user, I)
		return
	..()

/obj/item/weldingtool/electrowelder/gen_desc()
	var/desc_text
	if(cell)
		desc_text += SPAN("notice", "\The [src] charge is: [get_fuel()]/[get_max_fuel()]")
	else
		desc_text += SPAN_WARNING("\nThere is no cell attached.")
	return desc_text

/obj/item/weldingtool/electrowelder/update_icon()
	overlays.Cut()
	item_state = "[initial(icon_state)]"
	if(welding)
		overlays += "exwelder-on"
		item_state = "[initial(icon_state)]-on"
	if(cell)
		if(cell.charge > 0)
			overlays += "charge[ceil(cell.charge / (cell.maxcharge / 3))]"
		else
			overlays += "charge0"

/obj/item/weldingtool/electrowelder/get_fuel()
	return cell ? cell.charge : 0

/obj/item/weldingtool/electrowelder/get_max_fuel()
	return cell ? cell.maxcharge : 0

/obj/item/weldingtool/electrowelder/remove_fuel(amount = 1, mob/M = null)
	if(!welding)
		return FALSE
	if(get_fuel() >= amount)
		burn_fuel(amount)
		if(M)
			eyecheck(M)
			playsound(M.loc, 'sound/items/Welder.ogg', 20, 1)
		return TRUE
	else
		if(M)
			to_chat(M, SPAN("notice", "You need more fuel to complete this task."))
		return FALSE

/obj/item/weldingtool/electrowelder/burn_fuel(amount)
	if(!cell)
		return
	var/mob/living/in_mob = null
	if(isliving(src.loc))
		var/mob/living/L = src.loc
		if(!(L.l_hand == src || L.r_hand == src))
			in_mob = L
	if(in_mob)
		amount = max(amount, 2)
		cell.use(amount)
		in_mob.IgniteMob()
	else
		cell.use(amount)
		var/turf/location = get_turf(loc)
		if(location)
			location.hotspot_expose(700, 5)

/obj/item/weldingtool/electrowelder/refuel_from_obj(obj/O, mob/user)
	return

/obj/item/weldingtool/electrowelder/sindi
	icon_state = "exwelder_sindi"
	origin_tech = list(TECH_ENGINEERING = 4, TECH_POWER = 3, TECH_ILLEGAL = 2)
