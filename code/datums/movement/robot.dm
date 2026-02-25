/*********
* /robot *
*********/
/datum/movement_handler/robot
	expected_host_type = /mob/living/silicon/robot
	var/mob/living/silicon/robot/robot

/datum/movement_handler/robot/New(host)
	..()
	src.robot = host

/datum/movement_handler/robot/Destroy()
	robot = null
	. = ..()

// Use power while moving.
/datum/movement_handler/robot/use_power/DoMove(direction, mob/mover, is_external)
	var/datum/robot_component/actuator/A = robot.get_robot_component("actuator")
	if(!is_external && !robot.cell_use_power(A.active_usage))
		return MOVEMENT_HANDLED
	return MOVEMENT_PROCEED

/datum/movement_handler/robot/use_power/MayMove(mob/mover, is_external)
	return (robot.lockcharge || !robot.is_component_functioning("actuator")) ? MOVEMENT_STOP : MOVEMENT_PROCEED
