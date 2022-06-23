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

		if(C?.is_ambience_music_playing())
			continue

		if(!C) // clients may get lost while the proc above is running
			continue // and they do so way more frequent than you may think

		THROTTLE_SHARED(cooldown, AMBIENT_MUSIC_COOLDOWN, C.last_time_ambient_music_played)

		if(!cooldown)
			continue

		var/area/A = get_area(player)
		if(!A)
			C.play_ambience_music(GET_SFX(SFX_AMBIENT_MUSIC_NORMAL))
			continue

		if(istype(A, /area/space))
			if(!(player.loc.z in GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION)) && prob(40))
				C.play_ambience_music(GET_SFX(SFX_AMBIENT_MUSIC_SPACE_TRAVEL))
				continue

		var/tag = pick(A.ambient_music_tags)

		// The conductor decided to not play music but keep silence.
		if(!tag)
			C.last_time_ambient_music_played = world.time

		var/file_to_play = get_sound_by_tag(tag)
		C.play_ambience_music(file_to_play)

/datum/controller/subsystem/processing/conductor/proc/get_sound_by_tag(meta_tag)
	switch(meta_tag)
		if(MUSIC_TAG_MYSTIC)
			return GET_SFX(SFX_AMBIENT_MUSIC_MYSTIC)
		if(MUSIC_TAG_SPACE)
			if(prob(20))
				return GET_SFX(SFX_AMBIENT_MUSIC_MYSTIC)

			return GET_SFX(SFX_AMBIENT_MUSIC_SPACE)
		if(MUSIC_TAG_CENTCOMM)
			return GET_SFX(SFX_AMBIENT_MUSIC_CENTCOMM)
		else
			if(prob(50))
				return
			return GET_SFX(SFX_AMBIENT_MUSIC_NORMAL)
