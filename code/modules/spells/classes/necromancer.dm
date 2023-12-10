/datum/wizard_class/necromancer
	name = "Necromancer"
	feedback_tag = "NM"
	description = "Channel the dark energy of death."
	points = 8
	can_make_contracts = FALSE

	spells = list(
		SPELL_DATA(/datum/spell/targeted/raiseundead,                 1),
		SPELL_DATA(/datum/spell/targeted/raiseundead/lichify,         3),
		SPELL_DATA(/datum/spell/hand/charges/marsh_of_the_dead,       1),
		SPELL_DATA(/datum/spell/toggled/immaterial_form,              1),
		SPELL_DATA(/datum/spell/targeted/noremorse,                   1),
		SPELL_DATA(/datum/spell/aoe_turf/conjure/tombstone,           1),
		SPELL_DATA(/datum/spell/targeted/shapeshift/ghoul_form,       1),
		SPELL_DATA(/datum/spell/noclothes,                            3)
	)

	artifacts = list(
		ARTIFACT_DATA(/obj/item/gun/whip_of_torment,                  1),
		ARTIFACT_DATA(/obj/item/staff/plague_bell,                    1),
		ARTIFACT_DATA(/obj/item/device/ghost_gramophone,              1),
		ARTIFACT_DATA(/obj/structure/closet/wizard/necrorobe,         1)
	)
