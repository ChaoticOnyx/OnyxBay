/datum/configuration_section/donations
	name = "donations"

	var/enable = FALSE

/datum/configuration_section/donations/load_data(list/data)
	CONFIG_LOAD_BOOL(enable, data["enable"])
