
/datum/changeling_power/toggled/sting/fake_armblade
	name = "Fake Arm Blade Sting"
	desc = "We sting our victim, causing one of their arms to reform into a fake armblade."
	icon_state = "ling_sting_fake_armblade"
	required_chems = 15

/datum/changeling_power/toggled/sting/fake_armblade/sting_target(mob/living/carbon/human/target, loud = FALSE)
	if(!..())
		return FALSE

	spawn(10 SECONDS)
		to_chat(target, SPAN("danger", "You feel strange spasms in your hand."))
		target.visible_message("<b>[target]</b>'s arm twitches.")

	spawn(15 SECONDS)
		playsound(target.loc, 'sound/effects/blob/blobattack.ogg', 30, 1)
		var/hand = pick(list(BP_R_HAND, BP_L_HAND))
		var/failed = FALSE
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
		if(!failed)
			target.visible_message(SPAN("danger", "The flesh is torn around the [target.name]\'s arm!"))
			new /obj/item/melee/prosthetic/bio/fake_arm_blade(target, target.organs_by_name[hand])
