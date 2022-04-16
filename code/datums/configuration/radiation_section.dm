/datum/configuration_section/radiation
	name = "radiation"

	var/radiation_decay_rate = 1
	var/radiation_resistance_multiplier = 1.25
	var/radiation_material_resistance_divisor = 2
	var/radiation_lower_limit = 0.35

/datum/configuration_section/radiation/load_data(list/data)
	CONFIG_LOAD_NUM(radiation_decay_rate, data["radiation_decay_rate"])
	CONFIG_LOAD_NUM(radiation_resistance_multiplier, data["radiation_resistance_multiplier"])
	CONFIG_LOAD_NUM(radiation_material_resistance_divisor, data["radiation_material_resistance_divisor"])
	CONFIG_LOAD_NUM(radiation_lower_limit, data["radiation_lower_limit"])
