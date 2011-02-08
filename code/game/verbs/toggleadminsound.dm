/client/verb/adminsounds()
	set name = "Toggle admin sounds"

	src.play_adminsound = !src.play_adminsound
	if(src.play_adminsound == 0)
		var/sound/S = sound(null,0,0,7,100)
		src << S

	src << "Toggled [src.play_adminsound]."