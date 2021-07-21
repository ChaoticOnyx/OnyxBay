/datum/wizard_class/battlemage
	name = "Battlemage"
	feedback_tag = "BM"
	description = "Mix physical with the mystical in head to head combat."
	spell_points = 6
	can_make_contracts = TRUE
	investable = TRUE

	spells = list(
		SPELL_DATA(/datum/spell/targeted/projectile/dumbfire/passage,  1),
		SPELL_DATA(/datum/spell/targeted/equip_item/dyrnwyn,           1),
		SPELL_DATA(/datum/spell/targeted/equip_item/shield,            1),
		SPELL_DATA(/datum/spell/targeted/projectile/dumbfire/fireball, 1),
		SPELL_DATA(/datum/spell/targeted/disintegrate,                 2),
		SPELL_DATA(/datum/spell/targeted/torment,                      1),
		SPELL_DATA(/datum/spell/targeted/heal_target,                  2),
		SPELL_DATA(/datum/spell/targeted/genetic/mutate,               1),
		SPELL_DATA(/datum/spell/aoe_turf/conjure/mirage,               1),
		SPELL_DATA(/datum/spell/targeted/shapeshift/corrupt_form,      1),
		SPELL_DATA(/datum/spell/radiant_aura,                          1),
		SPELL_DATA(/datum/spell/noclothes,                             3)
	)

	artefacts = list(
		ARTEFACT_DATA(/obj/structure/closet/wizard/armor,         1),
		ARTEFACT_DATA(/obj/item/weapon/gun/energy/staff/focus,    1),
		ARTEFACT_DATA(/obj/item/weapon/dice/d20/cursed,           1),
		ARTEFACT_DATA(/obj/item/weapon/monster_manual,            2),
		ARTEFACT_DATA(/obj/item/weapon/magic_rock,                1),
		ARTEFACT_DATA(/obj/item/weapon/contract/wizard/xray,      1),
		ARTEFACT_DATA(/obj/item/weapon/contract/wizard/telepathy, 1),
		ARTEFACT_DATA(/obj/item/weapon/contract/apprentice,       1)
	)

	sacrifice_objects = list(
		/obj/item/weapon/material/sword,
		/obj/item/weapon/material/twohanded/fireaxe
	)
