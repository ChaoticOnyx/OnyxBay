/datum/configuration_section/movement
	name = "movement"

	var/run_speed
	var/walk_speed
	var/human_delay
	var/robot_delay
	var/drone_delay
	var/metroid_delay
	var/animal_delay

/datum/configuration_section/movement/load_data(list/data)
	CONFIG_LOAD_NUM(run_speed, data["run_speed"])
	CONFIG_LOAD_NUM(walk_speed, data["walk_speed"])
	CONFIG_LOAD_NUM(human_delay, data["human_delay"])
	CONFIG_LOAD_NUM(robot_delay, data["robot_delay"])
	CONFIG_LOAD_NUM(metroid_delay, data["metroid_delay"])
	CONFIG_LOAD_NUM(animal_delay, data["animal_delay"])
