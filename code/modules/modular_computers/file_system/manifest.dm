GLOBAL_LIST_EMPTY(dept_data)

// Generates a simple HTML crew manifest for use in various places
/proc/html_crew_manifest(monochrome, OOC)
	GLOB.dept_data = list(
		list("names" = list(), "header" = "Heads of Staff", "flag" = COM),
		list("names" = list(), "header" = "Command Support", "flag" = SPT),
		list("names" = list(), "header" = "Research", "flag" = SCI),
		list("names" = list(), "header" = "Security", "flag" = SEC),
		list("names" = list(), "header" = "Medical", "flag" = MED),
		list("names" = list(), "header" = "Engineering", "flag" = ENG),
		list("names" = list(), "header" = "Supply", "flag" = SUP),
		list("names" = list(), "header" = "Exploration", "flag" = EXP),
		list("names" = list(), "header" = "Service", "flag" = SRV),
		list("names" = list(), "header" = "Civilian", "flag" = CIV),
		list("names" = list(), "header" = "Miscellaneous", "flag" = MSC),
		list("names" = list(), "header" = "Silicon")
	)
	var/list/misc //Special departments for easier access
	var/list/bot
	for(var/list/department in GLOB.dept_data)
		if(department["flag"] == MSC)
			misc = department["names"]
		if(isnull(department["flag"]))
			bot = department["names"]

	var/list/isactive = new()
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
	<tr class='head'><th>Name</th><th>Position</th><th>Activity</th></tr>
	"}
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
	GLOB.dept_data = list(
		list("jobs" = list(), "header" = "Heads of Staff", "flag" = COM),
		list("jobs" = list(), "header" = "Command Support", "flag" = SPT),
		list("jobs" = list(), "header" = "Research", "flag" = SCI),
		list("jobs" = list(), "header" = "Security", "flag" = SEC),
		list("jobs" = list(), "header" = "Medical", "flag" = MED),
		list("jobs" = list(), "header" = "Engineering", "flag" = ENG),
		list("jobs" = list(), "header" = "Supply", "flag" = SUP),
		list("jobs" = list(), "header" = "Exploration", "flag" = EXP),
		list("jobs" = list(), "header" = "Service", "flag" = SRV),
		list("jobs" = list(), "header" = "Civilian", "flag" = CIV),
		list("jobs" = list(), "header" = "Miscellaneous", "flag" = MSC),
		list("jobs" = list(), "header" = "Silicon")
	)
	var/dat = {"
	<head><style>
		.manifest {border-collapse:collapse;}
		.manifest td, th {border:1px solid ["black; background-color:#272727; color:white"]; padding:.25em}
		.manifest th {height: 2em; ["background-color: ["#40628A"]; color:white"]}
		.manifest tr.head th {["background-color: ["#013D3B"]"]}
		.manifest td:first-child {text-align:right}
		.manifest tr.alt td {["background-color: ["#373737"]; color:white"]"]}
	</style></head>
	<table class="manifest" width='350px'>
	<tr class='head'><th>Name</th><th>Position</th><th>Chances</th></tr>
	"}

	for(var/mob/new_player/player in GLOB.player_list)
		if(!player.ready)
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

		for(var/list/J in preferenced_jobs)
			var/list/jobs = J
			if(length(jobs))
				var/job = pick(jobs)
					
				if(job in list("AI", "Cyborg"))
					silicon = TRUE

				for(var/list/department in GLOB.dept_data)
					var/flag = job_master.occupations_by_title[job].department_flag

					if(!silicon ? department["flag"]&flag : department["header"] == "Silicon")
						department["jobs"][job] += list(!silicon ? "[player_name]" : "\[Unknown\]" = player_prefs.player_alt_titles[job] ? player_prefs.player_alt_titles[job] : job)
						break
				break

	for(var/list/department in GLOB.dept_data)
		var/list/all_jobs = department["jobs"]
		if(length(all_jobs))
			dat += "<tr><th colspan=3>[department["header"]]</th></tr>"
			for(var/J in all_jobs)
				var/list/job = all_jobs[J]
				for(var/name in job)
					var/job_slots = job_master.occupations_by_title[job[name]].spawn_positions
					var/chance
					job_slots == -1 ? (chance = 100) : (chance = clamp(job_slots/length(job)*100, 0, 100))
					dat += "<tr class='candystripe'><td>[name]</td><td>[job[name]]</td><td>[chance]%</td></tr>"

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
