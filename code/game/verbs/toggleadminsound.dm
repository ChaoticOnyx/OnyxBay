/client/verb/adminsounds()
	set name = "Toggle admin sounds"

	src.playadminsound = !src.playadminsound
	if(src.playadminsound == 0)
		var/sound/S = sound(null)
		S.channel = 999
		src << S

	src << "Toggled [src.playadminsound]"