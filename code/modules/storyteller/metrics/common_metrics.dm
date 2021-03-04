
// number of living characters excluding out-of-station roles
/storyteller_metric/station_characters_count
	name = "Living Station Characters"

/storyteller_metric/station_characters_count/_evaluate()
	// crew manifest records + AIs + cyborgs
	var/personnel = 0
	var/AIs = 0
	var/cyborgs = 0

	for(var/mob/living/carbon/human/M in GLOB.player_list)
		for (var/datum/computer_file/crew_record/CR in GLOB.all_crew_records)
			if (CR.get_name() == M.real_name && !M.is_dead())
				personnel++

	for (var/mob/living/silicon/ai/ai in SSmobs.mob_list)
		if (!ai.is_dead())
			AIs++

	for (var/mob/living/silicon/robot/robot in SSmobs.mob_list)
		if (!robot.is_dead())
			cyborgs++

	var/result = personnel + AIs + cyborgs
	_log_debug("personnel: [personnel], AIs: [AIs], cyborgs: [cyborgs]. Summary: [result]")

	return result


/storyteller_metric/ghosts_count
	name = "Ghosts Count"

/storyteller_metric/ghosts_count/_evaluate()
	var/ghosts = 0
	for(var/mob/observer/ghost/G in GLOB.player_list)
		ghosts++
	_log_debug("Count: [ghosts]")
	return ghosts


/storyteller_metric/security_manpower
	name = "Security Manpower"

/storyteller_metric/security_manpower/_evaluate()
	var/security_manpower = 0

	for(var/mob/living/carbon/human/M in GLOB.player_list)
		for (var/datum/computer_file/crew_record/CR in GLOB.all_crew_records)
			if (CR.get_name() == M.real_name && !M.is_dead())
				var/add_manpower = 0
				switch (CR.get_job())
					if ("Captain")          add_manpower = 7
					if ("Head of Security") add_manpower = 6
					if ("Warden")           add_manpower = 5
					if ("Detective")        add_manpower = 4
					if ("Security Officer") add_manpower = 3
				if (add_manpower)
					security_manpower += add_manpower
					_log_debug("+[add_manpower] for an [CR.get_job()]")

	for (var/mob/living/silicon/robot/robot in GLOB.player_list)
		if (!robot.is_dead())
			if (istype(robot.module, /obj/item/weapon/robot_module/security/general) || istype(robot.module, /obj/item/weapon/robot_module/security/combat))
				var/add_manpower = 3
				security_manpower += add_manpower
				_log_debug("+[add_manpower] for a Security Cyborg")

	_log_debug("Total manpower: [security_manpower]")
	return security_manpower


/storyteller_metric/antagonists_danger
	name = "Danger by Antagonists"

/storyteller_metric/antagonists_danger/_evaluate()
	var/antagonists_danger = 0

	for (var/role_id in GLOB.all_antag_types_)
		var/datum/antagonist/antag = GLOB.all_antag_types_[role_id]
		var/add_danger = 0
		switch (role_id)
			if (MODE_ERT)           add_danger = -6
			if (MODE_LOYALIST)      add_danger = -2
			if (MODE_BORER)         add_danger = 2
			if (MODE_REVOLUTIONARY) add_danger = 2
			if (MODE_COMMANDO)      add_danger = 4
			if (MODE_TRAITOR)       add_danger = 4
			if (MODE_CULTIST)       add_danger = 4
			if (MODE_RENEGADE)      add_danger = 4
			if (MODE_RAIDER)        add_danger = 4
			if (MODE_NUKE)          add_danger = 4
			if (MODE_DEATHSQUAD)    add_danger = 6
			if (MODE_CHANGELING)    add_danger = 8
			if (MODE_NINJA)         add_danger = 12
			if (MODE_WIZARD)        add_danger = 16
			if (MODE_BLOB)          add_danger = 24
			if (MODE_MALFUNCTION)   add_danger = 24

			// if ("god cultist") - /datum/antagonist/godcultist
			// if ("xeno") - /datum/antagonist/xenos
			// if ("actor") - /datum/antagonist/actor
			// if ("deity") - /datum/antagonist/deity

		var/count = 0
		for (var/datum/mind/M in antag.current_antagonists)
			if (M.current)
				var/mob/living/L = M.current
				if (L.stat & DEAD)
					_log_debug("Dead antagonist: [L] ([role_id])")
					continue
				if (antag.station_crew_involved && M.is_brigged(0))
					_log_debug("Brigged antagonist: [L] ([role_id])")
					continue
				count++
		if (count)
			_log_debug("Add +[add_danger] for each [role_id] ([count] times)")
			antagonists_danger += count * add_danger

	_log_debug("Total danger: [antagonists_danger]")
	return antagonists_danger


/storyteller_metric/is_storyteller_random
	name = "Is Storyteller Random"
	_can_be_used_on_setup = TRUE
	_const = TRUE

/storyteller_metric/is_storyteller_random/_evaluate()
	return SSstoryteller.was_character_choosen_with_random()



/storyteller_metric/time_of_day
	name = "Time of day"
	_can_be_used_on_setup = TRUE
	_const = TRUE

/storyteller_metric/time_of_day/_evaluate()
	return world.timeofday
