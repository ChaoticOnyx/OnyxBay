
/proc/power_failure(announce = 1, severity = 2, list/affected_z_levels)
	if(announce)
		GLOB.using_map.grid_check_announcement()

	for(var/obj/machinery/power/smes/buildable/S in GLOB.smes_list)
		S.energy_fail(rand(15 * severity,30 * severity))


	for(var/obj/machinery/power/apc/C in GLOB.apc_list)
		if(!C.is_critical && (!affected_z_levels || (C.z in affected_z_levels)))
			C.energy_fail(rand(30 * severity,60 * severity))

/proc/power_restore(announce = 1)
	if(announce)
		GLOB.using_map.grid_restored_announcement()
	for(var/obj/machinery/power/apc/C in GLOB.apc_list)
		C.failure_timer = 0
		if(C.cell)
			C.cell.charge = C.cell.maxcharge
	for(var/obj/machinery/power/smes/S in GLOB.smes_list)
		S.failure_timer = 0
		S.charge = S.capacity
		S.update_icon()
		S.power_change()

/proc/power_restore_quick(announce = 1)

	if(announce)
		command_announcement.AnnounceLocalizeable(
			TR_DATA(L10N_ANNOUNCE_POWER_RESTORE, null, list("station_name" = station_name())),
			TR_DATA(L10N_ANNOUNCE_POWER_RESTORE_TITLE, null, null),
			new_sound = GLOB.using_map.grid_restored_sound
		)

	for(var/obj/machinery/power/smes/S in GLOB.smes_list)
		S.failure_timer = 0
		S.charge = S.capacity
		S.output_level = S.output_level_max
		S.output_attempt = 1
		S.input_attempt = 1
		S.update_icon()
		S.power_change()
