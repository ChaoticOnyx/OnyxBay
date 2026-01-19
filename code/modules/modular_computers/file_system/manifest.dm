GLOBAL_LIST_EMPTY(dept_data)

/proc/manifest_data_initialization(monochrome = FALSE, OOC = FALSE, prediction = FALSE)
	var/key = prediction ? "all_jobs_in_dept" : "names"

	GLOB.dept_data = list(
		list("[key]" = list(), "header" = "Heads of Staff", "flag" = COM),
		list("[key]" = list(), "header" = "Command Support", "flag" = SPT),
		list("[key]" = list(), "header" = "Research", "flag" = SCI),
		list("[key]" = list(), "header" = "Security", "flag" = SEC),
		list("[key]" = list(), "header" = "Medical", "flag" = MED),
		list("[key]" = list(), "header" = "Engineering", "flag" = ENG),
		list("[key]" = list(), "header" = "Cargo", "flag" = SUP),
		list("[key]" = list(), "header" = "Exploration", "flag" = EXP),
		list("[key]" = list(), "header" = "Provisioning", "flag" = SRV),
		list("[key]" = list(), "header" = "Civilian", "flag" = CIV),
		list("[key]" = list(), "header" = "Miscellaneous", "flag" = MSC),
		list("[key]" = list(), "header" = "Silicon")
	)

	var/dat = {"
	<head><style>
		.manifest {border-collapse:collapse;}
		.manifest td, th {border:1px solid [monochrome?"black":"[OOC?"black; background-color:#272727; color:white":"#DEF; background-color:white; color:black"]"]; padding:.25em}
		.manifest th {height: 2em; [monochrome?"border-top-width: 3px":"background-color: [OOC?"#40628A":"#48C"]; color:white"]}
		.manifest tr.head th { [monochrome?"border-top-width: 1px":"background-color: [OOC?"#013D3B;":"#488;"]"] }
		.manifest td:first-child {text-align:right}
		.manifest tr.alt td {[monochrome?"border-top-width: 2px":"background-color: [OOC?"#373737; color:white":"#DEF"]"]}
	</style></head>
	<table class="manifest" width='350px'>
	<tr class='head'><th>Name</th><th>Position</th><th>[prediction?"Chances":"Activity"]</th></tr>
	"}

	return dat

// Generates a simple HTML crew manifest for use in various places
/proc/html_crew_manifest(monochrome, OOC)
	var/dat = manifest_data_initialization(monochrome, OOC)
	var/list/misc //Special departments for easier access
	var/list/bot

	for(var/list/department in GLOB.dept_data)
		if(department["flag"] == MSC)
			misc = department["names"]
		if(isnull(department["flag"]))
			bot = department["names"]

	var/list/isactive = list()

	// sort mobs
	for(var/datum/computer_file/crew_record/CR in GLOB.all_crew_records)
		var/name = CR.get_name()
		var/rank = CR.get_job()

		if(OOC)
			var/active = 0
			for(var/mob/M in GLOB.player_list)
				if(M.real_name == name && M.client && M.client.inactivity <= 10 * 60 * 10)
					active = 1
					break
			isactive[name] = active ? "Active" : "Inactive"
		else
			isactive[name] = CR.get_status_physical()

		var/found_place = FALSE
		for(var/list/department in GLOB.dept_data)
			var/list/names = department["names"]
			//if(CR.get_department() && (GLOB.text_to_department_flags[CR.get_department()] & department["flag"]))
			if(department["flag"] in CR.assigned_deparment_flags)
				names[name] = rank
				found_place = TRUE
		if(!found_place)
			misc[name] = rank

	// Synthetics don't have actual records, so we will pull them from here.
	for(var/mob/living/silicon/ai/ai in SSmobs.mob_list)
		bot[ai.name] = "Artificial Intelligence"

	for(var/mob/living/silicon/robot/robot in SSmobs.mob_list)
		// No combat/syndicate cyborgs, no drones.
		if(robot.module && robot.module.hide_on_manifest)
			continue

		bot[robot.name] = "[robot.modtype] [robot.braintype]"

	for(var/list/department in GLOB.dept_data)
		var/list/names = department["names"]
		if(length(names))
			dat += "<tr><th colspan=3>[department["header"]]</th></tr>"
			for(var/name in names)
				dat += "<tr class='candystripe'><td>[name]</td><td>[names[name]]</td><td>[isactive[name]]</td></tr>"

	dat += "</table>"
	dat = replacetext(dat, "\n", "") // so it can be placed on paper correctly
	dat = replacetext(dat, "\t", "")
	return dat

/proc/manifest_prediction()
	var/dat = manifest_data_initialization(monochrome = FALSE, OOC = TRUE, prediction = TRUE)
	var/list/empty_command_positions = GLOB.command_positions.Copy()
	var/list/command_positions_with_candidates = list()
	var/list/command_candidates = list()

	//searching for heads positions
	for(var/mob/new_player/player in GLOB.player_list)
		if(!player.ready || ("Assistant" in player.client.prefs.job_low))
			continue

		var/datum/preferences/player_prefs = player.client.prefs
		var/player_name = player_prefs.real_name
		for(var/command_position in GLOB.command_positions)
			var/datum/job/job = job_master.GetJob(command_position)
			for(var/priority = JOB_PRIORITY_HIGH to JOB_PRIORITY_LOW)
				if(player_prefs.IsJobPriority(job, priority))
					if(!command_positions_with_candidates[command_position])
						command_positions_with_candidates[command_position] = list(
							JOB_PRIORITY_HIGH = list(),
							JOB_PRIORITY_MIDDLE = list(),
							JOB_PRIORITY_LOW = list()
							)
					command_positions_with_candidates[command_position][priority] += list("[player_name]" = player.client.ckey)

	//sorting head positions
	var/list/command_positions_by_ckey = list()
	for(var/CP in command_positions_with_candidates)
		var/command_position = CP
		var/list/candidates = command_positions_with_candidates[command_position]
		for(var/priority = JOB_PRIORITY_HIGH to JOB_PRIORITY_LOW)
			if(!(command_position in empty_command_positions))
				break
			for(var/candidate in candidates[priority])
				empty_command_positions -= command_position
				var/ckey = candidates[priority][candidate]
				if(!command_positions_by_ckey[ckey])
					command_positions_by_ckey[ckey] = list(
						"positions" = list(
							JOB_PRIORITY_HIGH = list(),
							JOB_PRIORITY_MIDDLE = list(),
							JOB_PRIORITY_LOW = list()
							),
						"player_name" = "[candidate]"
						)
				command_positions_by_ckey[ckey]["positions"][priority] += command_position
				command_candidates |= ckey

	//inserting choosen heads in GLOB.dept_data
	for(var/ckey in command_positions_by_ckey)
		var/command_position
		for(var/priority = JOB_PRIORITY_HIGH to JOB_PRIORITY_LOW)
			if(length(command_positions_by_ckey[ckey]["positions"][priority]))
				command_position = pick(command_positions_by_ckey[ckey]["positions"][priority])
				break
		var/player_name = command_positions_by_ckey[ckey]["player_name"]
		for(var/list/department in GLOB.dept_data)
			var/flag = job_master.occupations_by_title[command_position].department_flag
			if(department["flag"]&flag)
				department["all_jobs_in_dept"][command_position] += list("[player_name]" = list ("job_title" = command_position))
				break

	//searching for rest non-heads positions
	for(var/mob/new_player/player in GLOB.player_list)
		if(!player.ready || (player.client.ckey in command_candidates))
			continue

		var/datum/preferences/player_prefs = player.client.prefs
		var/player_name = player_prefs.real_name
		var/silicon = FALSE

		var/list/preferenced_jobs
		if("Assistant" in player_prefs.job_low)
			preferenced_jobs = list(
				list("Assistant")
				)
		else
			preferenced_jobs = list(
				player_prefs.job_high ? list(player_prefs.job_high) : list(),
				player_prefs.job_medium,
				player_prefs.job_low
				)

		//inserting non-head positions in GLOB.dept_data
		for(var/list/J in preferenced_jobs)
			var/list/jobs = J - GLOB.command_positions
			if(!length(jobs))
				continue

			var/job = pick(jobs)

			if(job in list("AI", "Cyborg"))
				silicon = TRUE

			for(var/list/department in GLOB.dept_data)
				var/flag = job_master.occupations_by_title[job].department_flag

				if(!silicon ? department["flag"]&flag : department["header"] == "Silicon")
					department["all_jobs_in_dept"][job] += list(!silicon ? "[player_name]" : "\[Unknown\]" = list("job_title" = job, "job_alt_title" = player_prefs.player_alt_titles[job]))
					break
			break

	//building manifest page
	for(var/list/department in GLOB.dept_data)
		var/list/all_jobs = department["all_jobs_in_dept"]
		if(!length(all_jobs))
			continue

		dat += "<tr><th colspan=3>[department["header"]]</th></tr>"
		for(var/J in all_jobs)
			var/list/job = all_jobs[J]
			for(var/name in job)
				var/job_slots = job_master.occupations_by_title[job[name]["job_title"]].spawn_positions
				var/chance = job_slots == -1 ? 100 : clamp(job_slots/length(job)*100, 0, 100)
				var/job_title = job[name]["job_alt_title"] ? job[name]["job_alt_title"] : job[name]["job_title"]
				dat += "<tr class='candystripe'><td>[name]</td><td>[job_title]</td><td>[chance]%</td></tr>"

	dat += "</table>"
	dat = replacetext(dat, "\n", "") // so it can be placed on paper correctly
	dat = replacetext(dat, "\t", "")
	return dat

/proc/silicon_nano_crew_manifest(list/filter)
	var/list/filtered_entries = list()

	for(var/mob/living/silicon/ai/ai in SSmobs.mob_list)
		filtered_entries.Add(list(list(
			"name" = ai.name,
			"rank" = "Artificial Intelligence",
			"status" = ""
		)))
	for(var/mob/living/silicon/robot/robot in SSmobs.mob_list)
		if(robot.module && robot.module.hide_on_manifest)
			continue
		filtered_entries.Add(list(list(
			"name" = robot.name,
			"rank" = "[robot.modtype] [robot.braintype]",
			"status" = ""
		)))
	return filtered_entries

/proc/filtered_nano_crew_manifest(list/filter, blacklist = FALSE)
	var/list/filtered_entries = list()
	for(var/datum/computer_file/crew_record/CR in department_crew_manifest(filter, blacklist))
		filtered_entries.Add(list(list(
			"name" = CR.get_name(),
			"rank" = CR.get_job(),
			"status" = CR.get_status_physical()
		)))
	return filtered_entries

/proc/nano_crew_manifest()
	return list(\
		"heads" = filtered_nano_crew_manifest(GLOB.command_positions),\
		"spt" = filtered_nano_crew_manifest(GLOB.support_positions),\
		"sci" = filtered_nano_crew_manifest(GLOB.science_positions),\
		"sec" = filtered_nano_crew_manifest(GLOB.security_positions),\
		"eng" = filtered_nano_crew_manifest(GLOB.engineering_positions),\
		"med" = filtered_nano_crew_manifest(GLOB.medical_positions),\
		"sup" = filtered_nano_crew_manifest(GLOB.supply_positions),\
		"exp" = filtered_nano_crew_manifest(GLOB.exploration_positions),\
		"srv" = filtered_nano_crew_manifest(GLOB.service_positions),\
		"bot" = silicon_nano_crew_manifest(GLOB.nonhuman_positions),\
		"civ" = filtered_nano_crew_manifest(GLOB.civilian_positions),\
		"misc" = filtered_nano_crew_manifest(GLOB.unsorted_positions)\
		)
