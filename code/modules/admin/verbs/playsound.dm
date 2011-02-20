/client/proc/play_sound(S as sound)
	set category = "Special Verbs"
	set name = "play sound"

	if(!src.holder)
		src << "Only administrators may use this command."
		return

	var/sound/uploaded_sound = sound(S,0,0,7,100)
	uploaded_sound.priority = 255

	if(src.holder.rank == "Host" || src.holder.rank == "Coder" || src.holder.rank == "Super Administrator")
		log_admin("[key_name(src)] played sound [S]")
		message_admins("[key_name_admin(src)] played sound [S]", 1)
		for(var/client/C)
			if(C.play_ambiences == 1 && C.play_adminsound == 1)
				C << "[key_name_admin(src)] played sound [S]"
				C << uploaded_sound
	else
		if(usr.client.canplaysound)
			usr.client.canplaysound = 0
			log_admin("[key_name(src)] played sound [S]")
			message_admins("[key_name_admin(src)] played sound [S]", 1)
			for(var/client/C)
				if(C.play_ambiences == 1 && C.play_adminsound == 1)
					C << uploaded_sound
		else
			usr << "You already used up your jukebox monies this round!"
			del(uploaded_sound)
//	else
//		usr << "Can't play Sound."


	//else
	//	alert("Debugging is disabled")
	//	return