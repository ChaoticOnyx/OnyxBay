/datum/event_window
	var/datum/event/event
	var/datum/admins/holder
	var/datum/tgui/ui

/datum/event_window/New(datum/admins/holder, datum/event/event)
	ASSERT(holder)
	ASSERT(event)

	for(var/datum/event_window/W in holder.events_windows)
		if(W.event.id == event.id)
			qdel(src)
			return

	src.holder = holder
	src.event = event
	src.holder.events_windows += src

	tgui_interact(holder.owner.mob)

/datum/event_window/Destroy()
	holder?.events_windows -= src
	holder = null
	event = null

	if(ui)
		ui.close()
		ui = null

	. = ..()

/datum/event_window/tgui_interact(mob/user, datum/tgui/ui)
	src.ui = SStgui.try_update_ui(user, src, ui)

	if(!src.ui)
		src.ui = new(user, src, "EventWindow", "Event Window")
		src.ui.set_autoupdate(TRUE)
		src.ui.open()

/datum/event_window/tgui_data(mob/user)
	var/list/data = list(
		"event" = list(
			"id" = event.id,
			"name" = event.name,
			"description" = event.get_description(),
			"mtth" = event.get_mtth(),
			"chance" = (SSstoryteller.character ? SSstoryteller.character.calc_event_chance(event) : event.calc_chance()),
			"waiting_option" = event._waiting_option,
			"fire_conditions" = event.check_conditions(),
			"conditions_description" = event.get_conditions_description(),
			"options" = list()
		),
	)

	for(var/datum/event_option/O in event.options)
		data["event"]["options"] += list(list(
			"id" = O.id,
			"name" = O.name,
			"description" = O.get_description(),
			"event_id" = O.event_id,
			"weight" = O.get_weight()
		))

	return data

/datum/event_window/tgui_act(action, params)
	. = ..()

	if(.)
		return

	if(!usr.has_admin_rights())
		return TRUE

	switch(action)
		if("choose")
			ASSERT(params["option_id"])
			ASSERT(params["event_id"])

			var/option_id = params["option_id"]
			var/event_id = params["event_id"]

			var/datum/event/E = SSevents.total_events[event_id]

			if(!E._waiting_option)
				CRASH("invalid state")

			for(var/datum/event_option/O in E.options)
				if(O.id == option_id)
					O.choose()
					break

			qdel(src)
			return TRUE
		if("close")
			qdel(src)

			return TRUE

/datum/event_window/ui_close(mob/user)
	if(!QDELETED(src))
		qdel(src)

/datum/event_window/tgui_state(mob/user)
	return GLOB.tgui_admin_state
