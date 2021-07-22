/datum/wizard_class/spatial
	name = "Spatial"
	feedback_tag = "SP"
	description = "Movement and teleportation. Run from your problems!"
	spell_points = 11
	can_make_contracts = TRUE
	investable = TRUE

	spells = list(
		SPELL_DATA(/datum/spell/targeted/ethereal_jaunt,              1),
		SPELL_DATA(/datum/spell/aoe_turf/blink,                       1),
		SPELL_DATA(/datum/spell/area_teleport,                        1),
		SPELL_DATA(/datum/spell/targeted/projectile/dumbfire/passage, 1),
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
		ARTEFACT_DATA(/obj/item/weapon/contract/wizard/tk,        5),
		ARTEFACT_DATA(/obj/item/weapon/dice/d20/cursed,           1),
		ARTEFACT_DATA(/obj/structure/closet/wizard/scrying,       2),
		ARTEFACT_DATA(/obj/item/weapon/teleportation_scroll,      1),
		ARTEFACT_DATA(/obj/item/weapon/magic_rock,                1),
		ARTEFACT_DATA(/obj/item/weapon/contract/wizard/telepathy, 1),
		ARTEFACT_DATA(/obj/item/weapon/contract/apprentice,       1)
	)

	sacrifice_objects = list(
		SACRIFICE_DATA(/obj/item/stack/telecrystal)
	)

	sacrifice_reagents = list(
		SACRIFICE_DATA(/datum/reagent/hyperzine)
	)
