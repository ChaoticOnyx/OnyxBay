/datum/movespeed_modifier/human_delay
	flags = MOVESPEED_FLAG_SPACEMOVEMENT

/datum/movespeed_modifier/human_delay/New()
	. = ..()
	slowdown = config.movement.human_delay

/datum/movespeed_modifier/lying
	variable = TRUE
	flags = MOVESPEED_FLAG_SPACEMOVEMENT

/datum/movespeed_modifier/mutation_fat
	slowdown = 1.5

/datum/movespeed_modifier/blocking
	slowdown = 1.5

/datum/movespeed_modifier/bodybuild
	slowdown = 0

/datum/movespeed_modifier/bodybuild/fat
	slowdown = 0.5

/datum/movespeed_modifier/aiming_tally
	slowdown = 5

/datum/movespeed_modifier/walk
	id = MOVESPEED_ID_MOB_WALK_RUN
	flags = MOVESPEED_FLAG_SPACEMOVEMENT

/datum/movespeed_modifier/walk/New()
	. = ..()
	slowdown = config.movement.walk_speed

/datum/movespeed_modifier/run
	id = MOVESPEED_ID_MOB_WALK_RUN
	flags = MOVESPEED_FLAG_SPACEMOVEMENT

/datum/movespeed_modifier/run/New()
	. = ..()
	slowdown = config.movement.run_speed

/datum/movespeed_modifier/remotebot
	flags = MOVESPEED_FLAG_SPACEMOVEMENT
	slowdown = 7

/datum/movespeed_modifier/remotebot_holding
	flags = MOVESPEED_FLAG_SPACEMOVEMENT
	variable = TRUE

/datum/movespeed_modifier/simple_animal
	flags = MOVESPEED_FLAG_SPACEMOVEMENT

/datum/movespeed_modifier/simple_animal/New()
	. = ..()
	slowdown = config.movement.animal_delay

/datum/movespeed_modifier/robot_movement
	flags = MOVESPEED_FLAG_SPACEMOVEMENT

/datum/movespeed_modifier/robot_movement/New()
	. = ..()
	slowdown = config.movement.robot_delay

/datum/movespeed_modifier/drone_movement
	flags = MOVESPEED_FLAG_SPACEMOVEMENT

/datum/movespeed_modifier/robot_movement/New()
	. = ..()
	slowdown = config.movement.drone_delay

/datum/movespeed_modifier/vtec_speedup
	flags = MOVESPEED_FLAG_SPACEMOVEMENT
	slowdown = -1

/datum/movespeed_modifier/hamstring_magic
	slowdown = -1.0
