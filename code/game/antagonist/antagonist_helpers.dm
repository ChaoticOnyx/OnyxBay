/datum/antagonist/proc/can_become_antag(datum/mind/player, ignore_role, max_stat = CONSCIOUS)
	if(player.current && jobban_isbanned(player.current, id))
		return FALSE

	if(isliving(player.current) && (player.current.stat > max_stat))
		return FALSE

	var/datum/job/J = job_master.GetJob(player.assigned_role)
	if(is_type_in_list(J, blacklisted_jobs))
		return FALSE

	if(!ignore_role)
		if(player.current && player.current.client)
			var/client/C = player.current.client
			// Limits antag status to clients above player age, if the age system is being used.
			if(C && config.game.use_age_restriction_for_antags && isnum(C.player_age) && isnum(min_player_age) && (C.player_age < min_player_age))
				return 0
		log_debug("can_become_antag: ckey is [player.current.ckey], mob is [player.current], assigned_role is [player.assigned_role ? player.assigned_role : "NOT EXIST"], assigned_job is [player.assigned_job ? player.assigned_job.type : "NOT EXIST"]")
		if(is_type_in_list(J,restricted_jobs))
			return 0
		if(player.current && (player.current.status_flags & NO_ANTAG))
			return 0
	return 1

/datum/antagonist/proc/antags_are_dead()
	for(var/datum/mind/antag in current_antagonists)
		if(mob_path && !istype(antag.current,mob_path))
			continue
		if(antag.current.stat==2)
			continue
		return 0
	return 1

/datum/antagonist/proc/get_antag_count()
	return current_antagonists ? current_antagonists.len : 0

/datum/antagonist/proc/get_active_antag_count()
	var/active_antags = 0
	for(var/datum/mind/player in current_antagonists)
		var/mob/living/L = player.current
		if(!L || L.stat == DEAD)
			continue //no mob or dead
		if(!L.client && !L.teleop)
			continue //SSD
		active_antags++
	return active_antags

/datum/antagonist/proc/is_antagonist(datum/mind/player)
	if(player in current_antagonists)
		return 1

/datum/antagonist/proc/is_type(antag_type)
	if(antag_type == id || antag_type == role_text)
		return 1
	return 0

/datum/antagonist/proc/is_votable()
	return (flags & ANTAG_VOTABLE)

/datum/antagonist/proc/can_late_spawn()
	if(!SSticker.mode)
		return 0
	if(!(id in SSticker.mode.latejoin_antag_tags))
		return 0
	return 1

/datum/antagonist/proc/is_latejoin_template()
	return (flags & (ANTAG_OVERRIDE_MOB|ANTAG_OVERRIDE_JOB))

/proc/all_random_antag_types()
	// No caching as the ANTAG_RANDOM_EXCEPTED flag can be added/removed mid-round.
	var/list/antag_candidates = GLOB.all_antag_types_.Copy()
	for(var/datum/antagonist/antag in antag_candidates)
		if(antag.flags & ANTAG_RANDOM_EXCEPTED)
			antag_candidates -= antag
	return antag_candidates
