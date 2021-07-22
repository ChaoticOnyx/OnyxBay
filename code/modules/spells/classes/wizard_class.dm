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

	for(var/T in spells)
		var/datum/spell/spell = T["path"]
		T["icon"] = icon2base64html(T["path"])
		T["name"] = initial(spell.name)
		T["description"] = initial(spell.desc)
		data["spells"] += list(T)
	
	for(var/T in artefacts)
		var/obj/artefact = T["path"]
		T["icon"] = icon2base64html(T["path"])
		T["name"] = initial(artefact.name)
		T["description"] = initial(artefact.desc)
		data["artefacts"] += list(T)
	
	for(var/T in sacrifice_objects)
		var/obj/object = T["path"]
		T["icon"] = icon2base64html(T["path"])
		T["name"] = initial(object.name)
		T["description"] = initial(object.desc)
		data["sacrifice_objects"] += list(T)

	for(var/T in sacrifice_reagents)
		var/datum/reagent/reagent = T["path"]
		T["name"] = initial(reagent.name)
		T["description"] = initial(reagent.description)
		data["sacrifice_reagents"] += list(T)

	return data
