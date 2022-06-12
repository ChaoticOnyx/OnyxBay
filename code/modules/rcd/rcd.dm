/obj/item/rcd
	name = "rapid construction device"
	desc = "Small, portable, and far, far heavier than it looks, this gun-shaped device has a port into which one may insert compressed matter cartridges."
	description_info = "On use, this device will toggle between various types of structures (or their removal). You can examine it to see its current mode. It must be loaded with compressed matter cartridges, which can be obtained from an autolathe. Click an adjacent tile to use the device."
	description_fluff = "Advents in material printing and synthesis technology have produced everyday miracles, such as the RCD, which in certain industries has single-handedly put entire construction crews out of a job."
	description_antag = "RCDs can be incredibly dangerous in the wrong hands. Use them to swiftly block off corridors, or instantly breach the ship wherever you want."

	icon = 'icons/obj/items.dmi'
	icon_state = "rcd-e"

	opacity = 0
	density = FALSE
	anchored = FALSE
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT|SLOT_HOLSTER

	force = 10.0
	throwforce = 10.0
	throw_range = 5

	w_class = ITEM_SIZE_NORMAL
	mod_weight = 1.0
	mod_reach = 0.75
	mod_handy = 1.0

	origin_tech = list(TECH_ENGINEERING = 4, TECH_MATERIAL = 2)
	matter = list(MATERIAL_STEEL = 50000)

	var/datum/effect/effect/system/spark_spread/spark_system
	var/stored_matter = 0
	var/max_stored_matter = 30

	var/list/works = list()
	var/selected_work

	var/can_rwall = FALSE

/obj/item/rcd/Initialize()
	. = ..()

	spark_system = new /datum/effect/effect/system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	for(var/S in subtypesof(/datum/rcd_work_mode))
		var/datum/rcd_work_mode/M = new S
		works += M

		if(!selected_work)
			selected_work = M.name

/obj/item/rcd/proc/_collect_radial_choices()
	var/list/choices = list()

	for(var/datum/rcd_work_mode/W in works)
		choices[W.name] = W.preview

	return choices

/obj/item/rcd/_examine_text(user)
	. = ..()

	if(type == /obj/item/rcd && loc == user)
		. += "\nThe current mode is '[SPAN("notice", "[selected_work]")]'"
		. += "\nIt currently holds [SPAN("notice", "[stored_matter]")]/[SPAN("notice", "[max_stored_matter]")] matter-units."

/obj/item/rcd/attackby(obj/item/W, mob/user)
	update_icon()

	if(istype(W, /obj/item/rcd_ammo))
		var/obj/item/rcd_ammo/cartridge = W

		if((stored_matter + cartridge.remaining) > 30)
			to_chat(user, SPAN("notice", "The RCD can't hold that many additional matter-units."))
			return

		stored_matter += cartridge.remaining

		user.drop_from_inventory(W)
		qdel(W)

		update_icon()

		playsound(src.loc, 'sound/effects/weapons/energy/no_power1.ogg', 50, 1)
		to_chat(user, "The RCD now holds [SPAN("notice", "[stored_matter]")]/[SPAN("notice", "[max_stored_matter]")] matter-units.")

		return

	..()

/obj/item/rcd/attack_self(mob/user)
	var/list/choices = _collect_radial_choices()

	selected_work = show_radial_menu(user, src, choices, require_near = TRUE)

	if(!selected_work)
		return

	to_chat(user, "Changed mode to '[SPAN("notice", "[selected_work]")]'")
	playsound(loc, 'sound/effects/pop.ogg', 50, 0)

	if(prob(20))
		spark_system.start()

/obj/item/rcd/afterattack(atom/A, mob/user, proximity)
	if(!proximity)
		return

	if(isrobot(user))
		return FALSE

	if(istype(get_area(A), /area/shuttle) || istype(get_area(A), /turf/space/transit))
		return FALSE

	for(var/datum/rcd_work_mode/W in works)
		if(W.name == selected_work)
			W.do_work(src, A, user)
			return

/obj/item/rcd/proc/use_resource(amount, mob/user)
	if(stored_matter < amount)
		return FALSE

	stored_matter -= amount

	update_icon()

	return TRUE

/obj/item/rcd/update_icon()
	..()

	if(stored_matter > 0)
		icon_state = "rcd"
	else
		icon_state = "rcd-e"

/obj/item/rcd/Destroy()
	QDEL_LIST(works)
	QDEL_NULL(spark_system)

	. = ..()

/obj/item/rcd/borg
	can_rwall = TRUE

/obj/item/rcd/borg/use_resource(amount, mob/user)
	if(!isrobot(user))
		return FALSE

	var/mob/living/silicon/robot/R = user
	var/cost = amount * 30

	if(R.cell?.charge >= cost)
		R.cell.use(cost)

		return TRUE

	return FALSE

/obj/item/rcd/borg/attackby()
	return

/obj/item/rcd/mounted/use_resource(amount, mob/user)
	// So that a rig with default powercell can build ~2.5x the stuff a fully-loaded RCD can.
	var/cost = amount*130

	if(istype(loc, /obj/item/rig_module))

		var/obj/item/rig_module/module = loc

		if(module.holder && module.holder.cell)
			if(module.holder.cell.charge >= cost)
				module.holder.cell.use(cost)

				return TRUE
	return FALSE

/obj/item/rcd/mounted/attackby()
	return
