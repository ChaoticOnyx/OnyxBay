/// Associative list [type] -> [/datum/rad_resist]
GLOBAL_LIST_INIT(rad_resists_cache, generate_rad_resist_cache())

/proc/generate_rad_resist_cache()
	var/list/resist_cache = list()
	for(var/datum/rad_resist/resist as anything in subtypesof(/datum/rad_resist))
		resist = new resist()
		resist_cache[resist.type] = resist
	return resist_cache

/proc/get_rad_resist(resist_type)
	if(resist_type == /datum/rad_resist)
		CRASH("Attempted to get base rad resist type!")

	var/datum/rad_resist/resist = GLOB.rad_resists_cache[resist_type]
	if(istype(resist))
		return resist

	CRASH("Attempted to get a resist type that did not exist! '[resist_type]'")

/proc/get_rad_resist_value(resist_type, value)
	var/datum/rad_resist/resist = get_rad_resist(resist_type)
	switch(value)
		if(RADIATION_ALPHA_PARTICLE)
			return resist.alpha_particle_resist

		if(RADIATION_BETA_PARTICLE)
			return resist.beta_particle_resist

		if(RADIATION_HAWKING)
			return resist.hawking_resist

		else
			util_crash_with("Attempted to get a non-existing rad resist value [value], from [resist_type]!")
			return 0 // Better than null, whatever called this function is less likely to runtime this way.

/datum/rad_resist
	var/alpha_particle_resist = 0
	var/beta_particle_resist = 0
	var/hawking_resist = 0

/datum/rad_resist/none
