#define TOPIC_UPDATE_PREVIEW 4
#define TOPIC_HARD_REFRESH   8 // use to force a browse() call, unblocking some rsc operations
#define TOPIC_REFRESH_UPDATE_PREVIEW (TOPIC_HARD_REFRESH|TOPIC_UPDATE_PREVIEW)

#define PREF_FBP_CYBORG "cyborg"
#define PREF_FBP_POSI "posi"
#define PREF_FBP_SOFTWARE "software"


var/const/CHARACTER_PREFERENCE_INPUT_TITLE = "Character Preference"

/datum/category_group/player_setup_category/general_preferences
	name = "General"
	sort_order = 1
	category_item_type = /datum/category_item/player_setup_item/general

/datum/category_group/player_setup_category/occupation_preferences
	name = "Jobs"
	sort_order = 2
	category_item_type = /datum/category_item/player_setup_item/occupation

/datum/category_group/player_setup_category/appearance_preferences
	name = "Roles"
	sort_order = 3
	category_item_type = /datum/category_item/player_setup_item/antagonism

/datum/category_group/player_setup_category/loadout_preferences
	name = "Loadout"
	sort_order = 4
	category_item_type = /datum/category_item/player_setup_item/loadout

/datum/category_group/player_setup_category/trait_preferences
	name = "Traits"
	sort_order = 5
	category_item_type = /datum/category_item/player_setup_item/traits

/datum/category_group/player_setup_category/relations_preferences
	name = "Relations"
	sort_order = 6
	category_item_type = /datum/category_item/player_setup_item/relations

/datum/category_group/player_setup_category/global_preferences
	name = "<b>Settings</b>"
	sort_order = 7
	category_item_type = /datum/category_item/player_setup_item/player_global


/****************************
* Category Collection Setup *
****************************/
/datum/category_collection/player_setup_collection
	category_group_type = /datum/category_group/player_setup_category
	var/datum/preferences/preferences
	var/datum/category_group/player_setup_category/selected_category = null

/datum/category_collection/player_setup_collection/New(datum/preferences/preferences)
	src.preferences = preferences
	..()
	selected_category = categories[1]

/datum/category_collection/player_setup_collection/Destroy()
	preferences = null
	selected_category = null
	return ..()

/datum/category_collection/player_setup_collection/proc/sanitize_setup()
	for(var/datum/category_group/player_setup_category/PS in categories)
		PS.sanitize_setup()

/datum/category_collection/player_setup_collection/proc/load_character(datum/pref_record_reader/R)
	for(var/datum/category_group/player_setup_category/PS in categories)
		PS.load_character(R)

/datum/category_collection/player_setup_collection/proc/save_character(datum/pref_record_writer/W)
	for(var/datum/category_group/player_setup_category/PS in categories)
		PS.save_character(W)

/datum/category_collection/player_setup_collection/proc/load_preferences(datum/pref_record_reader/R)
	for(var/datum/category_group/player_setup_category/PS in categories)
		PS.load_preferences(R)

/datum/category_collection/player_setup_collection/proc/save_preferences(datum/pref_record_writer/W)
	for(var/datum/category_group/player_setup_category/PS in categories)
		PS.save_preferences(W)

/datum/category_collection/player_setup_collection/proc/header()
	var/dat = ""
	for(var/datum/category_group/player_setup_category/PS in categories)
		if(PS == selected_category)
			dat += "[PS.name] "	// TODO: Check how to properly mark a href/button selected in a classic browser window
		else
			dat += "<a href='?src=\ref[src];category=\ref[PS]'>[PS.name]</a> "
	return dat

/datum/category_collection/player_setup_collection/proc/content(mob/user)
	if(selected_category)
		return selected_category.content(user)

/datum/category_collection/player_setup_collection/Topic(href,list/href_list)
	if(..())
		return 1
	var/mob/user = usr
	if(!user.client)
		return 1

	if(href_list["category"])
		var/category = locate(href_list["category"])
		if(category && (category in categories))
			selected_category = category
		. = 1

	if(.)
		user.client.prefs.update_setup_window(user)

/**************************
* Category Category Setup *
**************************/
/datum/category_group/player_setup_category
	var/sort_order = 0

/datum/category_group/player_setup_category/dd_SortValue()
	return sort_order

/datum/category_group/player_setup_category/proc/sanitize_setup()
	for(var/datum/category_item/player_setup_item/PI in items)
		PI.sanitize_preferences()
	for(var/datum/category_item/player_setup_item/PI in items)
		PI.sanitize_character()

/datum/category_group/player_setup_category/proc/load_character(datum/pref_record_reader/R)
	for(var/datum/category_item/player_setup_item/PI in items)
		PI.load_character(R)

