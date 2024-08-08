/turf/simulated/floor/get_footstep_sound()
	var/sound = flooring?.footstep_sound || footstep_sound

	return pick(GLOB.sfx_list[sound || SFX_FOOTSTEP_PLATING])

/turf/Entered(atom/A, atom/OL)
	..()
	if(istype(A, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = A
		H.handle_footsteps()
		H.step_count++
	else if(istype(A, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = A
		R.handle_footsteps()
		R.step_count++

/mob/living/carbon/human/var/step_count

/mob/living/carbon/human/proc/handle_footsteps()
	var/turf/T = get_turf(src)

	if(!istype(T))
		return

	if(buckled || lying || throwing)
		return //people flying, lying down or sitting do not step

	if(is_cloaked())
		return

	if(m_intent == M_RUN)
		if(step_count % 2) //every other turf makes a sound
			return

	if(!has_gravity(src))
		if(step_count % 3) // don't need to step as often when you hop around
			return

	if(!has_organ(BP_L_FOOT) && !has_organ(BP_R_FOOT))
		return //no feet no footsteps

	var/S = T.get_footstep_sound()
	if(S)
		var/range = -(world.view - 2)
		var/volume = 70
		if(m_intent == M_WALK)
			volume -= 45
			range -= 0.333
		if(!shoes)
			volume -= 60
			range -= 0.333

		playsound(T, S, volume, FALSE, range)

	// Playing far movement sound with small chance when someone make step in maintenance area
	// These sounds another players can hear only in the same maintenance area
	if(m_intent == M_WALK)
		return

	var/chance = 25

	if(MUTATION_FAT in mutations)
		chance += 5

	if(MUTATION_CLUMSY in mutations)
		chance += 10

	if(MUTATION_HULK in mutations)
		chance += 15

	if(!prob(chance))
		return

	var/area/maintenance/A = get_area(src)

	if(!istype(A))
		return

	for(var/mob/M in GLOB.player_list)
		if(M == src)
			continue

		if(istype(M, /mob/new_player))
			continue

		// This IS NOT a permanent solution, but I've spent too much time trying to track down
		// the way a mob can get nullspace'd BEFORE getting removed from the player_list.
		// Testing it on a local machine is totally pointless.
		// I'll remove it once things become clear.
		if(!M.loc)
			util_crash_with("[M] was in nullspace trying to receive [src]'s distant footstep sound!")
			return

		if(M.loc.z != src.loc.z || !istype(get_area(M), /area/maintenance))
			continue

		var/dist = get_dist(get_turf(M), T)

		if(dist >= world.view && dist <= world.view * 3)
			M.playsound_local(src.loc, SFX_DISTANT_MOVEMENT, 100)

/mob/living/silicon/robot/var/step_count = 0

/mob/living/silicon/robot/proc/handle_footsteps()
	var/turf/T = get_turf(src)

	if(!istype(T))
		return

	if(buckled || lying || throwing)
		return // people flying, lying down or sitting do not step

	if(m_intent == M_RUN)
		if(step_count % 2) // every other turf makes a sound
			return

	if(!has_gravity(src))
		if(step_count % 3) // don't need to step as often when you hop around
			return

	play_footstep_sound()
