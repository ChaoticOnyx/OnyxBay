/mob/dead/observer/Login()
	..()
	client.screen = null

	if (!isturf(loc))
		client.eye = loc
		client.perspective = EYE_PERSPECTIVE