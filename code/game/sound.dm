//Sound environment defines. Reverb preset for sounds played in an area, see sound datum reference for more.
#define GENERIC 0
#define PADDED_CELL 1
#define ROOM 2
#define BATHROOM 3
#define LIVINGROOM 4
#define STONEROOM 5
#define AUDITORIUM 6
#define CONCERT_HALL 7
#define CAVE 8
#define ARENA 9
#define HANGAR 10
#define CARPETED_HALLWAY 11
#define HALLWAY 12
#define STONE_CORRIDOR 13
#define ALLEY 14
#define FOREST 15
#define CITY 16
#define MOUNTAINS 17
#define QUARRY 18
#define PLAIN 19
#define PARKING_LOT 20
#define SEWER_PIPE 21
#define UNDERWATER 22
#define DRUGGED 23
#define DIZZY 24
#define PSYCHOTIC 25

#define STANDARD_STATION STONEROOM
#define LARGE_ENCLOSED HANGAR
#define SMALL_ENCLOSED BATHROOM
#define TUNNEL_ENCLOSED CAVE
#define LARGE_SOFTFLOOR CARPETED_HALLWAY
#define MEDIUM_SOFTFLOOR LIVINGROOM
#define SMALL_SOFTFLOOR ROOM
#define ASTEROID CAVE
#define SPACE UNDERWATER

GLOBAL_LIST_INIT(shatter_sound,list('sound/effects/materials/glass/break1.ogg', 'sound/effects/materials/glass/break2.ogg', 'sound/effects/materials/glass/break3.ogg'))
GLOBAL_LIST_INIT(glass_hit_sound,list('sound/effects/materials/glass/knock1.ogg', 'sound/effects/materials/glass/knock2.ogg', 'sound/effects/materials/glass/knock3.ogg',
										'sound/effects/materials/glass/knock4.ogg', 'sound/effects/materials/glass/knock5.ogg', 'sound/effects/materials/glass/knock6.ogg'))

GLOBAL_LIST_INIT(explosion_sound,list('sound/effects/explosions/explosion1.ogg', 'sound/effects/explosions/explosion2.ogg', 'sound/effects/explosions/explosion3.ogg',
										'sound/effects/explosions/explosion4.ogg', 'sound/effects/explosions/explosion5.ogg', 'sound/effects/explosions/explosion6.ogg',
										'sound/effects/explosions/explosion7.ogg', 'sound/effects/explosions/explosion8.ogg', 'sound/effects/explosions/explosion9.ogg',
										'sound/effects/explosions/explosion10.ogg', 'sound/effects/explosions/explosion11.ogg', 'sound/effects/explosions/explosion12.ogg',
										'sound/effects/explosions/explosion13.ogg', 'sound/effects/explosions/explosion14.ogg', 'sound/effects/explosions/explosion15.ogg',
										'sound/effects/explosions/explosion16.ogg', 'sound/effects/explosions/explosion17.ogg', 'sound/effects/explosions/explosion18.ogg',
										'sound/effects/explosions/explosion19.ogg', 'sound/effects/explosions/explosion20.ogg', 'sound/effects/explosions/explosion21.ogg',
										'sound/effects/explosions/explosion22.ogg', 'sound/effects/explosions/explosion23.ogg', 'sound/effects/explosions/explosion24.ogg'))

GLOBAL_LIST_INIT(spark_sound,list('sound/effects/electric/spark1.ogg','sound/effects/electric/spark2.ogg','sound/effects/electric/spark3.ogg',
									'sound/effects/electric/spark4.ogg', 'sound/effects/electric/spark5.ogg'))

GLOBAL_LIST_INIT(spark_medium_sound,list('sound/effects/electric/medium_spark1.ogg','sound/effects/electric/medium_spark2.ogg'))

GLOBAL_LIST_INIT(spark_heavy_sound,list('sound/effects/electric/heavy_spark1.ogg','sound/effects/electric/heavy_spark2.ogg','sound/effects/electric/heavy_spark3.ogg',
									'sound/effects/electric/heavy_spark4.ogg'))

