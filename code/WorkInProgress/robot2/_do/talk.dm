/obj/machinery/robot2/chip/_do/talk
	name = "Voice synthizer"
	var/say = "DEFAULT STRING"
	var/memory = "NULL"
/obj/machinery/robot2/chip/_do/talk/debug()
	robot.speak("Speaking")

/obj/machinery/robot2/chip/_do/talk/trigger()
	if(memory != "NULL")
		robot.speak(say + " " + robot.getmemory(memory))
	else
		robot.speak(say)
