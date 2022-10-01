/datum/space_level
	var/path
	var/list/traits
	var/travel_chance = 0
	var/base_turf = /turf/space

/datum/space_level/New()
	var/list/traits_map = list()

	for(var/T in traits)
		traits_map += list("[T]" = TRUE)
	
	traits = traits_map

/datum/space_level/proc/remove_trait(trait)
	traits["[trait]"] = FALSE

/datum/space_level/proc/add_trait(trait)
	traits["[trait]"] = TRUE

/datum/space_level/proc/has_trait(trait)
	return traits[trait]

/datum/space_level/proc/generate(z)
	return
