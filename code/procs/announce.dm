/proc/should_recieve_announce(mob/M, list/contact_levels)
	if (istype(M,/mob/new_player) || isdeaf(M))
		return 0
	if (M.z in (contact_levels | GLOB.using_map.get_levels_with_trait(ZTRAIT_CENTCOM)))
		return 1
	var/turf/loc_turf = get_turf(M.loc) // for mobs in lockers, sleepers, etc.
	if (!loc_turf)
		return 0
	if (loc_turf.z in (contact_levels | GLOB.using_map.get_levels_with_trait(ZTRAIT_CENTCOM)))
		return 1
	return 0

/proc/GetNameAndAssignmentFromId(obj/item/card/id/I)
	// Format currently matches that of newscaster feeds: Registered Name (Assigned Rank)
	return I.assignment ? "[I.registered_name] ([I.assignment])" : I.registered_name

/proc/get_announcement_frequency(datum/job/job)
	// During red alert all jobs are announced on main frequency.
	var/decl/security_state/security_state = decls_repository.get_decl(GLOB.using_map.security_state)
	if (security_state.current_security_level_is_same_or_higher_than(security_state.high_security_level))
		return "Common"

	if(job.department_flag & (COM | CIV | MSC))
		return "Common"
	if(job.department_flag & SUP)
		return "Supply"
	if(job.department_flag & SPT)
		return "Command"
	if(job.department_flag & SEC)
		return "Security"
	if(job.department_flag & ENG)
		return "Engineering"
	if(job.department_flag & MED)
		return "Medical"
	if(job.department_flag & SCI)
		return "Science"
	if(job.department_flag & SRV)
		return "Service"
	if(job.department_flag & EXP)
		return "Exploration"
	return "Common"
