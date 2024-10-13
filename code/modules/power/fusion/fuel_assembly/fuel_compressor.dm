/obj/machinery/fusion_fuel_compressor
	name = "fuel compressor"
	icon = 'icons/obj/machines/power/fusion.dmi'
	icon_state = "fuel_compressor1"
	density = TRUE
	anchored = TRUE
	atom_flags = ATOM_FLAG_CLIMBABLE
	turf_height_offset = 23

	component_types = list(
		/obj/item/circuitboard/fusion_fuel_compressor = 1,
		/obj/item/stock_parts/manipulator/pico = 2,
		/obj/item/stock_parts/matter_bin/super = 2,
		/obj/item/stock_parts/console_screen = 1
	)

/obj/machinery/fusion_fuel_compressor/MouseDrop_T(atom/movable/target, mob/user)
	if(user.incapacitated() || !user.Adjacent(src))
		return

	if(target == user)
		. = ..()

	return do_fuel_compression(target, user)

/obj/machinery/fusion_fuel_compressor/attackby(obj/item/thing, mob/user)
	if(default_deconstruction_screwdriver(user, thing))
		return

	if(default_deconstruction_crowbar(user, thing))
		return

	if(do_fuel_compression(thing, user))
		return

	return ..()

/obj/machinery/fusion_fuel_compressor/proc/do_fuel_compression(obj/item/thing, mob/user)
	if(istype(thing) && thing.reagents && thing.reagents.total_volume && thing.is_open_container())
		if(thing.reagents.reagent_list.len > 1)
			to_chat(user, "<span class='warning'>The contents of \the [thing] are impure and cannot be used as fuel.</span>")
			return TRUE

		if(thing.reagents.total_volume < 50)
			to_chat(user, "<span class='warning'>You need at least fifty units of material to form a fuel rod.</span>")
			return TRUE

		var/datum/reagent/R = thing.reagents.reagent_list[1]
		visible_message("<span class='notice'>\The [src] compresses the contents of \the [thing] into a new fuel assembly.</span>")
		var/obj/item/fuel_assembly/F = new(get_turf(src), R.type, R.color)
		thing.reagents.remove_reagent(R.type, R.volume)
		user.pick_or_drop(F)
		return TRUE

	else if(istype(thing, /obj/machinery/power/supermatter/shard))
		var/obj/item/fuel_assembly/F = new(get_turf(src), MATERIAL_SUPERMATTER)
		visible_message("<span class='notice'>\The [src] compresses the \[thing] into a new fuel assembly.</span>")
		qdel(thing)
		user.pick_or_drop(F)
		return TRUE

	else if(istype(thing, /obj/item/stack/material))
		var/obj/item/stack/material/M = thing
		var/material/mat = M.get_material()
		if(!mat.is_fusion_fuel)
			to_chat(user, "<span class='warning'>It would be pointless to make a fuel rod out of [mat.use_name].</span>")
			return TRUE

		if(M.get_amount() < 25)
			to_chat(user, "<span class='warning'>You need at least 25 [mat.sheet_plural_name] to make a fuel rod.</span>")
			return TRUE

		var/obj/item/fuel_assembly/F = new(get_turf(src), mat.name)
		visible_message("<span class='notice'>\The [src] compresses the [mat.use_name] into a new fuel assembly.</span>")
		M.use(25)
		user.pick_or_drop(F)
		return TRUE

	return FALSE
