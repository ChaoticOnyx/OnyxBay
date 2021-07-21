// Abstract type for all wizard's classes
/datum/wizard_class
	var/name = ""
	var/description = ""
	var/feedback_tag = ""
	var/spell_points = 0

	var/icon = 'icons/obj/library.dmi'
	var/icon_state = "spellbook"

	// Flags
	var/no_revert = FALSE
	var/locked = FALSE
	var/can_make_contracts = FALSE
	var/investable = FALSE

	var/list/spells = list()
	var/list/artefacts = list()
	var/list/sacrifice_objects = list()
	var/list/sacrifice_reagents = list()

/datum/wizard_class/proc/to_list()
	var/list/data = list(
		"name" = name,
		"icon" = icon2base64html(type),
		"description" = description,
		"spell_points" = spell_points,
		"flags" = list(
			"no_revert" = no_revert,
			"locked" = locked,
			"can_make_contracts" = can_make_contracts,
			"investable" = investable
		),
		"spells" = list(),
		"artefacts" = list(),
		"sacrifice_objects" = list(),
		"sacrifice_reagents" = list()
	)

	for(var/S in spells)
		S["icon"] = icon2base64html(S["path"])
		data["spells"] += list(S)
	
	for(var/A in artefacts)
		A["icon"] = icon2base64html(A["path"])
		data["artefacts"] += list(A)
	
	for(var/O in sacrifice_objects)
		O["icon"] = icon2base64html(O["path"])
		data["sacrifice_objects"] += list(O)

	for(var/R in sacrifice_reagents)
		R["icon"] = icon2base64html(R["path"])
		data["sacrifice_reagents"] += list(R)

	return data
