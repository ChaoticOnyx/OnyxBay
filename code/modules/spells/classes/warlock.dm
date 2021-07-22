/datum/wizard_class/warlock
	name = "Warlock"
	feedback_tag = "SB"
	description = "Dark Spells and Artifacts."
	spell_points = 8
	can_make_contracts = TRUE
	investable = TRUE

	spells = list(
		SPELL_DATA(/datum/spell/targeted/projectile/magic_missile,     1),
		SPELL_DATA(/datum/spell/hand/charges/blood_shard,              0),
		SPELL_DATA(/datum/spell/acid_spray,                            0),
		SPELL_DATA(/datum/spell/hand/slippery_surface,                 0),
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
		ARTEFACT_DATA(/obj/item/weapon/contract/apprentice,    1),
		ARTEFACT_DATA(/obj/item/weapon/gun/energy/staff/focus, 1),
		ARTEFACT_DATA(/obj/structure/closet/wizard/souls,      1),
		ARTEFACT_DATA(/obj/structure/closet/wizard/scrying,    1),
		ARTEFACT_DATA(/obj/item/weapon/monster_manual,         1)
	)

	sacrifice_objects = list(
		SACRIFICE_DATA(/obj/item/organ/internal/heart),
		SACRIFICE_DATA(/obj/item/stack/material/silver)
	)
