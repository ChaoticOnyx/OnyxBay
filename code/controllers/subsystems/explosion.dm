#define EXPLOSION_THROW_SPEED 0.5
GLOBAL_LIST_EMPTY(explosions)

SUBSYSTEM_DEF(explosions)
	name = "Explosions"
	init_order = SS_INIT_EXPLOSIONS
	priority = SS_PRIORITY_EXPLOSION
	wait = 1
	flags = SS_TICKER|SS_NO_INIT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/cost_lowturf = 0
	var/cost_medturf = 0
	var/cost_highturf = 0

	var/cost_throwturf = 0

	var/cost_low_mov_atom = 0
	var/cost_med_mov_atom = 0
	var/cost_high_mov_atom = 0

	var/list/lowturf = list()
	var/list/medturf = list()
	var/list/highturf = list()

	var/list/throwturf = list()

	var/list/low_mov_atom = list()
	var/list/med_mov_atom = list()
	var/list/high_mov_atom = list()

	var/list/explosions = list()

	var/currentpart = SSEXPLOSIONS_TURFS

/datum/controller/subsystem/explosions/stat_entry()
	var/msg = ""
	msg += "C:{"
	msg += "LT:[round(cost_lowturf,1)]|"
	msg += "MT:[round(cost_medturf,1)]|"
	msg += "HT:[round(cost_highturf,1)]|"

	msg += "LO:[round(cost_low_mov_atom,1)]|"
	msg += "MO:[round(cost_med_mov_atom,1)]|"
	msg += "HO:[round(cost_high_mov_atom,1)]|"

	msg += "TO:[round(cost_throwturf,1)]"

	msg += "} "

	msg += "AMT:{"
	msg += "LT:[lowturf.len]|"
	msg += "MT:[medturf.len]|"
	msg += "HT:[highturf.len]|"

	msg += "LO:[low_mov_atom.len]|"
	msg += "MO:[med_mov_atom.len]|"
	msg += "HO:[high_mov_atom.len]|"

	msg += "TO:[throwturf.len]"

	msg += "} "

	..(msg)

#define SSEX_TURF "turf"
#define SSEX_OBJ "obj"

/datum/controller/subsystem/explosions/proc/is_exploding()
	return (lowturf.len || medturf.len || highturf.len || throwturf.len || low_mov_atom.len || med_mov_atom.len || high_mov_atom.len)

/datum/controller/subsystem/explosions/proc/wipe_turf(turf/T)
	lowturf -= T
	medturf -= T
	highturf -= T
	throwturf -= T

/**
 * Handles the effects of an explosion originating from a given point.
 *
 * Primarily handles popagating the balstwave of the explosion to the relevant turfs.
 * Also handles the fireball from the explosion.
 * Also handles the smoke cloud from the explosion.
 * Also handles sfx and screenshake.
 *
 * Arguments:
 * - [epicenter][/turf]: The turf that's exploding.
 * - devastation_range: The range at which the effects of the explosion are at their strongest.
 * - heavy_impact_range: The range at which the effects of the explosion are relatively severe.
 * - light_impact_range: The range at which the effects of the explosion are relatively weak.
 * - flash_range: The range at which the explosion flashes people.
 * - adminlog: Whether to log the explosion/report it to the administration.
 * - z_transfer: flags that tells if we need to create another explosion on turf.
 * - shaped: if true make explosions look like circle
 * - sfx_to_play: sound to play, when expolosion near player
 */
