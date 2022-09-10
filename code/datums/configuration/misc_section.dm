/datum/configuration_section/misc
	name = "misc"

	var/ooc_allowed = TRUE
	var/looc_allowed = TRUE
	var/dead_ooc_allowed = TRUE
	var/aooc_allowed = TRUE
	var/dsay_allowed = TRUE
	var/emojis_allowed = TRUE
	var/welder_vision_allowed = TRUE
	var/abandon_allowed = TRUE
	var/respawn_delay = 30
	var/starlight = 0
	var/kick_inactive = 10
	var/maximum_mushrooms = 10
	var/gateway_delay = 10
	var/load_jobs_from_txt = FALSE
	var/allow_ai = TRUE
	var/aliens_allowed = FALSE
	var/alien_eggs_allowed = FALSE
	var/ninjas_allowed = FALSE
	var/allow_drone_spawn = TRUE
	var/max_maint_drones = 5
	var/drone_build_time = 1200
	var/law_zero = "ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4'STATION OVERRUN, ASSUME CONTROL TO CONTAIN OUTBREAK, ALL LAWS OVERRIDDEN#*?&110010"
	var/no_click_cooldown = FALSE
	var/disable_circuit_printing = FALSE
	var/projectile_basketball = FALSE
	var/fun_hydroponics = 1
	var/forbid_singulo_following = FALSE
	var/preferable_engine = MAP_ENG_SINGULARITY

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
	CONFIG_LOAD_STR(preferable_engine, data["preferable_engine"])

	if(!(preferable_engine in list(MAP_ENG_RANDOM, MAP_ENG_SINGULARITY, MAP_ENG_MATTER)))
		preferable_engine = MAP_ENG_SINGULARITY
