
//Hide us from anyone who would do us harm.
/mob/proc/changeling_visible_camouflage()
	set category = "Changeling"
	set name = "Visible Camouflage (10)"
	set desc = "Turns us almost invisible, as long as we move slowly."

	if(istype(src, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = src

		if(H.mind.changeling.cloaked)
			H.mind.changeling.cloaked = FALSE
			return

		//We delay the check, so that people can uncloak without needing 10 chemicals to do so.
		var/datum/changeling/changeling = changeling_power(10)
		if(!changeling)
			return

		changeling.chem_charges -= 10
		var/old_regen_rate = H.mind.changeling.chem_recharge_rate

		to_chat(H, SPAN("changeling", "We vanish from sight, and will remain hidden, so long as we move carefully."))
		H.mind.changeling.cloaked = TRUE
		H.mind.changeling.chem_recharge_rate = 0
		animate(src, alpha = 255, alpha = 10, time = 10)

		var/must_walk = TRUE
		if(mind.changeling.recursive_enhancement)
			must_walk = FALSE
			to_chat(src, SPAN("changeling", "We may move at our normal speed while hidden."))

		if(must_walk)
			H.set_m_intent(M_WALK)

		var/remain_cloaked = TRUE
		while(remain_cloaked && !is_regenerating()) //This loop will keep going until the player uncloaks.
			sleep(1 SECOND) // Sleep at the start so that if something invalidates a cloak, it will drop immediately after the check and not in one second.

			if(H.m_intent != M_WALK && must_walk) // Moving too fast uncloaks you.
				remain_cloaked = FALSE
			if(!H.mind.changeling.cloaked)
				remain_cloaked = FALSE
			if(H.stat) // Dead or unconscious lings can't stay cloaked.
				remain_cloaked = FALSE
			if(H.incapacitated(INCAPACITATION_DISABLED)) // Stunned lings also can't stay cloaked.
				remain_cloaked = FALSE

			if(mind.changeling.chem_recharge_rate != 0) //Without this, there is an exploit that can be done, if one buys engorged chem sacks while cloaked.
				old_regen_rate += mind.changeling.chem_recharge_rate //Unfortunately, it has to occupy this part of the proc.  This fixes it while at the same time
				mind.changeling.chem_recharge_rate = 0 //making sure nobody loses out on their bonus regeneration after they're done hiding.

		H.invisibility = initial(invisibility)
		visible_message(SPAN("warning", "[src] suddenly fades in, seemingly from nowhere!"), \
						SPAN("changeling", "We revert our camouflage, revealing ourselves."))
		H.set_m_intent(M_RUN)
		H.mind.changeling.cloaked = 0
		H.mind.changeling.chem_recharge_rate = old_regen_rate

		animate(src, alpha = 10, alpha = 255, time = 10)
