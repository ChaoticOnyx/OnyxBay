var/list/sounds_cache = list()

/client/proc/play_sound(S as sound)
	set category = "Fun"
	set name = "Play Global Sound"
	if(!check_rights(R_SOUNDS))	return

	var/sound/uploaded_sound = sound(S, repeat = 0, wait = 1, channel = 777)
	uploaded_sound.priority = 250

	sounds_cache += S

	if(alert("Do you ready?\nSong: [S]\nNow you can also play this sound using \"Play Server Sound\".", "Confirmation request" ,"Play", "Cancel") == "Cancel")
		return

	log_admin("[key_name(src)] played sound [S]", notify_admin = TRUE)
	for(var/mob/M in GLOB.player_list)
		if(M.get_preference_value(/datum/client_preference/play_admin_midis) == GLOB.PREF_YES)
			sound_to(M, uploaded_sound)

	feedback_add_details("admin_verb","PGS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/play_local_sound(S as sound)
	set category = "Fun"
	set name = "Play Local Sound"
	if(!check_rights(R_SOUNDS))	return

	log_admin("[key_name(src)] played a local sound [S]", location = src.mob, notify_admin = TRUE)
	playsound(src.mob, S, 50, 0, 0)
	feedback_add_details("admin_verb","PLS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/play_server_sound()
	set category = "Fun"
	set name = "Play Server Sound"

	if(!check_rights(R_SOUNDS))
		return

	var/list/sounds = getallfiles("sound/music/")
	sounds += sounds_cache

	var/melody = input("Select a sound from the server to play", "Server sound list") as null|anything in sounds
	if(!melody)
		return

	play_sound(melody)
	feedback_add_details("admin_verb","PSS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
