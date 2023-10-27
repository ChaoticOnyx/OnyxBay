// Vampire and thrall datums. Contains the necessary information about a vampire.
// Must be attached to a /datum/mind.
#define isfakeliving(A) (A.status_flags & FAKELIVING)
#define isundead(A) (A.status_flags & UNDEAD)
/datum/vampire
	var/list/thralls = list()                              // A list of thralls that obey the vamire.
	var/blood_total = 0                                    // How much total blood do we have?
	var/blood_usable = 0                                   // How much usable blood do we have?
	var/blood_vamp = 0                                     // How much vampire blood do we have?
	var/frenzy = 0                                         // A vampire's frenzy meter.
	var/last_frenzy_message = 0                            // Keeps track of when the last frenzy alert was sent.
	var/status = 0                                         // Bitfield including different statuses.
	var/stealth = TRUE                                     // Do you want your victims to know of your sucking?

	var/list/datum/vampire_power/available_powers = list() // List of power datums available for use.
	var/obj/effect/dummy/veil_walk/holder = null           // The veil_walk dummy.
	var/weakref/master = null                              // The vampire/thrall's master.
	var/mob/living/carbon/human/my_mob = null              // Vampire mob

/datum/vampire/thrall
	status = VAMP_ISTHRALL

/datum/vampire/proc/transfer_to(mob/living/new_character)
	if(my_mob && (status & VAMP_FRENZIED))
		stop_frenzy(TRUE)
		for(var/datum/datum/vampire_power/VP in available_powers)
			qdel(VP)
		available_powers.Cut()

	my_mob = new_character

/datum/vampire/proc/add_power(datum/mind/vampire, datum/power/vampire/power, announce = 0)
	if(!vampire || !power)
		return
	if(power in purchased_powers)
		return

	purchased_powers += power

	if(power.is_active && power.verbpath)
		vampire.current.verbs += power.verbpath
	if(announce)
		to_chat(vampire.current, SPAN_NOTICE("<b>You have unlocked a new power:</b> [power.name]."))
		to_chat(vampire.current, SPAN_NOTICE("[power.desc]"))
		if(power.helptext)
			to_chat(vampire.current, "<font color='green'>[power.helptext]</font>")

/datum/vampire/New(mob/_M)
	..()
	my_mob = _M
	set_next_think(world.time + 1 SECOND)

/datum/vampire/Destroy()
	if(my_mob && (status & VAMP_FRENZIED))
		stop_frenzy(TRUE)
	purchased_powers.Cut()
	thralls.Cut()
	my_mob = null
	master = null
	holder = null
	. = ..()

// Frenzy handling.
/datum/vampire/think()
	if(QDELETED(my_mob)) // Some baddy's happened, let's let our body go for good, and keep ourselves existing for credits' sake
		my_mob = null
		return

	if(my_mob.is_ooc_dead()) // We're done here, but let's check for resurrection (or body destroying) from time to time
		// Might be worth using some RESURRECTED signal, but for now it's far out of scope
		if(status & VAMP_FRENZIED)
			frenzy = 0
			stop_frenzy(TRUE, FALSE)
		set_next_think(world.time + 3 SECONDS)
		return

	var/area/A = get_area(my_mob)
	if(A?.holy)
		frenzy += 3
		if(prob(20))
			to_chat(my_mob, "You feel like you're [pick("burning", "on fire", "melting", "scorching"!")

	if(!(status & VAMP_ISTHRALL))
		if(my_mob.reagents.has_reagent(/datum/reagent/water/holywater) || my_mob.get_ingested_reagents().has_reagent(/datum/reagent/water/holywater))
			my_mob.adjust_fire_stacks(0.2)
			my_mob.IgniteMob()
			if(prob(20))
				for(var/mob/V in viewers(my_mob))
					V.show_message(SPAN("warning", "[my_mob]'s skin sizzles and burns."), 1)
			my_mob.reagents.remove_reagent(/datum/reagent/water/holywater, 3)
			my_mob.get_ingested_reagents().remove_reagent(/datum/reagent/water/holywater, 3)

	if(blood_usable < 10)
		frenzy += 2
	else if(frenzy > 0)
		frenzy = max(0, frenzy - Clamp(blood_usable * 0.1, 1, 10))

	frenzy = min(frenzy, 450)

	vampire_check_frenzy()

	set_next_think(world.time + 1 SECOND)


