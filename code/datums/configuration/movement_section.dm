/datum/configuration_section/movement
	name = "movement"

	var/run_speed = 3
	var/walk_speed = 7
	var/human_delay = 0
	var/robot_delay = 0
	var/drone_delay = -1
	var/metroid_delay = 0
	var/animal_delay = 0

/datum/configuration_section/movement/load_data(list/data)
	CONFIG_LOAD_NUM(run_speed, data["run_speed"])
	CONFIG_LOAD_NUM(walk_speed, data["walk_speed"])
	CONFIG_LOAD_NUM(human_delay, data["human_delay"])
	CONFIG_LOAD_NUM(robot_delay, data["robot_delay"])
	CONFIG_LOAD_NUM(metroid_delay, data["metroid_delay"])
	CONFIG_LOAD_NUM(animal_delay, data["animal_delay"])
