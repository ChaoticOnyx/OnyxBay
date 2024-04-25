#define MIN_UNBUCKLE_TIME (4 SECONDS)
#define MAX_UNBUCKLE_TIME (10 SECONDS)

/datum/deity_power/structure/thalamus/trap
	name = "Trap"
	desc = "An upgraded tendril with a large boney spike at the end"
	power_path = /obj/structure/deity/thalamus/trap
	resource_cost = list(
		/datum/deity_resource/thalamus/nutrients = 10
	)

/obj/structure/deity/thalamus/trap
	name = "trap"
	desc = "a pit filled with teeth, capable of biting at those who step on it."
	icon_state = "trap"
	var/damage = 14
	density = FALSE

/obj/structure/deity/thalamus/trap/Crossed(atom/movable/O)
	if(is_valid_target(O))
		bite(O)

/obj/structure/deity/thalamus/trap/proc/is_valid_target(mob/living/victim)
	if(!istype(victim))
		return FALSE

	if(ishuman(victim))
		var/mob/living/carbon/human/H = victim
		if(H.species.species_flags & SPECIES_FLAG_NO_TANGLE)
			return

	return TRUE

/obj/structure/deity/thalamus/trap/proc/bite(mob/living/victim)
	if(victim.anchored)
		return

	if(!Adjacent(victim))
		return

	show_splash_text(victim, "You're stuck!", SPAN_DANGER("You're stuck in \the [src]!"))

	victim.forceMove(loc)

	victim.adjustBruteLoss(damage)

	if(buckle_mob(victim))
		victim.set_dir(pick(GLOB.cardinal))
		show_splash_text(victim, "You're stuck!", SPAN_DANGER("You're stuck in \the [src]!"))

	playsound(get_turf(src), GET_SFX(SFX_THALAMUS_BITE), 100, -1)

/obj/structure/deity/thalamus/trap/attack_hand(mob/user)
	if(buckled_mob)
		user_unbuckle_mob(user)
	else
		..()

/obj/structure/deity/thalamus/trap/user_unbuckle_mob(mob/user)
	visible_message(
		SPAN_WARNING("\The [user] attempts to free themselves from \the [src]!"),
		SPAN_WARNING("You attempt to free yourself from \the [src]!</span>")
		)
	if(!do_after(user, rand(MIN_UNBUCKLE_TIME, MAX_UNBUCKLE_TIME), src, incapacitation_flags = INCAPACITATION_DISABLED))
		return FALSE

	unbuckle_mob()
	return TRUE

#undef MIN_UNBUCKLE_TIME
#undef MAX_UNBUCKLE_TIME
