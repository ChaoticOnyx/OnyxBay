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
	var/vamp_status = 0                                    // Bitfield including different statuses.
	var/stealth = TRUE                                     // Do you want your victims to know of your sucking?
	var/list/eyescolor = list()
	var/list/skincolor = list()

	var/list/purchased_powers = list()                      // List of power datums we currently use.
	var/list/datum/vampire_power/available_powers = list() // List of vampire_power datums available for use.
	var/obj/effect/dummy/veil_walk/holder = null           // The veil_walk dummy.
	var/weakref/master = null                              // The vampire/thrall's master.
	var/mob/living/carbon/human/my_mob = null              // Vampire mob

/datum/vampire/thrall
	vamp_status = VAMP_ISTHRALL

/datum/vampire/proc/transfer_to(mob/living/new_character)
	if(my_mob)
		my_mob.unmake_vampire(TRUE)

	if(!ishuman(new_character))
		set_next_think(0) // Let's just sit straight and wait for a proper body
		return

	my_mob = new_character
	my_mob.make_vampire()
	set_next_think(world.time + 1 SECOND)

/datum/vampire/New(mob/_M)
	..()
	if(!istype(_M))
		util_crash_with("Vampire datum was initialised without `var/my_mob`. Shit is fucked.")
		qdel_self()
		return

	my_mob = _M
	set_next_think(world.time + 1 SECOND)

/datum/vampire/Destroy()
	if(my_mob)
		stop_frenzy(TRUE)
	remove_powers()
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
		if(vamp_status & VAMP_FRENZIED)
			frenzy = 0
			stop_frenzy(TRUE, FALSE)
		set_next_think(world.time + 3 SECONDS)
		return

	var/area/A = get_area(my_mob)
	if(A?.holy)
		frenzy += 3
		if(prob(20))
			to_chat(my_mob, "You feel like you're [pick("burning", "on fire", "melting", "scorching")]!")

	if(!(vamp_status & VAMP_ISTHRALL))
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

	check_frenzy()

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

/datum/vampire/proc/set_up_colors()
	eyescolor += my_mob.r_eyes
	eyescolor += my_mob.g_eyes
	eyescolor += my_mob.b_eyes

	skincolor += my_mob.s_tone
	my_mob.change_eye_color(255, 0, 0)
	my_mob.change_skin_tone(35)

/datum/vampire/proc/restore_colors()
	my_mob.change_eye_color(eyescolor[1], eyescolor[2], eyescolor[3])
	my_mob.change_skin_tone(skincolor[1])
	eyescolor = list()
	skincolor = list()

/datum/vampire/proc/set_up_organs()
	if(vamp_status & VAMP_ISTHRALL)
		return

	if(!istype(my_mob))
		util_crash_with("Vampire datum was initialised without `var/my_mob`. Shit is fucked.")
		return

	blood_usable = 200

	my_mob.does_not_breathe = 1
	my_mob.remove_blood(my_mob.species.blood_volume)
	my_mob.status_flags |= UNDEAD
	my_mob.oxygen_alert = 0
	my_mob.add_modifier(/datum/modifier/trait/low_metabolism)
	my_mob.innate_heal = 0
	set_up_colors()

	for(var/obj/item/organ/external/E in my_mob.organs)
		E.limb_flags &= ~ORGAN_FLAG_CAN_BREAK

	for(var/datum/modifier/mod in my_mob.modifiers)
		if(!isnull(mod.metabolism_percent))
			mod.metabolism_percent = 0 // Vampire is not affected by chemicals

	var/obj/item/organ/internal/heart/O = my_mob.internal_organs_by_name[BP_HEART]
	if(O)
		O.rejuvenate(ignore_prosthetic_prefs = TRUE)
		O.max_damage = 150
		O.min_bruised_damage = 30
		O.min_broken_damage = 70
		O.vital = TRUE
	return

/datum/vampire/proc/unset_organs()
	my_mob.does_not_breathe = 0
	my_mob.restore_blood()
	my_mob.status_flags &= ~UNDEAD
	my_mob.remove_modifiers_of_type(/datum/modifier/trait/low_metabolism, TRUE)
	my_mob.innate_heal = 1
	restore_colors()

	for(var/obj/item/organ/external/E in my_mob.organs)
		E.limb_flags |= ORGAN_FLAG_CAN_BREAK

	var/obj/item/organ/internal/heart/O = my_mob.internal_organs_by_name[BP_HEART]
	if(O)
		O.max_damage = initial(O.max_damage)
		O.damage = min(O.damage, O.max_damage)
		O.min_bruised_damage = initial(O.min_bruised_damage)
		O.min_broken_damage = initial(O.min_bruised_damage)
		O.vital = initial(O.vital)
		O.pulse = PULSE_NORM
		O.think()

// Adds a power
/datum/vampire/proc/add_power(datum/power/vampire/P, announce = FALSE)
	if(P in purchased_powers)
		return

	purchased_powers.Add(P)

	if(P.legacy_handling)
		my_mob.verbs += P.verbpath
	else
		new P.verbpath(my_mob)

	if(announce)
		to_chat(my_mob, SPAN("notice", "<b>You have unlocked a new power:</b> [P.name]!\n[P.desc]"))
		if(P.helptext)
			to_chat(my_mob, "<font color='green'>[P.helptext]</font>")

