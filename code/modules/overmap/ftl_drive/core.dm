/obj/machinery/ftl_drive
	anchored = TRUE
	icon = 'icons/obj/artillery.dmi'
	var/initial_id_tag = "ftl"

/obj/machinery/ftl_drive/core
	name = "drive core"

	use_power = POWER_USE_OFF
	power_channel = STATIC_EQUIP
	idle_power_usage = 1600
	icon_state = "bsd"
	light_color = COLOR_BLUE
	var/obj/machinery/computer/ship/ftl/ftl_computer
	var/ftl_flags = FTL_DRIVE_MAKES_ANNOUNCEMENT
	var/list/fuel_ports = list() //We mainly use fusion fuels.
	var/list/accepted_fuels = list()

	var/cooldown_delay = 5 MINUTES
	var/cooldown
	var/required_fuel_joules
	var/required_charge //This is a function of the required fuel joules.
	var/accumulated_charge
	var/max_charge = 2000000
	var/max_range = 30000 //max jump range. This is _very_ long distance

	var/progress = 0 SECONDS
	var/progress_rate = 1 SECONDS
	var/jump_delay = 31 SECONDS
	var/jump_duration = 30 MINUTES

	var/sabotaged
	var/jumping = FALSE

	var/jump_start_text = "Attention! Superluminal shunt warm-up initiated! Spool-up ETA: %%TIME%%"
	var/jump_cancel_text = "Attention! Faster-than-light transition cancelled."
	var/jump_complete_text = "Attention! Faster-than-light transition completed."
	var/jump_spooling_text = "Attention! Superluminal shunt warm-up complete, spooling up."

	var/sabotage_text_minor = "Warning! Electromagnetic flux beyond safety limits - aborting shunt!"
	var/sabotage_text_major = "Warning! Critical electromagnetic flux in accelerator core! Dumping core and aborting shunt!"
	var/sabotage_text_critical = "ALERT! Critical malfunction in microsingularity containment core! Safety systems offline!"

	var/moderate_jump_distance = 15000
	var/safe_jump_distance = 15000
	var/lockout = FALSE

/obj/machinery/ftl_drive/core/Initialize()
	. = ..()
	add_think_ctx("start_jump", CALLBACK(src, nameof(.proc/start_jump)), 0)
	add_think_ctx("execute_jump", CALLBACK(src, nameof(.proc/execute_jump)), 0)
	add_think_ctx("jump_end", CALLBACK(src, nameof(.proc/jump_end)), 0)

/obj/machinery/ftl_drive/core/proc/find_ports()
	pass()

/obj/machinery/ftl_drive/core/proc/get_fuel()
	pass()

/// Initiates FTL jump, returns defines regarding jump status.
/obj/machinery/ftl_drive/core/proc/initiate_jump(datum/star_system/target_system, force = FALSE)
	if(stat & BROKEN)
		return FTL_START_FAILURE_BROKEN

	if(stat & NOPOWER)
		return FTL_START_FAILURE_POWER

	if(world.time <= cooldown)
		return FTL_START_FAILURE_COOLDOWN

	if(ftl_flags & FTL_DRIVE_REQUIRES_FUEL)
		if(!length(fuel_ports)) //no fuel ports
			find_ports()
			if(!length(fuel_ports))
				return FTL_START_FAILURE_OTHER

		if(required_fuel_joules > get_fuel(fuel_ports))
			return FTL_START_FAILURE_FUEL

	//calculate_jump_requirements()

	if(ftl_flags & FTL_DRIVE_REQUIRES_CHARGE)
		if(accumulated_charge < required_charge)
			return FTL_START_FAILURE_POWER

		if(max_charge < required_charge)
			return FTL_START_FAILURE_POWER

	if(sabotaged)
		sabotage_warning()

	if(ftl_flags & FTL_DRIVE_MAKES_ANNOUNCEMENT)
		var/announcetxt = replacetext(jump_start_text, "%%TIME%%", "[round(jump_delay / 600)] minutes.")

		SSannounce.play_station_announce(/datum/announce/comm_program, announcetxt, "FTL drive Management System", sound_override = 'sound/misc/notice2.ogg', msg_sanitized = TRUE)

	update_icon()

	ftl_computer.linked?.relay('sound/effects/ship/FTL_long_thirring.ogg', channel = SOUND_CHANNEL_FTL_MANIFOLD)
	set_next_think_ctx("start_jump", world.time + jump_delay, target_system, force)
	return FTL_START_CONFIRMED

