/datum/admin_secret_item/admin_secret/storyteller_control_panel
	name = "Storyteller Control Panel"

/datum/admin_secret_item/admin_secret/storyteller_control_panel/execute(mob/user)
	. = ..()
	if(!.)
		return
	SSstoryteller.open_control_panel(user)
