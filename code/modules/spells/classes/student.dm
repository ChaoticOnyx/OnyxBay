/datum/wizard_class/student
	name = "Student"
	feedback_tag = "ST"
	description = "This spells are dedicated to neophytes in the ways of magic."
	spell_points = 5
	can_make_contracts = TRUE
	investable = TRUE

	spells = list(
		SPELL_DATA(/datum/spell/aoe_turf/knock,                    1),
		SPELL_DATA(/datum/spell/targeted/ethereal_jaunt,           1),
		SPELL_DATA(/datum/spell/targeted/projectile/magic_missile, 1)
	)

	artefacts = list(
		ARTEFACT_DATA(/obj/item/weapon/gun/energy/staff/focus, 1),
		ARTEFACT_DATA(/obj/item/weapon/contract/wizard/xray,   1)
	)
