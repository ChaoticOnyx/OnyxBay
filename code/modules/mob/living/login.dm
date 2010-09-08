/mob/living/Login()
	..()
	if (!isturf(loc))
		client.eye = loc
		client.perspective = EYE_PERSPECTIVE

	update_clothing()

	if (stat == 2)
		verbs += /mob/proc/ghostize