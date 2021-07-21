/datum/wizard_class/cleric
	name = "Cleric"
	feedback_tag = "CR"
	description = "All about healing. Mobility and offense comes at a higher price but not impossible."
	spell_points = 8
	can_make_contracts = TRUE
	investable = TRUE

	spells = list(
		SPELL_DATA(/datum/spell/targeted/heal_target/major,            1),
		SPELL_DATA(/datum/spell/targeted/heal_target/area,             1),
		SPELL_DATA(/datum/spell/targeted/heal_target/sacrifice,        1),
		SPELL_DATA(/datum/spell/targeted/genetic/blind,                1),
		SPELL_DATA(/datum/spell/targeted/shapeshift/baleful_polymorph, 1),
		SPELL_DATA(/datum/spell/targeted/projectile/dumbfire/stuncuff, 1),
		SPELL_DATA(/datum/spell/targeted/ethereal_jaunt,               2),
		SPELL_DATA(/datum/spell/aoe_turf/knock,                        1),
		SPELL_DATA(/datum/spell/radiant_aura,                          1),
		SPELL_DATA(/datum/spell/targeted/equip_item/holy_relic,        1),
		SPELL_DATA(/datum/spell/aoe_turf/conjure/grove/sanctuary,      1),
		SPELL_DATA(/datum/spell/targeted/projectile/dumbfire/fireball, 2),
		SPELL_DATA(/datum/spell/area_teleport,                         2),
		SPELL_DATA(/datum/spell/aoe_turf/conjure/forcewall,            1),
		SPELL_DATA(/datum/spell/noclothes,                             3),
		SPELL_DATA(/datum/spell/hand/mind_control,                     2)
	)

	artefacts = list(
		ARTEFACT_DATA(/obj/item/weapon/magic_rock,                1),
		ARTEFACT_DATA(/obj/structure/closet/wizard/scrying,       2),
		ARTEFACT_DATA(/obj/item/weapon/contract/wizard/telepathy, 1),
		ARTEFACT_DATA(/obj/item/weapon/contract/apprentice,       1)
	)

	sacrifice_objects = list(
		SACRIFICE_DATA(/obj/item/seeds/mtearseed)
	)

	sacrifice_reagents = list(
		SACRIFICE_DATA(/datum/reagent/peridaxon),
		SACRIFICE_DATA(/datum/reagent/adminordrazine)
	)
