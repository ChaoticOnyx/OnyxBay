/datum/configuration_section/health
	name = "health"

	var/health_threshold_dead
	var/bones_can_break
	var/limbs_can_break
	var/organs_can_decay
	var/organ_health_multiplier
	var/organ_regeneration_multiplier
	var/organ_damage_spillover_multiplier

/datum/configuration_section/health/load_data(list/data)
	CONFIG_LOAD_NUM(health_threshold_dead, data["health_threshold_dead"])
	CONFIG_LOAD_BOOL(bones_can_break, data["bones_can_break"])
	CONFIG_LOAD_BOOL(limbs_can_break, data["limbs_can_break"])
	CONFIG_LOAD_BOOL(organs_can_decay, data["organs_can_decay"])
	CONFIG_LOAD_NUM(organ_health_multiplier, data["organ_health_multiplier"])
	CONFIG_LOAD_NUM(organ_regeneration_multiplier, data["organ_regeneration_multiplier"])
	CONFIG_LOAD_NUM(organ_damage_spillover_multiplier, data["organ_damage_spillover_multiplier"])
