/mob/living/silicon/proc/init_subsystems()
	for(var/subsystem_type in default_silicon_subsystems)
		init_subsystem(subsystem_type)

	if(/datum/nano_module/alarm_monitor/all in default_silicon_subsystems)
		for(var/datum/alarm_handler/AH in SSalarm.all_handlers)
			AH.register_alarm(src, /mob/living/silicon/proc/receive_alarm)
			queued_alarms[AH] = list()	// Makes sure alarms remain listed in consistent order

/mob/living/silicon/proc/init_subsystem(subsystem_type)
	var/existing_entry = default_silicon_subsystems[subsystem_type]
	if(existing_entry && !ispath(existing_entry))
		return

	var/datum/nano_module/subsystem_to_init = new subsystem_type(src)

	LAZYSET(silicon_subsystems_states, subsystem_type, subsystem_type == /datum/nano_module/law_manager ? GLOB.conscious_state : GLOB.self_state)
	LAZYADD(silicon_subsystems, subsystem_to_init)

/mob/living/silicon/proc/remove_subsystem(subsystem_type)
	var/datum/nano_module/subsystem_to_remove = locate(subsystem_type) in silicon_subsystems

	if(isnull(subsystem_to_remove))
		return

	LAZYREMOVE(silicon_subsystems, subsystem_to_remove)
	LAZYREMOVE(silicon_subsystems_states, subsystem_type)

	qdel(subsystem_to_remove)

/mob/living/silicon/verb/activate_subsystem()
	set name = "Subsystems"
	set category = "Silicon Commands"

	var/datum/nano_module/chosen_subsystem = tgui_input_list(src, "Opens the given subsystem's control.", "Subsystems", silicon_subsystems)

	if(isnull(chosen_subsystem))
		return

	open_subsystem(chosen_subsystem.type)

/// Opens subsystem's UI if valid path is given.
/mob/living/silicon/proc/open_subsystem(subsystem_type)
	var/datum/nano_module/subsystem_to_open = locate(subsystem_type) in silicon_subsystems

	if(isnull(subsystem_to_open))
		return

	subsystem_to_open.ui_interact(src, state = silicon_subsystems_states[subsystem_type])
