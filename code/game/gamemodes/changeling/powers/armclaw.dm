
// Grows a claw - armorpen higher than blade's, but lower damage
/mob/proc/changeling_claw()
	set category = "Changeling"
	set name = "Claw (15)"
	set desc = "We reform our hand into a deadly claw."

	if(changeling_is_incapacitated())
		return

	if(mind.changeling.recursive_enhancement)
		if(!changeling_generic_weapon(/obj/item/weapon/melee/changeling/claw/greater, 15))
			return
		to_chat(src, SPAN("changeling", "We prepare an extra sharp claw."))
	else
		if(!changeling_generic_weapon(/obj/item/weapon/melee/changeling/claw, 15))
			return

	visible_message(SPAN("danger", "[name]\'s arm twists horribly as sharpened bones grow through flesh!"), \
					SPAN("changeling", "We transform our hand into a claw."), \
					SPAN("italics", "You hear organic matter ripping and tearing!"))
