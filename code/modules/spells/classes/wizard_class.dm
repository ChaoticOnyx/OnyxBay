// Abstract type for all wizard's classes
/datum/wizard_class
	var/name = ""
	var/description = ""
	var/feedback_tag = ""
	var/spell_points = 0

	// Flags
	var/no_revert = FALSE
	var/locked = FALSE
	var/can_make_contracts = FALSE
	var/investable = FALSE

	var/static/list/spells = list()
	var/static/list/artefacts = list()
	var/static/list/sacrifice_objects = list()
	var/static/list/sacrifice_reagents = list()

/datum/wizard_class/New()
	ASSERT(name != "")
	ASSERT(description != "")
	ASSERT(feedback_tag != "")
