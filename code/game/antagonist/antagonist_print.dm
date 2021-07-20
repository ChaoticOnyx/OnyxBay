/datum/antagonist/proc/print_player_summary()

	if(!current_antagonists.len)
		return

	var/text = list()
	text += "<br><br><font size = 2><b>The [current_antagonists.len == 1 ? "[role_text] was" : "[role_text_plural] were"]:</b></font>"
	for(var/datum/mind/P in current_antagonists)
		text += print_player(P)
		text += get_special_objective_text(P)
		if(!global_objectives.len && P.objectives && P.objectives.len)
			var/failed
			var/num = 1
			for(var/datum/objective/O in P.objectives)
				text += print_objective(O, num)
				if(O.check_completion())
					text += "<font color='green'><B>Success!</B></font>"
					feedback_add_details(feedback_tag,"[O.type]|SUCCESS")
				else
					text += "<font color='red'>Fail.</font>"
					feedback_add_details(feedback_tag,"[O.type]|FAIL")
					failed = 1
				num++
			if(P.ambitions)
				text += "<br>Their goals for today were..."
				text += "<br>Their goals for today were...<br>[SPAN_NOTICE(P.ambitions)]"
			if(failed)
				text += "<br><font color='red'><B>The [role_text] has failed.</B></font>"
			else
				text += "<br><font color='green'><B>The [role_text] was successful!</B></font>"
			if(P.was_antag_given_by_storyteller)
				text += "<br><b>This antagonist was spawned by storyteller.</b>"

	if(global_objectives && global_objectives.len)
		text += "<BR><FONT size = 2>Their objectives were:</FONT>"
		var/num = 1
		for(var/datum/objective/O in global_objectives)
			text += print_objective(O, num, 1)
			num++

	// Display the results.
	text += "<br>"
	return jointext(text,null)


/datum/antagonist/proc/print_objective(datum/objective/O, num, append_success)
	var/text = "<br><b>Objective [num]:</b> [O.explanation_text] "
	if(append_success)
		if(O.check_completion())
			text += "<font color='green'><B>Success!</B></font>"
		else
			text += "<font color='red'>Fail.</font>"
	return text

/datum/antagonist/proc/print_player(datum/mind/ply)
	var/role = ply.assigned_role ? "[ply.assigned_role]" : (ply.special_role ? "[ply.special_role]" : "unknown role")
	var/text = "<br><b>[ply.name]</b> (<b>[ply.key]</b>) as \a <b>[role]</b> ("
	if(ply.current)
		if(ply.current.stat == DEAD)
			text += "died"
		else if(isNotStationLevel(ply.current.z))
			text += "fled"
		else
			text += "survived"
		if(ply.current.real_name != ply.name)
			text += " as <b>[ply.current.real_name]</b>"
	else
		text += "body destroyed"
	text += ")"

	return text