// Proc to safely remove blood, without resulting in negative amounts of blood.
/datum/vampire/proc/use_blood(blood_to_use)
	if(blood_to_use <= 0)
		return FALSE
	blood_usable -= min(blood_to_use, blood_usable)
	return TRUE

/datum/vampire/proc/gain_blood(blood_to_get)
	blood_usable += blood_to_get
	return


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


// Checks whether or not the target can be affected by a vampire's abilities.
#define NOTIFIED_WARNING(msg) if(notify) {to_chat(src, SPAWN("warning", msg))}
/datum/vampire/proc/can_affect(mob/living/carbon/human/target, notify = TRUE, check_loyalty_implant = FALSE, check_thrall = TRUE)
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

/*
 * Frenzy info:
 * 100 points ~= 3.5 minutes.
 * Average duration should be around 4 minutes of frenzy.
 * Trigger at 120 points or higher.
 */
/datum/vampire/proc/check_frenzy(force_frenzy = FALSE)
	// Thralls don't frenzy.
	if(status & VAMP_ISTHRALL)
		return

	if(status & VAMP_FRENZIED)
		if(frenzy < 10)
			vampire_stop_frenzy()
		return

	var/next_alert = 0
	var/message = ""

	switch(frenzy)
		if(0 to 20)
			return
		if(21 to 40)
			next_alert = 60 SECONDS
			message = SPAN("warning", "You feel the power of the Veil bubbling in your veins.")
		if(41 to 60)
			next_alert = 50 SECONDS
			message = SPAN("warning", "The corruption within your blood is seeking to take over, you can feel it.")
		if(61 to 80)
			next_alert = 40 SECONDS
			message = SPAN("danger", "Your rage is growing ever greater. You are having to actively resist it.")
		if(81 to 120)
			next_alert = 30 SECONDS
			message = SPAN("danger", "The corruption of the Veil is about to take over. You have little time left.")
		else
			vampire_start_frenzy(force_frenzy)

	if(message && next_alert && last_frenzy_message + next_alert < world.time)
		to_chat(my_mob, message)
		last_frenzy_message = world.time

/datum/vampire/proc/start_frenzy(force_frenzy = FALSE)
	if(status & VAMP_FRENZIED)
		return

	if(prob(force_frenzy ? 100 : frenzy * 0.5))
		status |= VAMP_FRENZIED
		my_mob.visible_message(SPAN("danger", "A dark aura manifests itself around [my_mob], their eyes turning red and their composure changing to be more beast-like."),\
							   SPAN("danger", "You can resist no longer. The power of the Veil takes control over your mind: you are unable to speak or think. In people, you see nothing but prey to be feasted upon. You are reduced to an animal."))

		my_mob.mutations.Add(MUTATION_HULK)
		my_mob.update_mutations()

		my_mob.set_sight(sight|SEE_MOBS)

		my_mob.verbs += /datum/vampire/proc/grapple

/datum/vampire/proc/stop_frenzy(force_stop = FALSE, show_msg = TRUE)
	if(!(status & VAMP_FRENZIED))
		return

	if(prob(force_stop ? 100 : blood_usable))
		status &= ~VAMP_FRENZIED

		my_mob.mutations.Remove(MUTATION_HULK)
		my_mob.update_mutations()

		my_mob.set_sight(sight&(~SEE_MOBS))

		if(show_msg)
			my_mob.visible_message(SPAN("danger", "[my_mob]'s eyes no longer glow with violent rage, their form reverting to resemble that of a normal person's."),\
								   SPAN("danger", "The beast within you retreats. You gain control over your body once more."))

		my_mob.verbs -= /datum/vampire/proc/grapple
		my_mob.regenerate_icons()
