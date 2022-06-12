/datum/configuration_section/gamemode
	name = "gamemode"

	var/list/probabilities = list()
	var/traitor_scaling = FALSE
	var/disable_objectives = "none"
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
	CONFIG_LOAD_STR(disable_objectives, data["disable_objectives"])

	if(disable_objectives != null)
		switch(disable_objectives)
			if("none")
				disable_objectives = CONFIG_OBJECTIVE_NONE
			if("verb")
				disable_objectives = CONFIG_OBJECTIVE_VERB
			if("all")
				disable_objectives = CONFIG_OBJECTIVE_ALL
			else
				log_misc("Incorrect objective disabled definition: [disable_objectives]")
				disable_objectives = CONFIG_OBJECTIVE_NONE

	CONFIG_LOAD_BOOL(ert_admin_only, data["ert_admin_only"])
	CONFIG_LOAD_BOOL(protect_roles_from_antagonist, data["protect_roles_from_antagonist"])
