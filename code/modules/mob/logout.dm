/mob/Logout()
	log_access("Logout: [key_name(src)]")
	logged_in = 0
	world.makejson()
	..()

	return 1