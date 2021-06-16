/datum/category_item/player_setup_item/player_global/pai
	name = "pAI"
	sort_order = 3

	var/datum/paiCandidate/candidate

/datum/category_item/player_setup_item/player_global/pai/load_preferences(datum/pref_record_reader/R)
	if(!candidate)
		candidate = new()
	candidate.savefile_load(pref.client)

/datum/category_item/player_setup_item/player_global/pai/save_preferences(datum/pref_record_writer/W)
	if(!candidate)
		return
	candidate.savefile_save(pref.client)

/datum/category_item/player_setup_item/player_global/pai/content(mob/user)
	if(!candidate)
		candidate = new()

	. += "<b>pAI:</b><br>"
	if(!candidate)
		log_debug("[user] pAI prefs have a null candidate var.")
		return .
	. += "Name: <a href='?src=\ref[src];option=name'>[candidate.name ? candidate.name : "None Set"]</a><br>"
	. += "Description: <a href='?src=\ref[src];option=desc'>[candidate.description ? TextPreview(candidate.description, 40) : "None Set"]</a><br>"
	. += "Role: <a href='?src=\ref[src];option=role'>[candidate.role ? TextPreview(candidate.role, 40) : "None Set"]</a><br>"
	. += "OOC Comments: <a href='?src=\ref[src];option=ooc'>[candidate.comments ? TextPreview(candidate.comments, 40) : "None Set"]</a><br>"

/datum/category_item/player_setup_item/player_global/pai/OnTopic(href,list/href_list, mob/user)
	if(href_list["option"])
		var/t
		switch(href_list["option"])
			if("name")
				t = sanitizeName(input(user, "Enter a name for your pAI", "Global Preference", candidate.name) as text|null, MAX_NAME_LEN, TRUE)
				if(t && CanUseTopic(user))
					candidate.name = t
			if("desc")
				t = input(user, "Enter a description for your pAI", "Global Preference", html_decode(candidate.description)) as message|null
				if(!isnull(t) && CanUseTopic(user))
					candidate.description = sanitize(t)
			if("role")
				t = input(user, "Enter a role for your pAI", "Global Preference", html_decode(candidate.role)) as text|null
				if(!isnull(t) && CanUseTopic(user))
					candidate.role = sanitize(t)
			if("ooc")
				t = input(user, "Enter any OOC comments", "Global Preference", html_decode(candidate.comments)) as message
				if(!isnull(t) && CanUseTopic(user))
					candidate.comments = sanitize(t)
		return TOPIC_REFRESH

	return ..()
