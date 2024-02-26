/datum/state_machine/turret
	current_state = /datum/state/turret/idle
	expected_type = /obj/machinery/turret

/datum/state/turret
	var/ray_color = "#ffffffff" // Turrets have a visual indicator of their current state.
	var/ray_alpha = 255
	var/switched_to_sound = null
	var/switched_from_sound = null
	var/sound_played_last
	var/sound_cd = 1 SECOND

	var/timer_proc = null
	var/timer_wait = TURRET_WAIT

/datum/state/turret/entered_state(obj/machinery/turret/turret)
	turret.ray_color = ray_color
	turret.ray_alpha = ray_alpha
	turret.update_icon()

	if(switched_to_sound && world.time + sound_cd >= sound_played_last)
		sound_played_last = world.time
		playsound(turret, switched_to_sound, 40, TRUE)

	if(timer_proc)
		turret.timer_id = addtimer(CALLBACK(turret, timer_proc), timer_wait, TIMER_UNIQUE | TIMER_STOPPABLE | TIMER_LOOP | TIMER_OVERRIDE)

/datum/state/turret/exited_state(obj/machinery/turret/turret)
	if(switched_from_sound && world.time + sound_cd >= sound_played_last)
		sound_played_last = world.time
		playsound(turret, switched_from_sound, 40, TRUE)

	if(timer_proc && turret.timer_id)
		deltimer(turret.timer_id)
		turret.timer_id = null

/datum/state/turret/idle
	ray_color = "#ffffffff"
	ray_alpha = 0
	switched_to_sound = SFX_TURRET_RETRACT
	switched_from_sound = SFX_TURRET_DEPLOY
	// Timer for returning to default bearing.
	timer_proc = /obj/machinery/turret/proc/process_idle
	timer_wait = 5 SECONDS

	transitions = list(
		/datum/state_transition/turret/lost_power,
		/datum/state_transition/turret/reload,
		/datum/state_transition/turret/shoot,
		/datum/state_transition/turret/turn_to_bearing
		)

/datum/state/turret/idle/entered_state(obj/machinery/turret/turret)
	. = ..()
	// Flicking popup overlay
	var/atom/flick_holder = new /atom/movable/porta_turret_cover(turret.loc)
	flick_holder.layer = turret.layer + 0.1
	var/icon/flick_icon = icon(turret.icon, "popdown")
	flick_holder.SetTransform(rotation = turret.current_bearing)
	flick(flick_icon, flick_holder)
	//sleep(10) // LMAO
	//qdel(flick_holder)
	QDEL_IN(flick_holder, 1 SECOND)
	turret.raised = FALSE
	turret.update_icon()

/datum/state/turret/idle/exited_state(obj/machinery/turret/turret)
	. = ..()
	// Flicking popdown overlay
	var/atom/flick_holder = new /atom/movable/porta_turret_cover(turret.loc)
	flick_holder.layer = turret.layer + 0.1
	var/icon/flick_icon = icon(turret.icon, "popup")
	flick_holder.SetTransform(rotation = turret.current_bearing)
	flick(flick_icon, flick_holder)
	QDEL_IN(flick_holder, 1 SECOND)
	turret.raised = TRUE
	turret.update_icon()

/datum/state/turret/turning
	ray_color = "#ffff00ff"
	switched_to_sound = SFX_TURRET_ROTATE
	//switched_to_sound = 'sound/machines/quiet_beep.ogg'
	timer_proc = /obj/machinery/turret/proc/process_turning
	transitions = list(
		/datum/state_transition/turret/lost_power,
		/datum/state_transition/turret/reload,
		/datum/state_transition/turret/shoot,
		/datum/state_transition/turret/no_enemies
		)

/datum/state/turret/engaging
	ray_color = "#ff0000ff"
	//switched_to_sound = 'sound/machines/buttonbeep.ogg'
	timer_proc = /obj/machinery/turret/proc/process_shooting
	transitions = list(
		/datum/state_transition/turret/lost_power,
		/datum/state_transition/turret/reload,
		/datum/state_transition/turret/turn_to_bearing,
		/datum/state_transition/turret/no_enemies
		)

/datum/state/turret/reloading
	ray_color = "#ffa600ff"
	switched_to_sound = 'sound/effects/weapons/gun/interaction/rifle_load.ogg'
	timer_proc = /obj/machinery/turret/proc/process_reloading
	transitions = list(
		/datum/state_transition/turret/lost_power,
		/datum/state_transition/turret/shoot,
		/datum/state_transition/turret/turn_to_bearing,
		/datum/state_transition/turret/no_enemies
	)

/datum/state/turret/reloading/get_open_transitions(obj/machinery/turret/turret)
	if(turret.reloading) // We do not exit this state until reload is finished.
		return FALSE

	return ..()

/datum/state/turret/reloading/entered_state(obj/machinery/turret/turret)
	. = ..()
	turret.reloading = TRUE

/datum/state/turret/no_power
	ray_color = "#00000000" // Makes the beam invisible with #RRGGBBAA, not black.
	transitions = list(
		/datum/state_transition/turret/reload,
		/datum/state_transition/turret/shoot,
		/datum/state_transition/turret/turn_to_bearing,
		/datum/state_transition/turret/no_enemies
		)

/datum/state_transition/turret/is_open(obj/machinery/turret/turret)
	return turret.operable() && turret.enabled

/datum/state_transition/turret/turn_to_bearing
	target = /datum/state/turret/turning

/datum/state_transition/turret/turn_to_bearing/is_open(obj/machinery/turret/turret)
	. = ..()
	return . && !turret.within_bearing()

/datum/state_transition/turret/shoot
	target = /datum/state/turret/engaging

/datum/state_transition/turret/shoot/is_open(obj/machinery/turret/turret)
	. = ..()
	return . && turret.find_target() && turret.within_bearing()

/datum/state_transition/turret/reload
	target = /datum/state/turret/reloading

/datum/state_transition/turret/reload/is_open(obj/machinery/turret/turret)
	. = ..()
	return . && turret.should_reload()

/datum/state_transition/turret/no_enemies
	target = /datum/state/turret/idle

/datum/state_transition/turret/no_enemies/is_open(obj/machinery/turret/turret)
	. = ..()
	return . && turret.within_bearing() && !turret.find_target()

/datum/state_transition/turret/lost_power
	target = /datum/state/turret/no_power

/datum/state_transition/turret/lost_power/is_open(obj/machinery/turret/turret)
	return !turret.enabled || turret.inoperable()
