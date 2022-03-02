/datum/wizard_class/spatial
	name = "Spatial"
	feedback_tag = "SP"
	description = "Movement and teleportation. Run from your problems!"
	points = 9
	can_make_contracts = TRUE

	spells = list(
		SPELL_DATA(/datum/spell/targeted/ethereal_jaunt,              1),
		SPELL_DATA(/datum/spell/area_teleport,                        1),
		SPELL_DATA(/datum/spell/mark_recall,                          1),
		SPELL_DATA(/datum/spell/targeted/swap,                        1),
		SPELL_DATA(/datum/spell/targeted/shapeshift/avian,            1),
		SPELL_DATA(/datum/spell/targeted/projectile/magic_missile,    1),
		SPELL_DATA(/datum/spell/targeted/heal_target,                 1),
		SPELL_DATA(/datum/spell/aoe_turf/conjure/forcewall,           1),
		SPELL_DATA(/datum/spell/aoe_turf/smoke,                       1),
		SPELL_DATA(/datum/spell/aoe_turf/conjure/summon/bats,         3),
		SPELL_DATA(/datum/spell/noclothes,                            3)
	)

	artifacts = list(
		ARTIFACT_DATA(/obj/item/contract/wizard/tk,        5),
		ARTIFACT_DATA(/obj/item/dice/d20/cursed,           1),
		ARTIFACT_DATA(/obj/structure/closet/wizard/scrying,       2),
		ARTIFACT_DATA(/obj/item/teleportation_scroll,      1),
		ARTIFACT_DATA(/obj/item/magic_rock,                1),
		ARTIFACT_DATA(/obj/item/contract/wizard/telepathy, 1),
		ARTIFACT_DATA(/obj/item/contract/apprentice,       1)
	)
