
// Drains the target's blood.
/datum/vampire_power/drain_blood
	name = "Drain Blood"
	desc = "Drain the blood of a humanoid creature."
	icon_state = "vamp_drain"
	blood_cost = 0

/datum/vampire_power/drain_blood/activate()
	. = ..()
	if(!.)
		return

	var/obj/item/grab/G = my_mob.get_active_hand()
	if (!istype(G))
		to_chat(my_mob, SPAN("warning", "You must be grabbing a victim in your active hand to drain their blood."))
		return

	if(!G.can_absorb())
		to_chat(my_mob, SPAN("warning", "You must have a tighter grip on victim to drain their blood."))
		return

	var/mob/living/carbon/human/T = G.affecting
	if (!istype(T) || T.isSynthetic() || T.species.species_flags & SPECIES_FLAG_NO_BLOOD)
		to_chat(my_mob, SPAN("warning", "[T] is not a creature you can drain useful blood from."))
		return

	if(T.head && (T.head.item_flags & ITEM_FLAG_AIRTIGHT))
		to_chat(my_mob, SPAN("warning", "[T]'s headgear is blocking the way to the neck."))
		return

	var/obj/item/blocked = my_mob.check_mouth_coverage()
	if(blocked)
		to_chat(my_mob, SPAN("warning", "\The [blocked] is in the way of your fangs!"))
		return

	if(vampire.vamp_status & VAMP_DRAINING)
		to_chat(my_mob, SPAN("warning", "Your fangs are already sunk into a victim's neck!"))
		return

	var/datum/vampire/draining_vamp = null
	if(T.mind?.vampire)
		draining_vamp = T.mind.vampire

	var/target_aware = !!T.client

	var/blood = 0
	var/blood_total = 0
	var/blood_usable = 0
	var/blood_drained = 0

	vampire.vamp_status |= VAMP_DRAINING

	my_mob.visible_message(SPAN("danger", "[my_mob] bites [T]'s neck!"),\
						   SPAN("danger", "You bite [T]'s neck and begin to drain their blood."),\
						   SPAN("danger", "You hear a soft puncture and a wet sucking noise"))
	var/remembrance
	if(vampire.stealth)
		remembrance = "forgot"
	else
		remembrance = "remembered"
	admin_attack_log(my_mob, T, "drained blood from [key_name(T)], who [remembrance] the encounter.", "had their blood drained by [key_name(my_mob)] and [remembrance] the encounter.", "is draining blood from")

	to_chat(T, SPAN("warning", FONT_LARGE("You feel yourself falling into a pleasant dream, from which even a smile appeared on your face.")))
	T.paralysis = 3400

	playsound(my_mob.loc, 'sound/effects/drain_blood.ogg', 50, 1)


	while(do_mob(my_mob, T, 50))
		if(!my_mob.mind.vampire)
			to_chat(my_mob, SPAN("danger", "Your fangs have suddenly disappeared!"))
			return
		if(blood_drained >= 250)
			to_chat(my_mob, SPAN("danger", "You can't force any more blood down your throat!"))
			break

		blood_total = vampire.blood_total
		blood_usable = vampire.blood_usable

		if(!T.vessel.get_reagent_amount(/datum/reagent/blood))
			to_chat(my_mob, SPAN("danger", "[T] has no more blood left to give."))
			break

		if(!T.stunned)
			T.Stun(10)

		var/frenzy_lower_chance = 0

		// Alive and not of empty mind.
		if(T.stat < DEAD && T.client)
			blood = min(30, T.vessel.get_reagent_amount(/datum/reagent/blood))
			vampire.blood_total += blood
			vampire.gain_blood(blood)
			blood_drained += blood

			frenzy_lower_chance = 40

			if(draining_vamp)
				vampire.blood_vamp += blood
				// Each point of a vampire's blood will increase your chance to frenzy.
				vampire.frenzy += blood

				// And drain the vampire as well.
				draining_vamp.use_blood(min(blood, draining_vamp.blood_usable))
				vampire.check_frenzy()

				frenzy_lower_chance = 0
		// SSD/protohuman or dead.
		else
			blood = min(5, T.vessel.get_reagent_amount(/datum/reagent/blood))
			vampire.gain_blood(blood)
			blood_drained += blood

			frenzy_lower_chance = 40

		if(prob(frenzy_lower_chance) && vampire.frenzy > 0)
			vampire.frenzy--

		if(blood_total != vampire.blood_total)
			var/update_msg = SPAN("notice", "You have accumulated [vampire.blood_total] [vampire.blood_total > 1 ? "units" : "unit"] of blood")
			if(blood_usable != vampire.blood_usable)
				update_msg += SPAN("notice", " and have [vampire.blood_usable] left to use.")
			else
				update_msg += SPAN_NOTICE(".")
			to_chat(my_mob, update_msg)

		if (blood_drained >= 70 && blood_drained < 85)
			to_chat(my_mob, SPAN("warning", "You have enough amount of drained blood."))


		vampire.update_powers()
		T.vessel.remove_reagent(/datum/reagent/blood, 15)

	vampire.vamp_status &= ~VAMP_DRAINING

	var/endsuckmsg = "You extract your fangs from [T.name]'s neck and stop draining them of blood."
	if(vampire.stealth)
		endsuckmsg += "They will remember nothing of this occurance, provided they survived."
	my_mob.visible_message(SPAN("danger", "[my_mob] stops biting [T.name]'s neck!"),\
						   SPAN("notice", "[endsuckmsg]"))
	T.paralysis = 0
	if(target_aware)
		if(!T.is_ooc_dead() && vampire.stealth)
			spawn()			//Spawned in the same manner the brain damage alert is, just so the proc keeps running without stops.
				alert(T, "You remember NOTHING about the cause of your blackout. Instead, you remember having a pleasant encounter with [my_mob].", "Bitten by a vampire")
		else if(!T.is_ooc_dead())
			spawn()
				alert(T, "You remember everything that happened. Remember how blood was sucked from your neck. It gave you pleasure, like a pleasant dream. You feel great. How you react to [my_mob]'s actions is up to you.", "Bitten by a vampire")

	if(blood_drained <= 85)
		set_cooldown(60 SECONDS)
	else
		set_cooldown(90 SECONDS)
