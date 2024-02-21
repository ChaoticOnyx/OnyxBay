//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/computer/operating
	name = "patient monitoring console"
	density = 1
	anchored = 1.0
	icon_keyboard = "med_key"
	icon_screen = "crew"
	light_color = "#5284E7"
	circuit = /obj/item/circuitboard/operating
	/// Weakref to a connected operating table
	var/weakref/optable

/obj/machinery/computer/operating/attack_hand(mob/user)
	. = ..()

	if(!.)
		tgui_interact(user)

/obj/machinery/computer/operating/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "OperatingTable", name)
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/operating/tgui_act(action, params)
	. = ..()

	if(.)
		return

	switch(action)
		if("remove_clothes")
			var/obj/machinery/optable/table = optable?.resolve()
			table?.remove_clothes()
			return TRUE

/obj/machinery/computer/operating/tgui_data(mob/user)
	var/list/data = list()

	var/obj/machinery/optable/table = optable?.resolve()
	var/mob/living/carbon/human/H = table?.victim_ref?.resolve()

	data["medical_data"] = H?.get_medical_data_ui()

	return data

/obj/machinery/computer/operating/Destroy()
	optable = null
	return ..()
