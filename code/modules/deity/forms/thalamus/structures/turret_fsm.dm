/datum/state_machine/turret_thalamus
	current_state = /datum/state/turret_thalamus/idle
	expected_type = /obj/machinery/turret/thalamus

/datum/state/turret_thalamus
	var/switched_to_sound = null
	var/switched_from_sound = null
	var/sound_played_last
	var/sound_cd = 1 SECOND

/datum/state/turret_thalamus/entered_state(obj/machinery/turret/thalamus/turret, datum/state/turret_thalamus/previous_state)
	turret.update_icon()

	if(switched_to_sound && world.time + sound_cd >= sound_played_last)
		sound_played_last = world.time
		playsound(turret, switched_to_sound, 40, TRUE)

/datum/state/turret_thalamus/exited_state(obj/machinery/turret/thalamus/turret)
	if(switched_from_sound && world.time + sound_cd >= sound_played_last)
		sound_played_last = world.time
		playsound(turret, switched_from_sound, 40, TRUE)

/datum/state/turret_thalamus/idle
	transitions = list(
		/datum/state_transition/turret_thalamus/shoot,
		/datum/state_transition/turret_thalamus/turn_to_bearing
		)

/datum/state/turret_thalamus/idle/entered_state(obj/machinery/turret/thalamus/turret, datum/state/turret_thalamus/previous_state)
	. = ..()
	turret.set_next_think_ctx("process_idle", world.time + TURRET_WAIT)
	turret.set_next_think_ctx("process_reloading", 0)
	turret.set_next_think_ctx("process_turning", 0)
	turret.set_next_think_ctx("process_shooting", 0)

/datum/state/turret_thalamus/idle/exited_state(obj/machinery/turret/thalamus/turret)
	. = ..()
	turret.set_next_think_ctx("process_idle", 0)

/datum/state/turret_thalamus/turning
	switched_to_sound = SFX_TURRET_ROTATE
	transitions = list(
		/datum/state_transition/turret_thalamus/reload,
		/datum/state_transition/turret_thalamus/shoot,
		/datum/state_transition/turret_thalamus/no_enemies
		)

/datum/state/turret_thalamus/turning/entered_state(obj/machinery/turret/thalamus/turret, datum/state/turret_thalamus/previous_state)
	. = ..()
	turret.set_next_think_ctx("process_turning", world.time + TURRET_WAIT)
	turret.set_next_think_ctx("process_reloading", 0)
	turret.set_next_think_ctx("process_idle", 0)
	turret.set_next_think_ctx("process_shooting", 0)

/datum/state/turret_thalamus/turning/exited_state(obj/machinery/turret/thalamus/turret)
	. = ..()
	turret.set_next_think_ctx("process_turning", 0)

/datum/state/turret_thalamus/engaging
	transitions = list(
		/datum/state_transition/turret_thalamus/reload,
		/datum/state_transition/turret_thalamus/turn_to_bearing,
		/datum/state_transition/turret_thalamus/no_enemies
		)

/datum/state/turret_thalamus/engaging/entered_state(obj/machinery/turret/thalamus/turret, datum/state/turret_thalamus/previous_state)
	. = ..()
	turret.set_next_think_ctx("process_shooting", world.time + TURRET_WAIT)
	turret.set_next_think_ctx("process_reloading", 0)
	turret.set_next_think_ctx("process_idle", 0)
	turret.set_next_think_ctx("process_turning", 0)

/datum/state/turret_thalamus/engaging/exited_state(obj/machinery/turret/thalamus/turret)
	. = ..()
	turret.set_next_think_ctx("process_shooting", 0)

/datum/state/turret_thalamus/reloading
	switched_to_sound = 'sound/effects/weapons/gun/interaction/rifle_load.ogg'
	transitions = list(
		/datum/state_transition/turret_thalamus/shoot,
		/datum/state_transition/turret_thalamus/turn_to_bearing,
		/datum/state_transition/turret_thalamus/no_enemies
	)

/datum/state/turret_thalamus/reloading/entered_state(obj/machinery/turret/thalamus/turret, datum/state/turret_thalamus/previous_state)
	. = ..()
	turret.set_next_think_ctx("process_reloading", world.time + TURRET_WAIT)
	turret.set_next_think_ctx("process_shooting", 0)
	turret.set_next_think_ctx("process_idle", 0)
	turret.set_next_think_ctx("process_turning", 0)

/datum/state/turret_thalamus/reloading/exited_state(obj/machinery/turret/thalamus/turret)
	. = ..()
	turret.set_next_think_ctx("process_reloading", 0)

/datum/state/turret_thalamus/reloading/get_open_transitions(obj/machinery/turret/thalamus/turret)
	if(turret.reloading) // We do not exit this state until reload is finished.
		return FALSE

	return ..()

/datum/state/turret_thalamus/reloading/entered_state(obj/machinery/turret/thalamus/turret)
	. = ..()
	turret.reloading = TRUE

/datum/state_transition/turret_thalamus/is_open(obj/machinery/turret/thalamus/turret)
	return turret.operable() && turret.enabled

/datum/state_transition/turret_thalamus/turn_to_bearing
	target = /datum/state/turret_thalamus/turning

/datum/state_transition/turret_thalamus/turn_to_bearing/is_open(obj/machinery/turret/thalamus/turret)
	. = ..()
	return . && !turret.within_bearing()

/datum/state_transition/turret_thalamus/shoot
	target = /datum/state/turret_thalamus/engaging

/datum/state_transition/turret_thalamus/shoot/is_open(obj/machinery/turret/thalamus/turret)
	. = ..()
	return . && turret.find_target() && turret.within_bearing()

/datum/state_transition/turret_thalamus/reload
	target = /datum/state/turret_thalamus/reloading

/datum/state_transition/turret_thalamus/reload/is_open(obj/machinery/turret/thalamus/turret)
	. = ..()
	return . && turret.should_reload()

/datum/state_transition/turret_thalamus/no_enemies
	target = /datum/state/turret_thalamus/idle

/datum/state_transition/turret_thalamus/no_enemies/is_open(obj/machinery/turret/thalamus/turret)
	. = ..()
	return . && turret.within_bearing() && !turret.find_target()
