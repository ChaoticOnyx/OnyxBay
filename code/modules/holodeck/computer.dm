#define PROJECTION_POWER_COST 5 HECTO WATTS

// TODO: add ability to construct holodeck console & document usage
/obj/machinery/computer/holodeck
	name = "holodeck control console"
	desc = "A computer used to control a nearby holodeck."

	icon_keyboard = "tech_key"
	icon_screen = "holocontrol"
	light_color = "#41E0FC"

	active_power_usage = 8 KILO WATTS

	var/mapped_start_area_typepath = /area/holodeck

	var/area/holodeck/linked_area
	var/turf/bottom_left

	var/datum/map_template/holodeck/using_template
	var/list/atom/spawned
	var/list/atom/effects

	var/list/programs_cache
	var/list/emag_programs_cache

	var/active = FALSE

	var/locked = FALSE

	var/offline_program = "holodeck_offline"

	var/program
	var/last_program

	var/safety_disabled = FALSE

	var/gravity_disabled = FALSE

/obj/machinery/computer/holodeck/Initialize()
	. = ..()

	LAZYINITLIST(spawned)
	LAZYINITLIST(effects)

	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/holodeck/LateInitialize()
	linked_area = pick_area_by_type(mapped_start_area_typepath, list())
	if(isnull(linked_area))
		log_debug("[src] has no matching holodeck area.")
		qdel(src)
		return

	bottom_left = locate(linked_area.x, linked_area.y, z)
	if(isnull(bottom_left))
		log_debug("[src] has an invalid holodeck area.")
		qdel(src)
		return

	if(isnull(offline_program))
		log_debug("[src] created without offline ptogram.")
		qdel(src)
		return

	generate_programs_list()
	load_program(offline_program, TRUE)

/obj/machinery/computer/holodeck/proc/generate_programs_list()
	for(var/typepath in subtypesof(/datum/map_template/holodeck))
		var/datum/map_template/holodeck/program = typepath
		var/list/program_data = list("id" = initial(program.template_id), "name" = initial(program.name))
		if(initial(program.restricted))
			LAZYADD(emag_programs_cache, list(program_data))
		else
			LAZYADD(programs_cache, list(program_data))

/obj/machinery/computer/holodeck/proc/load_program(map_id, force = FALSE)
	if(program == map_id)
		return

	THROTTLE(cooldown, 10 SECONDS)
	if(!cooldown && !force)
		audible_message(SPAN_WARNING("ERROR. Recalibrating projection apparatus."))
		return

	clear_projections()

	using_template = SSmapping.holodeck_templates[map_id]
	using_template.load(bottom_left)

	spawned = using_template.created_atoms

	last_program = program
	program = map_id

	active = program != offline_program

	linked_area.forced_ambience = length(using_template.ambience) ? using_template.ambience : initial(linked_area.forced_ambience)
	linked_area.ambient_music_tags = length(using_template.ambience_music) ? using_template.ambience_music : initial(linked_area.ambient_music_tags)

	finish_loading()
	nerf(!emagged)

	update_use_power(active ? POWER_USE_ACTIVE : POWER_USE_IDLE)

/obj/machinery/computer/holodeck/proc/finish_loading()
	for(var/atom/holo_atom as anything in spawned)
		if(QDELETED(holo_atom))
			spawned -= holo_atom
			continue

		finilize_spawned(holo_atom)

/obj/machinery/computer/holodeck/proc/add_to_spawned(atom/holo_atom)
	spawned |= holo_atom

	if(emagged && isitem(holo_atom))
		var/obj/item/holo_item = holo_atom
		holo_item.damtype = PAIN

	finilize_spawned(holo_atom)

/obj/machinery/computer/holodeck/proc/remove_from_spawned(datum/to_remove, _force)
	SIGNAL_HANDLER
	spawned -= to_remove
	unregister_signal(to_remove, SIGNAL_QDELETING)

/obj/machinery/computer/holodeck/proc/finilize_spawned(atom/holo_atom)
	register_signal(holo_atom, SIGNAL_QDELETING, nameof(.proc/remove_from_spawned))
	holo_atom.atom_flags |= ATOM_FLAG_HOLOGRAM

	if(isturf(holo_atom))
		holo_atom.atom_flags |= ATOM_FLAG_NO_DECONSTRUCTION
		return

	if(isholoeffect(holo_atom))
		var/obj/effect/holodeck_effect/holo_effect = holo_atom

		effects += holo_effect
		spawned -= holo_effect

		var/atom/holo_effect_product = holo_effect.activate()
		if(istype(holo_effect_product))
			add_to_spawned(holo_effect_product)

		if(islist(holo_effect_product))
			for(var/atom/atom_product as anything in holo_effect_product)
				add_to_spawned(holo_effect_product)

		return

	if(length(holo_atom.contents))
		for(var/atom/contained_atom as anything in holo_atom.contents)
			add_to_spawned(contained_atom)

	if(isobj(holo_atom))
		var/obj/holo_obj = holo_atom
		holo_obj.unacidable = TRUE
		holo_obj.atom_flags |= ATOM_FLAG_NO_DECONSTRUCTION
		return

/obj/machinery/computer/holodeck/proc/clear_projections()
	for(var/holo_atom in spawned)
		derez(holo_atom)

	for(var/obj/effect/holodeck_effect/holo_effect as anything in effects)
		effects -= holo_effect
		holo_effect.deactivate()

