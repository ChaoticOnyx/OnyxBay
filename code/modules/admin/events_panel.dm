/datum/events_panel/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "EventsPanel", "Events Panel")
		ui.set_autoupdate(TRUE)
		ui.open()

/datum/events_panel/tgui_data(mob/user)
	var/list/data = list(
		"events" = list(),
	)

	for(var/datum/event/E  in SSevents.scheduled_events)
		if(E.triggered_only || E.fire_only_once && E.fired)
			continue

		var/list/event_data = list(
			"id" = E.id,
			"name" = E.name,
			"description" = E.get_description(),
			"mtth" = E.get_mtth(),
			"chance" = E.calc_chance(),
			"waiting_option" = E._waiting_option,
			"fire_conditions" = E.check_conditions(),
			"conditions_description" = E.get_conditions_description(),
			"options" = list()
		)

		for(var/datum/event_option/O in E.options)
			event_data["options"] += list(list(
				"id" = O.id,
				"name" = O.name,
				"description" = O.get_description(),
				"event_id" = O.event_id,
				"weight" = O.get_weight()
			))
		
		data["events"] += list(event_data)

	return data

/datum/events_panel/tgui_act(action, params)
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

			for(var/datum/event_option/O in E.options)
				if(O.id == option_id)
					O.choose()
					break

			return TRUE
		if("force")
			ASSERT(params["event_id"])

			var/event_id = params["event_id"]

			var/datum/event/E = SSevents.total_events[event_id]
			E.fire()

/datum/events_panel/tgui_state(mob/user)
	return GLOB.tgui_admin_state

/datum/admins/proc/events_panel()
	set category = "Admin"
	set name = "Events Panel"

	if (!istype(src, /datum/admins))
		src = usr.client.holder

	events_panel.tgui_interact(usr, null)
