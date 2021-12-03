
// Makes us almost transparent, using chemicals in process.
/datum/changeling_power/toggle/visible_camouflage
	name = "Visible Camouflage"
	desc = "Turns us almost invisible, as long as we move slowly."
	icon_state = "ling_boost_range"
	required_chems = 10
	chems_drain = 0.5
	power_processing = TRUE

	text_activate = "We vanish from sight, and will remain hidden, so long as we move carefully."
	text_deactivate = "We revert our camouflage, revealing ourselves."
	var/must_walk = TRUE

/datum/changeling_power/toggle/visible_camouflage/update_recursive_enhancement()
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

/datum/changeling_power/toggle/visible_camouflage/activate()
	if(!..())
		return
	animate(my_mob, alpha = 255, alpha = 10, time = 10)
	if(must_walk)
		my_mob.set_m_intent(M_WALK)

/datum/changeling_power/toggle/visible_camouflage/deactivate()
	if(!..())
		return
	my_mob.invisibility = initial(my_mob.invisibility)
	my_mob.visible_message(SPAN("warning", "[my_mob] suddenly fades in, seemingly from nowhere!"), \
						   SPAN("changeling", text_deactivate))
	my_mob.set_m_intent(M_RUN)
	animate(my_mob, alpha = 10, alpha = 255, time = 10)

/datum/changeling_power/toggle/visible_camouflage/Process()
	if(!..())
		return
	if(changeling.is_regenerating())
		deactivate()
		return
	if(my_mob.m_intent != M_WALK && must_walk) // Moving too fast uncloaks you.
		deactivate()
		return
	if(my_mob.stat) // Dead or unconscious lings can't stay cloaked.
		deactivate()
		return
	if(my_mob.incapacitated(INCAPACITATION_DISABLED)) // Stunned lings also can't stay cloaked.
		deactivate()
		return