/obj/machinery/computer/holodeck/proc/derez(atom/holo_atom, silent = TRUE)
	spawned -= holo_atom
	if(isnull(holo_atom) || isturf(holo_atom))
		return

	unregister_signal(holo_atom, SIGNAL_QDELETING)

	var/turf/target_turf = get_turf(holo_atom)
	for(var/atom/movable/atom_contents as anything in holo_atom)
		if(atom_contents.atom_flags & ATOM_FLAG_HOLOGRAM)
			continue

		atom_contents.forceMove(target_turf)

	if(!silent)
		visible_message(SPAN_NOTICE("\The [holo_atom] fades away!"))

	qdel(holo_atom)

/obj/machinery/computer/holodeck/proc/nerf(nerf = TRUE)
	for(var/obj/item/nerfing_item in spawned)
		nerfing_item.damtype = nerf ? PAIN : initial(nerfing_item.damtype)

	for(var/obj/effect/holodeck_effect/nerfing_effect as anything in effects)
		nerfing_effect.nerf(nerf)

/obj/machinery/computer/holodeck/proc/check_flooring()
	for(var/turf/checking_turf in linked_area)
		if(!checking_turf.holodeck_compatible && !(checking_turf.atom_flags & ATOM_FLAG_HOLOGRAM))
			return FALSE

	return TRUE

/obj/machinery/computer/holodeck/proc/toggle_power(new_state)
	if(active == new_state)
		return

	if(active)
		load_program(offline_program)
		set_gravity()
	else
		if(last_program && (last_program != program))
			load_program(last_program)
			set_gravity(!gravity_disabled)


/obj/machinery/computer/holodeck/proc/toggle_gravity()
	THROTTLE(cooldown, 3 SECONDS)
	if(!cooldown)
		audible_message(SPAN_WARNING("ERROR. Recalibrating gravity field."))
		return

	gravity_disabled = !gravity_disabled
	set_gravity(!gravity_disabled)

// TODO: fix this proc
/obj/machinery/computer/holodeck/proc/set_gravity(new_value)
	if(!isnull(new_value))
		var/obj/machinery/gravity_generator/main/gravity_generator = GLOB.station_gravity_generator
		linked_area.gravitychange(gravity_generator?.enabled)
		return

	linked_area.gravitychange(new_value)

/obj/machinery/computer/holodeck/proc/toggle_safety()
	safety_disabled = !safety_disabled
	nerf(!safety_disabled)

	message_admins("[key_name_admin(usr)] [safety_disabled ? "restored" : "overrode"] the holodeck's safeties")
	log_game("[key_name(usr)] [safety_disabled ? "restored" : "overrode"] the holodeck's safeties")

// TODO: use fax state due to access complications
/obj/machinery/computer/holodeck/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "Holodeck")
		ui.open()

/obj/machinery/computer/holodeck/tgui_data(mob/user)
	var/list/data = list()

	data["isLocked"] = locked
	data["isSafetyDisabled"] = safety_disabled
	data["isGravityDisabled"] = gravity_disabled
	data["canToggleSafety"] = issilicon(user) || is_admin(user)

	data["currentProgram"] = program

	data["programs"] = list()
	if(!isnull(programs_cache))
		data["programs"] += programs_cache
	if(emagged && !isnull(emag_programs_cache))
		data["programs"] += emag_programs_cache

	return data

/obj/machinery/computer/holodeck/tgui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("toggleLock")
			if(!allowed(usr))
				return

			locked = !locked
			return TRUE

		if("toggleSafety")
			if(!issilicon(usr) || !is_admin(usr))
				return

			toggle_safety()
			return TRUE

		if("toggleGravity")
			toggle_gravity()
			return TRUE

		if("changeProgram")
			var/program_id = params["id"]
			if(isnull(program_id))
				return

			load_program(program_id)
			return TRUE

/obj/machinery/computer/holodeck/proc/emergency_shutdown()
	load_program(offline_program, TRUE)
	set_gravity()

/obj/machinery/computer/holodeck/ex_act(severity)
	INVOKE_ASYNC(src, CALLBACK(nameof(.proc/emergency_shutdown)))
	return ..()

/obj/machinery/computer/holodeck/Destroy()
	INVOKE_ASYNC(src, CALLBACK(nameof(.proc/emergency_shutdown)))
	return ..()

/obj/machinery/computer/holodeck/power_change()
	. = ..()
	INVOKE_ASYNC(src, nameof(.proc/toggle_power), !(stat & NOPOWER))

/obj/machinery/computer/holodeck/Process()
	if(program == offline_program)
		return

	if(!check_flooring())
		audible_message(SPAN_WARNING("ERROR! Structural damage detected, overload imminent."))
		emergency_shutdown()

		for(var/turf/affected_turf in linked_area)
			if(prob(30))
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(2, 1, affected_turf)
				s.start()

			affected_turf.ex_act(EXPLODE_LIGHT)
			affected_turf.hotspot_expose(1000, 500, 1)

	if(!emagged)
		for(var/spawned_atom in spawned)
			if(get_area(spawned_atom) != linked_area)
				derez(spawned_atom)

	if(active)
		use_power_oneoff(active_power_usage + length(spawned) * PROJECTION_POWER_COST + length(effects) * PROJECTION_POWER_COST)

/obj/machinery/computer/holodeck/attack_hand(mob/user)
	tgui_interact(user)

/obj/machinery/computer/holodeck/attack_ai(mob/user)
	tgui_interact(user)
