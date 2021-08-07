/datum/admin_secret_item/admin_secret/toggle_virus
	name = "Toggle Viruses"

/datum/admin_secret_item/admin_secret/toggle_virus/execute()
	if(!(. = ..()))
		return
	var/choice = alert("Viruses are currently [SSvirus2suka.can_fire ? "enabled" : "disabled"].","Toggle Viruses", SSvirus2suka.can_fire ? "Disable" : "Enable","Cancel")
	if(choice == "Disable")
		SSvirus2suka.disable()
	else if(choice == "Enable")
		SSvirus2suka.enable()
