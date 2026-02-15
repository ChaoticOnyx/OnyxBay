// Include the lobby music tracks to automatically add them to the random selection.

GLOBAL_DATUM(lobby_music, /lobby_music)

/lobby_music
	var/artist
	var/title
	var/album
	var/license
	var/song
	var/url // Remember to include http:// or https://

/lobby_music/proc/play_to(client/listener)
	if(!song)
		return
	if(title)
		to_chat(listener, "<span class='good'>Now Playing:</span>")
		to_chat(listener, "<span class='good'>[url ? "<a href='[url]'>[title]</a>" : "[title]"][artist ? " by [artist]" : ""][album ? " ([album])" : ""]</span>")
	if(license)
		var/license_url = license_to_url[license]
		to_chat(listener, "<span class='good linkify'>License: [license_url ? "<a href='[license_url]'>[license]</a>" : license]</span>")

	var/pref_volume = listener.get_preference_value(/datum/client_preference/volume_lobby_music)
	var/volume_music = get_volume_from_pref(pref_volume)
	sound_to(listener, sound(song, repeat = 0, wait = 0, volume = volume_music, channel = 1))


/lobby_music/proc/get_volume_from_pref(pref_volume)
	switch(pref_volume)
		if(GLOB.PREF_LOW) return 30
		if(GLOB.PREF_MED) return 60
		if(GLOB.PREF_HIGH) return 90
	return 0