//Starts the jump
/obj/machinery/ftl_drive/core/proc/start_jump(datum/star_system/target_system, force = FALSE)
	if(ftl_flags & FTL_DRIVE_MAKES_ANNOUNCEMENT)
		SSannounce.play_station_announce(/datum/announce/comm_program, jump_spooling_text, "FTL Shunt Management System", sound_override = sound('sound/misc/notice2.ogg'))

	if(sabotaged)
		cancel_shunt(TRUE)
		do_sabotage()
		//ftl_computer.jump_plotted = FALSE
		return

	if(ftl_flags & FTL_DRIVE_REQUIRES_FUEL)
		//if(use_fuel(required_fuel_joules))
		//	jump_timer = addtimer(CALLBACK(src, PROC_REF(execute_shunt)), jump_delay, TIMER_STOPPABLE)
		//else
		//	cancel_shunt()
		return //If for some reason we don't have fuel now, just return.

	jumping = TRUE
	update_icon()
	set_next_think_ctx("execute_jump", world.time + 1, target_system, force)

/obj/machinery/ftl_drive/core/proc/execute_jump(datum/star_system/target_system, force = FALSE)
	var/datum/star_system/curr = SSstar_system.ships[ftl_computer.linked]["current_system"]
	curr.remove_ship(ftl_computer.linked)
	var/speed = (curr.dist(target_system) / (1 * 10))
	SSstar_system.ships[ftl_computer.linked]["to_time"] = world.time + speed MINUTES
	SSstar_system.ships[ftl_computer.linked]["target_system"] = target_system
	SSstar_system.ships[ftl_computer.linked]["from_time"] = world.time
	SSstar_system.ships[ftl_computer.linked]["current_system"] = null
	ftl_computer.linked?.relay('sound/effects/ship/FTL_loop.ogg', null, loop = TRUE, channel = SOUND_CHANNEL_FTL_MANIFOLD)
	SSskybox.reinstate_skyboxes("ftl", FALSE)

	for(var/mob/M in GLOB.living_mob_list_)
		shake_camera(M, 2, 3)

	GLOB.using_map.apply_ftl_mask()
	do_effects(curr.dist(target_system))

	set_next_think_ctx("jump_end", world.time + jump_duration, target_system, force)

/obj/machinery/ftl_drive/core/proc/jump_end(datum/star_system/target_system)
	SSstar_system.ships[ftl_computer.linked]["target_system"] = null
	SSstar_system.ships[ftl_computer.linked]["current_system"] = target_system
	SSstar_system.ships[ftl_computer.linked]["last_system"] = target_system
	SSstar_system.ships[ftl_computer.linked]["from_time"] = 0
	SSstar_system.ships[ftl_computer.linked]["to_time"] = 0
	SEND_SIGNAL(ftl_computer.linked, SIGNAL_OVERMAP_STATE_CHANGE)
	jump_handle_shake()
	target_system.add_ship(ftl_computer.linked)
	SSskybox.reinstate_skyboxes("dyable", FALSE)

/obj/machinery/ftl_drive/core/proc/jump_handle_shake(ftl_start)
	pass()

/// A proc for warning crew when jumping with a sabotaged/damaged FTL drive.
/obj/machinery/ftl_drive/core/proc/sabotage_warning()
	pass()