/datum/category_group/player_setup_category/proc/save_character(datum/pref_record_writer/W)
	// Sanitize all data, then save it
	for(var/datum/category_item/player_setup_item/PI in items)
		PI.sanitize_character()
	for(var/datum/category_item/player_setup_item/PI in items)
		PI.save_character(W)

/datum/category_group/player_setup_category/proc/load_preferences(datum/pref_record_reader/R)
	for(var/datum/category_item/player_setup_item/PI in items)
		PI.load_preferences(R)

/datum/category_group/player_setup_category/proc/save_preferences(datum/pref_record_writer/W)
	for(var/datum/category_item/player_setup_item/PI in items)
		PI.sanitize_preferences()
	for(var/datum/category_item/player_setup_item/PI in items)
		PI.save_preferences(W)

/datum/category_group/player_setup_category/proc/content(mob/user)
	. = "<table style='width:100%'><tr style='vertical-align:top'><td style='width:50%'>"
	var/current = 0
	var/halfway = items.len / 2
	for(var/datum/category_item/player_setup_item/PI in items)
		if(halfway && current++ >= halfway)
			halfway = 0
			. += "</td><td></td><td style='width:50%'>"
		. += "[PI.content(user)]<br>"
	. += "</td></tr></table>"

/datum/category_group/player_setup_category/occupation_preferences/content(mob/user)
	for(var/datum/category_item/player_setup_item/PI in items)
		. += "[PI.content(user)]<br>"

/**********************
* Category Item Setup *
**********************/
/datum/category_item/player_setup_item
	var/sort_order = 0
	var/datum/preferences/pref

/datum/category_item/player_setup_item/New()
	..()
	var/datum/category_collection/player_setup_collection/psc = category.collection
	pref = psc.preferences

/datum/category_item/player_setup_item/Destroy()
	pref = null
	return ..()

/datum/category_item/player_setup_item/dd_SortValue()
	return sort_order

/*
* Called when the item is asked to load per character settings
*/
/datum/category_item/player_setup_item/proc/load_character(datum/pref_record_reader/R)
	return

/*
* Called when the item is asked to save per character settings
*/
/datum/category_item/player_setup_item/proc/save_character(datum/pref_record_writer/W)
	return

/*
* Called when the item is asked to load user/global settings
*/
/datum/category_item/player_setup_item/proc/load_preferences(datum/pref_record_reader/R)
	return

/*
* Called when the item is asked to save user/global settings
*/
/datum/category_item/player_setup_item/proc/save_preferences(datum/pref_record_writer/W)
	return

/datum/category_item/player_setup_item/proc/content()
	return

/datum/category_item/player_setup_item/proc/sanitize_character()
	return

/datum/category_item/player_setup_item/proc/sanitize_preferences()
	return

/datum/category_item/player_setup_item/Topic(href,list/href_list)
	if(..())
		return 1
	var/mob/pref_mob = preference_mob()
	if(!pref_mob || !pref_mob.client)
		return 1

	. = OnTopic(href, href_list, usr)

	// The user might have joined the game or otherwise had a change of mob while tweaking their preferences.
	pref_mob = preference_mob()
	if(!pref_mob || !pref_mob.client)
		return 1
	if(. & TOPIC_UPDATE_PREVIEW)
		pref_mob.client.prefs.preview_icon = null
	if(. & TOPIC_HARD_REFRESH)
		pref_mob.client.prefs.open_setup_window(usr)
	else if(. & TOPIC_REFRESH)
		pref_mob.client.prefs.update_setup_window(usr)

/datum/category_item/player_setup_item/CanUseTopic(mob/user)
	return 1

/datum/category_item/player_setup_item/proc/OnTopic(href,list/href_list, mob/user)
	return TOPIC_NOACTION

/datum/category_item/player_setup_item/proc/preference_mob()
	if(!pref.client)
		for(var/client/C)
			if(C.ckey == pref.client_ckey)
				pref.client = C
				break

	if(pref.client)
		return pref.client.mob

/datum/category_item/player_setup_item/proc/preference_species()
	return all_species[pref.species] || all_species[SPECIES_HUMAN]

// Checks in a really hacky way if a character's preferences say they are an FBP or not.
/datum/category_item/player_setup_item/proc/is_FBP()
	if(pref.organ_data && pref.organ_data[BP_CHEST] != "cyborg")
		return 0
	return 1

// Returns what kind of FBP the player's prefs are.  Returns 0 if they're not an FBP.
/datum/category_item/player_setup_item/proc/get_FBP_type()
	if(!is_FBP())
		return 0 // Not a robot.
	if(BP_BRAIN in pref.organ_data)
		switch(pref.organ_data[BP_BRAIN])
			if("assisted")
				return PREF_FBP_CYBORG
			if("mechanical")
				return PREF_FBP_POSI
			if("digital")
				return PREF_FBP_SOFTWARE
	return 0 //Something went wrong!
