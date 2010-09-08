/mob/living/silicon/ai/Login()
	..()
	for(var/S in client.screen)
		del(S)
	flash = new /obj/screen( null )
	flash.icon_state = "blank"
	flash.name = "flash"
	flash.screen_loc = "1,1 to 15,15"
	flash.layer = 17
	blind = new /obj/screen( null )
	blind.icon_state = "black"
	blind.name = " "
	blind.screen_loc = "1,1 to 15,15"
	blind.layer = 0
	client.screen += list( blind, flash )

	if(stat != 2)
		for(var/obj/machinery/ai_status_display/O in world) //change status
			O.mode = 1
			O.emotion = "Neutral"