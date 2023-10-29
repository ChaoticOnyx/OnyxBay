
/datum/vampire_power/touch_of_life
	name = "Touch of Life"
	desc = "You lay your hands on the target, transferring healing chemicals to them."
	icon_state = "vamp_touch_of_life"
	blood_cost = 30

/datum/vampire_power/touch_of_life/activate()
	if(!..())
		return

	var/obj/item/grab/G = my_mob.get_active_hand()
	if(!istype(G))
		to_chat(my_mob, SPAN("warning", "You must be grabbing a victim in your active hand to touch them."))
		return

	var/mob/living/carbon/human/T = G.affecting
	if (T.isSynthetic() || T.species.species_flags & SPECIES_FLAG_NO_BLOOD)
		to_chat(my_mob, SPAN("warning", "[T] has no blood and can not be affected by your powers!"))
		return

	my_mob.visible_message("<b>[my_mob]</b> gently touches [T].")
	to_chat(T, SPAN("notice", "You feel pure bliss as [my_mob] touches you."))
	use_blood()

	T.reagents.add_reagent(/datum/reagent/rezadone, 2)
	T.reagents.add_reagent(/datum/reagent/painkiller, 1.0) //enough to get back onto their feet
