/mob/living/silicon/robot/_examine_text(mob/user)
	var/custom_infix = custom_name ? ", [modtype] [braintype]" : ""
	. = ..(user, infix = custom_infix)

	var/msg = ""
	msg += "\n"
	msg += examine_all_modules()
	
	msg += "<span class='warning'>"
	if (getBruteLoss())
		if (getBruteLoss() < 75)
			msg += "It looks slightly dented.\n"
		else
			msg += "<B>It looks severely dented!</B>\n"
	if (src.getFireLoss())
		if (getFireLoss() < 75)
			msg += "It looks slightly charred.\n"
		else
			msg += "<B>It looks severely burnt and heat-warped!</B>\n"
	msg += "</span>"

	if(opened)
		msg += "<span class='warning'>Its cover is open and the power cell is [cell ? "installed" : "missing"].</span>\n"
	else
		msg += "Its cover is closed.\n"

	if(!has_power)
		msg += "<span class='warning'>It appears to be running on backup power.</span>\n"

	switch(stat)
		if(CONSCIOUS)
			if (ssd_check())
				msg += "It appears to be in stand-by mode.\n" //afk
		if(UNCONSCIOUS)
			msg += "<span class='warning'>It doesn't seem to be responding.</span>\n"
		if(DEAD)
			msg += "<span class='deadsay'>It's broken, but looks repairable.</span>\n"
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
			msg += "<b><span class='notice'>Supported upgrades:</b></span>\n"
			for(var/i in module.supported_upgrades)
				var/atom/tmp = i
				if(findtext("[tmp]","/obj/item/borg/upgrade/visor/"))
					visors += "<span class='notice'>	[initial(tmp.name)]<br></span>"
				else
					msg += "<span class='notice'>	[initial(tmp.name)]<br></span>"
			msg += "<b><span class='notice'>Supported visors:</b></span>\n"
			msg += visors

	. += "\n[msg]"
	user.showLaws(src)
	return
