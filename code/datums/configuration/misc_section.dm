/datum/configuration_section/misc
	name = "misc"

	var/ooc_allowed
	var/looc_allowed
	var/dead_ooc_allowed
	var/aooc_allowed
	var/dsay_allowed
	var/emojis_allowed
	var/welder_vision_allowed
	var/abandon_allowed
	var/respawn_delay
	var/starlight
	var/kick_inactive
	var/maximum_mushrooms
	var/gateway_delay
	var/load_jobs_from_txt
	var/allow_ai
	var/aliens_allowed
	var/alien_eggs_allowed
	var/ninjas_allowed
	var/allow_drone_spawn
	var/max_maint_drones
	var/drone_build_time
	var/law_zero = "ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4'STATION OVERRUN, ASSUME CONTROL TO CONTAIN OUTBREAK, ALL LAWS OVERRIDDEN#*?&110010"
	var/no_click_cooldown
	var/disable_circuit_printing
	var/projectile_basketball
	var/fun_hydroponics
	var/forbid_singulo_following
	var/toogle_gun_safety


/datum/configuration_section/misc/load_data(list/data)
	CONFIG_LOAD_BOOL(ooc_allowed, data["ooc_allowed"])
	CONFIG_LOAD_BOOL(looc_allowed, data["looc_allowed"])
	CONFIG_LOAD_BOOL(dead_ooc_allowed, data["dead_ooc_allowed"])
	CONFIG_LOAD_BOOL(aooc_allowed, data["aooc_allowed"])
	CONFIG_LOAD_BOOL(dsay_allowed, data["dsay_allowed"])
	CONFIG_LOAD_BOOL(emojis_allowed, data["emojis_allowed"])
	CONFIG_LOAD_BOOL(welder_vision_allowed, data["welder_vision_allowed"])
	CONFIG_LOAD_BOOL(abandon_allowed, data["abandon_allowed"])
	CONFIG_LOAD_NUM(respawn_delay, data["respawn_delay"])
	CONFIG_LOAD_NUM(starlight, data["starlight"])
	CONFIG_LOAD_NUM(kick_inactive, data["kick_inactive"])
	CONFIG_LOAD_NUM(maximum_mushrooms, data["maximum_mushrooms"])
	CONFIG_LOAD_NUM(gateway_delay, data["gateway_delay"])
	CONFIG_LOAD_BOOL(load_jobs_from_txt, data["load_jobs_from_txt"])
	CONFIG_LOAD_BOOL(allow_ai, data["allow_ai"])
	CONFIG_LOAD_BOOL(aliens_allowed, data["aliens_allowed"])
	CONFIG_LOAD_BOOL(alien_eggs_allowed, data["alien_eggs_allowed"])
	CONFIG_LOAD_BOOL(ninjas_allowed, data["ninjas_allowed"])
	CONFIG_LOAD_BOOL(allow_drone_spawn, data["allow_drone_spawn"])
	CONFIG_LOAD_NUM(max_maint_drones, data["max_maint_drones"])
	CONFIG_LOAD_NUM(drone_build_time, data["drone_build_time"])
	CONFIG_LOAD_STR(law_zero, data["law_zero"])
	CONFIG_LOAD_BOOL(no_click_cooldown, data["no_click_cooldown"])
	CONFIG_LOAD_BOOL(disable_circuit_printing, data["disable_circuit_printing"])
	CONFIG_LOAD_BOOL(projectile_basketball, data["projectile_basketball"])
	CONFIG_LOAD_NUM(fun_hydroponics, data["fun_hydroponics"])
	CONFIG_LOAD_BOOL(forbid_singulo_following, data["forbid_singulo_following"])
	CONFIG_LOAD_BOOL(toogle_gun_safety, data["toogle_gun_safety"])
