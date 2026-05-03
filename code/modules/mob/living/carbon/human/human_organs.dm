/mob/living/carbon/human/proc/update_eyes()
	var/obj/item/organ/internal/eyes/eyes = internal_organs_by_name[species.vision_organ ? species.vision_organ : BP_EYES]
	if(eyes)
		eyes.update_colour()
		regenerate_icons()

/mob/living/carbon/human/proc/get_bodypart_name(zone)
	var/obj/item/organ/external/E = get_organ(zone)
	if(E) . = E.name

/mob/living/carbon/human/proc/restore_limb(limb_type, show_message = FALSE)	//only for changling for now
	var/obj/item/organ/external/E = external_organs_by_name[limb_type]
	if(E && E.organ_tag != (BP_HEAD || BP_GROIN) && !E.vital && !E.is_usable(ignore_pain = TRUE))	//Skips heads and vital bits...
		E.removed()//...because no one wants their head to explode to make way for a new one.
		qdel(E)
		E= null
	if(!E)
		var/path = species.has_limbs[limb_type]["path"]
		var/regenerating_limb = text2path("[path]")
		var/parent_organ = initial(regenerating_limb["parent_organ"])
		if(!(parent_organ in external_organs_by_name) || external_organs_by_name[parent_organ].is_stump())
			return 0

		var/list/organ_data = species.has_limbs[limb_type]
		var/limb_path = organ_data["path"]
		var/obj/item/organ/external/O = new limb_path(src)
		organ_data["descriptor"] = O.name
		var/datum/reagent/blood/B = locate(/datum/reagent/blood) in vessel.reagent_list
		blood_splatter(src,B,1)
		O.set_dna(dna)
		update_body()
		if (show_message)
			to_chat(src, "<span class='danger'>With a shower of fresh blood, a new [O.name] forms.</span>")
			visible_message("<span class='danger'>With a shower of fresh blood, a length of biomass shoots from [src]'s [O.amputation_point], forming a new [O.name]!</span>")
		return 1
	else if(E.damage > 0 || E.status & (ORGAN_BROKEN) || E.status & (ORGAN_ARTERY_CUT))
		E.mend_fracture()
		E.status &= ~ORGAN_ARTERY_CUT
		return 1
	else
		return 0


/mob/living/carbon/human/proc/restore_organ(organ_type)	//only for changling for now
	var/obj/item/organ/internal/E = internal_organs_by_name[organ_type]
	if(E && !E.vital && !E.is_usable() && E.organ_tag != BP_BRAIN) //Skips brains and vital bits...
		E.removed()
		qdel(E)
		E = null
	if(!E)
		var/organ_path = species.has_organ[organ_type]
		var/obj/item/organ/internal/O = new organ_path(src)
		internal_organs_by_name[organ_type] = O
		O.set_dna(dna)
		update_body()
		if(O.organ_tag == BP_BRAIN)
			O.vital = 0
		return TRUE
	else if (E.damage > 0 || E.status & (ORGAN_BROKEN) || E.status & (ORGAN_ARTERY_CUT))
		E.status &= ~ORGAN_BROKEN
		E.status &= ~ORGAN_ARTERY_CUT
		return TRUE
	else
		return FALSE

/mob/living/carbon/human/proc/handle_organs_pain() // It's more efficient to process it separately from the actual organ processing
	full_pain = 0

	var/hurt_organs = 0
	var/highest_pain = 0
	for(var/obj/item/organ/external/O in external_organs)
		O.update_pain()
		if(O.full_pain)
			full_pain += O.full_pain
			hurt_organs++
			highest_pain = max(highest_pain, O.full_pain)

	if(hurt_organs)
		// The more ouchies we have, the less each individual one affects us, i.e. we don't even notice a bruise on the shoulder if there's a gaping hole in our chest.
		full_pain = max(highest_pain, full_pain / sqrt(hurt_organs))

	if(full_pain != full_pain_lasttick)
		update_pain_slowdown()

	full_pain_lasttick = full_pain

