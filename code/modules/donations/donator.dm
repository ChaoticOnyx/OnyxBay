
/proc/patron_tier_to_css_class(tier)
	switch(tier)
		if(PATREON_CARGO)     return "pt_cargo"
		if(PATREON_ENGINEER)  return "pt_engineer"
		if(PATREON_SCIENTIST) return "pt_scientist"
		if(PATREON_HOS)       return "pt_hos"
		if(PATREON_CAPTAIN)   return "pt_captain"
		if(PATREON_WIZARD)    return "pt_wizard"
		if(PATREON_CULTIST)   return "pt_cultist"
		if(PATREON_ASSISTANT) return "pt_assistant"

/proc/patron_tier_decorated(tier)
	if(tier == PATREON_NONE)
		return null

	switch(tier)
		if(PATREON_CARGO) . = "Cargo Technician"
		if(PATREON_HOS) . = "Head of Security"
		else
			. = capitalize(tier)

	return "<span class='[patron_tier_to_css_class(tier)]'>[.]</span>"

/datum/donator_info
	var/donator = FALSE
	var/patron_type = PATREON_NONE
	var/opyxes
	var/list/items = new

/datum/donator_info/proc/on_patreon_tier_loaded(client/C)
	if(!SScharacter_setup.initialized)
		return
	var/choosen_ooc_patreon_tier = C.get_preference_value(/datum/client_preference/ooc_name_color)
	if(!patreon_tier_available(choosen_ooc_patreon_tier))
		C.set_preference(/datum/client_preference/ooc_name_color, patron_type)

/datum/donator_info/proc/get_decorated_ooc_name(client/C)
	if(!SScharacter_setup.initialized)
		return C.key
	var/choosen_ooc_patreon_tier = C.get_preference_value(/datum/client_preference/ooc_name_color)
	if(choosen_ooc_patreon_tier == PATREON_NONE)
		return C.key
	return "<span class='[patron_tier_to_css_class(choosen_ooc_patreon_tier)]'>[C.key]</span>"

/datum/donator_info/proc/get_full_patron_tier()
	return patron_tier_decorated(patron_type)

/datum/donator_info/proc/get_available_ooc_patreon_tiers()
	. = list()
	for(var/type in PATREON_ALL_TIERS)
		. += type
		if(type == patron_type)
			break

/datum/donator_info/proc/patreon_tier_available(required)
	ASSERT(required in PATREON_ALL_TIERS)

	if(!(patron_type in PATREON_ALL_TIERS))
		return FALSE

	for(var/type in PATREON_ALL_TIERS)
		if(type == required)
			return TRUE
		if(type == patron_type)
			return FALSE

	CRASH("This code should not be accessible")

/datum/donator_info/proc/has_item(type)
	return "[type]" in items
