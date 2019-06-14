/mob/living/carbon/human/proc/update_eyes()
	var/obj/item/organ/internal/eyes/eyes = internal_organs_by_name[species.vision_organ ? species.vision_organ : BP_EYES]
	if(eyes)
		eyes.update_colour()
		regenerate_icons()

/mob/living/carbon/human/proc/get_bodypart_name(var/zone)
	var/obj/item/organ/external/E = get_organ(zone)
	if(E) . = E.name

/mob/living/carbon/human/proc/recheck_bad_external_organs()
	var/damage_this_tick = getToxLoss()
	for(var/obj/item/organ/external/O in organs)
		damage_this_tick += O.burn_dam + O.brute_dam

	if(damage_this_tick > last_dam)
		. = TRUE
	last_dam = damage_this_tick

/mob/living/carbon/human/proc/restore_limb(var/limb_type, var/show_message = FALSE)	//only for changling for now
	var/obj/item/organ/external/E = organs_by_name[limb_type]
	if(E && E.organ_tag != BP_HEAD && !E.vital && !E.is_usable())	//Skips heads and vital bits...
		E.removed()//...because no one wants their head to explode to make way for a new one.
		qdel(E)
		E= null
	if(!E)
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
	else if (E.damage > 0 || E.status & (ORGAN_BROKEN) || E.status & (ORGAN_ARTERY_CUT))
		E.status &= ~ORGAN_BROKEN
		E.status &= ~ORGAN_ARTERY_CUT
		for(var/datum/wound/W in E.wounds)
			if(W.wound_damage() == 0 && prob(50))
				E.wounds -= W
		return 1
	else
		return 0


/mob/living/carbon/human/proc/restore_organ(var/organ_type)	//only for changling for now
	var/obj/item/organ/internal/E = internal_organs_by_name[organ_type]
	if(E && !E.vital && !E.is_usable())	//Skips heads and vital bits...
		E.removed()//...because no one wants their head to explode to make way for a new one.
		qdel(E)
		E= null
	if(!E)
		var/list/organ_data = species.has_organ[organ_type]
		var/organ_path = organ_data["path"]
		var/obj/item/organ/internal/O = new organ_path(src)
		organ_data["descriptor"] = O.name
//		var/datum/reagent/blood/B = locate(/datum/reagent/blood) in vessel.reagent_list
//		blood_splatter(src,B,1)
		O.set_dna(dna)
		update_body()
		if(O.organ_tag == BP_BRAIN)
			O.vital = 0
//		if (show_message)
//			to_chat(src, "<span class='danger'>With a shower of fresh blood, a new [O.name] forms.</span>")
//			visible_message("<span class='danger'>With a shower of fresh blood, a length of biomass shoots from [src]'s [O.amputation_point], forming a new [O.name]!</span>")
		return 1
	else if (E.damage > 0 || E.status & (ORGAN_BROKEN) || E.status & (ORGAN_ARTERY_CUT))
		E.status &= ~ORGAN_BROKEN
		E.status &= ~ORGAN_ARTERY_CUT
//		for(var/datum/wound/W in E.wounds)
//			if(W.wound_damage() == 0 && prob(50))
//				E.wounds -= W
		return 1
	else
		return 0
// Takes care of organ related updates, such as broken and missing limbs
/mob/living/carbon/human/proc/handle_organs()

	var/force_process = recheck_bad_external_organs()

	if(force_process)
		bad_external_organs.Cut()
		for(var/obj/item/organ/external/Ex in organs)
			bad_external_organs |= Ex

	//processing internal organs is pretty cheap, do that first.
	for(var/obj/item/organ/I in internal_organs)
		I.Process()

	handle_stance()
	handle_grasp()

	if(!force_process && !bad_external_organs.len)
		return

	for(var/obj/item/organ/external/E in bad_external_organs)
		if(!E)
			continue
		if(!E.need_process())
			bad_external_organs -= E
			continue
		else
			E.Process()

			if (!lying && !buckled && world.time - l_move_time < 15)
			//Moving around with fractured ribs won't do you any good
				if (prob(10) && !stat && can_feel_pain() && chem_effects[CE_PAINKILLER] < 50 && E.is_broken() && E.internal_organs.len)
					custom_pain("Pain jolts through your broken [E.encased ? E.encased : E.name], staggering you!", 50, affecting = E)
					drop_item(loc)
					Stun(2)

				//Moving makes open wounds get infected much faster
				if (E.wounds.len)
					for(var/datum/wound/W in E.wounds)
						if (W.infection_check())
							W.germ_level += 1

