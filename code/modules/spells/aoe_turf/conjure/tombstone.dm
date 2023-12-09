/datum/spell/aoe_turf/conjure/tombstone
	name = "Tombstone"
	desc = "Creates a tombstone that will summon skeletons."

	spell_flags = NEEDSCLOTHES | Z2NOCAST | IGNOREPREV
	charge_max = 3000
	school = "necromancy"

	range = 0

	cooldown_min = 1600

	level_max = list(SP_TOTAL = 2, SP_SPEED = 2)

	summon_amt = 1
	summon_type = list(/obj/structure/tombstone)
	duration = 2 MINUTES

	icon_state = "wiz_tombstone"
	override_base = "const"

/obj/structure/tombstone
	name = "Tombstone"
	icon = 'icons/obj/structures.dmi'
	icon_state = "tombstone"
	anchored = TRUE
	density = TRUE
	var/list/summons = list()

	var/list/possible_summons = list(
		/mob/living/simple_animal/hostile/skull = 10,
		/mob/living/simple_animal/hostile/wight = 90
		)

/obj/structure/tombstone/Initialize()
	. = ..()
	set_next_think(world.time + 1 SECOND)

/obj/structure/tombstone/think()
	var/to_summon = util_pick_weight(possible_summons)
	to_summon = new to_summon(loc)
	summons.Add(to_summon)
	set_next_think(world.time + 15 SECONDS)

/obj/structure/tombstone/Destroy()
	QDEL_LIST(summons)
	set_next_think(0)
	return ..()
