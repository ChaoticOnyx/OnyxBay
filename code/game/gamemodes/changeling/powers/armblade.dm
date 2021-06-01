
//Grows a scary, and powerful arm blade.
/mob/proc/changeling_arm_blade()
	set category = "Changeling"
	set name = "Arm Blade (20)"

	if(is_regenerating())
		return

	visible_message("<span class='warning'>The flesh is torn around the [src.name]\'s arm!</span>",
		"<span class='warning'>The flesh of our hand is transforming.</span>",
		"<span class='italics'>You hear organic matter ripping and tearing!</span>")
	spawn(4 SECONDS)
		playsound(src, 'sound/effects/blob/blobattack.ogg', 30, 1)
		if(mind.changeling.recursive_enhancement)
			if(changeling_generic_weapon(/obj/item/weapon/melee/changeling/arm_blade/greater))
				to_chat(src, "<span class='notice'>We prepare an extra sharp blade.</span>")
		else
			changeling_generic_weapon(/obj/item/weapon/melee/changeling/arm_blade)