/mob/living/carbon/human/proc/handle_stance()
	// Don't need to process any of this if they aren't standing anyways
	// unless their stance is damaged, and we want to check if they should stay down
	if (!stance_damage && (lying || resting) && (life_tick % 4) != 0)
		return

	stance_damage = 0
	stance_d_l = 0
	stance_d_r = 0

	// Buckled to a bed/chair. Stance damage is forced to 0 since they're sitting on something solid
	if (istype(buckled, /obj/structure/bed))
		return

	// Can't fall if nothing pulls you down
	var/area/area = get_area(src)
	if (!area || !area.has_gravity())
		return

	var/limb_pain
	for(var/limb_tag in list(BP_L_LEG, BP_L_FOOT))	// Left leg processing
		var/obj/item/organ/external/E = organs_by_name[limb_tag]

		if(!E || (E.disfigured) || istype(E,/obj/item/organ/external/stump))
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

		else if(E.is_broken() || (E.pain >= E.pain_disability_threshold))
			stance_d_l += 2

		else if(E.is_dislocated())
			stance_d_l += 1

		if(E) limb_pain = E.can_feel_pain()

		if(l_hand && istype(l_hand, /obj/item/weapon/cane))
			stance_d_l -= 1.5

	for(var/limb_tag in list(BP_R_LEG, BP_R_FOOT))	// Right leg processing
		var/obj/item/organ/external/E = organs_by_name[limb_tag]

		if(!E || (E.disfigured) || istype(E,/obj/item/organ/external/stump))
			stance_d_l += 5

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

		else if(E.is_broken() || (E.pain >= E.pain_disability_threshold))
			stance_d_r += 2

		else if(E.is_dislocated())
			stance_d_r += 1

		if(E) limb_pain = E.can_feel_pain()

		if (r_hand && istype(r_hand, /obj/item/weapon/cane))
			stance_d_r -= 1.5

	stance_damage = stance_d_r + stance_d_l
	// standing is poor
	if(!(lying || resting))
		if(((stance_d_l >= 5) && (stance_d_r >= 5)))
			custom_emote(VISIBLE_MESSAGE, "can't stand without legs!")
			Weaken(10)
		else if(((stance_d_l >= 5) && (stance_d_r > 1)) || ((stance_d_l > 1) && (stance_d_r >= 5)))
			if(limb_pain)
				emote("scream")
				shock_stage+=5
			custom_emote(VISIBLE_MESSAGE, "collapses!")
			Weaken(10)
		else if(((stance_d_l >= 4) && (stance_d_l > 0)) || ((stance_d_l > 0) && (stance_d_r >= 4)))
			if(prob(60))
				if(limb_pain)
					emote("scream")
					shock_stage+=50
				custom_emote(VISIBLE_MESSAGE, "collapses!")
				Weaken(10)
		else if((stance_d_l >= 2) && (stance_d_r >= 2))
			if(prob(40))
				if(limb_pain)
					emote("scream")
					shock_stage+=25
				custom_emote(VISIBLE_MESSAGE, "collapses!")
				Weaken(10)
		else if(((stance_d_l >= 2) && (stance_d_r > 0)) || ((stance_d_l > 0) && (stance_d_r >= 2)))
			if(prob(30))
				if(limb_pain)
					emote("scream")
					shock_stage+=15
				custom_emote(VISIBLE_MESSAGE, "collapses!")
				Weaken(7)
		else if((stance_d_l > 0) && (stance_d_r > 0))
			if(prob(20))
				if(limb_pain)
					emote("scream")
					shock_stage+=12.5
				custom_emote(VISIBLE_MESSAGE, "collapses!")
				Weaken(5)
		else if((stance_d_l >= 5) || (stance_d_r >= 5))
			if(prob(10))
				custom_emote(VISIBLE_MESSAGE, "collapses!")
				Weaken(3)
		else if((stance_d_l >= 4) || (stance_d_r >= 4))
			if(prob(8))
				if(limb_pain)
					emote("scream")
					shock_stage+=12.5
				custom_emote(VISIBLE_MESSAGE, "collapses!")
				Weaken(5)
		else if((stance_d_l >= 3) || (stance_d_r >= 3))
			if(prob(6))
				if(limb_pain)
					emote("scream")
					shock_stage+=10
				custom_emote(VISIBLE_MESSAGE, "collapses!")
				Weaken(5)
		else if((stance_d_l >= 2) || (stance_d_r >= 2))
			if(prob(4))
				if(limb_pain)
					emote("scream")
					shock_stage+=5
				custom_emote(VISIBLE_MESSAGE, "collapses!")
				Weaken(3)
		else if((stance_d_l >= 1) || (stance_d_r >= 1))
			if(prob(2))
				if(limb_pain)
					emote("scream")
					shock_stage+=5
				custom_emote(VISIBLE_MESSAGE, "collapses!")
				Weaken(3)
		else return

