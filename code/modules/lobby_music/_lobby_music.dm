// Include the lobby music tracks to automatically add them to the random selection.

GLOBAL_DATUM(lobby_music, /lobby_music)

/lobby_music
	var/artist
	var/title
	var/album
	var/license
	var/song
	var/url // Remember to include http:// or https://

/lobby_music/proc/play_to(listener)
	if(!song)
		return
	if(title)
		to_chat(listener, "<span class='good'>Now Playing:</span>")
		to_chat(listener, "<span class='good'>[url ? "<a href='[url]'>[title]</a>" : "[title]"][artist ? " by [artist]" : ""][album ? " ([album])" : ""]</span>")
	if(license)
		var/license_url = license_to_url[license]
		to_chat(listener, "<span class='good linkify'>License: [license_url ? "<a href='[license_url]'>[license]</a>" : license]</span>")
	sound_to(listener, sound(song, repeat = 0, wait = 0, volume = 70, channel = 1))
