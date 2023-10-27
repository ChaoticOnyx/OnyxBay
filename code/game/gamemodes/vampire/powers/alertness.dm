
// Makes vampire's victim not get paralyzed, and remember the suckings
/datum/vampire_power/toggled/alertness
	name = "Victim Alertness"
	desc = "Toggle whether you wish for your victims to forget your deeds."
	icon_state = "vamp_alertness"
	power_processing = FALSE
	max_stat = UNCONSCIOUS

	text_activate = "Your victims will now remember your interactions."
	text_deactivate = "Your victims will now forget your interactions."

/datum/vampire_power/toggled/alertness/activate()
	if(!..())
		return
	vampire.stealth = FALSE

/datum/vampire_power/toggled/alertness/deactivate(no_message = TRUE)
	if(!..())
		return
	vampire.stealth = TRUE
