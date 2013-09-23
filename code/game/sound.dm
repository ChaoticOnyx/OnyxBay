/proc/playsound(var/atom/source, soundin, vol as num, vary, extrarange as num)
	//Frequency stuff only works with 45kbps oggs.

	switch(soundin)
		if ("shatter") soundin = pick('sound/effects/Glassbr1.ogg','sound/effects/Glassbr2.ogg','sound/effects/Glassbr3.ogg')
		if ("explosion") soundin = pick('sound/effects/Explosion1.ogg','sound/effects/Explosion2.ogg')
		if ("sparks") soundin = pick('sound/effects/sparks1.ogg','sound/effects/sparks2.ogg','sound/effects/sparks3.ogg','sound/effects/sparks4.ogg')
		if ("rustle") soundin = pick('sound/misc/rustle1.ogg','sound/misc/rustle2.ogg','sound/misc/rustle3.ogg','sound/misc/rustle4.ogg','sound/misc/rustle5.ogg')
		if ("punch") soundin = pick('sound/weapons/punch1.ogg','sound/weapons/punch2.ogg','sound/weapons/punch3.ogg','sound/weapons/punch4.ogg')
		if ("clownstep") soundin = pick('sound/misc/clownstep1.ogg','sound/misc/clownstep2.ogg')
		if ("swing_hit") soundin = pick('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg')

	var/sound/S = sound(soundin)
	S.wait = 0 //No queue
	S.channel = 0 //Any channel
	S.volume = vol

	if (vary)
		S.frequency = rand(32000, 55000)
	for (var/mob/M in range(world.view+extrarange, source))
		if (M.client)
			if(isturf(source))
				var/dx = source.x - M.x
				S.pan = max(-100, min(100, dx/8.0 * 100))
			M << S

/mob/proc/playsound_local(var/atom/source, soundin, vol as num, vary, extrarange as num)
	if(!src.client)
		return
	switch(soundin)
		if ("shatter") soundin = pick('sound/effects/Glassbr1.ogg','sound/effects/Glassbr2.ogg','sound/effects/Glassbr3.ogg')
		if ("explosion") soundin = pick('sound/effects/Explosion1.ogg','sound/effects/Explosion2.ogg')
		if ("sparks") soundin = pick('sound/effects/sparks1.ogg','sound/effects/sparks2.ogg','sound/effects/sparks3.ogg','sound/effects/sparks4.ogg')
		if ("rustle") soundin = pick('sound/misc/rustle1.ogg','sound/misc/rustle2.ogg','sound/misc/rustle3.ogg','sound/misc/rustle4.ogg','sound/misc/rustle5.ogg')
		if ("punch") soundin = pick('sound/weapons/punch1.ogg','sound/weapons/punch2.ogg','sound/weapons/punch3.ogg','sound/weapons/punch4.ogg')
		if ("clownstep") soundin = pick('sound/misc/clownstep1.ogg','sound/misc/clownstep2.ogg')
		if ("swing_hit") soundin = pick('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg')

	var/sound/S = sound(soundin)
	S.wait = 0 //No queue
	S.channel = 0 //Any channel
	S.volume = vol

	if (vary)
		S.frequency = rand(32000, 55000)
	if(isturf(source))
		var/dx = source.x - src.x
		S.pan = max(-100, min(100, dx/8.0 * 100))
	src << S

client/verb/Toggle_Soundscape()
	usr:client:play_ambiences = !usr:client:play_ambiences
	usr << "Toggled ambient sound."
	return


/area/Entered(A)

	if(!music)
		music = list('sound/ambience/ambigen1.ogg','sound/ambience/ambigen2.ogg','sound/ambience/ambigen3.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambigen5.ogg','sound/ambience/ambigen6.ogg','sound/ambience/ambigen7.ogg','sound/ambience/ambigen8.ogg','sound/ambience/ambigen9.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen11.ogg','sound/ambience/ambigen12.ogg','sound/ambience/ambigen13.ogg','sound/ambience/ambigen14.ogg')

	if(!istype(music, /list))
		music = list(music)

	if (ismob(A))

		if (istype(A, /mob/dead)) return
		if (!A:client) return
		if (A:ear_deaf) return

		if (prob(35))
			if(A && A:client && !A:client:played)
				A << sound(pick(music), repeat = 0, wait = 0, volume = 25, channel = 1)
				A:client:played = 1
				spawn(600 )
					if(A && A:client)
						A:client:played = 0
