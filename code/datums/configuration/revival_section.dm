/datum/configuration_section/revival
	name = "revival"

	var/use_cortical_stacks = TRUE
	var/revival_brain_life = -1

/datum/configuration_section/revival/load_data(list/data)
	CONFIG_LOAD_BOOL(use_cortical_stacks, data["use_cortical_stacks"])
	CONFIG_LOAD_NUM(revival_brain_life, data["revival_brain_life"])
