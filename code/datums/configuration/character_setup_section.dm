/datum/configuration_section/character_setup
	name = "character-setup"

	var/character_slots = 10
	var/loadout_slots = 10
	var/max_gear_cost = 10
	var/humans_need_surnames = FALSE
	var/allow_metadata = FALSE

/datum/configuration_section/character_setup/load_data(list/data)
	CONFIG_LOAD_NUM(character_slots, data["character_slots"])
	CONFIG_LOAD_NUM(loadout_slots, data["loadout_slots"])
	CONFIG_LOAD_NUM(max_gear_cost, data["max_gear_cost"])
	
	if(max_gear_cost < 0)
		max_gear_cost = INFINITY

	CONFIG_LOAD_BOOL(humans_need_surnames, data["humans_need_surnames"])
	CONFIG_LOAD_BOOL(allow_metadata, data["allow_metadata"])
