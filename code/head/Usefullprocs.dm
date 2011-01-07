
// Catches a message from say()
obj/proc/CatchMessage(msg,mob/source)
	return

/*/obj/machinery/door/CatchMessage(msg,mob/source)
	if(!findtext(msg,"door,open") && !findtext(msg,"door,close"))
		return
	if(istype(source,/mob/living/carbon/human))
		if(!locate(source) in view(3,src))
			return
		if(src.allowed(source))
			for(var/mob/M in viewers(src))
				M << "[src]: Access Granted"
			if(src.density && findtext(msg,"door,open"))
				open()
			else if(findtext(msg,"door,close"))
				close()
		else
			for(var/mob/M in viewers(src))
				M << "[src]: Access Denied"*/


