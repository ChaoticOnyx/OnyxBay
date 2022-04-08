//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/computer/operating
	name = "patient monitoring console"
	density = 1
	anchored = 1.0
	icon_keyboard = "med_key"
	icon_screen = "crew"
	circuit = /obj/item/circuitboard/operating
	var/mob/living/carbon/human/victim = null
	var/obj/machinery/optable/table = null

/obj/machinery/computer/operating/New()
	..()
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		table = locate(/obj/machinery/optable, get_step(src, dir))
		if(!table || table?.computer)
			continue
		table.computer = src
		break

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
			table?.remove_clothes()
			return TRUE

/obj/machinery/computer/operating/tgui_data(mob/user)
	var/list/data = list(
		"medical_data" = table.victim?.get_medical_data_ui()
	)

	return data
