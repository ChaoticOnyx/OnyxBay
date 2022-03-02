
//Fake our own death and fully heal. You will appear to be dead but regenerate fully after a short delay.
/datum/changeling_power/toggled/stasis
	name = "Regenerative Stasis"
	desc = "We become weakened to a death-like state, where we will rise again from death. Uses our entire chemical storage."
	icon_state = "ling_stasis"
	required_chems = 0
	power_processing = FALSE
	max_stat = DEAD
	allow_stasis = TRUE

	text_activate = "We're starting to regenerate."
	text_deactivate = "We have regenerated."

	var/is_ready = FALSE
	var/max_revive_time = 240
	var/revive_speedup_by_chem = 1.2
	var/chemical_buffer = -1 // Amount of chemicals we regain if we use recursive enhancement
	var/chemical_buffer_divisor = 3

/datum/changeling_power/toggled/stasis/update_screen_button()
	if(is_ready)
		icon_state = "ling_revive"
	else
		icon_state = "ling_stasis"
	..()

/datum/changeling_power/toggled/stasis/update_recursive_enhancement()
	if(..())
		desc = "We become weakened to a death-like state, where we will rise again from death. Uses our entire chemical storage, but we regain some chemicals upon rising."
		chemical_buffer = 0
	else
		desc = initial(desc)
		chemical_buffer = -1

// Activating stasis
/datum/changeling_power/toggled/stasis/activate()
	if(changeling.true_dead)
		to_chat(my_mob, SPAN("changeling", "We can not do this. We are really dead."))
		return

	if(!active && !my_mob.stat && alert("Are we sure we wish to fake our death?",,"Yes","No") == "No") // Confirmation for living changelings if they want to fake their death
		return

	if(!..())
		return

	var/revive_time = max_revive_time - (changeling.chem_charges * revive_speedup_by_chem)
	revive_time = max(1, revive_time) SECONDS // 0s timers bad

	if(chemical_buffer != -1)
		chemical_buffer = round(changeling.chem_charges / chemical_buffer_divisor)
	changeling.chem_charges = 0

	my_mob.status_flags |= FAKEDEATH
	my_mob.update_canmove()

	my_mob.emote("gasp")

	my_mob.death(0) // So our body ~actually~ dies until revived

	addtimer(CALLBACK(src, .proc/revive_ready), revive_time)

	update_screen_button()

// Reviving ourselves
/datum/changeling_power/toggled/stasis/deactivate()
	if(changeling.true_dead)
		to_chat(src, SPAN("changeling", "We can not do this. We are really dead."))
		return
	if(!is_ready)
		to_chat(src, SPAN("changeling", "We are still regenerating."))
		return
	if(!is_usable())
		return
	if(!..())
		return
	var/mob/living/L = my_mob

	name = initial(name)
	desc = initial(desc)

	is_ready = FALSE
	update_screen_button()

	if(chemical_buffer != -1)
		changeling.chem_charges += chemical_buffer
		chemical_buffer = 0

	L.revive(ignore_prosthetic_prefs = TRUE) // Complete regeneration
	L.status_flags &= ~(FAKEDEATH)
	L.update_canmove()

/datum/changeling_power/toggled/stasis/proc/revive_ready()
	if(QDELETED(src))
		return
	if(!changeling.my_mob)
		return

	is_ready = TRUE
	to_chat(my_mob, SPAN("changeling", "<font size='5'>We are ready to rise. Use the <b>Revive</b> ability to get back up.</font>"))

	name = "Revive"
	desc = "We will rise again from death."

	update_screen_button()

	feedback_add_details("changeling_powers", "FD")
