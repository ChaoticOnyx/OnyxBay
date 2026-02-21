
// Makes us almost transparent, using chemicals in process.
/datum/changeling_power/toggled/visible_camouflage
	name = "Visible Camouflage"
	desc = "Turns us almost invisible, as long as we move slowly."
	icon_state = "ling_camouflage"
	required_chems = 20
	chems_drain = 1
	power_processing = TRUE

	text_activate = "We vanish from sight, and will remain hidden, so long as we move carefully."
	text_deactivate = "We revert our camouflage, revealing ourselves."
	text_nochems = "Our camouflage suddenly reverts, revealing us."
	var/must_walk = TRUE

/datum/changeling_power/toggled/visible_camouflage/update_recursive_enhancement()
	if(..())
		desc = "Turns us almost invisible."
		text_activate = "We vanish from sight."
		must_walk = FALSE
		if(active)
			to_chat(my_mob, "We can move with normal speed without reverealing ourself now.") // In case of buying recursive while hidden.
	else
		desc = initial(desc)
		text_activate = initial(text_activate)
		must_walk = TRUE

/datum/changeling_power/toggled/visible_camouflage/activate()
	if(!..())
		return
	var/mob/living/carbon/human/H = my_mob
	animate(H, alpha = 255, alpha = 10, time = 10, flags = ANIMATION_PARALLEL)
	if(must_walk)
		H.set_m_intent(M_WALK)
	use_chems()

/datum/changeling_power/toggled/visible_camouflage/deactivate(no_message = TRUE)
	if(!..(TRUE)) // Never use messages, since we use visible_message() here.
		return
	var/mob/living/carbon/human/H = my_mob
	H.invisibility = initial(H.invisibility)
	H.visible_message(SPAN("warning", "[H] suddenly fades in, seemingly from nowhere!"), \
					  SPAN("changeling", text_deactivate))
	H.set_m_intent(M_RUN)
	animate(H, alpha = 10, alpha = 255, time = 10, flags = ANIMATION_PARALLEL)

/datum/changeling_power/toggled/visible_camouflage/think()
	if(!..())
		return
	if(my_mob.m_intent != M_WALK && must_walk) // Moving too fast uncloaks you.
		deactivate()
		return
	if(my_mob.incapacitated(INCAPACITATION_DISABLED)) // Stunned lings can't stay cloaked.
		deactivate()
		return
