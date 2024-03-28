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

			if(!length(target.spell_tabs) && (length(target_mob?.ability_master?.ability_objects) || istype(target_mob?.back, /obj/item/rig)))
				update_actions = TRUE

			if(update_actions && num_fires % default_wait == 0)
				set_action_tabs(target, target_mob)

			// Handle the examined turf of the stat panel, if it's been long enough, or if we've generated new images for it
			var/turf/listed_turf = target_mob?.listed_turf
			if(listed_turf && num_fires % default_wait == 0)
				if(target.stat_tab == listed_turf.name || !(listed_turf.name in target.panel_tabs))
					set_turf_examine_tab(target, target_mob)

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

/datum/controller/subsystem/statpanels/proc/set_turf_examine_tab(client/target, mob/target_mob)
	var/list/overrides = list()
	for(var/image/target_image as anything in target.images)
		if(!target_image.loc || target_image.loc.loc != target_mob.listed_turf || !target_image.override)
			continue

		overrides += target_image.loc

	var/list/atoms_to_display = list(target_mob.listed_turf)
	for(var/atom/movable/turf_content as anything in target_mob.listed_turf)
		if(!turf_content.mouse_opacity)
			continue

		if(turf_content.invisibility > target_mob.see_invisible)
			continue

		if(turf_content in overrides)
			continue

		atoms_to_display += turf_content

	/// Set the atoms we're meant to display
	var/datum/object_window_info/obj_window = target.obj_window
	obj_window.atoms_to_show = atoms_to_display
	START_PROCESSING(SSobj_tab_items, obj_window)
	refresh_client_obj_view(target)

/datum/controller/subsystem/statpanels/proc/refresh_client_obj_view(client/refresh)
	var/list/turf_items = return_object_images(refresh)
	if(!length(turf_items) || isnull(refresh.mob?.listed_turf))
		return

	refresh.stat_panel.send_message("update_listedturf", turf_items)

#define OBJ_IMAGE_LOADING "statpanels obj loading temporary"

/**
 * Returns a list of generated images in format `list(list(object_name, object_ref, loaded_image), ...)`,
 * handles queueing generation to `/object_window_info`.
 */
/datum/controller/subsystem/statpanels/proc/return_object_images(client/load_from)
	// You might be inclined to think that this is a waste of cpu time, since we
	// A: Double iterate over atoms in the build case, or
	// B: Generate these lists over and over in the refresh case
	// It's really not very hot. The hot portion of this code is genuinely mostly in the image generation
	// So it's ok to pay a performance cost for cleanliness here

	// No turf? go away
	if(!load_from.mob?.listed_turf)
		return list()

	var/datum/object_window_info/obj_window = load_from.obj_window
	var/list/already_seen = obj_window.atoms_to_images
	var/list/to_make = obj_window.atoms_to_imagify
	var/list/turf_items = list()
	for(var/atom/turf_item as anything in obj_window.atoms_to_show)
		// First, we fill up the list of refs to display
		// If we already have one, just use that
		var/existing_image = already_seen[turf_item]
		if(existing_image == OBJ_IMAGE_LOADING)
			continue

		// We already have it. Success!
		if(existing_image)
			turf_items[++turf_items.len] = list("[turf_item.name]", ref(turf_item), existing_image)
			continue

		// Now, we're gonna queue image generation out of those refs
		to_make += turf_item
		already_seen[turf_item] = OBJ_IMAGE_LOADING
		obj_window.register_signal(turf_item, SIGNAL_QDELETING, nameof(/datum/object_window_info/proc/viewing_atom_deleted)) // we reset cache if anything in it gets deleted

	return turf_items

#undef OBJ_IMAGE_LOADING

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

	if(!length(target.spell_tabs) && (length(target_mob?.ability_master?.ability_objects) || istype(target_mob?.back, /obj/item/rig)))
		update_actions = TRUE

	if(update_actions)
		set_action_tabs(target, target_mob)
		return TRUE

	// Handle turfs

	if(target_mob?.listed_turf)
		if(!target_mob.TurfAdjacent(target_mob.listed_turf))
			target_mob.set_listed_turf(null)

		else if(target.stat_tab == target_mob?.listed_turf.name || !(target_mob?.listed_turf.name in target.panel_tabs))
			set_turf_examine_tab(target, target_mob)
			return TRUE

	if(!target.holder)
		return FALSE

	if(target.stat_tab == "MC")
		set_MC_tab(target)
		return TRUE
