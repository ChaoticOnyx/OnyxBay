/datum/robotinstructions
	var/list/obj/machinery/robot2/chip/_do/instructions = list()
	var/running = 0
	var/debug = 1
	var/abort = 0

/datum/robotinstructions/proc/execute()
	if(running == 0)
		running = 1
		spawn(0)
			for(var/i = 0 to instructions.len)
				var/obj/machinery/robot2/chip/_do/currentinstruction = instructions[i]
				if(abort)
					abort = 0
					running = 0
					return
				if(debug == 1)
					currentinstruction.debug()
				currentinstruction.trigger()
				sleep(10)
			running = 0
/datum/robotinstructions/proc/abort()
	abort = 1
/datum/robotinstructions/proc/ready()
	if(abort == 0 && running == 0)
		return 1
	else
		return 0

/datum/robotinstructions/proc/addchipend(var/obj/machinery/robot2/chip/_do/chip)
	instructions[instructions.len] = chip