
// Makes the vampire appear alive.
/datum/vampire_power/toggled/revitalise
	name = "Revitalise"
	desc = "Allows you to hide among your prey."
	icon_state = "vamp_revitalise"
	blood_cost = 1
	blood_drain = 0.3
	max_stat = UNCONSCIOUS

	text_activate = "You begin hiding your true self."
	text_deactivate = "You no longer pretend to be prey."
	text_noblood = "You stop hiding your true self because you run out of blood."

/datum/vampire_power/toggled/revitalise/activate()
	if(!..())
		return
	my_mob.status_flags |= FAKELIVING
	vampire.restore_colors()
	log_and_message_admins("activated revitalise.")

/datum/vampire_power/toggled/revitalise/deactivate(no_message = TRUE)
	if(!..())
		return
	my_mob.status_flags &= ~FAKELIVING
	vampire.set_up_colors()
