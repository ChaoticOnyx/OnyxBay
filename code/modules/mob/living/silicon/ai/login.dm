/mob/living/silicon/ai/Login()	//ThisIsDumb(TM) TODO: tidy this up �_� ~Carn
	..()
	if(!is_ooc_dead())
		for(var/obj/machinery/ai_status_display/O in GLOB.ai_status_display_list) //change status
			O.mode = 1
			O.emotion = "Neutral"
