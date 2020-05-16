/mob/living/silicon/robot/examine(mob/user)
	var/custom_infix = custom_name ? ", [modtype] [braintype]" : ""
	. = ..(user, infix = custom_infix)

	var/msg = ""
	msg += "<span class='warning'>"
	if (src.getBruteLoss())
		if (src.getBruteLoss() < 75)
			msg += "It looks slightly dented.\n"
		else
			msg += "<B>It looks severely dented!</B>\n"
	if (src.getFireLoss())
		if (src.getFireLoss() < 75)
			msg += "It looks slightly charred.\n"
		else
			msg += "<B>It looks severely burnt and heat-warped!</B>\n"
	msg += "</span>"

	if(opened)
		msg += SPAN("warning", "Its cover is open and the power cell is [cell ? "installed" : "missing"].\n")
	else
		msg += "Its cover is closed.\n"

	if(!has_power)
		msg += SPAN("warning", "It appears to be running on backup power.\n")

	switch(src.stat)
		if(CONSCIOUS)
			if(!src.client)	msg += "It appears to be in stand-by mode.\n" //afk
		if(UNCONSCIOUS)		msg += SPAN("warning", "It doesn't seem to be responding.\n")
		if(DEAD)
			if(remotable)
				msg += SPAN("notice", "It appears to be in stand-by mode.\n") // AI disconnected from it
			else
				msg += SPAN("deadsay", "It's broken, but looks repairable.\n")
			//msg += "<span class='deadsay'>It looks completely unsalvageable.</span>\n"
	msg += "*---------*"

	if(print_flavor_text()) msg += "\n[print_flavor_text()]\n"

	if (pose)
		if( findtext(pose,".",length(pose)) == 0 && findtext(pose,"!",length(pose)) == 0 && findtext(pose,"?",length(pose)) == 0 )
			pose = addtext(pose,".") //Makes sure all emotes end with a period.
		msg += "\nIt is [pose]"

	if(hasHUD(user, HUD_SCIENCE))
		if (module)
			msg += "<hr>"
			var/visors = ""
			msg += SPAN("notice", "<b>Supported upgrades:</b>\n")
			for(var/i in module.supported_upgrades)
				var/atom/tmp = i
				if(findtext("[tmp]","/obj/item/borg/upgrade/visor/"))
					visors += SPAN("notice", "	[initial(tmp.name)]<br>")
				else
					msg += SPAN("notice", "	[initial(tmp.name)]<br>")
			msg += SPAN("notice", "<b>Supported visors:</b>\n")
			msg += visors

	to_chat(user, msg)
	user.showLaws(src)
	return
