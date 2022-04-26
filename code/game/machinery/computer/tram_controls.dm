/obj/machinery/computer/tram_controls
	name = "tram controls"
	desc = "An interface for the tram that lets you tell the tram where to go and hopefully it makes it there. I'm here to describe the controls to you, not to inspire confidence."
	icon_screen = "tram"
	icon_keyboard = "atmos_key"
	light_color = COLOR_GREEN
	///The ID of the tram we control
	var/tram_id = "tram_station"
	///Weakref to the tram piece we control
	var/weakref/tram_ref

/obj/machinery/computer/tram_controls/Initialize()
	. = ..()
	find_tram()

/obj/machinery/computer/tram_controls/attack_hand(mob/user)
	. = ..()
	tgui_interact(user)

/**
 * Finds the tram from the console
 *
 * Locates tram parts in the lift global list after everything is done.
 */
/obj/machinery/computer/tram_controls/proc/find_tram()
	for(var/obj/structure/industrial_lift/tram/central/tram as anything in GLOB.central_trams)
		if(tram.tram_id != tram_id)
			continue
		tram_ref = weakref(tram)
		break

/obj/machinery/computer/tram_controls/tgui_state(mob/user)
	return GLOB.physical_state

/obj/machinery/computer/tram_controls/ui_status(mob/user,/datum/tgui/ui)
	var/obj/structure/industrial_lift/tram/central/tram_part = tram_ref?.resolve()

	if(tram_part?.travelling)
		return UI_CLOSE
	if(!in_range(user, src) && !isobserver(user))
		return UI_CLOSE
	return ..()

/obj/machinery/computer/tram_controls/tgui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TramControl", name)
		ui.open()

/obj/machinery/computer/tram_controls/tgui_data(mob/user)
	var/obj/structure/industrial_lift/tram/central/tram_part = tram_ref?.resolve()
	var/list/data = list()
	data["moving"] = tram_part?.travelling
	data["broken"] = tram_part ? FALSE : TRUE
	var/obj/effect/landmark/tram/current_loc = tram_part?.from_where
	if(current_loc)
		data["tram_location"] = current_loc.name
	return data

/obj/machinery/computer/tram_controls/tgui_static_data(mob/user)
	var/list/data = list()
	data["destinations"] = get_destinations()
	return data

/**
 * Finds the destinations for the tram console gui
 *
 * Pulls tram landmarks from the landmark gobal list
 * and uses those to show the proper icons and destination
 * names for the tram console gui.
 */
/obj/machinery/computer/tram_controls/proc/get_destinations()
	. = list()
	for(var/obj/effect/landmark/tram/destination as anything in GLOB.tram_landmarks)
		if(destination.tram_id != tram_id)
			continue
		var/list/this_destination = list()
		this_destination["name"] = destination.name
		this_destination["dest_icons"] = destination.tgui_icons
		this_destination["id"] = destination.destination_id
		. += list(this_destination)

/obj/machinery/computer/tram_controls/tgui_act(action, params)
	. = ..()
	if (.)
		return

	switch (action)
		if ("send")
			var/obj/effect/landmark/tram/to_where
			for (var/obj/effect/landmark/tram/destination as anything in GLOB.tram_landmarks)
				if(destination.tram_id != tram_id)
					continue
				if(destination.destination_id == params["destination"])
					to_where = destination
					break

			if (!to_where)
				return FALSE

			return try_send_tram(to_where)

/// Attempts to sends the tram to the given destination
/obj/machinery/computer/tram_controls/proc/try_send_tram(obj/effect/landmark/tram/to_where)
	var/obj/structure/industrial_lift/tram/central/tram_part = tram_ref?.resolve()
	if(!tram_part)
		return FALSE
	if(tram_part.travelling)
		return FALSE
	if(tram_part.controls_locked) // someone else started
		return FALSE
	tram_part.tram_travel(to_where)
	return TRUE
