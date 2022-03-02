/datum/wizard_class/student
	name = "Student"
	feedback_tag = "ST"
	description = "This spells are dedicated to neophytes in the ways of magic."
	points = 5
	can_make_contracts = FALSE

	spells = list(
		SPELL_DATA(/datum/spell/aoe_turf/knock,                    1),
		SPELL_DATA(/datum/spell/targeted/ethereal_jaunt,           1),
		SPELL_DATA(/datum/spell/targeted/projectile/magic_missile, 1)
	)

	artifacts = list(
		ARTIFACT_DATA(/obj/item/gun/energy/staff/focus, 1),
		ARTIFACT_DATA(/obj/item/contract/wizard/xray,   1)
	)
