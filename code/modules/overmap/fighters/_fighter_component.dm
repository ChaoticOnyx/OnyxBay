/obj/item/fighter_component
	name = "fighter component"
	desc = "It doesn't really do a whole lot"
	icon = 'icons/obj/fighter_components.dmi'
	w_class = ITEM_SIZE_GARGANTUAN
	//Thanks to comxy on Discord for these lovely tiered sprites o7
	/// used for multipliers
	var/tier = 1
	/// Change me!
	var/slot = null
	/// Some more advanced modules will weigh your fighter down some.
	var/weight = 0
	/// Does this module require power to process()?
	var/power_usage = 0
	/// Used if this is a weapon style hardpoint
	var/fire_mode = null
	var/active = FALSE
	var/integrity = 50
	var/max_integrity = 0

/obj/item/fighter_component/examine(mob/user, infix)
	. = ..()
	. += SPAN_NOTICE("Alt-click it to unload its contents.")

/obj/item/fighter_component/proc/toggle()
	active = !active

/obj/item/fighter_component/proc/dump_contents()
	if(!length(contents))
		return FALSE

	. = list()
	for(var/atom/movable/AM in contents)
		AM.forceMove(get_turf(loc))
		. += AM

/obj/item/fighter_component/proc/get_ammo()
	return FALSE

/obj/item/fighter_component/proc/get_max_ammo()
	return FALSE

/// Overload this method to apply stat benefits based on your module.
/obj/item/fighter_component/proc/on_install(obj/structure/overmap/target)
	forceMove(target)
	apply_drag(target)
	playsound(target, 'sound/effects/ship/mac_load.ogg', 100, 1)
	target.visible_message(SPAN_WARNING("[src] mounts onto [target]"))
	return TRUE

/// Allows you to jumpstart a fighter with an inducer.
/obj/structure/overmap/small_craft/proc/get_cell()
	return loadout.get_slot(HARDPOINT_SLOT_BATTERY)

/obj/item/fighter_component/proc/power_tick()
	var/obj/structure/overmap/small_craft/F = loc
	if(!istype(F) || !active)
		return FALSE

	var/obj/item/fighter_component/battery/B = F.loadout.get_slot(HARDPOINT_SLOT_BATTERY)
	return B?.use_power(power_usage)

/obj/item/fighter_component/think()
	return power_tick()

//Used for weapon style hardpoints
/obj/item/fighter_component/proc/fire(obj/structure/overmap/target)
	return FALSE

/// If you need your hardpoint to be loaded with things by clicking the fighter
/obj/item/fighter_component/proc/load(obj/structure/overmap/target, atom/movable/AM)
	return FALSE

/obj/item/fighter_component/proc/apply_drag(obj/structure/overmap/target)
	if(!weight)
		return FALSE

	target.speed_limit -= weight
	target.speed_limit = (target.speed_limit > 0) ? target.speed_limit : 0
	target.forward_maxthrust -= weight
	target.forward_maxthrust = (target.forward_maxthrust > 0) ? target.forward_maxthrust : 0
	target.backward_maxthrust -= weight
	target.backward_maxthrust = (target.backward_maxthrust > 0) ? target.backward_maxthrust : 0
	target.side_maxthrust -= 0.25 * weight
	target.side_maxthrust = (target.side_maxthrust > 0) ? target.side_maxthrust : 0
	target.max_angular_acceleration -= weight * 10
	target.max_angular_acceleration = (target.max_angular_acceleration > 0) ? target.max_angular_acceleration : 0

/obj/item/fighter_component/proc/remove_from(obj/structure/overmap/target, due_to_damage)
	forceMove(get_turf(target))
	if(!weight)
		return TRUE

	for(var/atom/movable/AM in contents)
		AM.forceMove(get_turf(target))
	target.speed_limit += weight
	target.forward_maxthrust += weight
	target.backward_maxthrust += weight
	target.side_maxthrust += 0.25 * weight
	target.max_angular_acceleration += weight * 10
	return TRUE

/obj/structure/overmap/small_craft/proc/set_master_caution(state)
	var/master_caution_switch = state
	if(master_caution_switch)
		relay('sound/effects/fighters/master_caution.ogg', null, loop = TRUE, channel = SOUND_CHANNEL_IMP_SHIP_ALERT)
		master_caution = TRUE
	else
		stop_relay(SOUND_CHANNEL_IMP_SHIP_ALERT)
		master_caution = FALSE

/obj/structure/overmap/small_craft/proc/get_fuel()
	var/obj/item/fighter_component/fuel_tank/ft = loadout.get_slot(HARDPOINT_SLOT_FUEL)
	var/datum/reagent/cryogenic_fuel/F = locate() in ft?.reagents.reagent_list
	return F ? F.volume : 0

/obj/structure/overmap/small_craft/proc/set_fuel(amount)
	var/obj/item/fighter_component/fuel_tank/ft = loadout.get_slot(HARDPOINT_SLOT_FUEL)
	if(!ft)
		return FALSE

	ft.reagents.add_reagent(/datum/reagent/cryogenic_fuel, amount)
	for(var/datum/reagent/cryogenic_fuel/F in ft?.reagents.reagent_list)
		if(!istype(F))
			continue

		F.volume = amount
	return amount

/// E's are good E's are good, he's ebeneezer goode.
/obj/structure/overmap/small_craft/proc/engines_active()
	var/obj/item/fighter_component/engine/E = loadout.get_slot(HARDPOINT_SLOT_ENGINE)
	return E?.active() && get_fuel() > 0

/obj/structure/overmap/small_craft/proc/use_fuel(force=FALSE)
	if(!engines_active() && !force) //No fuel? don't spam them with master cautions / use any fuel
		return FALSE

	var/fuel_consumption = 0.5*(loadout.get_slot(HARDPOINT_SLOT_ENGINE)?.tier)
	var/amount = (user_thrust_dir) ? fuel_consumption+0.25 : fuel_consumption //When you're thrusting : fuel consumption doubles. Idling is cheap.
	var/obj/item/fighter_component/fuel_tank/ft = loadout.get_slot(HARDPOINT_SLOT_FUEL)
	if(!ft)
		return FALSE

	ft.reagents.remove_reagent(/datum/reagent/cryogenic_fuel, amount)
	if(get_fuel() >= amount)
		return TRUE

	set_master_caution(TRUE)
	return FALSE