/mob/living/carbon/human/proc/recheck_bad_external_organs()
	var/damage_this_tick = getInternalLoss()
	for(var/obj/item/organ/external/O in external_organs)
		damage_this_tick += O.burn_dam + O.brute_dam

	if(damage_this_tick > last_dam)
		. = TRUE
	last_dam = damage_this_tick

// Takes care of organ related updates, such as broken and missing limbs
/mob/living/carbon/human/proc/handle_organs()
	heal_this_tick = 0

	var/force_process = recheck_bad_external_organs()

	if(force_process)
		bad_external_organs.Cut()
		for(var/obj/item/organ/external/Ex in external_organs)
			bad_external_organs |= Ex

	//processing internal organs is pretty cheap, do that first.
	for(var/obj/item/organ/I in internal_organs)
		I.think()

	handle_stance()
	handle_grasp()

	if(!force_process && !LAZYLEN(bad_external_organs))
		return

	var/should_update_damage_icon = FALSE

	for(var/obj/item/organ/external/E in bad_external_organs)
		if(!E)
			continue
		if(!E.need_process())
			bad_external_organs -= E
			should_update_damage_icon = TRUE
			continue
		else
			E.think()
			if(E.should_update_damage_icons_this_tick)
				should_update_damage_icon = TRUE

			if(!lying && !buckled && world.time - l_move_time < 15)
			//Moving around with fractured ribs won't do you any good
				if(prob(10) && !stat && can_feel_pain() && chem_effects[CE_PAINKILLER] < 50 && E.is_broken() && E.internal_organs.len)
					custom_pain("Pain jolts through your broken [E.encased ? E.encased : E.name], staggering you!", 50, affecting = E)
					if(prob(50))
						drop_active_hand()
					else
						drop_inactive_hand()
					Stun(2)

	if(should_update_damage_icon)
		update_damage_overlays()

