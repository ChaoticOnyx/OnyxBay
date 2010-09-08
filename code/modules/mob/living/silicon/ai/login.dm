/mob/living/silicon/ai/Login()
	..()
	client.screen = null
	if(stat != 2)
		for(var/obj/machinery/ai_status_display/O in world) //change status
			O.mode = 1
			O.emotion = "Neutral"