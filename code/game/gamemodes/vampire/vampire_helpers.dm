// Make a vampire, add initial powers.
/mob/proc/make_vampire()
	if(!isuman(src))
		log_debug("Trying to make a nonhuman mob [name] / [real_name] ([key]) a vampire! Aborting.")
		return
	if(!mind)
		return

	var/mob/living/carbon/human/H = src
	if(!mind.vampire)
		mind.vampire = new /datum/vampire(H)
	// No powers to thralls. Ew.
	else if(mind.vampire.status & VAMP_ISTHRALL)
		return

	mind.vampire.set_up_organs()
	mind.vampire.blood_usable = 30

	H.does_not_breathe = 1
	H.remove_blood(H.species.blood_volume)
	H.status_flags |= UNDEAD
	H.oxygen_alert = 0
	H.add_modifier(/datum/modifier/trait/low_metabolism)
	H.innate_heal = 0

	for(var/datum/modifier/mod in H.modifiers)
		if(!isnull(mod.metabolism_percent))
			mod.metabolism_percent = 0 // Vampire is not affected by chemicals

	if(!vampirepowers.len)
		for(var/P in vampirepower_types)
			vampirepowers += new P()

	verbs += /datum/game_mode/vampire/verb/vampire_help

	for(var/datum/power/vampire/P in vampirepowers)
		if(!(P in mind.vampire.purchased_powers))
			if(!P.blood_cost)
				mind.vampire.add_power(mind, P, 0)
		else if(P.is_active && P.verbpath)
			verbs += P.verbpath
	return TRUE

// Make a vampire thrall
/mob/proc/make_vampire_thrall()
	if(!isuman(src))
		log_debug("Trying to make a nonhuman mob [name] / [real_name] ([key]) a vampire thrall! Aborting.")
		return
	if(!mind)
		return

	var/datum/vampire/thrall/thrall = new()
	mind.vampire = thrall

/datum/vampire/proc/set_up_organs()
	var/mob/living/carbon/human/H = src
	if(H.mind.vampire?.status & VAMP_ISTHRALL)
		return
	var/obj/item/organ/internal/heart/O = H.internal_organs_by_name[BP_HEART]
	if(O)
		O.rejuvenate(ignore_prosthetic_prefs = TRUE)
		O.max_damage = 150
		O.min_bruised_damage = 30
		O.min_broken_damage = 70
		O.vital = TRUE
	return

// Proc to safely remove blood, without resulting in negative amounts of blood.
/datum/vampire/proc/use_blood(blood_to_use)
	if(blood_to_use <= 0)
		return FALSE
	blood_usable -= min(blood_to_use, blood_usable)
	return TRUE

/datum/vampire/proc/gain_blood(blood_to_get)
	blood_usable += blood_to_get
	return


// Checks the vampire's bloodlevel and unlocks new powers based on that.
/mob/proc/check_vampire_upgrade()
	if (!mind.vampire)
		return

	var/datum/vampire/vampire = mind.vampire

	for (var/datum/power/vampire/P in vampirepowers)
		if (P.blood_cost <= vampire.blood_total)
			if (!(P in vampire.purchased_powers))
				vampire.add_power(mind, P, 1)

	if (!(vampire.status & VAMP_FULLPOWER) && vampire.blood_total >= 650)
		vampire.status |= VAMP_FULLPOWER
		to_chat(src, SPAN_NOTICE("You've gained full power. Some abilities now have bonus functionality, or work faster."))

// Runs the checks for whether or not we can use a power.
/mob/proc/vampire_power(required_blood = 0, max_stat = 0, ignore_holder = 0, disrupt_healing = 1,required_vampire_blood = 0)
	if (!mind)
		return
	if (!ishuman(src))
		return
	var/datum/vampire/vampire = mind.vampire
	if (!vampire)
		log_debug("[src] has a vampire power but is not a vampire.")
		return
	if (vampire.holder && !ignore_holder)
		to_chat(src, SPAN_WARNING("You cannot use this power while walking through the Veil."))
		return
	if (stat > max_stat)
		to_chat(src, SPAN_WARNING("You are incapacitated."))
		return
	if (required_blood > vampire.blood_usable)
		to_chat(src, SPAN_WARNING("You do not have enough usable blood. [required_blood] needed."))
		return

	if ((vampire.status & VAMP_HEALING) && disrupt_healing)
		vampire.status &= ~VAMP_HEALING

	return vampire


// Checks whether or not the target can be affected by a vampire's abilities.
#define NOTIFIED_WARNING(msg) if(notify) {to_chat(src, SPAWN("warning", msg))}
/datum/vampire/proc/can_affect_target(mob/living/carbon/human/target, notify = TRUE, check_loyalty_implant = FALSE, check_thrall = TRUE)
	if(!istype(target))
		return FALSE
	if(!target.mind)
		// The target's dumbey-dumbey, not even worth the effort
		NOTIFIED_WARNING("[T] doesn't seem to even have a mind.")
		return FALSE

	if((status & VAMP_FULLPOWER) && !(target.mind.vampire && (T.mind.vampire.status & VAMP_FULLPOWER)))
		// We are a fullpowered vampire and our target isn't
		return TRUE

	if(T.mind.assigned_role == "Chaplain")
		NOTIFIED_WARNING("Your connection with the Veil is not strong enough to affect a being as devout as them.")
		return FALSE

	if(T.mind.vampire)
		if(!(T.mind.vampire.status & VAMP_ISTHRALL))
			// The target is a vampire
			NOTIFIED_WARNING("You lack the power required to affect another creature of the Veil.")
			return FALSE
		else if(check_thrall)
			// The target is a thrall
			NOTIFIED_WARNING("You lack the power required to affect a lesser creature of the Veil.")
			return FALSE
	else if(is_special_character(T))
		// The target is some non-vampire antag
		NOTIFIED_WARNING("[T]'s mind is too strong to be affected by our powers!")
		return FALSE

	if(T.isSynthetic())
		// The target is a cyberass
		NOTIFIED_WARNING("You lack the power to affect mechanical constructs.")
		return FALSE

	if(check_loyalty_implant)
		for(var/obj/item/implant/loyalty/I in T)
			if(I.implanted)
				// Found an active loyalty implant
				NOTIFIED_WARNING("You feel that [T]'s mind is protected from our powers.")
				return FALSE

	return TRUE
#undef NOTIFIED_WARNING

// Plays the vampire phase in animation.
/mob/proc/vampire_phase_in(turf/T)
	if (!T)
		return
	anim(T,src,'icons/mob/mob.dmi',null,"bloodify_in", null,dir)

// Plays the vampire phase out animation.
/mob/proc/vampire_phase_out(turf/T)
	if (!T)
		return
	anim(T,src,'icons/mob/mob.dmi',null,"bloodify_out", null,dir)


// Removes all vampire powers.
/mob/proc/remove_vampire_powers()
	if (!mind || !mind.vampire)
		return

	for (var/datum/power/vampire/P in mind.vampire.purchased_powers)
		if (P.is_active)
			verbs -= P.verbpath

	if (mind.vampire.status & VAMP_FRENZIED)
		vampire_stop_frenzy(1)

/mob/living/carbon/human/proc/finish_vamp_timeout(vamp_flags = 0)
	if (!src)
		return
	if (!mind || !mind.vampire)
		return FALSE
	if (vamp_flags && !(mind.vampire.status & vamp_flags))
		return FALSE
	return TRUE
