/datum/configuration_section/radiation
	name = "radiation"

	var/decay_rate = 1
	var/resistance_multiplier = 1.25
	var/material_resistance_divisor = 2
	var/lower_limit = 0.35

/datum/configuration_section/radiation/load_data(list/data)
	CONFIG_LOAD_NUM(decay_rate, data["decay_rate"])
	CONFIG_LOAD_NUM(resistance_multiplier, data["resistance_multiplier"])
	CONFIG_LOAD_NUM(material_resistance_divisor, data["_material_resistance_divisor"])
	CONFIG_LOAD_NUM(lower_limit, data["lower_limit"])
