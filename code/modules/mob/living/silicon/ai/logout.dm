/mob/living/silicon/ai/Logout()
	..()
	for(var/obj/machinery/ai_status_display/O in world) //change status
		spawn( 0 )
		O.mode = 0
	if(!isturf(loc))
		client.eye = loc
		client.perspective = EYE_PERSPECTIVE
	if (stat == 2)
		verbs += /mob/proc/ghostize
	return