GLOBAL_LIST_INIT(searching_clothes_sound,list('sound/effects/using/clothing/use1.ogg','sound/effects/using/clothing/use2.ogg','sound/effects/using/clothing/use3.ogg',
												'sound/effects/using/clothing/use4.ogg','sound/effects/using/clothing/use5.ogg','sound/effects/using/clothing/use6.ogg'))

GLOBAL_LIST_INIT(searching_cabinet_sound,list('sound/effects/using/cabinet/slide1.ogg','sound/effects/using/cabinet/slide2.ogg','sound/effects/using/cabinet/slide3.ogg',
												'sound/effects/using/cabinet/slide4.ogg'))

GLOBAL_LIST_INIT(searching_case_sound,list('sound/effects/using/case/use1.ogg','sound/effects/using/case/use2.ogg','sound/effects/using/case/use3.ogg',
											'sound/effects/using/case/use4.ogg','sound/effects/using/case/use5.ogg','sound/effects/using/case/use6.ogg',
											'sound/effects/using/case/use7.ogg','sound/effects/using/case/use8.ogg'))

GLOBAL_LIST_INIT(punch_sound,list('sound/weapons/punch1.ogg','sound/weapons/punch2.ogg','sound/weapons/punch3.ogg','sound/weapons/punch4.ogg'))
GLOBAL_LIST_INIT(clown_sound,list('sound/effects/clownstep1.ogg','sound/effects/clownstep2.ogg'))
GLOBAL_LIST_INIT(swing_hit_sound,list('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg'))
GLOBAL_LIST_INIT(hiss_sound,list('sound/voice/hiss1.ogg','sound/voice/hiss2.ogg','sound/voice/hiss3.ogg','sound/voice/hiss4.ogg'))
GLOBAL_LIST_INIT(page_sound,list('sound/effects/pageturn1.ogg', 'sound/effects/pageturn2.ogg','sound/effects/pageturn3.ogg'))
GLOBAL_LIST_INIT(fracture_sound,list('sound/effects/bonebreak1.ogg','sound/effects/bonebreak2.ogg','sound/effects/bonebreak3.ogg','sound/effects/bonebreak4.ogg'))
GLOBAL_LIST_INIT(lighter_sound,list('sound/items/lighter1.ogg','sound/items/lighter2.ogg','sound/items/lighter3.ogg'))
GLOBAL_LIST_INIT(keyboard_sound,list('sound/machines/keyboard/keypress1.ogg','sound/machines/keyboard/keypress2.ogg','sound/machines/keyboard/keypress3.ogg','sound/machines/keyboard/keypress4.ogg'))
GLOBAL_LIST_INIT(keystroke_sound,list('sound/machines/keyboard/keystroke1.ogg','sound/machines/keyboard/keystroke2.ogg','sound/machines/keyboard/keystroke3.ogg','sound/machines/keyboard/keystroke4.ogg'))

GLOBAL_LIST_INIT(switch_small_sound,list('sound/effects/using/switch/small1.ogg','sound/effects/using/switch/small2.ogg'))

GLOBAL_LIST_INIT(switch_large_sound,list('sound/effects/using/switch/large1.ogg','sound/effects/using/switch/large2.ogg','sound/effects/using/switch/large3.ogg',
									'sound/effects/using/switch/large4.ogg'))

GLOBAL_LIST_INIT(button_sound,list('sound/machines/button1.ogg','sound/machines/button2.ogg','sound/machines/button3.ogg','sound/machines/button4.ogg'))
GLOBAL_LIST_INIT(chop_sound,list('sound/weapons/chop1.ogg','sound/weapons/chop2.ogg','sound/weapons/chop3.ogg'))

