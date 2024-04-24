/atom/proc/get_description_info()
	return description_info

/atom/proc/get_description_fluff()
	return description_fluff

/atom/proc/get_description_antag()
	return description_antag

/// Called when `user` examines this atom.
/atom/proc/examine(mob/user, infix)
	RETURN_TYPE(/list)

	var/examine_string = get_examine_string(user, infix)
	if(examine_string)
		. = list(examine_string)
	else
		. = list()

	if(desc)
		. += desc

	SEND_SIGNAL(src, SIGNAL_EXAMINED, user, .)
	SEND_SIGNAL(user, SIGNAL_MOB_EXAMINED, src, .)

/// Called when `user` examines this atom multiple times in ~1 second window.
/atom/proc/examine_more(mob/user)
	RETURN_TYPE(/list)

	. = list()

	var/info_text = get_description_info()
	if(info_text)
		. += "<font color='#084b8a'>[info_text]</font>"

	var/fluff_text = get_description_fluff()
	if(fluff_text)
		. += "<font color='#298a08'>[fluff_text]</font>"

	var/antag_text = get_description_antag()
	if(antag_text && (user?.mind?.special_role || isghost(user)))
		. += "<font color='#8a0808'>[antag_text]</font>"

	SEND_SIGNAL(src, SIGNAL_EXAMINED_MORE, user, .)
	SEND_SIGNAL(user, SIGNAL_MOB_EXAMINED_MORE, src, .)

/// Generates fancy object's name including article and dirty status.
/atom/proc/get_examine_name(mob/user, infix)
	var/infix_string = isnull(infix) ? "" : " [infix]"
	var/examine_name = "\a [SPAN_INFO("<em>[name][infix_string]</em>")]."

	if(is_bloodied)
		examine_name = gender == PLURAL ? "some " : "a"

		if(blood_color != SYNTH_BLOOD_COLOUR)
			examine_name += "[SPAN_DANGER("blood-stained")] [SPAN_INFO("<em>[name][infix_string]</em>")]!"
		else
			examine_name += "oil-stained [name][infix_string]"

	return examine_name

/// Generates leading examine line containing object's name and icon.
/atom/proc/get_examine_string(mob/user, infix)
	return "\icon[src] That's [get_examine_name(user, infix)]"
