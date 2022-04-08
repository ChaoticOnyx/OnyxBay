/datum/admin_secret_item/admin_secret/toggle_virus
	name = "Toggle Viruses"

/datum/admin_secret_item/admin_secret/toggle_virus/execute()
	if(!(. = ..()))
		return
	var/choice = alert("Viruses are currently [SSvirus.can_fire ? "enabled" : "disabled"].","Toggle Viruses", SSvirus.can_fire ? "Disable" : "Enable","Cancel")
	if(choice == "Disable")
		SSvirus.disable()
	else if(choice == "Enable")
		SSvirus.enable()
