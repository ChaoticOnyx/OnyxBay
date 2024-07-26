/mob/living/Life()
	set invisibility = 0
	set background = BACKGROUND_ENABLED

	..()

	if(HAS_TRANSFORMATION_MOVEMENT_HANDLER(src))
		return 0
	if(!loc)
		return 0

	if(machine && !CanMouseDrop(machine, src))
		unset_machine()

	handle_modifiers() // Do this early since it might affect other things later.
	if (do_check_environment())
		//Handle temperature/pressure differences between body and environment
		var/datum/gas_mixture/environment = loc.return_air()
		if(environment)
			handle_environment(environment)

	blinded = 0 // Placing this here just show how out of place it is.
	// human/handle_regular_status_updates() needs a cleanup, as blindness should be handled in handle_disabilities()
	handle_regular_status_updates() // Status & health update, are we dead or alive etc.

	if(!is_ic_dead())
		aura_check(AURA_TYPE_LIFE)

	//Check if we're on fire
	handle_fire()

	for(var/obj/item/grab/G in src)
		G.think()

	handle_actions()

	if(!istype(src, /mob/living/carbon/human)) // It is a dirty thing but update_canmove() must be called as late as possible and I can't figure out how to do it in a better way sorry
		update_canmove(TRUE)

	handle_regular_hud_updates()

	if(mind)
		for(var/datum/objective/O in mind.objectives)
			O.update()

	return 1

/mob/living/proc/do_check_environment()
	return TRUE

/mob/living/proc/handle_breathing()
	return

/mob/living/proc/handle_mutations_and_radiation()
	return

/mob/living/proc/handle_chemicals_in_body()
	return

/mob/living/proc/handle_random_events()
	return

/mob/living/proc/handle_environment(datum/gas_mixture/environment)
	return

/mob/living/proc/handle_stomach()
	return

//This updates the health and status of the mob (conscious, unconscious, dead)
/mob/living/proc/handle_regular_status_updates()
	updatehealth()
	if(!is_ic_dead())
		if(paralysis)
			set_stat(UNCONSCIOUS)
		else if (status_flags & FAKEDEATH)
			set_stat(UNCONSCIOUS)
		else
			set_stat(CONSCIOUS)
		return 1

/mob/living/proc/handle_statuses()
	handle_stunned()
	handle_weakened()
	handle_paralysed()
	handle_stuttering()
	handle_silent()
	handle_drugged()
	handle_slurring()
	handle_stammering()
	handle_burrieng()
	handle_lisping()

/mob/living/proc/handle_stunned()
	if(stunned)
		AdjustStunned(-1)
	return stunned

/mob/living/proc/handle_weakened()
	if(weakened)
		weakened = max(weakened-1,0)
	return weakened

/mob/living/proc/handle_stuttering()
	if(stuttering)
		stuttering = max(stuttering-1, 0)
	return stuttering

/mob/living/proc/handle_silent()
	if(silent)
		silent = max(silent-1, 0)
	return silent

/mob/living/proc/handle_drugged()
	if(druggy)
		druggy = max(druggy-1, 0)
	return druggy

/mob/living/proc/handle_slurring()
	if(slurring)
		slurring = max(slurring-1, 0)
	return slurring

/mob/living/proc/handle_stammering()
	if(!stammering)
		for(var/datum/modifier/trait/stammering/M in modifiers)
			if(!isnull(M.stammering))
				stammering = TRUE
	return stammering

/mob/living/proc/handle_burrieng()
	if(!burrieng)
		for(var/datum/modifier/trait/burrieng/M in modifiers)
			if(!isnull(M.burrieng))
				burrieng = TRUE
	return burrieng

/mob/living/proc/handle_lisping()
	if(!lisping)
		for(var/datum/modifier/trait/lisping/M in modifiers)
			if(!isnull(M.lisping))
				lisping = TRUE
	return lisping

/mob/living/proc/handle_paralysed()
	if(paralysis)
		AdjustParalysis(-1)
	return paralysis

