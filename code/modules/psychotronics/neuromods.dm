/mob
	var/list/datum/neuromod/neuromods	// Contains paths

/* BASE DATUM */

/datum/neuromod
	var/name = "Name"
	var/desc = "Description"
	var/chance = 0				// Chance to be unlocked after scan
	var/research_time = 100		// How long this neuromod takes to research

/datum/neuromod/proc/ToList()
	var/list/N = list()

	N["name"] 			= name
	N["desc"] 			= desc
	N["type"] 			= type
	N["chance"]			= chance
	N["research_time"] 	= research_time

	return N

/* -- LIGHT REGENERATION -- */

/datum/neuromod/lightRegeneration
	name = "Light Regeneration"
	desc = "The neuromod changes skin structure and makes possible cure wounds just by light."
	chance = 25