/// Handles all jump-specific events.
/obj/machinery/ftl_drive/core/proc/do_effects(distance)
	var/shunt_sev
	if(distance < safe_jump_distance)
		shunt_sev = SHUNT_SEVERITY_MINOR
	else if(distance < moderate_jump_distance)
		shunt_sev = SHUNT_SEVERITY_MAJOR
	else
		shunt_sev = SHUNT_SEVERITY_CRITICAL

	for(var/mob/living/carbon/human/H in GLOB.living_mob_list_)
		if(!(H.z in GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION)))
			continue

		if(isnull(H) || QDELETED(H))
			continue

		if(H.isSynthetic())
			continue

		switch(shunt_sev)
			if(SHUNT_SEVERITY_MINOR)
				to_chat(H, SPAN_NOTICE("You feel your insides flutter about inside of you as you are briefly shunted into an alternate dimension.")) //No major effects.
				shake_camera(H, 2, 1)

			if(SHUNT_SEVERITY_MAJOR)
				to_chat(H, SPAN_WARNING("You feel your insides twisted inside and out as you are violently shunted between dimensions, and you feel like something is watching you!"))
				if(prob(25))
					H.hallucination(50, 50)
				if(prob(15))
					H.vomit()
				shake_camera(H, 2, 1)

			if(SHUNT_SEVERITY_CRITICAL)
				to_chat(H, SPAN_DANGER("You feel an overwhelming sense of nausea and vertigo wash over you, your instincts screaming that something is wrong!"))
				if(prob(50))
					H.hallucination(100, 100)
				if(prob(45))
					H.vomit()
				shake_camera(H, 5, 4)

	for(var/obj/machinery/light/L in SSmachines.machinery) //Fuck with and or break lights.
		if(!(L.z in GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION)))
			continue

		switch(shunt_sev)
			if(SHUNT_SEVERITY_MINOR)
				if(prob(15))
					L.flicker()
			if(SHUNT_SEVERITY_MAJOR)
				if(prob(35))
					L.flicker()

	for(var/obj/machinery/power/apc/A in SSmachines.machinery)
		if(!(A.z in GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION)))
			continue

		switch(shunt_sev)
			if(SHUNT_SEVERITY_MAJOR)
				if(prob(15))
					A.energy_fail(rand(30, 80))
				if(prob(10))
					A.overload_lighting(25)

			if(SHUNT_SEVERITY_CRITICAL)
				if(prob(35))
					A.energy_fail(rand(60, 150))
				if(prob(50))
					A.overload_lighting(50)

/obj/machinery/ftl_drive/core/proc/do_sabotage()
	var/announcetxt

	switch(sabotaged)
		if(SHUNT_SABOTAGE_MINOR)
			announcetxt = sabotage_text_minor
			for(var/mob/living/carbon/human/H in view(7))
				H.show_message(SPAN_DANGER("\The [src] emits a flash of incredibly bright, searing light!"), VISIBLE_MESSAGE)
				H.flash_eyes(FLASH_PROTECTION_NONE)
			empulse(src, 8, 10)

		if(SHUNT_SABOTAGE_MAJOR)
			announcetxt = sabotage_text_major

			visible_message(SPAN_DANGER("\The [src] hisses and sparks, before the coolant lines burst and spew superheated coolant!"))

			explosion(get_turf(src), -1, -1, 8, 10)

			for(var/obj/machinery/power/apc/A in SSmachines.machinery) //Effect Three: shut down power across the ship.
				if(A.z != z)
					continue

				A.energy_fail(rand(60,80))

		if(SHUNT_SABOTAGE_CRITICAL)
			announcetxt = sabotage_text_critical

			for(var/obj/machinery/power/apc/A in SSmachines.machinery)
				if(!(A.z in GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION)))
					continue

				A.energy_fail(rand(100,120))

			for(var/mob/living/carbon/human/H in view(7))
				H.show_message(SPAN_DANGER("The light around \the [src] warps before it emits a flash of incredibly bright, searing light!"), VISIBLE_MESSAGE)
				H.flash_eyes(FLASH_PROTECTION_NONE)

			new /obj/singularity(get_turf(src))

	SSannounce.play_station_announce(/datum/announce/comm_program, announcetxt, "FTL Shunt Management System", sound_override = sound('sound/misc/notice2.ogg'))

//Cancels the in-progress shunt.
/obj/machinery/ftl_drive/core/proc/cancel_shunt(silent = FALSE)
	set_next_think(0)
	cooldown = null
	required_fuel_joules = null
	if(!silent)
		SSannounce.play_station_announce(/datum/announce/comm_program, jump_cancel_text, "FTL Shunt Management System", sound_override = sound('sound/misc/notice2.ogg'))

	update_icon()