/mob/living/proc/handle_disabilities()
	handle_impaired_vision()
	handle_impaired_hearing()

/mob/living/proc/handle_impaired_vision()
	//Eyes
	if(sdisabilities & BLIND || stat)	//blindness from disability or unconsciousness doesn't get better on its own
		eye_blind = max(eye_blind, 1)
	else if(eye_blind)			//blindness, heals slowly over time
		eye_blind = max(eye_blind-1,0)
	else if(eye_blurry)			//blurry eyes heal slowly
		eye_blurry = max(eye_blurry-1, 0)

/mob/living/proc/handle_impaired_hearing()
	//Ears
	if(sdisabilities & DEAF)	//disabled-deaf, doesn't get better on its own
		setEarDamage(null, max(ear_deaf, 1))
	else if(ear_damage < 25)
		adjustEarDamage(-0.05, -1)	// having ear damage impairs the recovery of ear_deaf
	else if(ear_damage < 100)
		adjustEarDamage(-0.05, 0)	// deafness recovers slowly over time, unless ear_damage is over 100. TODO meds that heal ear_damage


//this handles hud updates. Calls update_vision() and handle_hud_icons()
/mob/living/proc/handle_regular_hud_updates()
	if(!client)
		return FALSE

	handle_hud_icons()
	handle_vision()
	if(pullin)
		if(pull_grab)
			pullin.icon_state = "pull1"
		else
			pullin.icon_state = "pull0"

	return TRUE

/mob/living/proc/handle_vision()
	update_sight()

	if(is_ooc_dead())
		return

	if(eye_blind)
		overlay_fullscreen("blind", /atom/movable/screen/fullscreen/blind)
	else
		clear_fullscreen("blind")
		set_fullscreen(disabilities & NEARSIGHTED, "impaired", /atom/movable/screen/fullscreen/impaired, 1)
		set_renderer_filter(eye_blurry, SCENE_GROUP_RENDERER, EYE_BLURRY_FILTER_NAME, 0, EYE_BLURRY_FILTER(eye_blurry))
		set_fullscreen(druggy, "high", /atom/movable/screen/fullscreen/high)

	set_fullscreen(stat == UNCONSCIOUS, "blackout", /atom/movable/screen/fullscreen/blackout)

	if(machine)
		var/viewflags = machine.check_eye(src)
		if(viewflags < 0)
			reset_view(null, 0)
		else if(viewflags)
			set_sight(viewflags)
	else if(eyeobj)
		if(eyeobj.owner != src)
			reset_view(null)
	else if(!client.adminobs)
		reset_view(null)

/mob/living/proc/update_sight()
	if(is_ooc_dead() || eyeobj)
		update_dead_sight()
	else
		update_living_sight()

/mob/living/proc/update_living_sight()
	set_sight(sight&(~(SEE_TURFS|SEE_MOBS|SEE_OBJS)))
	set_see_in_dark(initial(see_in_dark))
	set_see_invisible(initial(see_invisible))

/mob/living/proc/update_dead_sight()
	set_sight(sight|SEE_TURFS|SEE_MOBS|SEE_OBJS)
	set_see_in_dark(8)
	set_see_invisible(SEE_INVISIBLE_LEVEL_TWO)

/mob/living/proc/handle_hud_icons()
	handle_hud_icons_health()
	handle_hud_glasses()

/mob/living/proc/handle_hud_icons_health()
	if(!healths)
		return

	if(is_ic_dead())
		healths.icon_state = "health7"
		return

	var/health_ratio = health / maxHealth * 100
	switch(health_ratio)
		if(100 to INFINITY)
			healths.icon_state = "health0"
		if(80 to 100)
			healths.icon_state = "health1"
		if(60 to 80)
			healths.icon_state = "health2"
		if(40 to 60)
			healths.icon_state = "health3"
		if(20 to 40)
			healths.icon_state = "health4"
		if(0 to 20)
			healths.icon_state = "health5"
		else
			healths.icon_state = "health6"

	return