/mob/living/carbon/human/proc/handle_stance()
	// Don't need to process any of this if they aren't standing anyways
	// unless their stance is damaged, and we want to check if they should stay down
	if(!stance_damage && (lying || resting) && (life_tick % 4) != 0)
		return

	stance_damage = 0
	stance_d_l = 0
	stance_d_r = 0

	// Buckled to a bed/chair. Stance damage is forced to 0 since they're sitting on something solid
	if(istype(buckled, /obj/structure/bed))
		return

	// Can't fall if nothing pulls you down
	if(!has_gravity())
		return

	var/limb_pain
	for(var/limb_tag in list(BP_L_LEG, BP_L_FOOT))	// Left leg processing
		var/obj/item/organ/external/E = external_organs_by_name[limb_tag]

		if(!E || (E.status & ORGAN_DISFIGURED) || (E.status & ORGAN_CUT_AWAY) || istype(E,/obj/item/organ/external/stump))
			stance_d_l += 5

		else if(E.is_malfunctioning())
			stance_d_l += 4
			if(prob(10))
				visible_message("\The [src]'s [E.name] [pick("twitches", "shudders", "trembles", "suddenly bends")] and sparks!")
				var/datum/effect/effect/system/spark_spread/spark_system = new ()
				spark_system.set_up(5, 0, src)
				spark_system.attach(src)
				spark_system.start()
				spawn(10)
					qdel(spark_system)

		else if(E.is_broken() || (E.get_pain() >= E.pain_disability_threshold))
			stance_d_l += 2

		else if(E.is_dislocated())
			stance_d_l += 1

		if(E)
			limb_pain = E.can_feel_pain()

		if(l_hand && istype(l_hand, /obj/item/cane))
			stance_d_l -= 1.5

	for(var/limb_tag in list(BP_R_LEG, BP_R_FOOT))	// Right leg processing
		var/obj/item/organ/external/E = external_organs_by_name[limb_tag]

		if(!E || (E.status & ORGAN_DISFIGURED) || (E.status & ORGAN_CUT_AWAY) || istype(E,/obj/item/organ/external/stump))
			stance_d_r += 5

		else if(E.is_malfunctioning())
			stance_d_r += 4
			if(prob(10))
				visible_message("\The [src]'s [E.name] [pick("twitches", "shudders", "trembles", "suddenly bends")] and sparks!")
				var/datum/effect/effect/system/spark_spread/spark_system = new ()
				spark_system.set_up(5, 0, src)
				spark_system.attach(src)
				spark_system.start()
				spawn(10)
					qdel(spark_system)

		else if(E.is_broken() || (E.get_pain() >= E.pain_disability_threshold))
			stance_d_r += 2

		else if(E.is_dislocated())
			stance_d_r += 1

		if(E)
			limb_pain = E.can_feel_pain()

		if(r_hand && istype(r_hand, /obj/item/cane))
			stance_d_r -= 1.5

	stance_damage = stance_d_r + stance_d_l
	if(!stance_damage)
		return	// We're all good
	// standing is poor
	if(!(lying || resting))
		// Both legs are missing, but hey at least there's nothing to ache
		if(((stance_d_l >= 5) && (stance_d_r >= 5)))
			custom_emote(VISIBLE_MESSAGE, "can't stand without legs!", "AUTO_EMOTE")
			Weaken(10)
			set_resting(TRUE)

		// One leg is missing and the other one is at least broken
		else if(((stance_d_l >= 5) && (stance_d_r > 2)) || ((stance_d_l > 2) && (stance_d_r >= 5)))
			if(limb_pain)
				emote("scream")
				shock_stage+=5
			custom_emote(VISIBLE_MESSAGE, "collapses!", "AUTO_EMOTE")
			Weaken(10)
			set_resting(TRUE) // Let's help the poor creature to stay down, preventing further pain.

		// One leg is totally wrecked and the other one is hurt
		else if(((stance_d_l >= 4) && (stance_d_l > 0)) || ((stance_d_l > 0) && (stance_d_r >= 4)))
			if(prob(35))
				if(limb_pain)
					emote("scream")
					shock_stage+=50
				if(prob(50))
					custom_emote(VISIBLE_MESSAGE, "limps badly!", "AUTO_EMOTE")
				else
					custom_emote(VISIBLE_MESSAGE, "collapses!", "AUTO_EMOTE")
					Weaken(10)

		// Both legs are broken
		else if((stance_d_l >= 2) && (stance_d_r >= 2))
			if(prob(25))
				if(limb_pain)
					emote("scream")
					shock_stage+=25
				custom_emote(VISIBLE_MESSAGE, "collapses!", "AUTO_EMOTE")
				Weaken(10)

		// One leg is broken and the other one is hurt
		else if(((stance_d_l >= 2) && (stance_d_r > 0)) || ((stance_d_l > 0) && (stance_d_r >= 2)))
			if(prob(10))
				if(limb_pain)
					emote("scream")
					shock_stage+=15
				if(prob(75))
					custom_emote(VISIBLE_MESSAGE, "limps badly!", "AUTO_EMOTE")
				else
					custom_emote(VISIBLE_MESSAGE, "collapses!", "AUTO_EMOTE")
					Weaken(7)

		// Borth legs are hurt
		else if((stance_d_l > 0) && (stance_d_r > 0))
			if(prob(8))
				if(limb_pain)
					emote("scream")
					shock_stage+=12.5
				if(prob(75))
					custom_emote(VISIBLE_MESSAGE, "limps badly!", "AUTO_EMOTE")
				else
					custom_emote(VISIBLE_MESSAGE, "collapses!", "AUTO_EMOTE")
					Weaken(5)

		// One leg is missing and the other one is ok
		else if((stance_d_l >= 5) || (stance_d_r >= 5))
			if(prob(10))
				if(prob(75))
					custom_emote(VISIBLE_MESSAGE, "limps on one leg!", "AUTO_EMOTE")
				else
					custom_emote(VISIBLE_MESSAGE, "collapses!", "AUTO_EMOTE")
					Weaken(3)

		// One leg is wrecked and the other one is ok
		else if((stance_d_l >= 4) || (stance_d_r >= 4))
			if(prob(8))
				if(limb_pain)
					emote("scream")
					shock_stage+=12.5
				if(prob(75))
					custom_emote(VISIBLE_MESSAGE, "limps on one leg!", "AUTO_EMOTE")
				else
					custom_emote(VISIBLE_MESSAGE, "collapses!", "AUTO_EMOTE")
					Weaken(5)

		// One leg is broken + dislocated and the other one is ok
		else if((stance_d_l >= 3) || (stance_d_r >= 3))
			if(prob(4))
				if(limb_pain)
					emote("scream")
					shock_stage+=10
				custom_emote(VISIBLE_MESSAGE, "limps on one leg!", "AUTO_EMOTE")

		// One leg is broken and the other one is ok
		else if((stance_d_l >= 2) || (stance_d_r >= 2))
			if(prob(2))
				if(limb_pain)
					emote("scream")
					shock_stage+=5
				custom_emote(VISIBLE_MESSAGE, "limps on one leg!", "AUTO_EMOTE")
		else
			return

