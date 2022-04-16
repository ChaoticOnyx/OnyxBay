/datum/configuration_section/ban
	name = "ban"

	var/ban_legacy_system = TRUE
	var/mods_can_tempban = TRUE
	var/mods_can_job_tempban = TRUE
	var/mod_tempban_max = TRUE
	var/mod_job_tempban_max = TRUE

/datum/configuration_section/ban/load_data(list/data)
	CONFIG_LOAD_BOOL(ban_legacy_system, data["ban_legacy_system"])
	CONFIG_LOAD_BOOL(mods_can_tempban, data["mods_can_tempban"])
	CONFIG_LOAD_BOOL(mod_tempban_max, data["mod_tempban_max"])
	CONFIG_LOAD_BOOL(mod_job_tempban_max, data["mod_job_tempban_max"])
