/obj/machinery/robot2/chip/event/talk
	name = "Voice Recongition chip"
	var/memory_message = "NULL"
	var/memory_mob = "NULL"

/obj/machinery/robot2/chip/event/talk/proc/talk_into(mob/M as mob, var/message)
	robot.setmemory(memory_message,message)
	robot.setmemory(memory_mob,M.name)
	if(instructions.ready())
		instructions.execute()