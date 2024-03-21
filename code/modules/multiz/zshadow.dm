/mob  // TODO: rewrite as obj. If more efficient
	var/mob/zshadow/shadow

/mob/zshadow
	plane = OBSERVER_PLANE
	invisibility = INVISIBILITY_SYSTEM
	name = "shadow"
	desc = "Z-level shadow"
	status_flags = GODMODE
	stat = DEAD
	anchored = TRUE
	unacidable = TRUE
	density = FALSE
	opacity = FALSE					// Don't trigger lighting recalcs gah! TODO - consider multi-z lighting.
	simulated = FALSE
	//auto_init = FALSE 			// We do not need to be initialize()d
	vis_flags = VIS_HIDE
	virtual_mob = null
	var/mob/owner = null		// What we are a shadow of.

/mob/zshadow/can_fall()
	return FALSE

/mob/zshadow/Initialize(mapload, mob/L)
	if(!istype(L))
		return INITIALIZE_HINT_QDEL
	. = ..() // I'm cautious about this, but its the right thing to do.
	owner = L

/mob/zshadow/Destroy()
	owner = null
	. = ..()

// Relay some stuff they hear
/mob/zshadow/hear_say(message, verb = "says", datum/language/language = null, alt_name = "", italics = 0, atom/movable/speaker = null, sound/speech_sound, sound_vol)
	if(speaker && speaker.z != src.z)
		return // Only relay speech on our actual z, otherwise we might relay sounds that were themselves relayed up! Though this will only transmit message to adjacent z-levels
	return owner.hear_say(message, verb, language, alt_name, italics, speaker, speech_sound, sound_vol)

/mob/living/proc/check_shadow()
	var/mob/M = src
	if(isturf(M.loc))
		for(var/turf/simulated/open/OS = GetAbove(src); OS && istype(OS); OS = GetAbove(OS))
			//Check above
			if(!M.shadow)
				M.shadow = new /mob/zshadow(loc, M)
			if(M.shadow) // zshadow may get qdeled during init if something goes very wrong
				M.shadow.forceMove(OS)
				M = M.shadow

	// Clean up mob shadow if it has one
	if(M.shadow)
		qdel(M.shadow)
		M.shadow = null
		var/client/C = M.client
		if(C?.eye == shadow)
			M.reset_view(0)