GLOBAL_LIST_INIT(far_explosion_sound,list('sound/effects/explosions/far_explosion1.ogg', 'sound/effects/explosions/far_explosion2.ogg', 'sound/effects/explosions/far_explosion3.ogg',
										'sound/effects/explosions/far_explosion4.ogg', 'sound/effects/explosions/far_explosion5.ogg', 'sound/effects/explosions/far_explosion6.ogg',
										'sound/effects/explosions/far_explosion7.ogg', 'sound/effects/explosions/far_explosion8.ogg', 'sound/effects/explosions/far_explosion9.ogg',
										'sound/effects/explosions/far_explosion10.ogg', 'sound/effects/explosions/far_explosion11.ogg', 'sound/effects/explosions/far_explosion12.ogg',
										'sound/effects/explosions/far_explosion13.ogg', 'sound/effects/explosions/far_explosion14.ogg', 'sound/effects/explosions/far_explosion15.ogg',
										'sound/effects/explosions/far_explosion16.ogg', 'sound/effects/explosions/far_explosion17.ogg', 'sound/effects/explosions/far_explosion18.ogg',
										'sound/effects/explosions/far_explosion19.ogg', 'sound/effects/explosions/far_explosion20.ogg', 'sound/effects/explosions/far_explosion21.ogg',
										'sound/effects/explosions/far_explosion22.ogg', 'sound/effects/explosions/far_explosion23.ogg', 'sound/effects/explosions/far_explosion24.ogg',
										'sound/effects/explosions/far_explosion25.ogg', 'sound/effects/explosions/far_explosion26.ogg', 'sound/effects/explosions/far_explosion27.ogg',
										'sound/effects/explosions/far_explosion28.ogg', 'sound/effects/explosions/far_explosion29.ogg', 'sound/effects/explosions/far_explosion30.ogg',
										'sound/effects/explosions/far_explosion31.ogg', 'sound/effects/explosions/far_explosion32.ogg', 'sound/effects/explosions/far_explosion33.ogg',
										'sound/effects/explosions/far_explosion34.ogg', 'sound/effects/explosions/far_explosion35.ogg', 'sound/effects/explosions/far_explosion36.ogg',
										'sound/effects/explosions/far_explosion37.ogg', 'sound/effects/explosions/far_explosion38.ogg', 'sound/effects/explosions/far_explosion39.ogg',
										'sound/effects/explosions/far_explosion40.ogg', 'sound/effects/explosions/far_explosion41.ogg', 'sound/effects/explosions/far_explosion42.ogg',
										'sound/effects/explosions/far_explosion43.ogg', 'sound/effects/explosions/far_explosion44.ogg', 'sound/effects/explosions/far_explosion45.ogg',
										'sound/effects/explosions/far_explosion46.ogg', 'sound/effects/explosions/far_explosion47.ogg', 'sound/effects/explosions/far_explosion48.ogg',
										'sound/effects/explosions/far_explosion49.ogg', 'sound/effects/explosions/far_explosion50.ogg'))

/proc/playsound(var/atom/source, soundin, vol as num, vary, extrarange as num, falloff, var/is_global, var/frequency, var/is_ambiance = 0)

	soundin = get_sfx(soundin) // same sound for everyone

	if(isarea(source))
		error("[source] is an area and is trying to make the sound: [soundin]")
		return
	frequency = vary && isnull(frequency) ? get_rand_frequency() : frequency // Same frequency for everybody
	var/turf/turf_source = get_turf(source)

	// Looping through the player list has the added bonus of working for mobs inside containers
	for (var/P in GLOB.player_list)
		var/mob/M = P
		if(!M || !M.client)
			continue
		if(get_dist(M, turf_source) <= (world.view + extrarange) * 2)
			var/turf/T = get_turf(M)
			if(T && T.z == turf_source.z && (!is_ambiance || M.get_preference_value(/datum/client_preference/play_ambiance) == GLOB.PREF_YES))
				M.playsound_local(turf_source, soundin, vol, vary, frequency, falloff, is_global, extrarange)

var/const/FALLOFF_SOUNDS = 0.5

