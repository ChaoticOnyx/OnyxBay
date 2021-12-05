
//Fake our own death and fully heal. You will appear to be dead but regenerate fully after a short delay.
/datum/changeling_power/toggled/stasis
	name = "Regenerative Stasis"
	desc = "We become weakened to a death-like state, where we will rise again from death. Uses chemicals upon Revive, not when going into stasis."
	icon_state = "ling_stasis"
	required_chems = 20
	power_processing = FALSE
	max_stat = DEAD
	allow_stasis = TRUE

	var/is_ready = FALSE

/datum/changeling_power/toggled/stasis/update_screen_button()
	if(is_ready)
		icon_state = "ling_revive"
	else
		icon_state = "ling_stasis"
	..()

// Activating stasis
/datum/changeling_power/toggled/stasis/activate()
	if(changeling.true_dead)
		to_chat(my_mob, SPAN("changeling", "We can not do this. We are really dead."))
		return

	if(!..())
		return

	if(!my_mob.stat && alert("Are we sure we wish to fake our death?",,"Yes","No") == "No") // Confirmation for living changelings if they want to fake their death
		return

	my_mob.status_flags |= FAKEDEATH
	my_mob.update_canmove()

	my_mob.emote("gasp")

	my_mob.death(0) // So our body ~actually~ dies until revived
	to_chat(my_mob, SPAN("changeling", "We're starting to regenerate."))

	addtimer(CALLBACK(src, .proc/revive_ready), rand(80 SECONDS, 200 SECONDS))

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

	use_chems()

	name = initial(name)
	desc = initial(desc)

	update_screen_button()

	L.revive(ignore_prosthetic_prefs = TRUE) // Complete regeneration
	L.status_flags &= ~(FAKEDEATH)
	L.update_canmove()

	is_ready = FALSE
	to_chat(L, SPAN("changeling", "We have regenerated."))

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
