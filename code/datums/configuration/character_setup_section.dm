/datum/configuration_section/character_setup
	name = "character-setup"

	var/character_slots
	var/loadout_slots
	var/max_loadout_points
	var/extra_loadout_points
	var/humans_need_surnames
	var/allow_metadata

/datum/configuration_section/character_setup/load_data(list/data)
	CONFIG_LOAD_NUM(character_slots, data["character_slots"])
	CONFIG_LOAD_NUM(loadout_slots, data["loadout_slots"])
	CONFIG_LOAD_NUM(max_loadout_points, data["max_loadout_points"])
	CONFIG_LOAD_NUM(extra_loadout_points, data["extra_loadout_points"])

	if(max_loadout_points < 0)
		max_loadout_points = INFINITY

	CONFIG_LOAD_BOOL(humans_need_surnames, data["humans_need_surnames"])
	CONFIG_LOAD_BOOL(allow_metadata, data["allow_metadata"])
