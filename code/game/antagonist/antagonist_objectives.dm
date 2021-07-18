/datum/antagonist/proc/create_global_objectives(override=0)
	if(config.objectives_disabled != CONFIG_OBJECTIVE_ALL && !override)
		return 0
	if(global_objectives && global_objectives.len)
		return 0
	return 1

/datum/antagonist/proc/create_objectives(datum/mind/player, override=0)
	if(config.objectives_disabled != CONFIG_OBJECTIVE_ALL && !override)
		return 0
	if(create_global_objectives(override) || global_objectives.len)
		player.objectives |= global_objectives
	return 1

/datum/antagonist/proc/get_special_objective_text()
	return ""

/datum/antagonist/proc/print_roundend()
	var/result = 1
	if(config.objectives_disabled == CONFIG_OBJECTIVE_NONE)
		return
	if(global_objectives && global_objectives.len)
		for(var/datum/objective/O in global_objectives)
			if(!O.completed && !O.check_completion())
				result = 0
		if(result && victory_text)
			if(victory_feedback_tag)
				feedback_set_details("round_end_result","[victory_feedback_tag]")
			return SPAN_DANGER("<font size = 3>[victory_text]</font>")
		else if(loss_text)
			if(loss_feedback_tag)
				feedback_set_details("round_end_result","[loss_feedback_tag]")
			return SPAN_DANGER("<font size = 3>[loss_text]</font>")


/mob/proc/add_objectives()
	set name = "Get Objectives"
	set desc = "Recieve optional objectives."
	set category = "OOC"

	src.verbs -= /mob/proc/add_objectives

	if(!src.mind)
		return

	var/all_antag_types = GLOB.all_antag_types_
	for(var/tag in all_antag_types) //we do all of them in case an admin adds an antagonist via the PP. Those do not show up in gamemode.
		var/datum/antagonist/antagonist = all_antag_types[tag]
		if(antagonist && antagonist.is_antagonist(src.mind))
			antagonist.create_objectives(src.mind,1)

	to_chat(src, "<b><font size=3>These objectives are completely voluntary. You are not required to complete them.</font></b>")
	show_objectives(src.mind)

/mob/living/proc/write_ambition()
	set name = "Write Ambitions" //ported from infinitystation
	set category = "IC"
	set src = usr

	if(!mind)
		return
	if(!is_special_character(mind))
		to_chat(src, "<span class='warning'>While you may perhaps have goals, this verb's meant to only be visible \
		to antagonists.  Please make a bug report!</span>")
		return

	var/new_goal = sanitize(input(src, "Write down what you want to achieve in this round as an antagonist \
	 - your goals. They will be visible to all players after the end of the round. \
	remember you cannot rewrite them - only add new lines.", "Antagonist Goal") as null|message)
	if(new_goal)
		mind.ambitions += (new_goal = "<br>[roundduration2text()]: [new_goal]")
		to_chat(src, SPAN_NOTICE("Your ambitions now look like this: <b>[mind.ambitions]</b><br>. \
		You can view your ambitions in <b>Notes</b>. If you wish to change your ambition, \
		please contact Administator."))
		log_and_message_admins("updated his ambition: [new_goal]")

//some antagonist datums are not actually antagonists, so we might want to avoid
//sending them the antagonist meet'n'greet messages.
//E.G. ERT
/datum/antagonist/proc/show_objectives_at_creation(datum/mind/player)
	if(src.show_objectives_on_creation)
		show_objectives(player)
