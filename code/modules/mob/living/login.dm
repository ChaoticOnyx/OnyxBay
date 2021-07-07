
/mob/living/Login()
	..()
	//Mind updates
	mind_initialize()	//updates the mind (or creates and initializes one if one doesn't exist)
	mind.active = 1		//indicates that the mind is currently synced with a client
	if(mind.changeling?.is_revive_ready)
		to_chat(src, SPAN("notice", "<font size='5'>We are ready to rise.  Use the <b>Regenerative Stasis (20)</b> verb when you are ready.</font>"))
	//If they're SSD, remove it so they can wake back up.
	update_antag_icons(mind)
	return .
