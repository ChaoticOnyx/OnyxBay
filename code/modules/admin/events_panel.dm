/datum/events_panel/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "EventsPanel", "Events Panel")
		ui.set_autoupdate(TRUE)
		ui.open()

/datum/events_panel/tgui_data(mob/user)
	var/list/data = list(
		"events" = list(),
		"paused" = SSevents.paused,
		"presets" = list()
	)

	for(var/preset_name in SSevents.event_presets)
		data["presets"] += preset_name

	for(var/datum/event/E  in SSevents.scheduled_events)
		if(E.triggered_only || E.fire_only_once && E.fired && !E._waiting_option)
			continue

		var/list/event_data = list(
			"id" = E.id,
			"name" = E.name,
			"description" = E.get_description(),
			"mtth" = E.get_mtth(),
			"chance" = (SSstoryteller.character ? SSstoryteller.character.calc_event_chance(E) : E.calc_chance()),
			"waiting_option" = E._waiting_option,
			"fire_conditions" = E.check_conditions(),
			"conditions_description" = E.get_conditions_description(),
			"disabled" = SSevents.disabled_events[E.id],
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
			ASSERT(params["event_id"])

			var/event_id = params["event_id"]
			var/datum/event/E = SSevents.total_events[event_id]

			new /datum/event_window(usr.client.holder, E)

			return TRUE
		if("force")
			ASSERT(params["event_id"])

			var/event_id = params["event_id"]
			var/datum/event/E = SSevents.total_events[event_id]

			E.fire()

			return TRUE
		if("toggle_pause")
			SSevents.paused = !SSevents.paused
			log_and_message_admins("[key_name(usr)] [SSevents.paused ? "paused" : "resumed"] events.")

			return TRUE
		if("toggle_disable")
			ASSERT(params["event_id"])

			var/event_id = params["event_id"]
			SSevents.disabled_events[event_id] = !SSevents.disabled_events[event_id]

			return TRUE
		if("apply_preset")
			ASSERT(params["preset_name"])

			SSevents.apply_events_preset(params["preset_name"])

			return TRUE
		if("enable_all_events")
			SSevents.enable_all_events()

			return TRUE
		if("disable_all_events")
			SSevents.disable_all_events()

			return TRUE

/datum/events_panel/tgui_state(mob/user)
	return GLOB.tgui_admin_state

/datum/admins/proc/events_panel()
	set category = "Admin"
	set name = "Events Panel"

	usr.client.holder.events_panel.tgui_interact(usr, null)
