/mob/Logout()
	log_access("Logout: [src.key]([src])")
	logged_in = 0
	world.makejson()
	..()

	return 1