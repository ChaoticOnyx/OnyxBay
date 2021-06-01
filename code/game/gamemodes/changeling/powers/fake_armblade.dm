
/mob/proc/prepare_changeling_fake_arm_blade_sting()
	set category = "Changeling"
	set name = "Fake arm Blade (30)"
	set desc = "We reform victims arm into a fake armblade."
	if(is_regenerating())
		return
	change_ctate(/datum/click_handler/changeling/changeling_fake_arm_blade_sting)
	return

/mob/proc/changeling_fake_arm_blade_sting(mob/living/carbon/human/T)
	var/mob/living/carbon/human/target = changeling_sting(/mob/proc/prepare_changeling_fake_arm_blade_sting, T, 30)
	if(!target)
		return FALSE
	spawn(10 SECONDS)
		to_chat(target, "<span class='danger'>You feel strange spasms in your hand.</span>")
	spawn(15 SECONDS)
		playsound(target.loc, 'sound/effects/blob/blobattack.ogg', 30, 1)
		var/hand = pick(list(BP_R_HAND,BP_L_HAND))
		var/failed
		switch(hand)
			if(BP_R_HAND)
				if(!isProsthetic(target.r_hand))
					target.drop_r_hand()
				else if(!isProsthetic(target.l_hand))
					target.drop_l_hand()
					hand = BP_L_HAND
				else
					failed = TRUE

			if(BP_L_HAND)
				if(!isProsthetic(target.l_hand))
					target.drop_l_hand()
				else if(!isProsthetic(target.r_hand))
					target.drop_r_hand()
					hand = BP_R_HAND
				else
					failed = TRUE
		if (!failed)
			target.visible_message("<span class='warning'>The flesh is torn around the [target.name]\'s arm!</span>",
								"<span class='warning'>We are transforming [target.name]\'s arm into fake armblade.</span>",
								"<span class='italics'>You hear organic matter ripping and tearing!</span>")
			new /obj/item/weapon/melee/prosthetic/bio/fake_arm_blade(target,target.organs_by_name[hand])
