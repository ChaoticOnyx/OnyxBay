#define SHIPINFO 0
#define STARMAP 1

/datum/asset/simple/starmap
	assets = list(
		"space.png" = 'icons/space.png')

/obj/machinery/computer/ship/navigation
	name = "\improper FTL Navigation console"
	desc = "A computer which can interface with the Thirring Drive to allow the ship to travel vast distances in space."
	icon_screen = "ftl"
	var/datum/star_system/selected_system = null
	var/screen = STARMAP
	var/can_control_ship = TRUE

/obj/machinery/computer/ship/navigation/public
	name = "Starmap Console"
	desc = "A computer which shows the current position of the ship in the universe."
	can_control_ship = FALSE

/obj/machinery/computer/ship/navigation/attack_hand(mob/user)
	tgui_interact(user)

/obj/machinery/computer/ship/navigation/tgui_interact(mob/user, datum/tgui/ui)
	if(!linked)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		var/datum/asset/assets = get_asset_datum(/datum/asset/simple/starmap)
		assets.send(user.client)
		ui = new(user, src, "Starmap")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/ship/navigation/tgui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	if(!linked)
		return

	switch(action)
		if("map")
			screen = STARMAP
		if("shipinf")
			screen = SHIPINFO

		if("jump")
			if(linked.ftl_drive.lockout)
				to_chat(usr, SPAN_WARNING("[icon2html(src, viewers(src))] Unable to comply. Invalid authkey to unlock remove override code."))
				return TRUE

			linked.ftl_drive.initiate_jump(selected_system)
			return TRUE
		if("cancel_jump")
			if(linked.ftl_drive.lockout)
				to_chat(usr, SPAN_WARNING("[icon2html(src, viewers(src))] Unable to comply. Invalid authkey to unlock remove override code."))
				return TRUE

			if(linked.ftl_drive.cancel_shunt())
				linked.stop_relay(SOUND_CHANNEL_IMP_SHIP_ALERT)
				linked.relay('sound/effects/ship/general_quarters.ogg', channel = SOUND_CHANNEL_IMP_SHIP_ALERT)
				return TRUE

		if("select_system")
			var/datum/star_system/target = locate(params["star_id"])
			if(!istype(target))
				return
			selected_system = target
			screen = SHIPINFO
			return TRUE

