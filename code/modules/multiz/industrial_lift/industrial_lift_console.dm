/obj/machinery/computer/elevator_control
	name = "Elevator control"
	var/elevator_tag
	icon = 'icons/obj/computer.dmi'
	icon_state = "tiny"
	icon_keyboard = "tiny_keyboard"
	icon_screen = "lift"
	density = 0
	var/datum/lift_master/elevator_master
	var/ui_template = "elevator_control_console.tmpl"

/obj/machinery/computer/elevator_control/attack_hand(user as mob)
	if(..(user))
		return
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Access Denied.</span>")
		return 1

	ui_interact(user)

/obj/machinery/computer/elevator_control/proc/get_ui_data()
	var/elevator_state = "unknown"
	if(isnull(elevator_master))
		for(var/obj/structure/industrial_lift/L in GLOB.lifts)
			if(L.id == elevator_tag)
				elevator_master = L.lift_master_datum
				break

	switch(elevator_master.moving_status)
		if(ELEVATOR_IDLE) elevator_state = "idle"
		if(ELEVATOR_INTRANSIT) elevator_state = "in_transit"

	return list(
		"elevator_state" = elevator_state,
		"can_move_up" = elevator_master.Check_lift_move(UP),
		"can_move_down" = elevator_master.Check_lift_move(DOWN)
	)

/obj/machinery/computer/elevator_control/OnTopic(user, href_list)
	if(!istype(elevator_master))
		return TOPIC_NOACTION

	if(href_list["Up"])
		elevator_master.use("Up")
		return TOPIC_REFRESH

	if(href_list["Down"])
		elevator_master.use("Down")
		return TOPIC_REFRESH

	if(href_list["Cancel"])
		elevator_master.use("Cancel")
		return TOPIC_REFRESH

/obj/machinery/computer/elevator_control/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	if(!elevator_tag)
		to_chat(user,"<span class='warning'>Unable to establish link with the elevator.</span>")
		return

	var/list/data = get_ui_data()

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, ui_template, "[elevator_tag] elevator control", 470, 450)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)
