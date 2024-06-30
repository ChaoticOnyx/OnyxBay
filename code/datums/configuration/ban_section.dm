/datum/configuration_section/ban
	name = "ban"

	var/ban_legacy_system
	var/mods_can_job_tempban
	var/mod_tempban_max
	var/mod_job_tempban_max

/datum/configuration_section/ban/load_data(list/data)
	CONFIG_LOAD_BOOL(ban_legacy_system, data["ban_legacy_system"])
	CONFIG_LOAD_NUM(mod_tempban_max, data["mod_tempban_max"])
	CONFIG_LOAD_NUM(mod_job_tempban_max, data["mod_job_tempban_max"])
