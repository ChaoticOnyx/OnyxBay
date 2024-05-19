/datum/evolution_holder/wrath
	evolution_categories = list(
		/datum/evolution_category/wrath
	)
	default_modifiers = list(/datum/modifier/sin/wrath)

/datum/evolution_category/wrath
	name = "Sin of Wrath"
	items = list(
		/datum/evolution_package/devil_arc_lighting,
		/datum/evolution_package/wrath_modifier,
	)

/datum/evolution_package/devil_arc_lighting
	name = "Arc Lighting"
	desc = "Unleash your fury on those opposing your will."
	actions = list(
		/datum/action/cooldown/spell/beam/chained/devil_arc_lighting
	)

/datum/evolution_package/wrath_modifier
	name = "Unnatural Strength"
	desc = "Kick and punch."
	actions = list(
		/datum/action/cooldown/wrath_modifier
	)

/datum/evolution_package/wrath
	modifiers = list(
		/datum/modifier/sin/wrath
	)

/datum/modifier/sin/wrath
	outgoing_melee_damage_percent = 1.5
	incoming_damage_percent = 1.5
