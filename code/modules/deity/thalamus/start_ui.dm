/datum/thalamus_start/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ThalamusStart", "Start Menu")
		ui.open()

/datum/thalamus_start/tgui_state()
	return GLOB.tgui_always_state

/datum/thalamus_start/tgui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
