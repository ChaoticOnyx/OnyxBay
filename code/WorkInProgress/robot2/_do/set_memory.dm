/obj/machinery/robot2/chip/_do/setmemory
	name = "Set memory"
	var/at = "NULL"
	var/variable = "NULL"

/obj/machinery/robot2/chip/_do/setmemory/trigger()
	robot.setmemory(at,variable)


/obj/machinery/robot2/chip/_do/setmemory/debug()
	robot.speak("Setting memory at [at] to [variable]")