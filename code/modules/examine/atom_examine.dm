/// Called when `user` examines this atom.
/atom/proc/examine(mob/user)
	SHOULD_CALL_PARENT(TRUE)
	RETURN_TYPE(/list)

	var/examine_string = get_examine_string(user)
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
	SHOULD_CALL_PARENT(TRUE)
	RETURN_TYPE(/list)

	. = list()

	SEND_SIGNAL(src, SIGNAL_EXAMINED_MORE, user, .)
	SEND_SIGNAL(user, SIGNAL_MOB_EXAMINED_MORE, src, .)

/// Generates fancy object's name including article and dirty status.
/atom/proc/get_examine_name(mob/user)
	var/examine_name = "\a [SPAN_INFO("<em>[src]</em>")]."

	if(is_bloodied)
		examine_name = gender == PLURAL ? "some " : "a "

		if(blood_color != SYNTH_BLOOD_COLOUR)
			examine_name += "[SPAN_DANGER("blood-stained")] [SPAN_INFO("<em>[name]</em>")]!"
		else
			examine_name += "oil-stained [name]."

	return examine_name

/// Generates leading examine line containing object's name and icon.
/atom/proc/get_examine_string(mob/user)
	return "[icon2html(src, user)] That's [get_examine_name(user)]"
