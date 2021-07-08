
// Grows an arm blade - damage higher than claw's, but lower armorpen
/mob/proc/changeling_arm_blade()
	set category = "Changeling"
	set name = "Arm Blade (20)"
	set desc = "We reform our hand into a deadly arm blade."

	if(changeling_is_incapacitated())
		return

	visible_message("<b>[name]</b>'s arm twitches.", \
					SPAN("changeling", "The flesh of our hand is transforming."))
	spawn(4 SECONDS)
		playsound(src, 'sound/effects/blob/blobattack.ogg', 30, 1)
		if(mind.changeling.recursive_enhancement)
			if(!changeling_generic_weapon(/obj/item/weapon/melee/changeling/arm_blade/greater))
				return
			to_chat(src, SPAN("changeling", "We prepare an extra sharp blade."))
		else
			if(!changeling_generic_weapon(/obj/item/weapon/melee/changeling/arm_blade))
				return

	visible_message(SPAN("danger", "The flesh is torn around the [name]\'s arm!"), \
					SPAN("changeling", "We transform our hand into a blade."), \
					SPAN("italics", "You hear organic matter ripping and tearing!"))
