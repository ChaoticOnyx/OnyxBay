

/datum/preferences
	var/job_high = null        //There can be only 1 high priority job
	var/list/job_medium        //List of all things selected for medium weight
	var/list/job_low           //List of all the things selected for low weight
	var/list/player_alt_titles //Alternative names of a job like "Medical Doctor / Surgeon"

	//Keeps track of preferrence for not getting any wanted jobs
	var/alternate_option = RETURN_TO_LOBBY

/datum/category_item/player_setup_item/occupation
	name = "Occupation"
	sort_order = 1

/datum/category_item/player_setup_item/occupation/load_character(datum/pref_record_reader/R)
	pref.alternate_option  = R.read("alternate_option")
	pref.job_high          = R.read("job_high")
	pref.job_medium        = R.read("job_medium")
	pref.job_low           = R.read("job_low")
	pref.player_alt_titles = R.read("player_alt_titles")

/datum/category_item/player_setup_item/occupation/save_character(datum/pref_record_writer/W)
	W.write("alternate_option",  pref.alternate_option)
	W.write("job_high",          pref.job_high)
	W.write("job_medium",        pref.job_medium)
	W.write("job_low",           pref.job_low)
	W.write("player_alt_titles", pref.player_alt_titles)

/datum/category_item/player_setup_item/occupation/sanitize_character()
	pref.job_high = sanitize(pref.job_high, null)

	if(!istype(pref.job_medium))
		pref.job_medium = list()
	else
		for(var/i in 1 to length(pref.job_medium))
			pref.job_medium[i] = sanitize(pref.job_medium[i])

	if(!istype(pref.job_low))
		pref.job_low = list()
	else
		for(var/i in 1 to length(pref.job_low))
			pref.job_low[i] = sanitize(pref.job_low[i])

	pref.alternate_option = sanitize_integer(pref.alternate_option, 0, 2, initial(pref.alternate_option))


	if(!pref.player_alt_titles)
		pref.player_alt_titles = list()

	prune_job_prefs()

	if(!job_master)
		return

	for(var/datum/job/job in job_master.occupations)
		var/alt_title = pref.player_alt_titles[job.title]
		if(alt_title && !(alt_title in job.alt_titles))
			pref.player_alt_titles -= job.title

