SUBSYSTEM_DEF(statpanels)
	name = "Stat Panels"
	wait = 4
	init_order = SS_INIT_STATPANELS
	priority = SS_PRIORITY_STATPANELS
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY
	flags = SS_NO_INIT | SS_TICKER

	/// List of `/client` to send updates to.
	var/list/client/current_run = list()
	/// List of pre-generated Status tab data.
	var/list/global_data
	/// List of pre-generated MC tsb data.
	var/list/mc_data

	///how many subsystem fires between most tab updates
	var/default_wait = 10
	///how many subsystem fires between updates of the status tab
	var/status_wait = 2
	///how many subsystem fires between updates of the MC tab
	var/mc_wait = 5
	///how many full runs this subsystem has completed. used for variable rate refreshes.
	var/num_fires = 0

/datum/controller/subsystem/statpanels/fire(resumed = FALSE)
	if(!resumed)
		num_fires++

		global_data = list(
			"Map: [GLOB.using_map?.name || "Loading..."]",
			"Round ID: [game_id || "NULL"]",
			"Server Time: [time2text(world.timeofday, "YYYY-MM-DD hh:mm:ss")]",
			"Round Time: [roundduration2text()]",
			"Station Time: [stationtime2text()]",
			"Station Date: [stationdate2text()]",
			"",
		)

		if(evacuation_controller.has_eta())
			var/eta_status = evacuation_controller.get_status_panel_eta()
			if(length(eta_status))
				global_data += "[eta_status]"

		current_run = GLOB.clients.Copy()
		mc_data = null

	var/list/currentrun = src.current_run
	while(length(currentrun))
		var/client/target = currentrun[length(currentrun)]
		currentrun.len--

		if(!target.stat_panel.is_ready())
			continue

		if(target.stat_tab == "Status" && num_fires % status_wait == 0)
			set_status_tab(target)

		if(!target.holder)
			target.stat_panel.send_message("remove_admin_tabs")
		else
			target.stat_panel.send_message("update_split_admin_tabs", target.get_preference_value("SPLIT_TABS") == GLOB.PREF_YES)

			if(!("MC" in target.panel_tabs))
				target.stat_panel.send_message("add_admin_tabs")

			if(target.stat_tab == "MC" && ((num_fires % mc_wait == 0) || target.get_preference_value("FAST_REFRESH") == GLOB.PREF_YES))
				set_MC_tab(target)

		if(target.mob)
			var/mob/target_mob = target.mob

			// Handle the action panels of the stat panel

			var/update_actions = FALSE

			if(target.stat_tab in target.spell_tabs)
				update_actions = TRUE

			if(istype(target_mob?.back, /obj/item/rig))
				update_actions = TRUE

			if(!length(target.spell_tabs) && length(target_mob?.ability_master?.ability_objects))
				update_actions = TRUE

			if(update_actions && num_fires % default_wait == 0)
				set_action_tabs(target, target_mob)

		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/statpanels/proc/set_status_tab(client/target)
	if(!global_data)//statbrowser hasnt fired yet and we were called from immediate_send_stat_data()
		return

	target.stat_panel.send_message("update_stat", list(
		"global_data" = global_data,
		"other_str" = target.mob?.get_status_tab_items(),
	))

/datum/controller/subsystem/statpanels/proc/set_MC_tab(client/target)
	var/turf/eye_turf = get_turf(target.eye)
	var/coord_entry = isnull(eye_turf) ? "unknown location" : "([eye_turf.x], [eye_turf.y], [eye_turf.z]) [eye_turf]"
	if(!mc_data)
		generate_mc_data()
	target.stat_panel.send_message("update_mc", list("mc_data" = mc_data, "coord_entry" = coord_entry))

/// Set up the various action tabs.
/datum/controller/subsystem/statpanels/proc/set_action_tabs(client/target, mob/target_mob)
	var/list/actions = target_mob.get_actions_for_statpanel()
	target.spell_tabs.Cut()

	for(var/action_data in actions)
		target.spell_tabs |= action_data[1]

	target.stat_panel.send_message("update_spells", list(spell_tabs = target.spell_tabs, actions = actions))

/datum/controller/subsystem/statpanels/proc/generate_mc_data()
	mc_data = list(
		list("CPU:", world.cpu),
		list("Instances:", "[num2text(world.contents.len, 10)]"),
		list("World Time:", "[world.time]"),
		list("Globals:", GLOB.stat_entry(), ref(GLOB)),
		list("Byond:", "(FPS:[world.fps]) (TickCount:[world.time/world.tick_lag]) (TickDrift:[round(Master.tickdrift,1)]([round((Master.tickdrift/(world.time/world.tick_lag))*100,0.1)]%))"),
		list("Master Controller:", Master?.stat_entry() || "ERROR", ref(Master)),
		list("Failsafe Controller:", Failsafe?.stat_entry() || "ERROR", ref(Failsafe)),
		list("","")
	)
	for(var/datum/controller/subsystem/sub_system as anything in Master.subsystems)
		mc_data[++mc_data.len] = list("\[[sub_system.state_letter()]][sub_system.name]", sub_system.stat_entry(), ref(sub_system))

/// Immediately updates the active statpanel tab of the target client.
/datum/controller/subsystem/statpanels/proc/immediate_send_stat_data(client/target)
	if(!target.stat_panel.is_ready())
		return FALSE

	if(target.stat_tab == "Status")
		set_status_tab(target)
		return TRUE

	var/mob/target_mob = target.mob

	// Handle actions

	var/update_actions = FALSE
	if(target.stat_tab in target.spell_tabs)
		update_actions = TRUE

	if(istype(target_mob?.back, /obj/item/rig))
		update_actions = TRUE

	if(!length(target.spell_tabs) && length(target_mob?.ability_master?.ability_objects))
		update_actions = TRUE

	if(update_actions)
		set_action_tabs(target, target_mob)
		return TRUE

	if(!target.holder)
		return FALSE

	if(target.stat_tab == "MC")
		set_MC_tab(target)
		return TRUE
