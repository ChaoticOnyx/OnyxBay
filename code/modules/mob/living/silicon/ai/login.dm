/mob/living/silicon/ai/Login()
	..()
	for(var/S in src.client.screen)
		del(S)
	src.flash = new /obj/screen( null )
	src.flash.icon_state = "blank"
	src.flash.name = "flash"
	src.flash.screen_loc = "1,1 to 15,15"
	src.flash.layer = 17
	src.blind = new /obj/screen( null )
	src.blind.icon_state = "black"
	src.blind.name = " "
	src.blind.screen_loc = "1,1 to 15,15"
	src.blind.layer = 0
	src.client.screen += list( src.blind, src.flash )

	if(stat != 2)
		for(var/obj/machinery/ai_status_display/O in world) //change status
			O.mode = 1
			O.emotion = "Neutral"