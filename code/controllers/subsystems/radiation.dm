GLOBAL_DATUM_INIT(rad_instance, /datum/radiation, new(1, RADIATION_ALPHA_PARTICLE))

SUBSYSTEM_DEF(radiation)
	name = "Radiation"
	wait = 2 SECONDS
	priority = SS_PRIORITY_RADIATION
	flags = SS_NO_INIT

	var/list/sources = list()			// all radiation source datums

	var/tmp/list/current_sources   = list()
	var/tmp/list/listeners         = list()

/datum/controller/subsystem/radiation/fire(resumed = FALSE)
	if (!resumed)
		current_sources = sources.Copy()
		listeners = GLOB.living_mob_list_.Copy()

	while(current_sources.len)
		var/datum/radiation_source/S = current_sources[current_sources.len]
		current_sources.len--

		if(QDELETED(S))
			sources -= S
		else if(QDELETED(S.holder) || get_turf(S.holder) == null)
			qdel(S)
		if (MC_TICK_CHECK)
			return

	if(!sources.len)
		listeners.Cut()

	while(listeners.len)
		var/mob/A = listeners[listeners.len]
		listeners.len--

		if(!QDELETED(A))
			var/turf/T = get_turf(A)

			// TODO: REVERT THIS WHEN WE FIND THE MOTHERFUCKER
			if(T == null)
				log_debug("NULLSPACE ALERT: [A.name] | loc: `[A.loc]` | ckey: `[A.ckey]`")
				continue

			for(var/datum/radiation_source/source in sources)
				if(source.info.activity <= 0 || source.info.energy <= 0)
					qdel(source)

				var/turf/source_turf = get_turf(source.holder)

				if(source_turf.z != T.z)
					continue // Radiation is not multi-z

				var/dist = get_dist(T, source_turf)
				if(dist > source.range)
					continue

				var/E = source.info.energy / RADIATION_DISTANCE_MULT(dist)

				if(isobj(source.holder))
					var/obj/current_obj = source.holder
					E = max(E - RADIATION_CALC_OBJ_RESIST(source.info, current_obj), 0)

				if(E < RADIATION_MIN_IONIZATION)
					continue

				if(source.flat)
					if(source.respect_maint)
						var/area/AR = T.loc
						if(AR.area_flags & AREA_FLAG_RAD_SHIELDED)
							continue // In shielded area

					A.rad_act(source, T)
				else
					A.rad_act(source, source.holder)
		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/radiation/stat_entry()
	..("S:[sources.len]")

/// Returns Gy
/datum/controller/subsystem/radiation/proc/get_total_absorbed_dose_at_turf(turf/T, weight = AVERAGE_HUMAN_WEIGHT)
	var/list/sources = get_sources_in_range(T)
	var/dose = 0

	for(var/datum/radiation_source/source in sources)
		var/datum/radiation/R = source.travel(T)

		dose += R.calc_absorbed_dose(weight)

	return dose

/datum/controller/subsystem/radiation/proc/get_sources_in_range(atom/target)
	var/list/result = list()
	var/turf/target_turf = get_turf(target)

	for(var/datum/radiation_source/source in sources)
		var/turf/source_turf = get_turf(source.holder)

		if(QDELETED(source.holder) || !source_turf) // Duct taping this since getting >1k runtimes per min is painful
			return // TODO: Find out why the fuck it ever goes "Runtime in radiation.dm, line 79 (83 now): Cannot read null.z"

		if(source_turf.z != target_turf.z)
			continue // Radiation is not multi-z

		if(source.respect_maint)
			var/area/A = target_turf.loc
			if(A.area_flags & AREA_FLAG_RAD_SHIELDED)
				continue // In shielded area

		if(source.flat)
			result += source
			continue

		var/dist = get_dist(source_turf, target_turf)

		if(dist > source.range)
			continue

		result += source

	return result

// Add a radiation source instance to the repository.
/datum/controller/subsystem/radiation/proc/add_source(datum/radiation_source/S)
	sources += S

/datum/controller/subsystem/radiation/proc/del_source(datum/radiation_source/S)
	sources -= S

/// Creates a radiation source and reutrns it.
/datum/controller/subsystem/radiation/proc/radiate(atom/source, datum/radiation/rad_info) // Sends out a radiation pulse, taking walls into account
	if(!(source && rad_info)) //Sanity checking
		return

	if(source.atom_flags & ATOM_FLAG_IGNORE_RADIATION)
		return

	var/datum/radiation_source/S = new(rad_info, source)
	add_source(S)

	return S

/// Sets the radiation in a range to a constant value. Returns source.
/datum/controller/subsystem/radiation/proc/flat_radiate(atom/source, datum/radiation/rad_info, range, respect_maint = FALSE)
	if(!(source && rad_info && range))
		return

	if(source.atom_flags & ATOM_FLAG_IGNORE_RADIATION)
		return

	var/datum/radiation_source/S = new(rad_info, source)
	S.flat = TRUE
	S.range = range
	S.respect_maint = respect_maint
	add_source(S)

	return S

/// Irradiates a full Z-level. Hacky way of doing it, but not too expensive. Returns source.
/datum/controller/subsystem/radiation/proc/z_radiate(atom/source, datum/radiation/rad_info, respect_maint = FALSE)
	if(!(rad_info && source))
		return
	var/turf/epicentre = locate(round(world.maxx / 2), round(world.maxy / 2), source.z)
	return flat_radiate(epicentre, rad_info, world.maxx, respect_maint)
