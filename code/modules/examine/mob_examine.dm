// Mob verbs are faster than object verbs. See http://www.byond.com/forum/?post=1326139&page=2#comment8198716 for why this isn't atom/verb/examine()
/mob/verb/examinate(atom/to_axamine as mob|obj|turf in view(client.eye))
	set name = "Examine"
	set category = "IC"

	run_examinate(to_axamine)

/// Runs examine proc chain, generates styled description and prints it to mob's client chat.
/mob/proc/run_examinate(atom/to_axamine)
	if(is_ic_dead(src) || is_blind(src))
		to_chat(src, SPAN_NOTICE("Something is there but you can't see it."))
		return

	face_atom(to_axamine)

	var/to_examine_ref = ref(to_axamine)
	var/list/examine_result

	if(isnull(client))
		examine_result = to_axamine.examine(src)
	else
		if(LAZYISIN(client.recent_examines, to_examine_ref))
			examine_result = to_axamine.examine_more(src)

			if(!length(examine_result))
				examine_result += SPAN_NOTICE("<i>You examine [to_axamine] closer, but find nothing of interest...</i>")
		else
			examine_result = to_axamine.examine(src)
			LAZYADD(client.recent_examines, to_examine_ref)
			addtimer(CALLBACK(src, nameof(.proc/remove_from_recent_examines), to_examine_ref), 1 SECOND)

	to_chat(usr, "<div class='Examine'>[examine_result.Join("\n")]</div>")

/mob/proc/remove_from_recent_examines(ref_to_remove)
	SIGNAL_HANDLER

	if(isnull(client))
		return

	LAZYREMOVE(client.recent_examines, ref_to_remove)