/datum/category_item/player_setup_item/occupation/content(mob/user, limit = 16, list/splitJobs, splitLimit = 1)
	if(!job_master)
		return

	var/datum/species/S = preference_species()

	. = list()
	. += "<tt><center>"
	. += "<b>Choose occupation chances</b><br>Unavailable occupations are crossed out.<br>"
	. += "<br>"
	. += "<table width='100%' cellpadding='1' cellspacing='0'><tr><td width='20%'>" // Table within a table for alignment, also allows you to easily add more columns.
	. += "<table width='100%' cellpadding='1' cellspacing='0'>"

	var/index = -1
	if(splitLimit)
		limit = round((job_master.occupations.len+1)/2)

	//The job before the current job. I only use this to get the previous jobs color when I'm filling in blank rows.
	var/datum/job/lastJob
	if (!job_master)
		return

	for(var/datum/job/job in job_master.occupations)

		index += 1
		if((index >= limit) || (job.title in splitJobs))
			if((index < limit) && (lastJob != null))
				//If the cells were broken up by a job in the splitJob list then it will fill in the rest of the cells with
				//the last job's selection color. Creating a rather nice effect.
				for(var/i = 0, i < (limit - index), i += 1)
					. += "<tr bgcolor='[lastJob.selection_color]'><td width='60%' align='right'><a>&nbsp</a></td><td><a>&nbsp</a></td></tr>"
			. += "</table></td><td width='20%'><table width='100%' cellpadding='1' cellspacing='0'>"
			index = 0

		. += "<tr bgcolor='[job.selection_color]'><td width='60%' align='right'>"
		var/rank = job.title
		lastJob = job
		if(job.total_positions == 0 && job.spawn_positions == 0)
			. += "<del>[rank]</del></td><td><b> \[UNAVAILABLE]</b></td></tr>"
			continue
		var/bannedReason = jobban_isbanned(user, rank)
		if(bannedReason == "Whitelisted Job")
			. += "<del>[rank]</del></td><td><b> \[WHITELIST]</b></td></tr>"
			continue
		else if (bannedReason == IAA_ban_reason)
			. += "<del>[rank]</del></td><td><b> \[FIRED BY NT]</b></td></tr>"
			continue
		else if(bannedReason)
			. += "<del>[rank]</del></td><td><b> \[BANNED]</b></td></tr>"
			continue

		if(job.faction_restricted)
			if(user.client?.prefs.faction != GLOB.using_map.company_name)
				. += "<del>[rank]</del></td><td><b> \[FOR [uppertext(GLOB.using_map.company_name)] EMPLOYESS ONLY]</b></td></tr>"
				continue
			if(user.client?.prefs.nanotrasen_relation in COMPANY_OPPOSING)
				. += "<del>[rank]</del></td><td><b> \[LOW LOYALTY IS FORBIDDEN]</b></td></tr>"
				continue

		if(!job.player_old_enough(user.client))
			var/available_in_days = job.available_in_days(user.client)
			. += "<del>[rank]</del></td><td> \[IN [(available_in_days)] DAYS]</td></tr>"
			continue
		if(job.minimum_character_age && user.client && (user.client.prefs.age < job.minimum_character_age))
			. += "<del>[rank]</del></td><td> \[MINIMUM CHARACTER AGE: [job.minimum_character_age]]</td></tr>"
			continue

		if(!job.is_species_allowed(S))
			. += "<del>[rank]</del></td><td><b> \[SPECIES RESTRICTED]</b></td></tr>"
			continue

		if(("Assistant" in pref.job_low) && (rank != "Assistant"))
			. += "<font color=grey>[rank]</font></td><td></td></tr>"
			continue
		if((rank in GLOB.command_positions) || (rank == "AI"))//Bold head jobs
			. += "<b>[rank]</b>"
		else
			. += "[rank]"

		. += "</td><td width='40%'>"

		. += "<a href='?src=\ref[src];switch_job=[rank]'>"

		if(rank == "Assistant")//Assistant is special
			if("Assistant" in pref.job_low)
				. += " <font color=55cc55>\[Yes]</font>"
			else
				. += " <font color=black>\[No]</font>"
		else
			if(pref.job_high == job.title)
				. += " <font color=55cc55>\[High]</font>"
			else if(job.title in pref.job_medium)
				. += " <font color=eecc22>\[Medium]</font>"
			else if(job.title in pref.job_low)
				. += " <font color=cc5555>\[Low]</font>"
			else
				. += " <font color=black>\[NEVER]</font>"
		if(job.alt_titles)
			. += "</a></td></tr><tr bgcolor='[lastJob.selection_color]'><td width='60%' align='center'>&nbsp</td><td><a href='?src=\ref[src];select_alt_title=\ref[job]'>\[[pref.GetPlayerAltTitle(job)]\]</a></td></tr>"
		. += "</a></td></tr>"
	. += "</td'></tr></table>"
	. += "</center></table><center>"

	switch(pref.alternate_option)
		if(GET_RANDOM_JOB)
			. += "<u><a href='?src=\ref[src];job_alternative=1'>Get random job if preferences unavailable</a></u>"
		if(BE_ASSISTANT)
			. += "<u><a href='?src=\ref[src];job_alternative=1'>Be assistant if preference unavailable</a></u>"
		if(RETURN_TO_LOBBY)
			. += "<u><a href='?src=\ref[src];job_alternative=1'>Return to lobby if preference unavailable</a></u>"

	. += "<a href='?src=\ref[src];reset_jobs=1'>\[Reset\]</a></center>"
	. += "</tt>"
	. = jointext(.,null)

/datum/category_item/player_setup_item/occupation/OnTopic(href, href_list, user)
	if(href_list["reset_jobs"])
		ResetJobs()
		return TOPIC_REFRESH

	else if(href_list["job_alternative"])
		switch(pref.alternate_option)
			if(GET_RANDOM_JOB)
				pref.alternate_option = BE_ASSISTANT
			if(BE_ASSISTANT)
				pref.alternate_option = RETURN_TO_LOBBY
			if(RETURN_TO_LOBBY)
				pref.alternate_option = GET_RANDOM_JOB
			else
				pref.alternate_option = RETURN_TO_LOBBY
		return TOPIC_REFRESH

	else if(href_list["select_alt_title"])
		var/datum/job/job = locate(href_list["select_alt_title"])
		if (job)
			var/choices = list(job.title) + job.alt_titles
			var/choice = input("Choose an title for [job.title].", "Choose Title", pref.GetPlayerAltTitle(job)) as anything in choices|null
			if(choice && CanUseTopic(user))
				SetPlayerAltTitle(job, choice)
				return (pref.equip_preview_mob ? TOPIC_REFRESH_UPDATE_PREVIEW : TOPIC_REFRESH)

	else if(href_list["switch_job"])
		if(SwitchJobPriority(user, href_list["switch_job"])) return (pref.equip_preview_mob ? TOPIC_REFRESH_UPDATE_PREVIEW : TOPIC_REFRESH)

	return ..()

