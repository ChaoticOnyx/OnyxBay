/datum/wizard_class/necromancer
	name = "Necromancer"
	feedback_tag = "NM"
	description = "Channel the dark energy of death."
	points = 8
	can_make_contracts = TRUE

	spells = list(
		SPELL_DATA(/datum/spell/targeted/raiseundead,                1),
		SPELL_DATA(/datum/spell/targeted/heal_target,                 1),
		SPELL_DATA(/datum/spell/hand/marsh_of_the_dead,               1),
		SPELL_DATA(/datum/spell/immaterial_form,                      1),
		SPELL_DATA(/datum/spell/targeted/raiseundead/lichify,                   1),
		SPELL_DATA(/datum/spell/targeted/noremorse,                   1),
		SPELL_DATA(/datum/spell/noclothes,                            3),
		SPELL_DATA(/datum/spell/undead/undead_evolution,              1)
	)

	artifacts = list(
		ARTIFACT_DATA(/obj/item/gun/whip_of_torment,       1),
		ARTIFACT_DATA(/obj/item/staff/plague_bell,                 1),
		ARTIFACT_DATA(/obj/item/device/ghost_gramophone,           1)
	)

/datum/wizard_class/lich
	name = "Lich"
	feedback_tag = "LNM"
	description = "Channel the dark energy of death."
	points = 3
	can_make_contracts = FALSE

	spells = list(
		SPELL_DATA(/datum/spell/targeted/projectile/magic_missile,     1),
		SPELL_DATA(/datum/spell/hand/slippery_surface,                 1),
		SPELL_DATA(/datum/spell/targeted/projectile/dumbfire/fireball, 1),
		SPELL_DATA(/datum/spell/aoe_turf/disable_tech,                 1),
		SPELL_DATA(/datum/spell/aoe_turf/smoke,                        1),
		SPELL_DATA(/datum/spell/targeted/genetic/blind,                1),
		SPELL_DATA(/datum/spell/targeted/subjugation,                  1),
		SPELL_DATA(/datum/spell/aoe_turf/conjure/forcewall,            1),
		SPELL_DATA(/datum/spell/area_teleport,                         1),
		SPELL_DATA(/datum/spell/targeted/heal_target,                  1),
		SPELL_DATA(/datum/spell/aoe_turf/knock,                        1),
		SPELL_DATA(/datum/spell/hand/burning_grip,                     1)
	)

	artifacts = list(
		ARTIFACT_DATA(/obj/structure/closet/wizard/lich_garbs,       0)
	)
