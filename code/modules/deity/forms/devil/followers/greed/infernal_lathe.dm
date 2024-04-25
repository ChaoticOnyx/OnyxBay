/datum/action/cooldown/spell/infernal_lathe
	name = "Infernal Lathe"
	desc = "VOROVSKOY KARMAN4IK."
	button_icon_state = "devil_lathe"
	cooldown_time = 1 SECOND
	var/datum/infernal_lathe/lathe

/datum/action/cooldown/spell/infernal_lathe/New()
	. = ..()
	lathe = new /datum/infernal_lathe(src, owner)

/datum/action/cooldown/spell/infernal_lathe/Destroy()
	QDEL_NULL(lathe)
	return ..()

/datum/action/cooldown/spell/infernal_lathe/cast()
	lathe.tgui_interact(owner)