/datum/category_item/player_setup_item/occupation/proc/SetPlayerAltTitle(datum/job/job, new_title)
	// remove existing entry
	pref.player_alt_titles -= job.title
	// add one if it's not default
	if(job.title != new_title)
		pref.player_alt_titles[job.title] = new_title

/datum/category_item/player_setup_item/occupation/proc/SwitchJobPriority(mob/user, role)
	var/datum/job/job = job_master.GetJob(role)
	if(!job)
		return 0

	if(role == "Assistant")
		if(job.title in pref.job_low)
			pref.job_low -= job.title
		else
			pref.job_low |= job.title
		return 1

	if(role in GLOB.commandjobs)
		SSwarnings.show_warning(user.client, WARNINGS_HEADS, "window=Warning;size=440x300;can_resize=0;can_minimize=0")

	if(job.title == pref.job_high)
		CorrectJobsPriorities(job, JOB_PRIORITY_HIGH)
	else if(job.title in pref.job_medium)
		CorrectJobsPriorities(job, JOB_PRIORITY_MIDDLE)
	else if(job.title in pref.job_low)
		CorrectJobsPriorities(job, JOB_PRIORITY_LOW)
	else
		CorrectJobsPriorities(job, JOB_PRIORITY_NEVER)

	return 1

/datum/category_item/player_setup_item/occupation/proc/CorrectJobsPriorities(datum/job/switched_job, current_priority)
	if(!switched_job || !current_priority)	return 0
	switch(current_priority)
		if(JOB_PRIORITY_HIGH)
			pref.job_high = null
		if(JOB_PRIORITY_MIDDLE)
			pref.job_medium |= pref.job_high
			pref.job_high = switched_job.title
			pref.job_medium -= switched_job.title
		if(JOB_PRIORITY_LOW)
			pref.job_medium |= switched_job.title
			pref.job_low -= switched_job.title
		else
			pref.job_low |= switched_job.title
	return 1

/datum/preferences/proc/IsJobPriority(datum/job/job, priority)
	if(!job || !priority)	return 0
	switch(priority)
		if(JOB_PRIORITY_HIGH)
			return job_high == job.title
		if(JOB_PRIORITY_MIDDLE)
			return !!(job.title in job_medium)
		if(JOB_PRIORITY_LOW)
			return !!(job.title in job_low)
	return 0

/**
 *  Prune a player's job preferences based on current species
 *
 *  This proc goes through all the preferred jobs, and removes the ones incompatible
 */
/datum/category_item/player_setup_item/proc/prune_job_prefs()
	var/allowed_titles = list()

	for(var/job_type in GLOB.using_map.allowed_jobs)
		var/datum/job/job = decls_repository.get_decl(job_type)
		allowed_titles += job.title

		if(!job.is_restricted(pref))
			continue

		if(job.title == pref.job_high)
			pref.job_high = null

		else if(job.title in pref.job_medium)
			pref.job_medium -= job.title

		else if(job.title in pref.job_low)
			pref.job_low -= job.title

	if(pref.job_high && !(pref.job_high in allowed_titles))
		pref.job_high = null

	for(var/job_title in pref.job_medium)
		if(!(job_title in allowed_titles))
			pref.job_medium -= job_title

	for(var/job_title in pref.job_low)
		if(!(job_title in allowed_titles))
			pref.job_low -= job_title

/datum/category_item/player_setup_item/occupation/proc/ResetJobs()
	pref.job_high = null
	pref.job_medium.Cut()
	pref.job_low.Cut()

	pref.player_alt_titles.Cut()

/datum/preferences/proc/GetPlayerAltTitle(datum/job/job)
	return (job.title in player_alt_titles) ? player_alt_titles[job.title] : job.title
