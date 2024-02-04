#define MARSH_ACTIVE_TIME 60 SECONDS
#define MARSH_MIN_UNBUCKLE_TIME 7 SECONDS
#define MARSH_MAX_UNBUCKLE_TIME 14 SECONDS
#define MARSH_DAMAGE_PER_UPGRADE 10

/datum/spell/hand/charges/marsh_of_the_dead
	name = "Marsh of the dead"
	desc = "This spell creates a puddle of vile pus, staggering any mortal."
	school = "necromancy"
	feedback = "MD"
	range = 5
	spell_flags = 0
	invocation_type = SPI_NONE
	show_message = "snaps their fingers."
	spell_delay = 2 SECONDS
	icon_state = "wiz_marsh"
	level_max = list(SP_TOTAL = 3, SP_SPEED = 1, SP_POWER = 2)
	var/damage = 0
	override_base = "const"
	charge_max = 600
	cooldown_min = 300
	max_casts = 1

/datum/spell/hand/charges/marsh_of_the_dead/cast_hand(atom/a, mob/user)
	for(var/turf/simulated/T in view(1,a))
		new /obj/effect/deadhands(T, damage)
	return ..()

/datum/spell/hand/charges/marsh_of_the_dead/empower_spell()
	. = ..()
	if(!.)
		return FALSE

	damage += MARSH_DAMAGE_PER_UPGRADE

	return "[src] now lasts longer."

/obj/effect/deadhands
	name = "Vile pus"
	icon = 'icons/effects/effects.dmi'
	icon_state = "greenglow"
	layer = OBJ_LAYER
	pass_flags = PASS_FLAG_TABLE
	anchored = 1.0
	opacity = 0
	density = 0
	unacidable = 1
	var/damage = 0

/obj/effect/deadhands/Initialize(turf/t, damage_amount)
	. = ..()
	set_next_think(world.time + MARSH_ACTIVE_TIME)
	damage = damage_amount

/obj/effect/deadhands/think()
	qdel_self()
	set_next_think(0)

/obj/effect/deadhands/Crossed(atom/movable/O)
	if(is_valid_target(O))
		grab(O)

/obj/effect/deadhands/proc/is_valid_target(mob/living/victim)
	if(!victim)
		return FALSE

	if(!isliving(victim) || victim.isSynthetic() || isundead(victim) || (victim.faction && victim.faction == "wizard"))
		return FALSE

	return TRUE

/obj/effect/deadhands/proc/grab(mob/living/victim)
	if(victim.anchored) // Already got em
		return

	if(!Adjacent(victim)) // Smth went wrong, our target is not on the tile anymore
		return

	if(ishuman(victim))
		var/mob/living/carbon/human/H = victim
		if(H.species.species_flags & SPECIES_FLAG_NO_TANGLE)
			return

	to_chat(victim, SPAN_DANGER("You're stuck in \the [src]!"))

	victim.forceMove(loc)

	victim.adjustBruteLoss(damage)

	if(buckle_mob(victim))
		victim.set_dir(pick(GLOB.cardinal))
		to_chat(victim, SPAN_DANGER("You're stuck in \the [src]!"))

/obj/effect/deadhands/attack_hand(mob/user)
	if(buckled_mob)
		user_unbuckle_mob(user)
	else
		..()

/obj/effect/deadhands/user_unbuckle_mob(mob/user)
	visible_message(
		SPAN_WARNING("\The [user] attempts to free themselves from \the [src]!"),
		SPAN_WARNING("You attempt to free yourself from \the [src]!</span>")
		)
	if(do_after(user, rand(MARSH_MIN_UNBUCKLE_TIME, MARSH_MAX_UNBUCKLE_TIME), src, incapacitation_flags = INCAPACITATION_DISABLED))
		unbuckle_mob()
		return TRUE

	else
		return FALSE

#undef MARSH_ACTIVE_TIME
#undef MARSH_MIN_UNBUCKLE_TIME
#undef MARSH_MAX_UNBUCKLE_TIME
#undef MARSH_DAMAGE_PER_UPGRADE
