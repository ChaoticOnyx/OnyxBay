/datum/wizard_class/standard
	name = "Standard"
	feedback_tag = "SB"
	description = "All its spells are easy to use but hard to master."
	points = 8
	can_make_contracts = TRUE

	spells = list(
		SPELL_DATA(/datum/spell/targeted/projectile/magic_missile,     1),
		SPELL_DATA(/datum/spell/acid_spray,                            1),
		SPELL_DATA(/datum/spell/hand/slippery_surface,                 1),
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
		ARTIFACT_DATA(/obj/item/gun/energy/staff/focus,    1),
		ARTIFACT_DATA(/obj/structure/closet/wizard/souls,         1),
		ARTIFACT_DATA(/obj/item/gun/energy/staff/animate,  1),
		ARTIFACT_DATA(/obj/structure/closet/wizard/scrying,       1),
		ARTIFACT_DATA(/obj/item/monster_manual,            2),
		ARTIFACT_DATA(/obj/item/magic_rock,                1),
		ARTIFACT_DATA(/obj/item/contract/wizard/telepathy, 1),
		ARTIFACT_DATA(/obj/item/contract/apprentice,       1)
	)
