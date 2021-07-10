SUBSYSTEM_DEF(storyteller)
	name = "Storyteller"
	wait = 20 // changes with round story progress
	priority = SS_PRIORITY_STORYTELLER
	init_order = SS_INIT_STORYTELLER
	runlevels = RUNLEVEL_GAME

	var/__was_character_choosen_by_random = FALSE

	var/__storyteller_tick = -1 // updates on every fire
	var/datum/storyteller_character/__character = null

	var/list/__metrics = new
	var/list/__triggers = new

	var/list/__ui_tabs = list("StorytellerCPCharacterTab", "StorytellerCPMetricsTab", "StorytellerCPTriggersTab")
	var/list/__ckey_to_ui_data = new

/datum/controller/subsystem/storyteller/Initialize(timeofday)
	if (config.storyteller)
		return ..()
	flags = SS_NO_FIRE

// called on round setup, after players spawn and mode setup
/datum/controller/subsystem/storyteller/proc/setup()
	if (!config.storyteller)
		return
	_log_debug("Setup called")

	__create_character()
	__create_all_metrics()
	__create_all_triggers()
	_log_debug("Chosen character is '[__character]'")

	_log_debug("Process round start")
	var/time_to_first_cycle = __character.process_round_start()
	ASSERT(time_to_first_cycle)
	wait = time_to_first_cycle

// called in the round end
/datum/controller/subsystem/storyteller/proc/collect_statistics()
	if (!config.storyteller)
		return
	_log_debug("ROUND STATISTICS")
	for (var/M in __metrics)
		var/storyteller_metric/metric = __metrics[M]
		metric.print_statistics()
	_log_debug("ROUND STATISTICS END")

/datum/controller/subsystem/storyteller/fire(resumed = FALSE)
	if(__storyteller_tick == -1) // first tick is called with default 'wait', we need our tick with our value of 'wait'
		__storyteller_tick = 0
		return
	
	ASSERT(evacuation_controller)
	if(evacuation_controller.is_evacuating())
		_log_debug("Skip cycle due to evacuation. The next try is scheduled for 1 minute")
		wait = 1 MINUTE
		return

	__storyteller_tick++
	_log_debug("Process new cycle start")
	var/time_to_next_cycle = __character.process_new_cycle_start()
	ASSERT(time_to_next_cycle)
	wait = time_to_next_cycle

/datum/controller/subsystem/storyteller/proc/__get_params_for_ui(current_tab)
	var/list/data = new
	
	switch (current_tab)
		if ("StorytellerCPCharacterTab")
			data["character"] = __character ? __character.get_params_for_ui() : null

		if ("StorytellerCPMetricsTab")
			var/list/metrics_data = new
			for (var/type in __metrics)
				var/storyteller_metric/metric = __metrics[type]
				metrics_data[type] = metric.get_params_for_ui()
			data["metrics"] = metrics_data

		if ("StorytellerCPTriggersTab")
			var/list/triggers_data = new
			for (var/type in __triggers)
				var/storyteller_trigger/trigger = __triggers[type]
				if (trigger.can_be_invoked())
					triggers_data[type] = trigger.get_params_for_ui()
			data["triggers"] = triggers_data
		
		else crash_with("Bad tab key")
	
	return data

/datum/controller/subsystem/storyteller/proc/open_control_panel(mob/user, drop_data = TRUE)
	if (!config.storyteller)
		return
	ASSERT(user)

	if (drop_data)
		__ckey_to_ui_data[user.ckey] = list()
	var/data = __ckey_to_ui_data[user.ckey]
	if("current_tab" in data)
		data["storyteller"] = __get_params_for_ui(data["current_tab"])
	data["pregame"] = (GAME_STATE < RUNLEVEL_GAME)

	var/ui_key = "storyteller_control_panel"
	var/datum/nanoui/ui = SSnano.try_update_ui(user, src, ui_key, null, data, force_open=FALSE)
	if(!ui)
		ui = new (user, src, ui_key, "storyteller_control_panel.tmpl", "Storyteller Control Panel", 500, 600, state=GLOB.interactive_state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(0)

/datum/controller/subsystem/storyteller/Topic(href, href_list)
	var/mob/user = usr
	if (!user)
		return

	if(!check_rights(R_ADMIN))
		log_and_message_admins("[key_name(usr)] invoked Storyteller Control Panel topic without Admin rights.")
		return

	if (href_list["change_tab"])
		var/new_tab = href_list["change_tab"]
		ASSERT(new_tab in __ui_tabs)
		__ckey_to_ui_data[user.ckey]["current_tab"] = new_tab
		open_control_panel(user, drop_data = FALSE)

	else if (href_list["update_metric"])
		var/metric_type = text2path(href_list["update_metric"])
		ASSERT(ispath(metric_type, /storyteller_metric))
		var/storyteller_metric/metric = get_metric(metric_type);
		metric.update()
		open_control_panel(user, drop_data = FALSE)

	else if (href_list["view_metric_statistics"])
		var/metric_type = text2path(href_list["view_metric_statistics"])
		ASSERT(ispath(metric_type, /storyteller_metric))
		var/storyteller_metric/metric = get_metric(metric_type)
		metric.print_statistics(user)

	else if (href_list["invoke_trigger"])
		var/trigger_type = text2path(href_list["invoke_trigger"])
		ASSERT(ispath(trigger_type, /storyteller_trigger))
		var/result = run_trigger(trigger_type)
		to_chat(user, SPAN_WARNING("Trigger '[trigger_type]' was [result ? " completed successfuly!" : " failed!"]"))
		open_control_panel(user, drop_data = FALSE)

	return 0

/datum/controller/subsystem/storyteller/proc/get_metric(type)
	ASSERT(type in __metrics)
	return __metrics[type]

/datum/controller/subsystem/storyteller/proc/run_trigger(type)
	ASSERT(type in __triggers)
	var/storyteller_trigger/trigger = __triggers[type]
	return trigger.invoke()

/datum/controller/subsystem/storyteller/proc/get_tick()
	return __storyteller_tick

/datum/controller/subsystem/storyteller/proc/was_character_choosen_with_random()
	return __was_character_choosen_by_random

/datum/controller/subsystem/storyteller/proc/__create_character()
	__character = new /datum/storyteller_character/support

/datum/controller/subsystem/storyteller/proc/__create_all_metrics()
	for (var/type in subtypesof(/storyteller_metric))
		__metrics[type] = new type

/datum/controller/subsystem/storyteller/proc/__create_all_triggers()
	for (var/type in subtypesof(/storyteller_trigger))
		__triggers[type] = new type

/datum/controller/subsystem/storyteller/proc/get_character()
    return __character
