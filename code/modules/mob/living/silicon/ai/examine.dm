/mob/living/silicon/ai/_examine_text(mob/user)
	. = ..()
	var/msg = ""
	if (stat == DEAD)
		msg += "<span class='deadsay'>It appears to be powered-down.</span>\n"
	else
		msg += "<span class='warning'>"
		if (getBruteLoss())
			if (getBruteLoss() < 30)
				msg += "It looks slightly dented.\n"
			else
				msg += "<B>It looks severely dented!</B>\n"
		if (getFireLoss())
			if (getFireLoss() < 30)
				msg += "It looks slightly charred.\n"
			else
				msg += "<B>Its casing is melted and heat-warped!</B>\n"
		if (!has_power())
			if (getOxyLoss() > 175)
				msg += "<B>It seems to be running on backup power. Its display is blinking a \"BACKUP POWER CRITICAL\" warning.</B>\n"
			else if(getOxyLoss() > 100)
				msg += "<B>It seems to be running on backup power. Its display is blinking a \"BACKUP POWER LOW\" warning.</B>\n"
			else
				msg += "It seems to be running on backup power.\n"

		if (stat == UNCONSCIOUS || ssd_check())
			msg += "It is non-responsive and displaying the text: \"RUNTIME: Sensory Overload, stack 26/3\".\n"
		msg += "</span>"
	msg += "*---------*"
	if(hardware && (hardware.owner == src))
		msg += "<br>"
		msg += hardware.get_examine_desc()
	. += "\n[msg]"
	user.showLaws(src)
	return

/mob/proc/showLaws(mob/living/silicon/S)
	return

/mob/observer/ghost/showLaws(mob/living/silicon/S)
	if(antagHUD || is_admin(src))
		S.laws.show_laws(src)
