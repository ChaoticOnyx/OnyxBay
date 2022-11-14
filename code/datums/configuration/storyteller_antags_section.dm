/datum/configuration_section/storyteller_antags
	name = "storyteller_antags"

	var/spawn_abductors = TRUE
	var/spawn_vampire = TRUE
	var/spawn_traitor = TRUE
	var/spawn_borer = TRUE
	var/spawn_changeling = TRUE
	var/spawn_ninja = TRUE
	var/spawn_wizard = TRUE

/datum/configuration_section/storyteller_antags/load_data(list/data)
	CONFIG_LOAD_BOOL(spawn_abductors, data["spawn_abductors"])
	CONFIG_LOAD_BOOL(spawn_vampire, data["spawn_vampire"])
	CONFIG_LOAD_BOOL(spawn_traitor, data["spawn_traitor"])
	CONFIG_LOAD_BOOL(spawn_borer, data["spawn_borer"])
	CONFIG_LOAD_BOOL(spawn_changeling, data["spawn_changeling"])
	CONFIG_LOAD_BOOL(spawn_ninja, data["spawn_ninja"])
	CONFIG_LOAD_BOOL(spawn_wizard, data["spawn_wizard"])
