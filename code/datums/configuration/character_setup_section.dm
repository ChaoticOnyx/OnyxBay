/datum/configuration_section/character_setup
	name = "character-setup"

	var/character_slots = 10
	var/loadout_slots = 10
	var/default_gear_cost
	var/patron_gear_cost
	var/humans_need_surnames = FALSE
	var/allow_metadata = FALSE

/datum/configuration_section/character_setup/load_data(list/data)
	CONFIG_LOAD_NUM(character_slots, data["character_slots"])
	CONFIG_LOAD_NUM(loadout_slots, data["loadout_slots"])
	CONFIG_LOAD_NUM(default_gear_cost, data["default_gear_cost"])
	CONFIG_LOAD_NUM(patron_gear_cost, data["donator_gear_cost"])

	if(default_gear_cost < 0)
		default_gear_cost = INFINITY
		patron_gear_cost = INFINITY

	CONFIG_LOAD_BOOL(humans_need_surnames, data["humans_need_surnames"])
	CONFIG_LOAD_BOOL(allow_metadata, data["allow_metadata"])