/mob/living/carbon/human/proc/handle_grasp()
	if(!l_hand && !r_hand)
		return

	// You should not be able to pick anything up, but stranger things have happened.
	if(l_hand)
		var/obj/item/organ/external/E = get_organ(BP_L_HAND) // We don't need to check for arms if we already have no hands
		if(!E)
			visible_message("<span class='danger'>Lacking a functioning left hand, \the [src] drops \the [l_hand].</span>")
			drop_l_hand(force = TRUE)

	if(r_hand)
		var/obj/item/organ/external/E = get_organ(BP_R_HAND)
		if(!E)
			visible_message("<span class='danger'>Lacking a functioning right hand, \the [src] drops \the [r_hand].</span>")
			drop_r_hand(force = TRUE)

	// Check again...
	if(!l_hand && !r_hand)
		return

	for(var/obj/item/organ/external/E in grasp_limbs)
		if(!E || !(E.limb_flags & ORGAN_FLAG_CAN_GRASP))
			continue
		if(((E.is_broken() || E.is_dislocated()) && !E.splinted) || E.is_malfunctioning())
			grasp_damage_disarm(E)

/mob/living/carbon/human/proc/stance_damage_prone(obj/item/organ/external/affected)
	if(affected)
		switch(affected.body_part)
			if(FOOT_LEFT, FOOT_RIGHT)
				to_chat(src, SPAN("warning", "You lose your footing as your [affected.name] spasms!"))
			if(LEG_LEFT, LEG_RIGHT)
				to_chat(src, SPAN("warning", "Your [affected.name] buckles from the shock!"))
			else
				return
		Stun(2)
		Weaken(5)

/mob/living/carbon/human/proc/grasp_damage_disarm(obj/item/organ/external/affected)
	var/disarm_slot
	switch(affected.body_part)
		if(HAND_LEFT, ARM_LEFT)
			disarm_slot = slot_l_hand
		if(HAND_RIGHT, ARM_RIGHT)
			disarm_slot = slot_r_hand

	if(!disarm_slot)
		return

	var/obj/item/thing = get_equipped_item(disarm_slot)

	if(!thing)
		return

	if(!drop(thing))
		return // Failed to drop, don't spam messages.

	if(BP_IS_ROBOTIC(affected))
		visible_message("<B>\The [src]</B> drops what they were holding, \his [affected.name] malfunctioning!")

		var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
		spark_system.set_up(5, 0, src)
		spark_system.attach(src)
		spark_system.start()
		spawn(10)
			qdel(spark_system)

	else
		var/grasp_name = affected.name
		if((affected.body_part in list(ARM_LEFT, ARM_RIGHT)) && affected.children.len)
			var/obj/item/organ/external/hand = pick(affected.children)
			grasp_name = hand.name

		if(!no_pain && affected.can_feel_pain())
			var/emote_scream = pick("screams in pain", "lets out a sharp cry", "cries out")
			var/emote_scream_alt = pick("scream in pain", "let out a sharp cry", "cry out")
			visible_message(
				"<B>\The [src]</B> [emote_scream] and drops what they were holding in their [grasp_name]!",
				null,
				"You hear someone [emote_scream_alt]!"
			)
			custom_pain("The sharp pain in your [affected.name] forces you to drop [thing]!", 30)
		else
			visible_message("<B>\The [src]</B> drops what they were holding in their [grasp_name]!")

