PROCESSING_SUBSYSTEM_DEF(conductor)
	name = "Conductor"
	priority = SS_PRIORITY_CONDUCTOR
	flags = SS_NO_INIT | SS_BACKGROUND
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 10 SECONDS

/datum/controller/subsystem/processing/conductor/fire(resumed)
	if(!resumed)
		processing.Cut()
		for(var/mob/living/player in GLOB.player_list)
			processing += player

	for(var/mob/living/player in processing)
		processing -= player
		var/client/C = player.client

		if(!C)
			continue

		if(C.is_ambience_music_playing())
			continue

		THROTTLE_SHARED(cooldown, AMBIENT_MUSIC_COOLDOWN, C.last_time_ambient_music_played)

		if(!cooldown)
			continue

		var/area/A = get_area(player)
		if(!A)
			C.play_ambience_music(GET_SFX(SFX_AMBIENT_MUSIC_NORMAL))
			continue

		if(istype(A, /area/space))
			if(!(player.loc.z in GLOB.using_map.station_levels) && prob(40))
				C.play_ambience_music(GET_SFX(SFX_AMBIENT_MUSIC_SPACE_TRAVEL))
				continue

		var/tag = pick(A.ambient_music_meta_tags)
		var/file_to_play = get_sound_by_tag(tag)
		C.play_ambience_music(file_to_play)

/datum/controller/subsystem/processing/conductor/proc/get_sound_by_tag(meta_tag)
	switch(meta_tag)
		if(META_MYSTIC)
			return GET_SFX(SFX_AMBIENT_MUSIC_MYSTIC)
		if(META_SPACE)
			if(prob(20))
				return GET_SFX(SFX_AMBIENT_MUSIC_MYSTIC)

			return GET_SFX(SFX_AMBIENT_MUSIC_SPACE)
		if(META_CENTCOMM)
			return GET_SFX(SFX_AMBIENT_MUSIC_CENTCOMM)
		else
			return GET_SFX(SFX_AMBIENT_MUSIC_NORMAL)
