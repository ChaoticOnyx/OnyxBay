/obj/machinery/robot2/robot
	name = "robot"
	icon = 'robots.dmi'
	icon_state = "standardrobot"
	var/list/obj/machinery/robot2/chip/event/eventchips = list()
	var/hasvoice = 0
	var/list/obj/machinery/robot2/chip/memory/memory = list()

/obj/machinery/robot2/robot/proc/speak(var/message)
	if(hasvoice)
		for(var/mob/O in hearers(src, null))
			O << "<span class='game say'><span class='name'>[src]</span> beeps, \"[message]\""
		return
	else
		for(var/mob/O in hearers(src, null))
			O << "<span class='game say'><span class='name'>[src]</span> beeps"
		return


/obj/machinery/robot2/robot/hear_talk(mob/M as mob, message,italics,alt_name)
	for(var/obj/machinery/robot2/chip/event/talk/chip in eventchips)
		chip.talk_into(M,message)


/obj/machinery/robot2/robot/proc/getmemory(var/memoryat)
	var/obj/machinery/robot2/chip/memory/memorychip = memory["[memoryat]"]
	if(memorychip)
		return memorychip.variable

/obj/machinery/robot2/robot/proc/setmemory(var/memoryat,var/variable)
	var/obj/machinery/robot2/chip/memory/memorychip = memory["[memoryat]"]
	if(memorychip)
		memorychip.variable = variable


/obj/machinery/robot2/robot/proc/addevent(var/obj/machinery/robot2/chip/event/chip)
	for(var/obj/machinery/robot2/chip/event/c in eventchips)
		if(c.type == chip.type)
			return
	eventchips += chip
	chip.robot = src
	chip.loc = src
	return chip

/obj/machinery/robot2/robot/proc/addmemory(var/obj/machinery/robot2/chip/memory/chip,var/location)
	if(!memory["[location]"])
		chip.loc = src
		chip.robot = src
		memory["[location]"] = chip
	return chip

/obj/machinery/robot2/robot/testbot
	name = "TEST BOT"