/datum/vampire/proc/remove_power(datum/power/vampire/P)
	if(!(P in purchased_powers))
		return

	if(P.legacy_handling)
		my_mob.verbs -= P.verbpath
	else
		for(var/datum/vampire_power/VP in available_powers)
			if(VP.type == P.verbpath)
				qdel(VP)
				break
	purchased_powers.Remove(P)
	return

// Removes everything
/datum/vampire/proc/remove_powers()
	for(var/datum/power/vampire/P in purchased_powers)
		if(P.legacy_handling)
			my_mob.verbs -= P.verbpath
			continue
	purchased_powers.Cut()
	for(var/thing in available_powers)
		qdel(thing)
	available_powers.Cut()
	return

// Checks the vampire's bloodlevel and unlocks powers based on it.
/datum/vampire/proc/update_powers(announce = TRUE)
	for(var/datum/power/vampire/P in vampirepowers)
		if(P.blood_cost <= blood_total)
			if(P in purchased_powers)
				continue
			add_power(P, announce)

	if(!(vamp_status & VAMP_FULLPOWER) && blood_total >= 650)
		vamp_status |= VAMP_FULLPOWER
		to_chat(my_mob, SPAN("notice", "You've gained full power. Some abilities now have bonus functionality, or work faster."))

	my_mob.ability_master.reskin_vampire()
	my_mob.ability_master.update_abilities()


// Checks whether or not the target can be affected by a vampire's abilities.
#define NOTIFIED_WARNING(msg) if(notify) {to_chat(my_mob, SPAN("warning", msg))}
/datum/vampire/proc/can_affect(mob/living/carbon/human/target, notify = TRUE, check_loyalty_implant = FALSE, check_thrall = TRUE)
	if(!istype(target))
		return FALSE
	if(!target.mind)
		// The target's dumbey-dumbey, not even worth the effort
		NOTIFIED_WARNING("[target] doesn't seem to even have a mind.")
		return FALSE

	if((vamp_status & VAMP_FULLPOWER) && !(target.mind.vampire && (target.mind.vampire.vamp_status & VAMP_FULLPOWER)))
		// We are a fullpowered vampire and our target isn't
		return TRUE

	if(target.mind.assigned_role == "Chaplain")
		NOTIFIED_WARNING("Your connection with the Veil is not strong enough to affect a being as devout as them.")
		return FALSE

	if(target.mind.vampire)
		if(!(target.mind.vampire.vamp_status & VAMP_ISTHRALL))
			// The target is a vampire
			NOTIFIED_WARNING("You lack the power required to affect another creature of the Veil.")
			return FALSE
		else if(check_thrall)
			// The target is a thrall
			NOTIFIED_WARNING("You lack the power required to affect a lesser creature of the Veil.")
			return FALSE
	else if(is_special_character(target))
		// The target is some non-vampire antag
		NOTIFIED_WARNING("[target]'s mind is too strong to be affected by our powers!")
		return FALSE

	if(target.isSynthetic())
		// The target is a cyberass
		NOTIFIED_WARNING("You lack the power to affect mechanical constructs.")
		return FALSE

	if(check_loyalty_implant)
		for(var/obj/item/implant/loyalty/I in target)
			if(I.implanted)
				// Found an active loyalty implant
				NOTIFIED_WARNING("You feel that [target]'s mind is protected from our powers.")
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
	if(vamp_status & VAMP_ISTHRALL)
		return

	if(vamp_status & VAMP_FRENZIED)
		if(frenzy < 10)
			stop_frenzy()
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
			start_frenzy(force_frenzy)

	if(message && next_alert && last_frenzy_message + next_alert < world.time)
		to_chat(my_mob, message)
		last_frenzy_message = world.time

/datum/vampire/proc/start_frenzy(force_frenzy = FALSE)
	if(vamp_status & VAMP_FRENZIED)
		return

	if(prob(force_frenzy ? 100 : frenzy * 0.5))
		vamp_status |= VAMP_FRENZIED
		my_mob.visible_message(SPAN("danger", "A dark aura manifests itself around [my_mob], their eyes turning red and their composure changing to be more beast-like."),\
							   SPAN("danger", "You can resist no longer. The power of the Veil takes control over your mind: you are unable to speak or think. In people, you see nothing but prey to be feasted upon. You are reduced to an animal."))

		my_mob.set_sight(my_mob.sight|SEE_MOBS)

		for(var/datum/power/vampire/P in vampirepowers)
			if(P.name == "Grapple")
				add_power(P)
				break

/datum/vampire/proc/stop_frenzy(force_stop = FALSE, show_msg = TRUE)
	if(!(vamp_status & VAMP_FRENZIED))
		return

	if(prob(force_stop ? 100 : blood_usable))
		vamp_status &= ~VAMP_FRENZIED


		my_mob.set_sight(my_mob.sight&(~SEE_MOBS))

		if(show_msg)
			my_mob.visible_message(SPAN("danger", "[my_mob]'s eyes no longer glow with violent rage, their form reverting to resemble that of a normal person's."),\
								   SPAN("danger", "The beast within you retreats. You gain control over your body once more."))

		for(var/datum/power/vampire/P in vampirepowers)
			if(P.name == "Grapple")
				remove_power(P)
				break
		my_mob.regenerate_icons()
