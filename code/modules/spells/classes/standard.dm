/datum/wizard_class/standard
	name = "Standard"
	feedback_tag = "SB"
	description = "All its spells are easy to use but hard to master."
	spell_points = 6
	can_make_contracts = TRUE
	investable = TRUE

	spells = list(
		SPELL_DATA(/datum/spell/targeted/projectile/magic_missile,     1),
		SPELL_DATA(/datum/spell/acid_spray,                            0),
		SPELL_DATA(/datum/spell/hand/slippery_surface,                 0),
		SPELL_DATA(/datum/spell/targeted/projectile/dumbfire/fireball, 1),
		SPELL_DATA(/datum/spell/targeted/disintegrate,                 2),
		SPELL_DATA(/datum/spell/aoe_turf/disable_tech,                 1),
		SPELL_DATA(/datum/spell/aoe_turf/smoke,                        1),
		SPELL_DATA(/datum/spell/targeted/genetic/blind,                1),
		SPELL_DATA(/datum/spell/targeted/subjugation,                  1),
		SPELL_DATA(/datum/spell/aoe_turf/conjure/forcewall,            1),
		SPELL_DATA(/datum/spell/aoe_turf/blink,                        1),
		SPELL_DATA(/datum/spell/area_teleport,                         1),
		SPELL_DATA(/datum/spell/targeted/genetic/mutate,               1),
		SPELL_DATA(/datum/spell/targeted/ethereal_jaunt,               1),
		SPELL_DATA(/datum/spell/targeted/heal_target,                  1),
		SPELL_DATA(/datum/spell/aoe_turf/knock,                        1),
		SPELL_DATA(/datum/spell/noclothes,                             3),
		SPELL_DATA(/datum/spell/aoe_turf/conjure/faithful_hound,       1)
	)

	artifacts = list(
		ARTEFACT_DATA(/obj/item/weapon/gun/energy/staff/focus,    1),
		ARTEFACT_DATA(/obj/structure/closet/wizard/souls,         1),
		ARTEFACT_DATA(/obj/item/weapon/gun/energy/staff/animate,  1),
		ARTEFACT_DATA(/obj/structure/closet/wizard/scrying,       1),
		ARTEFACT_DATA(/obj/item/weapon/monster_manual,            2),
		ARTEFACT_DATA(/obj/item/weapon/magic_rock,                1),
		ARTEFACT_DATA(/obj/item/weapon/contract/wizard/telepathy, 1),
		ARTEFACT_DATA(/obj/item/weapon/contract/apprentice,       1)
	)

	sacrifice_objects = list(
		SACRIFICE_DATA(/obj/item/stack/material/gold),
		SACRIFICE_DATA(/obj/item/stack/material/silver)
	)