/mob/living/carbon/human/proc/sync_organ_dna()
	var/list/all_bits = internal_organs|external_organs
	for(var/obj/item/organ/O in all_bits)
		O.set_dna(dna)

/mob/living/proc/is_asystole()
	return FALSE

/mob/living/carbon/human/is_asystole()
	if(full_prosthetic)
		var/obj/item/organ/internal/cell/C = internal_organs_by_name[BP_CELL]
		if(istype(C) && !C.is_usable())
			return TRUE
	else if(should_have_organ(BP_HEART))
		var/obj/item/organ/internal/heart/heart = internal_organs_by_name[BP_HEART]
		if(!istype(heart) || !heart.is_working() || (isundead(src) && !isfakeliving(src)))
			return TRUE
	return FALSE

/mob/living/carbon/human/proc/has_damaged_organ()
	for(var/limb_type in (species.has_limbs | external_organs_by_name))
		var/obj/item/organ/external/E = external_organs_by_name[limb_type]
		if((E && E.damage > 0) || !E || (E && (E.status & ORGAN_BROKEN)) || (E && (E.status &= ~ORGAN_ARTERY_CUT)))
			return 1
	return 0

/mob/living/carbon/human/proc/handle_coagulation()
	if(isSynthetic() || isundead(src))
		coagulation = COAGULATION_NONE
		return

	if(!should_have_organ(BP_LIVER)) // Blood can clot w/out a liver.
		coagulation = species.coagulation
		return

	var/obj/item/organ/internal/liver/L = internal_organs_by_name[BP_LIVER]
	if(istype(L))
		coagulation = L.coagulation
		return

	coagulation = COAGULATION_NONE
	return