/datum/controller/subsystem/explosions/proc/explode(turf/epicenter, devastation_range = 0, heavy_impact_range = 0, light_impact_range = 0, flash_range = 0, adminlog = 1, z_transfer = UP|DOWN, shaped, sfx_to_play = SFX_EXPLOSION)
	epicenter = get_turf(epicenter)
	ASSERT(isturf(epicenter))
	if(isnull(flash_range))
		flash_range = devastation_range

	var/approximate_intensity = (devastation_range * 3) + (heavy_impact_range * 2) + light_impact_range
	// Large enough explosion. For performance reasons, powernets will be rebuilt manually
	if(!defer_powernet_rebuild && (approximate_intensity > 25))
		defer_powernet_rebuild = 1

	// Handles recursive propagation of explosions.
	if(z_transfer)
		var/multi_z_scalar = 0.35
		var/adj_dev   = max(0, (multi_z_scalar * devastation_range) - (shaped ? 2 : 0) )
		var/adj_heavy = max(0, (multi_z_scalar * heavy_impact_range) - (shaped ? 2 : 0) )
		var/adj_light = max(0, (multi_z_scalar * light_impact_range) - (shaped ? 2 : 0) )
		var/adj_flash = max(0, (multi_z_scalar * flash_range) - (shaped ? 2 : 0) )


		if(adj_dev > 0 || adj_heavy > 0)
			if(HasAbove(epicenter.z) && z_transfer & UP)
				SSexplosions.explode(GetAbove(epicenter), round(adj_dev), round(adj_heavy), round(adj_light), round(adj_flash), 0, UP, shaped)
			if(HasBelow(epicenter.z) && z_transfer & DOWN)
				SSexplosions.explode(GetBelow(epicenter), round(adj_dev), round(adj_heavy), round(adj_light), round(adj_flash), 0, DOWN, shaped)


	var/orig_max_distance = max(devastation_range, heavy_impact_range, light_impact_range, flash_range)

	var/max_range = max(devastation_range, heavy_impact_range, light_impact_range)
	var/started_at = REALTIMEOFDAY
	if(adminlog)
		message_admins("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range]) in <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[epicenter.x];Y=[epicenter.y];Z=[epicenter.z]'>(x:[epicenter.x], y:[epicenter.y], z:[epicenter.z])</a>")
		log_game("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range]) in (x:[epicenter.x], y:[epicenter.y], z:[epicenter.z])")

	var/x0 = epicenter.x
	var/y0 = epicenter.y
	var/z0 = epicenter.z

	// Play sounds; we want sounds to be different depending on distance so we will manually do it ourselves.
	// Stereo users will also hear the direction of the explosion!

	// Calculate far explosion sound range. Only allow the sound effect for heavy/devastating explosions.
	// 3/7/14 will calculate to 80 + 35

	var/far_dist = 0
	far_dist += heavy_impact_range * 15
	far_dist += devastation_range * 20

	shake_the_room(epicenter, orig_max_distance, far_dist, devastation_range, heavy_impact_range, near_sound = sfx_to_play)

	if(heavy_impact_range > 1)
		var/datum/effect/system/explosion/E = new()
		E.set_up(epicenter)
		E.start()
	//flash mobs
	if(flash_range)
		for(var/mob/living/O in viewers(flash_range, epicenter))
			var/flash_time = 10
			if(istype(O, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = O
				if(!H.eyecheck() <= 0)
					continue
				flash_time = round(H.species.flash_mod * flash_time)
				var/obj/item/organ/internal/eyes/E = H.internal_organs_by_name[BP_EYES]
				if(!E)
					return
				if(E.is_bruised() && prob(E.damage + 50))
					H.flash_eyes()
					E.damage += rand(1, 5)
			if(!O.blinded)
				if (istype(O,/mob/living/silicon/ai))
					return
				if (istype(O,/mob/living/silicon/robot))
					var/mob/living/silicon/robot/R = O
					if (R.sensor_mode == FLASH_PROTECTION_VISION)
						return
				O.flash_eyes()
				O.eye_blurry += flash_time
				O.confused += (flash_time + 2)
				O.Stun(flash_time / 2)
				O.Weaken(3)

	var/list/affected_turfs = GatherSpiralTurfs(max_range, epicenter)

	var/reactionary = config.game.use_recursive_explosions
	var/list/cached_exp_block

	if(reactionary)
		cached_exp_block = CaculateExplosionBlock(affected_turfs)

	//lists are guaranteed to contain at least 1 turf at this point

	for(var/TI in affected_turfs)
		var/turf/T = TI
		var/init_dist = cheap_hypotenuse(T.x, T.y, x0, y0)
		var/dist = init_dist

		if(reactionary)
			var/turf/Trajectory = T
			while(Trajectory != epicenter)
				Trajectory = get_step_towards(Trajectory, epicenter)
				dist += cached_exp_block[Trajectory]

		var/throw_dist = dist

		if(dist < devastation_range)
			dist = EXPLODE_DEVASTATE
		else if(dist < heavy_impact_range)
			dist = EXPLODE_HEAVY
		else if(dist < light_impact_range)
			dist = EXPLODE_LIGHT
		else
			dist = EXPLODE_NONE

		if(T == epicenter) // Ensures explosives detonating from bags trigger other explosives in that bag
			var/list/items = list()
			for(var/I in T)
				var/atom/A = I
				if(length(A.contents) && !T.protects_atom(A)) //The atom/contents_explosion() proc returns null if the contents ex_acting has been handled by the atom, and TRUE if it hasn't.
					var/list/AllContents = A.GetAllContents()
					for(var/atom_movable in AllContents)	//bypass type checking since only atom/movable can be contained by turfs anyway
						var/atom/movable/AM = atom_movable
						if(AM && AM.simulated && !T.protects_atom(AM))
							AllContents.Remove(atom_movable)
					items += AllContents
				items += A
			for(var/thing in items)
				var/atom/movable/movable_thing = thing
				if(QDELETED(movable_thing))
					continue
				switch(dist)
					if(EXPLODE_DEVASTATE)
						SSexplosions.high_mov_atom += movable_thing
					if(EXPLODE_HEAVY)
						SSexplosions.med_mov_atom += movable_thing
					if(EXPLODE_LIGHT)
						SSexplosions.low_mov_atom += movable_thing
		else
			for(var/thing in T.contents)
				var/atom/movable/movable_thing = thing
				if(QDELETED(movable_thing))
					continue
				if(movable_thing?.simulated)
					switch(dist)
						if(EXPLODE_DEVASTATE)
							SSexplosions.high_mov_atom += movable_thing
						if(EXPLODE_HEAVY)
							SSexplosions.med_mov_atom += movable_thing
						if(EXPLODE_LIGHT)
							if(T.protects_atom(movable_thing))
								continue
							SSexplosions.low_mov_atom += movable_thing
		switch(dist)
			if(EXPLODE_DEVASTATE)
				SSexplosions.highturf += T
			if(EXPLODE_HEAVY)
				SSexplosions.medturf += T
			if(EXPLODE_LIGHT)
				SSexplosions.lowturf += T

		//--- THROW ITEMS AROUND ---
		var/throw_dir = get_dir(epicenter,T)
		var/throw_range = max_range-throw_dist
		var/list/throwingturf = T.explosion_throw_details
		if (throwingturf)
			if (throwingturf[1] < throw_range)
				throwingturf[1] = throw_range
				throwingturf[2] = throw_dir
				throwingturf[3] = max_range
		else
			T.explosion_throw_details = list(throw_range, throw_dir, max_range)
			throwturf += T

	//You need to press the DebugGame verb to see these now....they were getting annoying and we've collected a fair bit of data. Just -test- changes  to explosion code using this please so we can compare
	if(Debug2)
		var/took = (REALTIMEOFDAY - started_at) / 10
		log_debug("## DEBUG: Explosion([x0],[y0],[z0])(d[devastation_range],h[heavy_impact_range],l[light_impact_range]): Took [took] seconds.")

// Explosion SFX defines...
/// The probability that a quaking explosion will make the station creak per unit. Maths!
#define QUAKE_CREAK_PROB 30
/// The probability that an echoing explosion will make the station creak per unit.
#define ECHO_CREAK_PROB 5
/// Time taken for the hull to begin to creak after an explosion, if applicable.
#define CREAK_DELAY (5 SECONDS)
/// Lower limit for far explosion SFX volume.
#define FAR_LOWER 40
/// Upper limit for far explosion SFX volume.
#define FAR_UPPER 60
/// The probability that a distant explosion SFX will be a far explosion sound rather than an echo. (0-100)
#define FAR_SOUND_PROB 75
/// The upper limit on screenshake amplitude for nearby explosions.
#define NEAR_SHAKE_CAP 10
/// The upper limit on screenshake amplifude for distant explosions.
#define FAR_SHAKE_CAP 2.5
/// The duration of the screenshake for nearby explosions.
#define NEAR_SHAKE_DURATION (2.5 SECONDS)
/// The duration of the screenshake for distant explosions.
#define FAR_SHAKE_DURATION (1 SECONDS)
/// The lower limit for the randomly selected hull creaking frequency.
#define FREQ_LOWER 25
/// The upper limit for the randomly selected hull creaking frequency.
#define FREQ_UPPER 40

/**
 * Handles the sfx and screenshake caused by an explosion.
 *
 * Arguments:
 * - [epicenter][/turf]: The location of the explosion.
 * - near_distance: How close to the explosion you need to be to get the full effect of the explosion.
 * - far_distance: How close to the explosion you need to be to hear more than echos.
 * - quake_factor: Main scaling factor for screenshake.
 * - echo_factor: Whether to make the explosion echo off of very distant parts of the station.
 * - creaking: Whether to make the station creak. Autoset if null.
 * - [near_sound][/sound]: The sound that plays if you are close to the explosion.
 * - [far_sound][/sound]: The sound that plays if you are far from the explosion.
 * - [echo_sound][/sound]: The sound that plays as echos for the explosion.
 * - [creaking_sound][/sound]: The sound that plays when the station creaks during the explosion.
 * - [hull_creaking_sound][/sound]: The sound that plays when the station creaks after the explosion.
 */
/datum/controller/subsystem/explosions/proc/shake_the_room(turf/epicenter, near_distance, far_distance, quake_factor, echo_factor, creaking, near_sound = SFX_EXPLOSION, far_sound = "far_explosion")
	var/frequency = get_rand_frequency()
	var/blast_z = epicenter.z
	if(isnull(creaking)) // Autoset creaking.
		var/on_station = (epicenter.z in GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION))
		if(on_station && prob((quake_factor * QUAKE_CREAK_PROB) + (echo_factor * ECHO_CREAK_PROB))) // Huge explosions are near guaranteed to make the station creak and whine, smaller ones might.
			creaking = TRUE // prob over 100 always returns true
		else
			creaking = FALSE

	if(creaking)
		SSmachines.flicker_all_lights()

	for(var/mob/listener as anything in GLOB.player_list)
		var/turf/listener_turf = get_turf(listener)
		if(!listener_turf || listener_turf.z != blast_z)
			continue

		var/distance = get_dist(epicenter, listener_turf)
		var/base_shake_amount
		if(near_distance > distance)
			base_shake_amount = sqrt((near_distance - distance) / 10)

		if(distance <= round(near_distance + world.view - 2, 1)) // If you are close enough to see the effects of the explosion first-hand (ignoring walls)
			listener.playsound_local(epicenter, near_sound, 100, TRUE, frequency, FALSE, falloff = 5)
			if(base_shake_amount > 0)
				shake_camera(listener, NEAR_SHAKE_DURATION, clamp(base_shake_amount, 0, NEAR_SHAKE_CAP))

		else if(distance < far_distance) // You can hear a far explosion if you are outside the blast radius. Small explosions shouldn't be heard throughout the station.
			var/far_volume = clamp(far_distance / 2, FAR_LOWER, FAR_UPPER)
			listener.playsound_local(epicenter, far_sound, far_volume, FALSE, falloff = 5)

			if(base_shake_amount || quake_factor)
				if(!base_shake_amount) // Devastating explosions rock the station and ground
					base_shake_amount = quake_factor * 3
				shake_camera(listener, FAR_SHAKE_DURATION, clamp(base_shake_amount / 4, 0, FAR_SHAKE_CAP))

#undef CREAK_DELAY
#undef QUAKE_CREAK_PROB
#undef ECHO_CREAK_PROB
#undef FAR_UPPER
#undef FAR_LOWER
#undef FAR_SOUND_PROB
#undef NEAR_SHAKE_CAP
#undef FAR_SHAKE_CAP
#undef NEAR_SHAKE_DURATION
#undef FAR_SHAKE_DURATION
#undef FREQ_UPPER
#undef FREQ_LOWER

/datum/controller/subsystem/explosions/proc/GatherSpiralTurfs(range, turf/epicenter)
	var/list/outlist = list()
	var/center = epicenter
	var/dist = range
	if(!dist)
		outlist += center
		return outlist

	var/turf/t_center = get_turf(center)
	if(!t_center)
		return outlist

	var/list/L = outlist
	var/turf/T
	var/y
	var/x
	var/c_dist = 1
	L += t_center

	while( c_dist <= dist )
		y = t_center.y + c_dist
		x = t_center.x - c_dist + 1
		for(x in x to t_center.x+c_dist)
			T = locate(x,y,t_center.z)
			if(T)
				L += T

		y = t_center.y + c_dist - 1
		x = t_center.x + c_dist
		for(y in t_center.y-c_dist to y)
			T = locate(x,y,t_center.z)
			if(T)
				L += T

		y = t_center.y - c_dist
		x = t_center.x + c_dist - 1
		for(x in t_center.x-c_dist to x)
			T = locate(x,y,t_center.z)
			if(T)
				L += T

		y = t_center.y - c_dist + 1
		x = t_center.x - c_dist
		for(y in y to t_center.y+c_dist)
			T = locate(x,y,t_center.z)
			if(T)
				L += T
		c_dist++
	. = L

/datum/controller/subsystem/explosions/proc/CaculateExplosionBlock(list/affected_turfs)
	. = list()
	var/I
	for(I in 1 to affected_turfs.len) // we cache the explosion block rating of every turf in the explosion area
		var/turf/T = affected_turfs[I]
		var/current_exp_block = T.density ? T.explosion_block : 0

		for(var/obj/O in T)
			var/the_block = O.explosion_block
			current_exp_block += the_block == EXPLOSION_BLOCK_PROC ? O.GetExplosionBlock() : the_block

		.[T] = current_exp_block
/datum/controller/subsystem/explosions/fire(resumed = 0)
	if (!is_exploding())
		return
	var/timer
	Master.current_ticklimit = TICK_LIMIT_RUNNING //force using the entire tick if we need it. Insane TG devs.

	if(currentpart == SSEXPLOSIONS_TURFS)
		currentpart = SSEXPLOSIONS_MOVABLES

		timer = TICK_USAGE
		while(length(lowturf))
			if(MC_TICK_CHECK)
				break
			var/turf/turf_thing = lowturf[lowturf.len]
			lowturf.len--
			if(!isturf(turf_thing))
				continue
			turf_thing.ex_act(EXPLODE_LIGHT)
		cost_lowturf = MC_AVERAGE(cost_lowturf, TICK_DELTA_TO_MS(TICK_USAGE - timer))

		if(MC_TICK_CHECK)
			if(lowturf.len || medturf.len || highturf.len)
				Master.laggy_byond_map_update_incoming()
			currentpart = SSEXPLOSIONS_TURFS
			return

		timer = TICK_USAGE
		while(length(medturf))
			if(MC_TICK_CHECK)
				break
			var/turf/turf_thing = medturf[medturf.len]
			medturf.len--
			if(!isturf(turf_thing))
				continue
			turf_thing.ex_act(EXPLODE_HEAVY)
		cost_medturf = MC_AVERAGE(cost_medturf, TICK_DELTA_TO_MS(TICK_USAGE - timer))

		if(MC_TICK_CHECK)
			if(lowturf.len || medturf.len || highturf.len)
				Master.laggy_byond_map_update_incoming()
			currentpart = SSEXPLOSIONS_TURFS
			return

		timer = TICK_USAGE
		while(length(highturf))
			if(MC_TICK_CHECK)
				break
			var/turf/turf_thing = highturf[highturf.len]
			highturf.len--
			if(!isturf(turf_thing))
				continue
			turf_thing.ex_act(EXPLODE_DEVASTATE)
		cost_highturf = MC_AVERAGE(cost_highturf, TICK_DELTA_TO_MS(TICK_USAGE - timer))

		if(MC_TICK_CHECK)
			if(lowturf.len || medturf.len || highturf.len)
				Master.laggy_byond_map_update_incoming()
			currentpart = SSEXPLOSIONS_TURFS
			return

		timer = TICK_USAGE

	if(currentpart == SSEXPLOSIONS_MOVABLES)
		currentpart = SSEXPLOSIONS_THROWS

		timer = TICK_USAGE
		while(length(high_mov_atom))
			if(MC_TICK_CHECK)
				break
			var/atom/movable/movable_thing = high_mov_atom[high_mov_atom.len]
			high_mov_atom.len--
			if(QDELETED(movable_thing))
				continue
			movable_thing.ex_act(EXPLODE_DEVASTATE)
		cost_high_mov_atom = MC_AVERAGE(cost_high_mov_atom, TICK_DELTA_TO_MS(TICK_USAGE - timer))

		if(MC_TICK_CHECK)
			currentpart = SSEXPLOSIONS_MOVABLES
			return

		timer = TICK_USAGE
		while(length(med_mov_atom))
			if(MC_TICK_CHECK)
				break
			var/atom/movable/movable_thing = med_mov_atom[med_mov_atom.len]
			med_mov_atom.len--
			if(QDELETED(movable_thing))
				continue
			movable_thing.ex_act(EXPLODE_HEAVY)
		cost_med_mov_atom = MC_AVERAGE(cost_med_mov_atom, TICK_DELTA_TO_MS(TICK_USAGE - timer))

		if(MC_TICK_CHECK)
			currentpart = SSEXPLOSIONS_MOVABLES
			return

		timer = TICK_USAGE
		while(length(low_mov_atom))
			if(MC_TICK_CHECK)
				break
			var/atom/movable/movable_thing = low_mov_atom[low_mov_atom.len]
			low_mov_atom.len--
			if(QDELETED(movable_thing))
				continue
			movable_thing.ex_act(EXPLODE_LIGHT)
		cost_low_mov_atom = MC_AVERAGE(cost_low_mov_atom, TICK_DELTA_TO_MS(TICK_USAGE - timer))

		if(MC_TICK_CHECK)
			return

	if (currentpart == SSEXPLOSIONS_THROWS) // throw is fine enougth, some lags are fine.
		currentpart = SSEXPLOSIONS_TURFS
		timer = TICK_USAGE
		while(length(throwturf))
			if(MC_TICK_CHECK)
				break
			var/thing = throwturf[throwturf.len]
			throwturf.len--
			var/turf/T = thing
			if(isturf(T))
				continue
			var/list/L = T.explosion_throw_details
			T.explosion_throw_details = null
			if(length(L) != 3)
				continue
			var/throw_range = L[1]
			var/throw_dir = L[2]
			var/max_range = L[3]
			for(var/atom/movable/A in T)
				if(QDELETED(A))
					continue
				if(!A.anchored)
					var/atom_throw_range = rand(throw_range, max_range)
					var/turf/throw_at = get_ranged_target_turf(A, throw_dir, atom_throw_range)
					A.throw_at(throw_at, atom_throw_range, EXPLOSION_THROW_SPEED)
		if(MC_TICK_CHECK)
			currentpart = SSEXPLOSIONS_THROWS
			return
		cost_throwturf = MC_AVERAGE(cost_throwturf, TICK_DELTA_TO_MS(TICK_USAGE - timer))

	currentpart = SSEXPLOSIONS_TURFS
