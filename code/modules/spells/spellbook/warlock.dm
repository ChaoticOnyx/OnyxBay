obj/item/weapon/spellbook/warlock
	spellbook_type = /datum/spellbook/warlock

/datum/spellbook/warlock
	name = "\improper Warlock Spellbook"
	feedback = "SB"
	title = "Book of Dark Spells and Artifacts"
	title_desc = "Buy spells using your available spell slots. Artefacts may also be bought however their cost is permanent."
	book_desc = "A dark wizard's spellbook. Use it with dare."
	book_flags = CAN_MAKE_CONTRACTS|INVESTABLE
	max_uses = 8

	spells = list(/spell/targeted/projectile/magic_missile =		1,
				/spell/hand/charges/blood_shard =					0,
				/spell/acid_spray =									0,
				/spell/hand/slippery_surface =						0,
				/spell/targeted/projectile/dumbfire/fireball =		1,
				/spell/targeted/disintegrate =						2,
				/spell/aoe_turf/smoke =								1,
				/spell/area_teleport =								1,
				/spell/targeted/heal_target =						1,
				/spell/aoe_turf/conjure/faithful_hound =			1,
				/spell/targeted/shapeshift/corrupt_form =			1,
				/spell/targeted/torment =							1,
				/spell/hand/burning_grip =							1,
				/spell/aoe_turf/drain_blood =						1,
				/spell/noclothes =									1,
				/obj/item/weapon/contract/apprentice =				1,
				/obj/item/weapon/gun/energy/staff/focus =			1,
				/obj/structure/closet/wizard/souls =				1,
				/obj/structure/closet/wizard/scrying =				1,
				/obj/item/weapon/monster_manual =					1
				)

	sacrifice_objects = list(/obj/item/organ/internal/heart,
							/obj/item/stack/material/silver)