/mob/proc/playsound_local(var/turf/turf_source, soundin, vol as num, vary, frequency, falloff, is_global, extrarange)
	if(!src.client || ear_deaf > 0)	return
	var/sound/S = soundin
	if(!istype(S))
		soundin = get_sfx(soundin)
		S = sound(soundin)
		S.wait = 0 //No queue
		S.channel = 0 //Any channel
		S.volume = vol
		S.environment = -1
		if(frequency)
			S.frequency = frequency
		else if (vary)
			S.frequency = get_rand_frequency()

	//sound volume falloff with pressure
	var/pressure_factor = 1.0

	if(isturf(turf_source))
		// 3D sounds, the technology is here!
		var/turf/T = get_turf(src)

		//sound volume falloff with distance
		var/distance = get_dist(T, turf_source)

		S.volume -= max(distance - (world.view + extrarange), 0) * 2 //multiplicative falloff to add on top of natural audio falloff.

		var/datum/gas_mixture/hearer_env = T.return_air()
		var/datum/gas_mixture/source_env = turf_source.return_air()

		if (hearer_env && source_env)
			var/pressure = min(hearer_env.return_pressure(), source_env.return_pressure())

			if (pressure < ONE_ATMOSPHERE)
				pressure_factor = max((pressure - SOUND_MINIMUM_PRESSURE)/(ONE_ATMOSPHERE - SOUND_MINIMUM_PRESSURE), 0)
		else //in space
			pressure_factor = 0

		if (distance <= 1)
			pressure_factor = max(pressure_factor, 0.15)	//hearing through contact

		S.volume *= pressure_factor

		if (S.volume <= 0)
			return	//no volume means no sound

		var/dx = turf_source.x - T.x // Hearing from the right/left
		S.x = dx
		var/dz = turf_source.y - T.y // Hearing from infront/behind
		S.z = dz
		// The y value is for above your head, but there is no ceiling in 2d spessmens.
		S.y = 1
		S.falloff = (falloff ? falloff : FALLOFF_SOUNDS)

	if(!is_global)

		if(istype(src,/mob/living/))
			var/mob/living/carbon/M = src
			if (istype(M) && M.hallucination_power > 50 && M.chem_effects[CE_MIND] < 1)
				S.environment = PSYCHOTIC
			else if (M.druggy)
				S.environment = DRUGGED
			else if (M.drowsyness)
				S.environment = DIZZY
			else if (M.confused)
				S.environment = DIZZY
			else if (M.stat == UNCONSCIOUS)
				S.environment = UNDERWATER
			else if (pressure_factor < 0.5)
				S.environment = SPACE
			else
				var/area/A = get_area(src)
				S.environment = A.sound_env

		else if (pressure_factor < 0.5)
			S.environment = SPACE
		else
			var/area/A = get_area(src)
			S.environment = A.sound_env

	src << S

/client/proc/playtitlemusic()
	if(get_preference_value(/datum/client_preference/play_lobby_music) == GLOB.PREF_YES)
		GLOB.lobby_music.play_to(src)

/proc/get_rand_frequency()
	return rand(32000, 55000) //Frequency stuff only works with 45kbps oggs.

/proc/get_sfx(soundin)
	if(istext(soundin))
		switch(soundin)
			if ("shatter") soundin = pick(GLOB.shatter_sound)
			if ("glass_hit") soundin = pick(GLOB.glass_hit_sound)
			if ("explosion") soundin = pick(GLOB.explosion_sound)
			if ("sparks") soundin = pick(GLOB.spark_sound)
			if ("sparks_medium") soundin = pick(GLOB.spark_medium_sound)
			if ("sparks_heavy") soundin = pick(GLOB.spark_heavy_sound)
			if ("searching_clothes") soundin = pick(GLOB.searching_clothes_sound)
			if ("searching_cabinet") soundin = pick(GLOB.searching_cabinet_sound)
			if ("searching_case") soundin = pick(GLOB.searching_case_sound)
			if ("punch") soundin = pick(GLOB.punch_sound)
			if ("clownstep") soundin = pick(GLOB.clown_sound)
			if ("swing_hit") soundin = pick(GLOB.swing_hit_sound)
			if ("hiss") soundin = pick(GLOB.hiss_sound)
			if ("pageturn") soundin = pick(GLOB.page_sound)
			if ("fracture") soundin = pick(GLOB.fracture_sound)
			if ("light_bic") soundin = pick(GLOB.lighter_sound)
			if ("keyboard") soundin = pick(GLOB.keyboard_sound)
			if ("keystroke") soundin = pick(GLOB.keystroke_sound)
			if ("switch_small") soundin = pick(GLOB.switch_small_sound)
			if ("switch_large") soundin = pick(GLOB.switch_large_sound)
			if ("button") soundin = pick(GLOB.button_sound)
			if ("chop") soundin = pick(GLOB.chop_sound)
			if ("far_explosion") soundin = pick(GLOB.far_explosion_sound)
	return soundin