/mob/living/carbon/human/proc/handle_toxins()
	if(isSynthetic() || isundead(src))
		return

	// Liverless species don't suffer from missing a liver, obviously.
	if(should_have_organ(BP_LIVER))
		var/obj/item/organ/internal/liver/L = internal_organs_by_name[BP_LIVER]
		var/filtering_efficiency = L ? L.filtering_efficiency : 0

		if(filtering_efficiency < 2) // Liver's not feeling alright, getting poisoned by our own metabolism.
			adjustToxLoss((2 - filtering_efficiency) * 0.5, TRUE)

	// Kidney-less species still get some passive detox as a placeholder. Xenomorphs and golems are immune to toxins anyway, but we can't be sure.
	var/detox_efficiency = 0.5
	var/obj/item/organ/internal/kidneys/K
	if(should_have_organ(BP_KIDNEYS))
		K = internal_organs_by_name[BP_KIDNEYS]
		if(K)
			detox_efficiency = K.detox_efficiency
		else
			detox_efficiency = -0.5

	// High hydratation boosts detox efficiency (if applicible), low hydration slows it down or halts it completely.
	switch(hydration)
		if(HYDRATION_NONE)
			detox_efficiency -= chem_effects[CE_ANTITOX] ? 0.3 : 0.5
		if(HYDRATION_NONE+0.01 to HYDRATION_LOW)
			detox_efficiency -= 0.2
		if(HYDRATION_HIGH+0.01 to HYDRATION_SUPER)
			if(detox_efficiency >= 0) // No effect if kidneys are broken
				detox_efficiency += 0.2
		if(HYDRATION_SUPER+0.01 to INFINITY)
			if(detox_efficiency >= 0) // No effect if kidneys are broken
				detox_efficiency += 0.5

	if(chem_effects[CE_TOXIN])
		detox_efficiency -= chem_effects[CE_TOXIN] * 0.1

	if(chem_effects[CE_ANTITOX])
		detox_efficiency += chem_effects[CE_ANTITOX] * 0.1

	adjustToxLoss(-1 * detox_efficiency, TRUE) // Either healing tox damage, or applying even more bypassing a liver's protection.

	// For simplicity, let's assume that 5% the blood volume equals the amount of toxins that's enough to completely wreck the body.
	toxic_severity = floor(toxic_buildup / (species ? (species.blood_volume * 0.05) : 280) * 100)

	var/kidney_strain = 1.0

	if(toxic_severity > TOXLOSS_HARDCAP) // hardcap
		toxic_severity = TOXLOSS_HARDCAP
		toxic_buildup = TOXLOSS_HARDCAP * ((species ? (species.blood_volume * 0.05) : 280) / 100)

	if(toxic_severity > TOXLOSS_SOFTCAP) // tb 350+, complete toxic shutdown
		Paralyse(20)

	if(toxic_severity > TOXLOSS_LETHAL) // tb 280+, we're wrecked, lethal poisoning
		Weaken(10)
		if(!chem_effects[CE_TOXBLOCK])
			adjustInternalLoss(2.5, TRUE)
			adjustBrainLoss(0.5)

	if(toxic_severity > TOXLOSS_CRITICAL) // tb 210+, we're in immediate danger, critical poisoning
		if(prob(10) && !chem_effects[CE_TOXBLOCK])
			losebreath++
			adjustInternalLoss(5.0, TRUE)

		make_dizzy(6)
		slurring = max(slurring, 30)
		eye_blurry = max(eye_blurry, 10)

		if(prob(5))
			Weaken(3)
			to_chat(src, SPAN("danger", "<b>You feel extremely [pick("nauseous", "sick", "weak")]!</b>"))
			vomit(timevomit = 3, silent = TRUE)
			adjustInternalLoss(3.0)

		kidney_strain = 2.5

	else if(toxic_severity > TOXLOSS_SEVERE) // tb 140+, we're in danger, severe poisoning
		make_dizzy(6)
		eye_blurry = max(eye_blurry, 5)

		if(prob(10) && !chem_effects[CE_TOXBLOCK])
			slurring = max(slurring, 10)
			adjustInternalLoss(3.0, TRUE)

		if(prob(5))
			to_chat(src, SPAN("danger", "You feel really [pick("nauseous", "sick", "weak")]!"))
			vomit(timevomit = 2, silent = TRUE)
			adjustInternalLoss(2.0) // Things start to become dangerous.

		kidney_strain = 2.0

	else if(toxic_severity > TOXLOSS_MILD) // tb 70+, we're not feeling well, mild poisoning
		make_dizzy(6)

		if(prob(10))
			eye_blurry = max(eye_blurry, 5)
			adjustInternalLoss(1.5, TRUE)

		if(prob(3))
			to_chat(src, SPAN("danger", "You feel [pick("nauseous", "sick", "weak")]..."))
			vomit(timevomit = 1, silent = TRUE)
			adjustInternalLoss(1.0) // Generalized organ damage in addition to the above. Still not lethal, but nasty.

		kidney_strain = 1.5

	else if(toxic_severity > TOXLOSS_CASUAL) // tb 14+, we start to notice that something's off, casual poisoning
		if(prob(10) && !chem_effects[CE_TOXBLOCK])
			make_dizzy(6)
			adjustInternalLoss(1.0, TRUE) // Not enough to be life-threatening, but may cause trouble if we have ongoing health issues.

		if(prob(1))
			to_chat(src, "<i>You feel a bit [pick("nauseous", "sick", "weak")]...</i>")
			vomit(timevomit = 1, level = 2, silent = TRUE)

	else if(toxic_severity > TOXLOSS_NONE)
		kidney_strain = 1.25

	if(K)
		K.hydration_consumption = DEFAULT_THIRST_FACTOR * kidney_strain
