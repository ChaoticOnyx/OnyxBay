/datum/donator_info
	var/donator = FALSE
	var/patron_type = PATREON_NONE
	var/points

/datum/donator_info/proc/on_loaded(client/C)
	if(patron_type != PATREON_NONE)
		C.set_preference(/datum/client_preference/ooc_name_color, patron_type)

/datum/donator_info/proc/get_decorated_ooc_name(client/C)
	var/choosen_ooc_patreon_tier = C.get_preference_value(/datum/client_preference/ooc_name_color)
	switch(choosen_ooc_patreon_tier)
		if(PATREON_CARGO)     return "<span class=\"pt_cargo\">[C.key]</span>"
		if(PATREON_ENGINEER)  return "<span class=\"pt_engineer\">[C.key]</span>"
		if(PATREON_SCIENTIST) return "<span class=\"pt_scientist\">[C.key]</span>"
		if(PATREON_HOS)       return "<span class=\"pt_hos\">[C.key]</span>"
		if(PATREON_CAPTAIN)   return "<span class=\"pt_captain\">[C.key]</span>"
		if(PATREON_WIZARD)    return "<span class=\"pt_wizard\">[C.key]</span>"
		if(PATREON_CULTIST)   return "<span class=\"pt_cultist\">[C.key]</span>"
		if(PATREON_ASSISTANT) return "<span class=\"pt_assistant\">[C.key]</span>"
	return C.key

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

	ASSERT(FALSE) // inaccessible
