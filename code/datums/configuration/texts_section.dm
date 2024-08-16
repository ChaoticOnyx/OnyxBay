/datum/configuration_section/texts
	name = "texts"

	var/motd
	var/heads
	var/newcomers

/datum/configuration_section/texts/load_data(list/data)
	CONFIG_LOAD_STR(motd, data["motd"])
	CONFIG_LOAD_STR(heads, data["heads"])
	CONFIG_LOAD_STR(newcomers, data["newcomers"])
