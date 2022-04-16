/datum/configuration_section/gamemode
	name = "gamemode"

	var/list/probabilities = list()
	var/traitor_scaling = FALSE
	var/objectives_disabled = null
	var/ert_admin_only = FALSE
	var/protect_roles_from_antagonist = FALSE

/datum/configuration_section/gamemode/load_data(data)
	CONFIG_LOAD_LIST(probabilities, data["probabilities"])


	for(var/game_mode in probabilities)
		if(game_mode in gamemode_cache)
			log_misc("Probability of [game_mode] is [probabilities[game_mode]].")
		else
			log_misc("Unknown game mode probability configuration definition: [game_mode].")

	CONFIG_LOAD_BOOL(traitor_scaling, data["traitor_scaling"])
	CONFIG_LOAD_STR(objectives_disabled, data["objectives_disabled"])

	if(objectives_disabled != null)
		switch(objectives_disabled)
			if("none")
				objectives_disabled = CONFIG_OBJECTIVE_NONE
			if("verb")
				objectives_disabled = CONFIG_OBJECTIVE_VERB
			if("all")
				objectives_disabled = CONFIG_OBJECTIVE_ALL
			else
				log_misc("Incorrect objective disabled definition: [objectives_disabled]")
				objectives_disabled = CONFIG_OBJECTIVE_NONE

	CONFIG_LOAD_BOOL(ert_admin_only, data["ert_admin_only"])
	CONFIG_LOAD_BOOL(protect_roles_from_antagonist, data["protect_roles_from_antagonist"])