/obj/machinery/computer/ship/navigation/tgui_data(mob/user)
	if(!has_overmap())
		return

	var/list/data = list()
	var/list/info = SSstar_system.ships[linked]
	var/list/lines = list()
	if(!info?.len)
		return data

	var/datum/star_system/current_system = info["current_system"]
	//SSstar_system.update_pos(linked) FUCK THIS SHIT.
	if(linked.ftl_drive)
		if(istype(linked.ftl_drive))
			data["ftl_progress"] = linked.ftl_drive.progress
	data["travelling"] = FALSE
	switch(screen)
		if(0)
			var/datum/star_system/target_system = info["target_system"]
			data["star_id"] = "\ref[selected_system]"
			data["star_name"] = selected_system?.name
			data["alignment"] = capitalize(selected_system?.alignment)
			if(info["current_system"])
				var/datum/star_system/curr = info["current_system"]
				data["star_dist"] = curr.dist(selected_system)
				data["can_jump"] = current_system.dist(selected_system) < linked.ftl_drive?.max_range && LAZYFIND(current_system.adjacency_list, selected_system.name)
				if(return_jump_check(selected_system))
					data["can_jump"] = TRUE
				if(!can_control_ship)
					data["can_jump"] = FALSE
					data["can_cancel"] = FALSE
				data["in_transit"] = FALSE
			if(target_system)
				data["in_transit"] = TRUE
				var/datum/star_system/last_system = info["last_system"]
				data["from_star_id"] = "\ref[last_system]"
				data["from_star_name"] = last_system.name
				data["to_star_id"] = "\ref[target_system]"
				data["to_star_name"] = target_system.name
				data["time_left"] = max(0, (info["to_time"] - world.time) / 1 MINUTES)

		if(1)
			var/list/systems_list = list()
			if(info["current_system"])
				var/datum/star_system/curr = info["current_system"]
				data["focus_x"] = curr.x
				data["focus_y"] = curr.y
			else
				data["focus_x"] = info["x"]
				data["focus_y"] = info["y"]
			for(var/datum/star_system/system in SSstar_system.systems) // for each system
				if(system.hidden)
					continue

				var/list/system_list = list()
				system_list["name"] = system.name
				if(current_system)
					system_list["in_range"] = is_in_range(current_system, system) || return_jump_check(system)
					system_list["distance"] = "[current_system.dist(system) > 0 ? "[current_system.dist(system)] LY" : "You are here."]"
				else
					system_list["in_range"] = 0
				system_list["x"] = system.x
				system_list["y"] = system.y
				system_list["star_id"] = "\ref[system]"
				system_list["is_current"] = (system == current_system)
				system_list["alignment"] = system.alignment
				system_list["visited"] = is_visited(system)
				system_list["hidden"] = FALSE
				var/label = ""
				if(system.is_hypergate)
					label += " HYPERGATE"
				if(system.is_capital && !label)
					label += "CAPITAL"
				if(system.trader)
					label += " [system.trader.name]"
				if(system.mission_sector)
					label += " OCCUPIED"
				if(system.objective_sector)
					label += " MISSION"
				system_list["label"] = label
				for(var/thename in system.adjacency_list) //Draw the lines joining our systems
					var/datum/star_system/sys = SSstar_system.system_by_id(thename)
					if(!sys)
						message_admins("[thename] exists in a system adjacency list, but does not exist. Go create a starsystem datum for it.")
						continue

					var/is_wormhole = (LAZYFIND(sys.wormhole_connections, system.name) || LAZYFIND(system.wormhole_connections, sys.name))
					var/is_bidirectional = (LAZYFIND(sys.adjacency_list, system.name) && LAZYFIND(system.adjacency_list, sys.name))
					if((!is_bidirectional && system != current_system) || sys.hidden)
						continue

					var/thecolour = "#FFFFFF"
					var/opacity = 1
					if(LAZYFIND(current_system?.adjacency_list, thename))
						if(is_wormhole)
							thecolour = "#BA55D3"
							opacity = 0.85
					var/list/line = list()
					var/dx = sys.x - system.x
					var/dy = sys.y - system.y
					var/len = sqrt(abs(dx * dx + dy * dy))
					var/angle = 90 - ATAN2(dy, dx)
					line["x"] = system.x
					line["y"] = system.y
					line["len"] = len
					line["angle"] = -angle
					line["colour"] = thecolour
					line["priority"] = (sys != current_system) ? 1 : 2
					line["opacity"] = opacity
					lines[++lines.len] = line
				systems_list[++systems_list.len] = system_list
			if(info["to_time"] > 0)
				data["freepointer_x"] = info["x"]
				data["freepointer_y"] = info["y"]
				var/datum/star_system/last = info["last_system"]
				var/datum/star_system/targ = info["target_system"]
				var/dist = last.dist(targ)
				var/dx = targ.x - last.x
				var/dy = targ.y - last.y
				data["freepointer_cos"] = dx / dist
				data["freepointer_sin"] = dy / dist
				data["travelling"] = TRUE
			data["star_systems"] = systems_list
			data["lines"] = lines

	data["screen"] = screen

	return data

/obj/machinery/computer/ship/navigation/proc/is_in_range(datum/star_system/current_system, datum/star_system/system)
	return LAZYFIND(current_system?.adjacency_list, system?.name)

/obj/machinery/computer/ship/navigation/proc/is_visited(datum/star_system/system)
	return system.visited

/obj/machinery/computer/ship/navigation/proc/return_jump_check(datum/star_system/system)
	return FALSE

#undef SHIPINFO
#undef STARMAP
