/datum/preferences
	var/list/may_be_special_role
	var/list/be_special_role

/datum/category_item/player_setup_item/antagonism/candidacy
	name = "Candidacy"
	sort_order = 1

/datum/category_item/player_setup_item/antagonism/candidacy/load_character(savefile/S)
	from_file(S["be_special"],           pref.be_special_role)
	from_file(S["may_be_special"],     pref.may_be_special_role)

/datum/category_item/player_setup_item/antagonism/candidacy/save_character(savefile/S)
	to_file(S["be_special"],             pref.be_special_role)
	to_file(S["may_be_special"],       pref.may_be_special_role)

/datum/category_item/player_setup_item/antagonism/candidacy/sanitize_character()
	if(!istype(pref.be_special_role))
		pref.be_special_role = list()
	if(!istype(pref.may_be_special_role))
		pref.may_be_special_role = list()

	var/special_roles = valid_special_roles()
	var/old_be_special_role = pref.be_special_role.Copy()
	var/old_may_be_special_role = pref.may_be_special_role.Copy()
	for(var/role in old_be_special_role)
		if(!(role in special_roles))
			pref.be_special_role -= role
	for(var/role in old_may_be_special_role)
		if(!(role in special_roles))
			pref.may_be_special_role -= role

/datum/category_item/player_setup_item/antagonism/candidacy/content(mob/user)
	. = list()
	. += "<b>Special Role Availability:</b><br>"
	. += "<table>"
	var/list/all_antag_types = GLOB.all_antag_types_
	for(var/antag_type in all_antag_types)
		var/datum/antagonist/antag = all_antag_types[antag_type]
		. += "<tr><td>[antag.role_text]: </td><td>"
		var/bannedReason = jobban_isbanned(preference_mob(), antag.id)
		if(bannedReason == "Whitelisted Job")
			. += "<span class='danger'>\[WHITELIST\]</span><br>"
		else if(bannedReason || (antag.id == MODE_MALFUNCTION && jobban_isbanned(preference_mob(), "AI")))
			. += "<span class='danger'>\[BANNED\]</span><br>"
		else if(antag.id in pref.be_special_role)
			. += "<span class='linkOn'>High</span> <a href='?src=\ref[src];add_maybe=[antag.id]'>Low</a> <a href='?src=\ref[src];del_special=[antag.id]'>Never</a></br>"
		else if(antag.id in pref.may_be_special_role)
			. += "<a href='?src=\ref[src];add_special=[antag.id]'>High</a> <span class='linkOn'>Low</span> <a href='?src=\ref[src];del_special=[antag.id]'>Never</a></br>"
		else
			. += "<a href='?src=\ref[src];add_special=[antag.id]'>High</a> <a href='?src=\ref[src];add_maybe=[antag.id]'>Low</a> <span class='linkOn'>Never</span></br>"
		. += "</td></tr>"
	. += "</table><br>"

	. += "<b>Offer Ghost Roles:</b><br>"
	. += "<table>"
	var/list/ghost_traps = get_ghost_traps()
	for(var/ghost_trap_key in ghost_traps)
		var/datum/ghosttrap/ghost_trap = ghost_traps[ghost_trap_key]
		if(!ghost_trap.list_as_special_role)
			continue

		. += "<tr><td>[(ghost_trap.ghost_trap_role)]: </td><td>"
		var/bannedReason = banned_from_ghost_role(preference_mob(), ghost_trap)
		if(bannedReason == "Whitelisted Job")
			. += "<span class='danger'>\[WHITELIST\]</span><br>"
		else if(bannedReason)
			. += "<span class='danger'>\[BANNED\]</span><br>"
		else if((ghost_trap.pref_check in pref.be_special_role) || (ghost_trap.pref_check in pref.may_be_special_role))
			. += "<span class='linkOn'>Always</span> <a href='?src=\ref[src];del_special=[ghost_trap.pref_check]'>Never</a></br>"
		else
			. += "<a href='?src=\ref[src];add_special=[ghost_trap.pref_check]'>Always</a> <span class='linkOn'>Never</span></br>"
		. += "</td></tr>"
	. += "</table>"
	. = jointext(.,null)

/datum/category_item/player_setup_item/proc/banned_from_ghost_role(mob, datum/ghosttrap/ghost_trap)
	for(var/ban_type in ghost_trap.ban_checks)
		var/banned = jobban_isbanned(mob, ban_type)
		if(banned)
			return banned
	return FALSE

/datum/category_item/player_setup_item/antagonism/candidacy/OnTopic(href,list/href_list, mob/user)
	if(href_list["add_special"])
		if(!(href_list["add_special"] in valid_special_roles()))
			return TOPIC_HANDLED
		pref.be_special_role |= href_list["add_special"]
		pref.may_be_special_role -= href_list["add_special"]
		return TOPIC_REFRESH

	if(href_list["del_special"])
		if(!(href_list["del_special"] in valid_special_roles()))
			return TOPIC_HANDLED
		pref.be_special_role -= href_list["del_special"]
		pref.may_be_special_role -= href_list["del_special"]
		return TOPIC_REFRESH

	if(href_list["add_maybe"])
		pref.be_special_role -= href_list["add_maybe"]
		pref.may_be_special_role |= href_list["add_maybe"]
		return TOPIC_REFRESH

	return ..()

/datum/category_item/player_setup_item/antagonism/candidacy/proc/valid_special_roles()
	var/list/private_valid_special_roles = list()

	for(var/antag_type in GLOB.all_antag_types_)
		private_valid_special_roles += antag_type

	var/list/ghost_traps = get_ghost_traps()
	for(var/ghost_trap_key in ghost_traps)
		var/datum/ghosttrap/ghost_trap = ghost_traps[ghost_trap_key]
		if(!ghost_trap.list_as_special_role)
			continue
		private_valid_special_roles += ghost_trap.pref_check

	return private_valid_special_roles

/client/proc/wishes_to_be_role(role)
	if(!prefs)
		return FALSE
	if(role in prefs.be_special_role)
		return 2
	if(role in prefs.may_be_special_role)
		return 1
	return FALSE	//Default to "never" if they don't opt-in.
