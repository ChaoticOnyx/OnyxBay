

// Heals the vampire at the cost of blood.
/datum/vampire_power/bloodheal
	name = "Blood Heal"
	desc = "At the cost of blood and time, heal any injuries you have sustained."
	icon_state = "vamp_blood_heal"
	blood_cost = 15

#define CHECK_HEAL_BREAK(amount) if(vampire.blood_usable < amount) {to_chat(my_mob, SPAN("warning", "You ran out of blood, and are unable to continue!")); return TRUE}
/datum/vampire_power/bloodheal/activate()
	if(!..())
		return
	vampire.vamp_status |= VAMP_HEALING

	to_chat(my_mob, SPAN("notice", "You begin the process of blood healing. Do not move, and ensure that you are not interrupted."))
	log_and_message_admins("activated blood heal.")

	while(do_after(my_mob, 20, 0, incapacitation_flags = INCAPACITATION_DISABLED))
		if(!(vampire.vamp_status & VAMP_HEALING))
			to_chat(my_mob, SPAN("warning", "Your concentration has been broken! You are no longer regenerating!"))
			break

		CHECK_HEAL_BREAK(15)

		var/tox_loss = my_mob.getToxLoss()
		var/oxy_loss = my_mob.getOxyLoss()
		var/ext_loss = my_mob.getBruteLoss() + my_mob.getFireLoss()
		var/clone_loss = my_mob.getCloneLoss()

		var/blood_used = 0
		var/to_heal = 0

		if(tox_loss)
			to_heal = min(10, tox_loss)
			my_mob.adjustToxLoss(0 - to_heal)
			blood_used += round(to_heal * 1.2)
		if(oxy_loss)
			to_heal = min(10, oxy_loss)
			my_mob.adjustOxyLoss(0 - to_heal)
			blood_used += round(to_heal * 1.2)
		if(ext_loss)
			to_heal = min(20, ext_loss)
			my_mob.heal_overall_damage(min(10, my_mob.getBruteLoss()), min(10, my_mob.getFireLoss()))
			blood_used += round(to_heal * 1.2)
		if(clone_loss)
			to_heal = min(10, clone_loss)
			my_mob.adjustCloneLoss(0 - to_heal)
			blood_used += round(to_heal * 1.2)

		use_blood(blood_used)
		CHECK_HEAL_BREAK(12)

		var/list/organs = my_mob.get_damaged_organs(1, 1)
		if(organs.len)
			// Heal an absurd amount, basically regenerate one organ.
			my_mob.heal_organ_damage(50, 50)
			blood_used += 12
			use_blood(12)

		CHECK_HEAL_BREAK(12)

		for(var/obj/item/organ/external/current_organ in organs)
			for(var/datum/wound/wound in current_organ.wounds)
				LAZYCLEARLIST(wound.embedded_objects)

			// remove embedded objects and drop them on the floor
			for(var/obj/implanted_object in current_organ.implants)
				if(!istype(implanted_object,/obj/item/implant))	// We don't want to remove REAL implants. Just shrapnel etc.
					implanted_object.loc = get_turf(my_mob)
					current_organ.implants -= implanted_object

		var/organ_heal_blood = 0
		for(var/A in organs)
			var/healed = FALSE
			var/obj/item/organ/external/E = A
			if(E.status & ORGAN_ARTERY_CUT)
				E.status &= ~ORGAN_ARTERY_CUT
				organ_heal_blood += 12
			if(E.status & ORGAN_TENDON_CUT)
				E.status &= ~ORGAN_TENDON_CUT
				organ_heal_blood += 12
			if(E.status & ORGAN_BROKEN)
				E.mend_fracture()
				E.stage = 0
				organ_heal_blood += 12
				healed = TRUE

			if(healed)
				vampire.use_blood(organ_heal_blood)
				break

		blood_used += organ_heal_blood
		CHECK_HEAL_BREAK(12)

		for(var/ID in my_mob.virus2)
			var/datum/disease2/disease/V = my_mob.virus2[ID]
			V.cure(my_mob)

		for(var/limb_type in my_mob.species.has_limbs)
			var/obj/item/organ/external/E = my_mob.organs_by_name[limb_type]
			if(E && E.organ_tag != BP_HEAD && !E.vital && !E.is_usable()) // Skips heads and vital bits...
				E.removed() // ...because no one wants their head to explode to make way for a new one.
				qdel(E)
				E = null
			if(!E)
				var/list/organ_data = my_mob.species.has_limbs[limb_type]
				var/limb_path = organ_data["path"]
				var/obj/item/organ/external/O = new limb_path(my_mob)
				organ_data["descriptor"] = O.name

				to_chat(my_mob, SPAN("danger", "With a shower of dark blood, a new [O.name] forms."))
				my_mob.visible_message(SPAN("danger", "With a shower of dark blood, a length of biomass shoots from [my_mob]'s [O.amputation_point], forming a new [O.name]!"))

				blood_used += 12
				vampire.use_blood(12)
				var/datum/reagent/blood/B = new /datum/reagent/blood
				blood_splatter(my_mob, B, 1)
				O.set_dna(my_mob.dna)
				my_mob.update_body()
				break

		var/list/emotes_lookers = list("[my_mob]'s skin appears to liquefy for a moment, sealing up their wounds.",
									"[my_mob]'s veins turn black as their damaged flesh regenerates before your eyes!",
									"[my_mob]'s skin begins to split open. It turns to ash and falls away, revealing the wound to be fully healed.",
									"Whispering arcane things, [my_mob]'s damaged flesh appears to regenerate.",
									"Thick globs of blood cover a wound on [my_mob]'s body, eventually melding to be one with \his flesh.",
									"[my_mob]'s body crackles, skin and bone shifting back into place.")
		var/list/emotes_self = list("Your skin appears to liquefy for a moment, sealing up your wounds.",
									"Your veins turn black as their damaged flesh regenerates before your eyes!",
									"Your skin begins to split open. It turns to ash and falls away, revealing the wound to be fully healed.",
									"Whispering arcane things, your damaged flesh appears to regenerate.",
									"Thick globs of blood cover a wound on your body, eventually melding to be one with your flesh.",
									"Your body crackles, skin and bone shifting back into place.")

		if(prob(20))
			my_mob.visible_message(SPAN("danger", "[pick(emotes_lookers)]"),\
								   SPAN("notice", "[pick(emotes_self)]"))

		if(!blood_used)
			vampire.vamp_status &= ~VAMP_HEALING
			to_chat(my_mob, SPAN("notice", "Your body has finished healing. You are ready to go."))
			return

	// We broke out of the loop naturally. Gotta catch that.
	if(vampire.vamp_status & VAMP_HEALING)
		vampire.vamp_status &= ~VAMP_HEALING
		to_chat(my_mob, SPAN("warning", "Your concentration is broken! You are no longer regenerating!"))
	return
#undef CHECK_HEAL_BREAK
