/turf/simulated/floor/var/global/list/footstep_sounds = list(
	FOOTSTEP_WOOD = list(
		'sound/effects/footstep/wood1.ogg',
		'sound/effects/footstep/wood2.ogg',
		'sound/effects/footstep/wood3.ogg',
		'sound/effects/footstep/wood4.ogg',
		'sound/effects/footstep/wood5.ogg'),
	FOOTSTEP_TILES = list(
		'sound/effects/footstep/floor1.ogg',
		'sound/effects/footstep/floor2.ogg',
		'sound/effects/footstep/floor3.ogg',
		'sound/effects/footstep/floor4.ogg',
		'sound/effects/footstep/floor5.ogg'),
	FOOTSTEP_PLATING =  list(
		'sound/effects/footstep/plating1.ogg',
		'sound/effects/footstep/plating2.ogg',
		'sound/effects/footstep/plating3.ogg',
		'sound/effects/footstep/plating4.ogg',
		'sound/effects/footstep/plating5.ogg'),
	FOOTSTEP_CARPET = list(
		'sound/effects/footstep/carpet1.ogg',
		'sound/effects/footstep/carpet2.ogg',
		'sound/effects/footstep/carpet3.ogg',
		'sound/effects/footstep/carpet4.ogg',
		'sound/effects/footstep/carpet5.ogg'),
	FOOTSTEP_ASTEROID = list(
		'sound/effects/footstep/asteroid1.ogg',
		'sound/effects/footstep/asteroid2.ogg',
		'sound/effects/footstep/asteroid3.ogg',
		'sound/effects/footstep/asteroid4.ogg',
		'sound/effects/footstep/asteroid5.ogg'),
	FOOTSTEP_SNOW = list(
		'sound/effects/footstep/snow1.ogg',
		'sound/effects/footstep/snow2.ogg',
		'sound/effects/footstep/snow3.ogg',
		'sound/effects/footstep/snow4.ogg',
		'sound/effects/footstep/snow5.ogg',
		'sound/effects/footstep/snow6.ogg'),
	FOOTSTEP_GRASS = list(
		'sound/effects/footstep/grass1.ogg',
		'sound/effects/footstep/grass2.ogg',
		'sound/effects/footstep/grass3.ogg',
		'sound/effects/footstep/grass4.ogg'),
	FOOTSTEP_WATER = list(
		'sound/effects/footstep/water1.ogg',
		'sound/effects/footstep/water2.ogg',
		'sound/effects/footstep/water3.ogg',
		'sound/effects/footstep/water4.ogg'),
	FOOTSTEP_BLANK = list(
		'sound/effects/footstep/blank.ogg')
)

/decl/flooring/var/footstep_type
/decl/flooring/footstep_type = FOOTSTEP_BLANK
/decl/flooring/carpet/footstep_type = FOOTSTEP_CARPET
/decl/flooring/tiling/footstep_type = FOOTSTEP_TILES
/decl/flooring/linoleum/footstep_type = FOOTSTEP_TILES
/decl/flooring/wood/footstep_type = FOOTSTEP_WOOD
/decl/flooring/reinforced/footstep_type = FOOTSTEP_PLATING

/turf/simulated/floor/proc/get_footstep_sound()
	if(is_plating())
		return safepick(footstep_sounds[FOOTSTEP_PLATING])
	else if(!flooring || !flooring.footstep_type)
		return safepick(footstep_sounds[FOOTSTEP_BLANK])
	else
		return safepick(footstep_sounds[flooring.footstep_type])

/turf/simulated/floor/asteroid/get_footstep_sound()
	return safepick(footstep_sounds[FOOTSTEP_ASTEROID])

/turf/simulated/floor/exoplanet/get_footstep_sound()
	return safepick(footstep_sounds[FOOTSTEP_CARPET])

/turf/simulated/floor/exoplanet/grass/get_footstep_sound()
	return safepick(footstep_sounds[FOOTSTEP_GRASS])

/turf/simulated/floor/exoplanet/water/shallow/get_footstep_sound()
	return safepick(footstep_sounds[FOOTSTEP_WATER])

/turf/simulated/floor/misc/fixed/get_footstep_sound()
	return safepick(footstep_sounds[FOOTSTEP_PLATING])

/turf/simulated/floor/natural/snow/get_footstep_sound()
	return safepick(footstep_sounds[FOOTSTEP_SNOW])

/turf/simulated/floor/natural/jungle/get_footstep_sound()
	return safepick(footstep_sounds[FOOTSTEP_GRASS])

/turf/simulated/floor/natural/jungle/dirt/get_footstep_sound()
	return safepick(footstep_sounds[FOOTSTEP_ASTEROID])

/turf/simulated/floor/natural/jungle/sand/get_footstep_sound()
	return safepick(footstep_sounds[FOOTSTEP_ASTEROID])

/turf/simulated/floor/natural/sand/get_footstep_sound()
	return safepick(footstep_sounds[FOOTSTEP_ASTEROID])

/turf/simulated/floor/natural/jungle/water/get_footstep_sound()
	return safepick(footstep_sounds[FOOTSTEP_WATER])

/turf/simulated/floor/trim/darkwood/get_footstep_sound()
	return safepick(footstep_sounds[FOOTSTEP_WOOD])

/turf/simulated/floor/Entered(atom/A, atom/OL)
	..()
	if(istype(A, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = A
		H.handle_footsteps()
		H.step_count++
	else if(istype(A, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = A
		R.handle_footsteps()
		R.step_count++

/datum/species/var/silent_steps
/datum/species/nabber/silent_steps = 1

/mob/living/carbon/human/var/step_count

/mob/living/carbon/human/proc/handle_footsteps()
	var/turf/simulated/floor/T = get_turf(src)

	if(!istype(T))
		return

	if(buckled || lying || throwing)
		return //people flying, lying down or sitting do not step

	if(is_cloaked())
		return

	if(m_intent == M_RUN)
		if(step_count % 2) //every other turf makes a sound
			return

	if(species.silent_steps)
		return //species is silent

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

		playsound(T, S, volume, 1, range)

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
			crash_with("[M] was in nullspace trying to receive [src]'s distant footstep sound!")
			return

		if(M.loc.z != src.loc.z || !istype(get_area(M), /area/maintenance))
			continue

		var/dist = get_dist(get_turf(M), T)

		if(dist >= world.view && dist <= world.view * 3)
			M.playsound_local(src.loc, SFX_DISTANT_MOVEMENT, 100)

/mob/living/silicon/robot/var/step_count = 0

/mob/living/silicon/robot/proc/handle_footsteps()
	var/turf/simulated/floor/T = get_turf(src)

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
