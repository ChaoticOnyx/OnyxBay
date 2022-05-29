/datum/map
	var/species_to_job_whitelist = list(
		/datum/species/tajaran = list(
			/datum/job/assistant,
			/datum/job/bartender,
			/datum/job/chef,
			/datum/job/hydro,
			/datum/job/cargo_tech,
			/datum/job/mining,
			/datum/job/janitor,
			/datum/job/librarian,
			/datum/job/merchant
		),
		/datum/species/unathi = list(
			/datum/job/assistant,
			/datum/job/bartender,
			/datum/job/chef,
			/datum/job/hydro,
			/datum/job/cargo_tech,
			/datum/job/mining,
			/datum/job/janitor,
			/datum/job/librarian,
			/datum/job/officer,
			/datum/job/merchant
		),
		/datum/species/skrell = list(
			/datum/job/assistant,
			/datum/job/bartender,
			/datum/job/chef,
			/datum/job/hydro,
			/datum/job/janitor,
			/datum/job/librarian,
			/datum/job/doctor,
			/datum/job/virologist,
			/datum/job/chemist,
			/datum/job/psychiatrist,
			/datum/job/scientist,
			/datum/job/xenobiologist,
			/datum/job/roboticist,
			/datum/job/merchant
		)
	)
	var/species_to_job_blacklist = list()

	var/job_to_species_whitelist = list()
	var/job_to_species_blacklist = list()

// The white, and blacklist are type specific, any subtypes (of both species and jobs) have to be added explicitly
/datum/map/proc/is_species_job_restricted(datum/species/S, datum/job/J)
	if(!istype(S) || !istype(J))
		return TRUE

	var/list/whitelist = species_to_job_whitelist[S.type]
	if(whitelist)
		return !(J.type in whitelist)

	whitelist = job_to_species_whitelist[J.type]
	if(whitelist)
		return !(S.type in whitelist)

	var/list/blacklist = species_to_job_blacklist[S.type]
	if(blacklist)
		return (J.type in blacklist)

	blacklist = job_to_species_blacklist[J.type]
	if(blacklist)
		return (S.type in blacklist)

	return FALSE
