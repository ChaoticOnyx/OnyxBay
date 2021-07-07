//STRIKE TEAMS
//Thanks to Kilakk for the admin-button portion of this code.

var/global/send_emergency_team = 0 // Used for automagic response teams
								   // 'admin_emergency_team' for admin-spawned response teams
var/ert_base_chance = 10 // Default base chance. Will be incremented by increment ERT chance.
var/can_call_ert

/client/proc/response_team()
	set name = "Dispatch Emergency Response Team"
	set category = "Special Verbs"
	set desc = "Send an emergency response team"

	if(!holder)
		to_chat(usr, "<span class='danger'>Only administrators may use this command.</span>")
		return
	if(GAME_STATE < RUNLEVEL_GAME)
		to_chat(usr, "<span class='danger'>The game hasn't started yet!</span>")
		return
	if(send_emergency_team)
		to_chat(usr, "<span class='danger'>[GLOB.using_map.boss_name] has already dispatched an emergency response team!</span>")
		return
	if(alert("Do you want to dispatch an Emergency Response Team?",,"Yes","No") != "Yes")
		return

	var/decl/security_state/security_state = decls_repository.get_decl(GLOB.using_map.security_state)
	if(security_state.current_security_level_is_lower_than(security_state.high_security_level)) // Allow admins to reconsider if the alert level is below High
		switch(alert("Current security level lower than [security_state.high_security_level.name]. Do you still want to dispatch a response team?",,"Yes","No"))
			if("No")
				return
	if(send_emergency_team)
		to_chat(usr, "<span class='danger'>Looks like somebody beat you to it!</span>")
		return

	log_admin("[key_name(usr)] used Dispatch Response Team.", notify_admin = TRUE)
	trigger_armed_response_team(1)

/client/proc/response_team_menu()
	set name = "Emergency Response Team Mission Menu"
	set category = "Special Verbs"
	set desc = "Add/remove/redact ERT mission"

	if(!check_rights(R_ADMIN))
		return
	holder.edit_mission()

/datum/admins/proc/edit_mission()
	if(GAME_STATE <= RUNLEVEL_SETUP)
		to_chat(usr, SPAN("danger", "The game hasn't started yet!"))
		return

	var/out = "<meta charset=\"utf-8\"><b>The Emergency Response Team Mission Menu</b>"
	out += "<hr>"
	out += "<b>Objectives</b></br>"
	if(GLOB.ert.global_objectives && GLOB.ert.global_objectives.len)
		var/num = 1
		for(var/datum/objective/O in GLOB.ert.global_objectives)
			out += "<b>Objective #[num]:</b> [O.explanation_text] "
			if(O.completed)
				out += "(<font color='green'>complete</font>)"
			else
				out += "(<font color='red'>incomplete</font>)"
			out += " <a href='?src=\ref[src];obj_completed=\ref[O];ert_action=1'>\[toggle\]</a>"
			out += " <a href='?src=\ref[src];obj_delete=\ref[O];ert_action=1'>\[remove\]</a><br>"
			num++
		out += "<br><a href='?src=\ref[src];obj_announce=1;ert_action=1'>\[announce objectives\]</a>"
	else
		out += "Emergency Response Teams haven't received any tasks yet!"
	out += "<br><a href='?src=\ref[src];obj_add=1;ert_action=1'>\[add objective\]</a><br><br>"
	out += "<hr>"
	out += "<b>Maximum avaliable players in ERT squad:</b> [GLOB.ert.hard_cap] "
	out += "<a href='?src=\ref[src];max_cap_change=1;ert_action=1'>\[Change\]</a>"
	show_browser(usr, out, "window=edit_mission[src]")

/mob/proc/join_response_team()
	set name = "Join Response Team"
	set category = "OOC"

	if(GAME_STATE < RUNLEVEL_GAME)
		return

	if(!MayRespawn(TRUE))
		to_chat(src, SPAN("warning", "You cannot join the response team at this time."))
		return

	if(isghost(src) || isnewplayer(src))
		if(!send_emergency_team)
			to_chat(src, SPAN("warning", "No emergency response team is currently being sent."))
			return
		if(jobban_isbanned(src, MODE_ERT) || jobban_isbanned(src, "Security Officer"))
			to_chat(src, SPAN("warning", "You are jobbanned from the emergency reponse team!"))
			return
		if(GLOB.ert.current_antagonists.len >= GLOB.ert.hard_cap)
			to_chat(src, SPAN("warning", "The emergency response team is already full!"))
			return
		GLOB.ert.create_default(src)
	else
		to_chat(src, SPAN("warning", "You need to be an observer or new player to use this."))

// returns a number of dead players in %
/proc/percentage_dead()
	var/total = 0
	var/deadcount = 0
	for(var/mob/living/carbon/human/H in SSmobs.mob_list)
		if(H.client) // Monkeys and mice don't have a client, amirite?
			if(H.stat == 2) deadcount++
			total++

	if(total == 0) return 0
	else return round(100 * deadcount / total)

// counts the number of antagonists in %
/proc/percentage_antagonists()
	var/total = 0
	var/antagonists = 0
	for(var/mob/living/carbon/human/H in SSmobs.mob_list)
		if(is_special_character(H) >= 1)
			antagonists++
		total++

	if(total == 0) return 0
	else return round(100 * antagonists / total)

// Increments the ERT chance automatically, so that the later it is in the round,
// the more likely an ERT is to be able to be called.
/proc/increment_ert_chance()
	while(send_emergency_team == 0) // There is no ERT at the time.
		var/decl/security_state/security_state = decls_repository.get_decl(GLOB.using_map.security_state)
		var/index = security_state.all_security_levels.Find(security_state.current_security_level)
		ert_base_chance += 2**index
		sleep(600 * 3) // Minute * Number of Minutes


/proc/trigger_armed_response_team(force = 0)
	if(!can_call_ert && !force)
		return
	if(send_emergency_team)
		return

	var/send_team_chance = ert_base_chance // Is incremented by increment_ert_chance.
	send_team_chance += 2*percentage_dead() // the more people are dead, the higher the chance
	send_team_chance += percentage_antagonists() // the more antagonists, the higher the chance
	send_team_chance = min(send_team_chance, 100)

	if(force) send_team_chance = 100

	// there's only a certain chance a team will be sent
	if(!prob(send_team_chance))
		command_announcement.Announce("It would appear that an emergency response team was requested for [station_name()]. Unfortunately, we were unable to send one at this time.", "[GLOB.using_map.boss_name]")
		can_call_ert = 0 // Only one call per round, ladies.
		return

	command_announcement.Announce("It would appear that an emergency response team was requested for [station_name()]. We will prepare and send one as soon as possible.", "[GLOB.using_map.boss_name]")
	evacuation_controller.add_can_call_predicate(new /datum/evacuation_predicate/ert())

	can_call_ert = 0 // Only one call per round, gentleman.
	send_emergency_team = 1

	sleep(600 * 5)
	send_emergency_team = 0 // Can no longer join the ERT.

/datum/evacuation_predicate/ert
	var/prevent_until

/datum/evacuation_predicate/ert/New()
	..()
	prevent_until = world.time + 30 MINUTES

/datum/evacuation_predicate/ert/is_valid()
	return world.time < prevent_until

/datum/evacuation_predicate/ert/can_call(user)
	if(world.time >= prevent_until)
		return TRUE
	to_chat(user, "<span class='warning'>An emergency response team has been dispatched. Evacuation requests will be denied until [duration2stationtime(prevent_until - world.time)].</span>")
	return FALSE
