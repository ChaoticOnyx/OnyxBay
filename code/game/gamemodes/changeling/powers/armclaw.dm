
/mob/proc/changeling_claw()
	set category = "Changeling"
	set name = "Claw (15)"

	if(is_regenerating())
		return

	if(mind.changeling.recursive_enhancement)
		if(changeling_generic_weapon(/obj/item/weapon/melee/changeling/claw/greater, 1, 15))
			to_chat(src, "<span class='notice'>We prepare an extra sharp claw.</span>")
			return 1

	else
		if(changeling_generic_weapon(/obj/item/weapon/melee/changeling/claw, 1, 15))
			return 1
		return 0
