/datum/follow_panel/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "Orbit", "Orbit")
		ui.set_autoupdate(TRUE)
		ui.open()

/datum/follow_panel/tgui_static_data(mob/user)
	var/list/new_mob_pois = SSpoints_of_interest.get_mob_pois(append_dead_role = FALSE)
	var/list/new_other_pois = SSpoints_of_interest.get_other_pois()

	var/list/alive = list()
	var/list/antagonists = list()
	var/list/dead = list()
	var/list/ghosts = list()
	var/list/misc = list()
	var/list/npcs = list()

	for(var/name in new_mob_pois)
		var/list/serialized = list()

		var/mob/mob_poi = new_mob_pois[name]

		var/poi_ref = ref(mob_poi)

		var/number_of_orbiters = length(mob_poi.get_all_orbiters())

		serialized["ref"] = poi_ref
		serialized["full_name"] = name
		if(number_of_orbiters)
			serialized["orbiters"] = number_of_orbiters

		if(isobserver(mob_poi))
			var/mob/observer/ghost/ghost = mob_poi
			if(ghost.client?.holder?.stealthy_ == 1) // 1 is STEALTH_MANUAL, so we have a sneaky boi here
				continue

			ghosts += list(serialized)
			continue

		if(mob_poi.stat == DEAD)
			dead += list(serialized)
			continue

		if(isnull(mob_poi.mind))
			npcs += list(serialized)
			continue

		var/datum/mind/mind = mob_poi.mind

		serialized["name"] = mob_poi.real_name

		if(isliving(mob_poi)) // handles edge cases like blob
			var/mob/living/player = mob_poi
			serialized["health"] = max((player.health / player.maxHealth * 100), 1)
			if(issilicon(player))
				serialized["job"] = player.job
			else
				var/obj/item/card/id/id_card = player.get_id_card()
				serialized["job"] = id_card?.assignment

		var/show_antags = FALSE
		if(isghost(user))
			var/mob/observer/ghost/ghost = user
			if(ghost.has_enabled_antagHUD)
				show_antags = TRUE

		if(!show_antags)
			show_antags = check_rights(R_ADMIN, FALSE, user.client)

		if(show_antags && !isnull(mind.special_role))
			serialized["antag"] = mind.special_role
			serialized["antag_group"] = mind.special_role
			antagonists += list(serialized)
			continue

		alive += list(serialized)

	for(var/name in new_other_pois)
		var/atom/atom_poi = new_other_pois[name]

		misc += list(list(
			"ref" = ref(atom_poi),
			"full_name" = name,
		))

		if(istype(atom_poi, /obj/machinery/power/supermatter))
			var/obj/machinery/power/supermatter/crystal = atom_poi
			misc[length(misc)]["extra"] = "Integrity: [round(crystal.get_integrity())]%"
			continue

		if(istype(atom_poi, /obj/machinery/nuclearbomb))
			var/obj/machinery/nuclearbomb/bomb = atom_poi
			if(bomb.timing)
				misc[length(misc)]["extra"] = "Timer: [bomb.timeleft / 10]s"
			continue

		if(istype(atom_poi, /obj/item/disk/nuclear))
			var/obj/item/disk/nuclear/disk = atom_poi
			var/mob/holder = disk.pulledby || get(disk, /mob)
			misc[length(misc)]["extra"] = "Location: [holder?.real_name || "Unsecured"]"
			continue

	return list(
		"alive" = alive,
		"antagonists" = antagonists,
		"dead" = dead,
		"ghosts" = ghosts,
		"misc" = misc,
		"npcs" = npcs,
	)

/datum/follow_panel/tgui_act(action, params)
	. = ..()

	if(.)
		return

	switch(action)
		if("orbit")
			var/ref = params["ref"]
			var/atom/poi = SSpoints_of_interest.get_poi_atom_by_ref(ref)

			if((ismob(poi) && !SSpoints_of_interest.is_valid_poi(poi)) \
				|| !SSpoints_of_interest.is_valid_poi(poi)
			)
				to_chat(usr, SPAN_NOTICE("That point of interest is no longer valid."))
				return TRUE

			var/mob/observer/ghost/user = usr
			user.ManualFollow(poi)
			return TRUE

		if ("refresh")
			update_static_data(usr)
			return TRUE

/datum/follow_panel/tgui_state(mob/user)
	return GLOB.tgui_always_state