/mob/living/carbon/human/proc/handle_grasp()
	if(!l_hand && !r_hand)
		return

	// You should not be able to pick anything up, but stranger things have happened.
	if(l_hand)
		for(var/limb_tag in list(BP_L_HAND, BP_L_ARM))
			var/obj/item/organ/external/E = get_organ(limb_tag)
			if(!E)
				visible_message("<span class='danger'>Lacking a functioning left hand, \the [src] drops \the [l_hand].</span>")
				drop_from_inventory(l_hand,force = 1)
				break

	if(r_hand)
		for(var/limb_tag in list(BP_R_HAND, BP_R_ARM))
			var/obj/item/organ/external/E = get_organ(limb_tag)
			if(!E)
				visible_message("<span class='danger'>Lacking a functioning right hand, \the [src] drops \the [r_hand].</span>")
				drop_from_inventory(r_hand,force = 1)
				break

	// Check again...
	if(!l_hand && !r_hand)
		return

	for (var/obj/item/organ/external/E in organs)
		if(!E || !E.can_grasp)
			continue
		if(((E.is_broken() || E.is_dislocated()) && !E.splinted) || E.is_malfunctioning())
			grasp_damage_disarm(E)


/mob/living/carbon/human/proc/grasp_damage_disarm(var/obj/item/organ/external/affected)
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

	drop_from_inventory(thing)

	if(affected.robotic >= ORGAN_ROBOT)
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
	var/list/all_bits = internal_organs|organs
	for(var/obj/item/organ/O in all_bits)
		O.set_dna(dna)

/mob/living/proc/is_asystole()
	return FALSE

/mob/living/carbon/human/is_asystole()
	if(isSynthetic())
		var/obj/item/organ/internal/cell/C = internal_organs_by_name[BP_CELL]
		if(istype(C))
			if(!C.is_usable())
				return TRUE
	else if(should_have_organ(BP_HEART))
		var/obj/item/organ/internal/heart/heart = internal_organs_by_name[BP_HEART]
		if(!istype(heart) || !heart.is_working())
			return TRUE
	return FALSE

/mob/living/carbon/human/proc/has_damaged_organ()
	for(var/limb_type in (species.has_limbs | organs_by_name))
		var/obj/item/organ/external/E = organs_by_name[limb_type]
		if((E && E.damage > 0) || !E || (E && (E.status & ORGAN_BROKEN)) || (E && (E.status &= ~ORGAN_ARTERY_CUT)))
			return 1
	return 0