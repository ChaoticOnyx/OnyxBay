/datum/wizard_class/warlock
	name = "Warlock"
	feedback_tag = "SB"
	description = "Dark Spells and Artifacts."
	points = 8
	can_make_contracts = TRUE

	spells = list(
		SPELL_DATA(/datum/spell/targeted/projectile/magic_missile,     1),
		SPELL_DATA(/datum/spell/hand/charges/blood_shard,              1),
		SPELL_DATA(/datum/spell/acid_spray,                            1),
		SPELL_DATA(/datum/spell/hand/slippery_surface,                 1),
		SPELL_DATA(/datum/spell/targeted/projectile/dumbfire/fireball, 1),
		SPELL_DATA(/datum/spell/targeted/disintegrate,                 2),
		SPELL_DATA(/datum/spell/aoe_turf/smoke,                        1),
		SPELL_DATA(/datum/spell/area_teleport,                         1),
		SPELL_DATA(/datum/spell/targeted/heal_target,                  1),
		SPELL_DATA(/datum/spell/aoe_turf/conjure/faithful_hound,       1),
		SPELL_DATA(/datum/spell/targeted/shapeshift/corrupt_form,      1),
		SPELL_DATA(/datum/spell/targeted/torment,                      1),
		SPELL_DATA(/datum/spell/hand/burning_grip,                     1),
		SPELL_DATA(/datum/spell/aoe_turf/drain_blood,                  1),
		SPELL_DATA(/datum/spell/noclothes,                             3)
	)

	artifacts = list(
		ARTIFACT_DATA(/obj/item/contract/apprentice,    1),
		ARTIFACT_DATA(/obj/item/gun/energy/staff/focus, 1),
		ARTIFACT_DATA(/obj/structure/closet/wizard/souls,      1),
		ARTIFACT_DATA(/obj/structure/closet/wizard/scrying,    1),
		ARTIFACT_DATA(/obj/item/monster_manual,         1)
	)
