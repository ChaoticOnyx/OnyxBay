/datum/wizard_class/druid
	name = "Druid"
	feedback_tag = "DL"
	description = "Summons, nature, and a bit o' healin."
	points = 8
	can_make_contracts = TRUE

	spells = list(
		SPELL_DATA(/datum/spell/targeted/heal_target,             1),
		SPELL_DATA(/datum/spell/targeted/heal_target/sacrifice,   1),
		SPELL_DATA(/datum/spell/aoe_turf/conjure/mirage,          1),
		SPELL_DATA(/datum/spell/aoe_turf/conjure/summon/bats,     1),
		SPELL_DATA(/datum/spell/aoe_turf/conjure/summon/bear,     1),
		SPELL_DATA(/datum/spell/targeted/equip_item/party_hardy,  1),
		SPELL_DATA(/datum/spell/targeted/equip_item/seed,         1),
		SPELL_DATA(/datum/spell/targeted/shapeshift/avian,        1),
		SPELL_DATA(/datum/spell/aoe_turf/disable_tech,            1),
		SPELL_DATA(/datum/spell/hand/charges/entangle,            1),
		SPELL_DATA(/datum/spell/aoe_turf/conjure/grove/sanctuary, 1),
		SPELL_DATA(/datum/spell/aoe_turf/knock,                   1),
		SPELL_DATA(/datum/spell/area_teleport,                    2),
		SPELL_DATA(/datum/spell/noclothes,                        3),
		SPELL_DATA(/datum/spell/aoe_turf/conjure/faithful_hound,  1)
	)

	artifacts = list(
		ARTIFACT_DATA(/obj/structure/closet/wizard/souls,         1),
		ARTIFACT_DATA(/obj/item/magic_rock,                1),
		ARTIFACT_DATA(/obj/item/monster_manual,            1),
		ARTIFACT_DATA(/obj/item/contract/wizard/telepathy, 1),
		ARTIFACT_DATA(/obj/item/contract/apprentice,       1)
	)
