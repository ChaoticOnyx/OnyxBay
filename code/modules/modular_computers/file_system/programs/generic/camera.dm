#define DEFAULT_CAMERA_MAP_SIZE 15

#define CAMERA_VIEW_MODE_SINGLE "single"
#define CAMERA_VIEW_MODE_MAP "map"
#define CAMERA_VIEW_MODE_MULTI "multi"

#define CAMERA_LAYOUT_1X2 "1x2"
#define CAMERA_LAYOUT_2X2 "2x2"
#define CAMERA_LAYOUT_2X3 "2x3"

#define CAMERA_MULTI_SLOT_COUNT 6
#define CAMERA_VIEWPORT_COUNT 7
#define CAMERA_SINGLE_VIEW_SLOT 7

// Returns which access is relevant to passed network. Used by the program.
/proc/get_camera_access(network)
	if(!network)
		return 0
	. = GLOB.using_map.get_network_access(network)
	if(.)
		return

	switch(network)
		if(NETWORK_ENGINEERING, NETWORK_ALARM_ATMOS, NETWORK_ALARM_CAMERA, NETWORK_ALARM_FIRE, NETWORK_ALARM_POWER)
			return access_engine
		if(NETWORK_CRESCENT, NETWORK_ERT)
			return access_cent_specops
		if(NETWORK_MEDICAL)
			return access_medical
		if(NETWORK_MINE, NETWORK_APPARAT_VORON)
			return access_mailsorting // Cargo office - all cargo staff should have access here.
		if(NETWORK_RESEARCH)
			return access_research
		if(NETWORK_THUNDER)
			return 0

	return access_security // Default for all other networks

/client
	/// Assoc list with all active temporary maps shown in UI windows.
	var/list/screen_maps = list()

/atom/movable
	/// Temporary map id assigned to this movable when used inside a map control.
	var/assigned_map
	/// Whether object should be qdel'd when map is cleared.
	var/del_on_map_removal = TRUE

/atom/movable/screen/map_view
	name = "map view"
	layer = DEFAULT_PLANE
	plane = DEFAULT_PLANE
	// Keep original planes of vis_contents atoms.
	vis_flags = VIS_INHERIT_PLANE | VIS_INHERIT_ID

/atom/movable/screen/background
	name = "background"
	icon = 'icons/hud/screen.dmi'
	icon_state = "blank"
	layer = DEFAULT_PLANE
	plane = DEFAULT_PLANE

/atom/movable/screen/camera_skybox
	name = "camera skybox"
	mouse_opacity = MOUSE_OPACITY_UNCLICKABLE
	appearance_flags = PASS_MOUSE | NO_CLIENT_COLOR | KEEP_TOGETHER
	layer = SKYBOX_LAYER
	plane = SKYBOX_PLANE
	alpha = 0

/atom/movable/screen/camera_skybox/proc/refresh_appearance()
	ClearOverlays()
	icon = SSskybox.BGpath
	icon_state = "background_[SSskybox.BGstate]"
	color = (SSskybox.BGstate == "dyable") ? SSskybox.BGcolor : null

	var/matrix/rotation = matrix()
	rotation.TurnTo(SSskybox.BGrot)
	transform = rotation

	if(SSskybox.use_stars)
		var/image/stars = image(SSskybox.star_path, src, SSskybox.star_state)
		stars.plane = DUST_PLANE
		stars.layer = DUST_LAYER
		stars.appearance_flags = RESET_COLOR
		AddOverlays(stars)

/atom/movable/screen/camera_skybox/proc/update_view(turf/focus, size_x, size_y)
	if(!assigned_map)
		return

	if(!focus)
		screen_loc = "[assigned_map]:CENTER"
		return

	var/view_maxx = max(1, ceil(size_x / 2))
	var/view_maxy = max(1, ceil(size_y / 2))

	var/normalized_x = 0
	var/normalized_y = 0
	var/usable_world_x = max(1, world.maxx - (TRANSITION_EDGE * 2))
	var/usable_world_y = max(1, world.maxy - (TRANSITION_EDGE * 2))

	normalized_x = (focus.x - TRANSITION_EDGE) / usable_world_x
	normalized_y = (focus.y - TRANSITION_EDGE) / usable_world_y
	normalized_x = min(max(normalized_x, 0), 1)
	normalized_y = min(max(normalized_y, 0), 1)

	var/result_x = round(view_maxx * WORLD_ICON_SIZE * normalized_x)
	var/result_y = round(view_maxy * WORLD_ICON_SIZE * normalized_y)
	var/max_offset = abs(size_x - size_y) * WORLD_ICON_SIZE

	if(view_maxx > view_maxy)
		result_x = min(max_offset, result_x)
	if(view_maxy > view_maxx)
		result_y = min(max_offset, result_y)

	screen_loc = "[assigned_map]:CENTER:[-result_x],CENTER:[-result_y]"

/atom/movable/screen/map_render_source
	name = "map render source"
	mouse_opacity = MOUSE_OPACITY_UNCLICKABLE
	appearance_flags = PASS_MOUSE | NO_CLIENT_COLOR | KEEP_TOGETHER
	layer = DEFAULT_PLANE
	plane = PREVIEW_PLANE

/atom/movable/screen/map_render_source/lighting_overlay
	name = "camera lighting overlay"
	blend_mode = BLEND_MULTIPLY
	layer = LIGHTING_LAYER
	plane = PREVIEW_PLANE

/atom/movable/screen/proc/set_position(x, y, px = 0, py = 0)
	if(assigned_map)
		screen_loc = "[assigned_map]:[x]:[px],[y]:[py]"
	else
		screen_loc = "[x]:[px],[y]:[py]"

/atom/movable/screen/proc/fill_rect(x1, y1, x2, y2)
	if(assigned_map)
		screen_loc = "[assigned_map]:[x1],[y1] to [x2],[y2]"
	else
		screen_loc = "[x1],[y1] to [x2],[y2]"

/client/proc/register_map_obj(atom/movable/map_obj)
	if(!map_obj?.assigned_map)
		CRASH("Can't register [map_obj] without assigned_map.")
	if(!screen_maps[map_obj.assigned_map])
		screen_maps[map_obj.assigned_map] = list()
	var/list/screen_map = screen_maps[map_obj.assigned_map]
	if(!(map_obj in screen_map))
		screen_map += map_obj
	if(!(map_obj in screen))
		screen += map_obj

/client/proc/clear_map(map_name)
	if(!map_name || !(map_name in screen_maps))
		return FALSE

	var/list/screen_map = screen_maps[map_name]
	for(var/atom/movable/map_obj as anything in screen_map.Copy())
		screen_map -= map_obj
		screen -= map_obj
		if(map_obj.del_on_map_removal)
			qdel(map_obj)

	screen_maps -= map_name
	return TRUE

/client/proc/clear_all_maps()
	for(var/map_name in screen_maps.Copy())
		clear_map(map_name)

/datum/computer_file/program/camera_monitor
	filename = "cammon"
	filedesc = "Camera Monitoring"
	nanomodule_path = /datum/nano_module/camera_monitor
	program_icon_state = "cameras"
	program_key_state = "generic_key"
	program_menu_icon = "search"
	program_light_color = "#00B000"
	extended_desc = "This program allows remote access to the camera system. Some camera networks may have additional access requirements."
	size = 12
	category = PROG_MONITOR
	available_on_ntnet = 1
	requires_ntnet = 1
	use_tgui = TRUE

/datum/nano_module/camera_monitor
	name = "Camera Monitoring program"
	var/obj/machinery/camera/current_camera = null
	var/current_network = null

	var/view_mode = CAMERA_VIEW_MODE_SINGLE
	var/multi_layout = CAMERA_LAYOUT_2X2
	var/list/multi_slots = list(null, null, null, null, null, null)
	var/active_slot = 1

	/// Per-slot map refs and screen objects for camera viewport rendering.
	var/list/map_refs = list(null, null, null, null, null, null, null)
	var/list/cam_screens = list(null, null, null, null, null, null, null)
	var/list/cam_skyboxes = list(null, null, null, null, null, null, null)
	/// Per-user per-slot renderer instances: user_ref => list(slot => list(renderer...))
	var/list/user_plane_masters = list()
	var/list/cam_backgrounds = list(null, null, null, null, null, null, null)
	var/list/last_camera_refs = list(null, null, null, null, null, null, null)
	var/list/last_camera_turfs = list(null, null, null, null, null, null, null)
	var/list/concurrent_users = list()
	var/list/holomap_cache = list()

/datum/nano_module/camera_monitor/New(host, topic_manager)
	. = ..()

	// Keep all per-slot lists dense to avoid numeric index runtimes.
	multi_slots = list(null, null, null, null, null, null)
	map_refs = list(null, null, null, null, null, null, null)
	cam_screens = list(null, null, null, null, null, null, null)
	cam_skyboxes = list(null, null, null, null, null, null, null)
	cam_backgrounds = list(null, null, null, null, null, null, null)
	last_camera_refs = list(null, null, null, null, null, null, null)
	last_camera_turfs = list(null, null, null, null, null, null, null)

	var/safe_ref = ref(src)
	safe_ref = replacetext(safe_ref, "\[", "")
	safe_ref = replacetext(safe_ref, "\]", "")
	safe_ref = replacetext(safe_ref, ":", "_")

	for(var/i = 1, i <= CAMERA_VIEWPORT_COUNT, i++)
		if(i <= CAMERA_MULTI_SLOT_COUNT)
			multi_slots[i] = null
		last_camera_refs[i] = null
		last_camera_turfs[i] = null

		var/map_ref = (i == CAMERA_SINGLE_VIEW_SLOT) ? "camera_[safe_ref]_single_map_a" : "camera_[safe_ref]_[i]_map_a"
		map_refs[i] = map_ref

		var/atom/movable/screen/map_view/cam_screen = new
		cam_screen.assigned_map = map_ref
		cam_screen.del_on_map_removal = FALSE
		cam_screen.set_position(1, 1)
		cam_screens[i] = cam_screen

		var/atom/movable/screen/camera_skybox/cam_skybox = new
		cam_skybox.assigned_map = map_ref
		cam_skybox.del_on_map_removal = FALSE
		cam_skybox.screen_loc = "[map_ref]:CENTER"
		cam_skyboxes[i] = cam_skybox

		var/atom/movable/screen/background/cam_background = new
		cam_background.assigned_map = map_ref
		cam_background.del_on_map_removal = FALSE
		cam_background.fill_rect(1, 1, DEFAULT_CAMERA_MAP_SIZE, DEFAULT_CAMERA_MAP_SIZE)
		cam_background.maptext_width = 320
		cam_background.maptext_height = 64
		cam_background.maptext_y = 128
		cam_backgrounds[i] = cam_background

/datum/nano_module/camera_monitor/Destroy()
	reset_current()

	for(var/user_ref in user_plane_masters)
		var/list/user_slots = user_plane_masters[user_ref]
		if(!islist(user_slots))
			continue

		for(var/i = 1, i <= CAMERA_VIEWPORT_COUNT, i++)
			var/list/slot_renderers = user_slots[i]
			if(!islist(slot_renderers))
				continue
			for(var/atom/movable/map_obj as anything in slot_renderers)
				qdel(map_obj)

	for(var/i = 1, i <= CAMERA_VIEWPORT_COUNT, i++)
		qdel(cam_screens[i])
		qdel(cam_skyboxes[i])
		qdel(cam_backgrounds[i])

	user_plane_masters.Cut()
	concurrent_users.Cut()
	map_refs.Cut()
	cam_screens.Cut()
	cam_skyboxes.Cut()
	cam_backgrounds.Cut()
	last_camera_refs.Cut()
	last_camera_turfs.Cut()
	multi_slots.Cut()
	holomap_cache.Cut()
	return ..()

/datum/nano_module/camera_monitor/tgui_state(mob/user)
	var/obj/item/modular_computer/MC = nano_host()
	if(MC)
		return MC.tgui_state(user)
	return ..()

/datum/nano_module/camera_monitor/ui_status(mob/user, datum/ui_state/state)
	var/obj/item/modular_computer/MC = nano_host()
	if(MC)
		return MC.ui_status(user, state)
	return ..()

/datum/nano_module/camera_monitor/tgui_interact(mob/user, datum/tgui/ui)
	ensure_slot_lists_ready()
	var/list/networks = get_available_networks(user)
	ensure_current_network(user, networks)
	sanitize_active_state()
	update_active_camera_screens()

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CameraConsole", "Camera Monitoring")
		ui.set_autoupdate(TRUE)
		ui.open()

	register_user_maps(user)

/datum/nano_module/camera_monitor/tgui_data(mob/user)
	ensure_slot_lists_ready()
	var/list/data = list()

	var/obj/item/modular_computer/MC = nano_host()
	if(MC)
		var/list/header_data = MC.get_header_data()
		for(var/header_key in header_data)
			data[header_key] = header_data[header_key]

	var/list/networks = get_available_networks(user)
	ensure_current_network(user, networks)
	sanitize_active_state()

	var/list/cameras = get_cameras_for_current_network()

	var/list/map_z_levels = list()
	for(var/list/cam_data as anything in cameras)
		if(isnull(cam_data["z"]))
			continue
		if(!(cam_data["z"] in map_z_levels))
			map_z_levels += cam_data["z"]
	map_z_levels = sortList(map_z_levels)

	var/list/map_refs_data = list()
	for(var/i = 1, i <= CAMERA_MULTI_SLOT_COUNT, i++)
		if(i <= length(map_refs))
			map_refs_data["[i]"] = map_refs[i]
		else
			map_refs_data["[i]"] = null

	data["networks"] = networks
	data["cameras"] = cameras
	data["current_network"] = current_network
	data["current_camera"] = current_camera ? current_camera.nano_structure() : null
	data["view_mode"] = view_mode
	data["multi_layout"] = multi_layout
	data["active_slot"] = active_slot
	data["visible_slots"] = get_visible_slot_count()
	data["multi_slots"] = get_multi_slots_ui_data()
	data["map_refs"] = map_refs_data
	data["map_ref_single"] = length(map_refs) >= CAMERA_SINGLE_VIEW_SLOT ? map_refs[CAMERA_SINGLE_VIEW_SLOT] : null
	data["single_feed_ready"] = is_slot_feed_ready(CAMERA_SINGLE_VIEW_SLOT, current_camera)
	data["map_z_levels"] = map_z_levels

	return data

/datum/nano_module/camera_monitor/tgui_static_data(mob/user)
	. = list(
		"multi_layouts" = list(CAMERA_LAYOUT_1X2, CAMERA_LAYOUT_2X2, CAMERA_LAYOUT_2X3),
		"world_max_x" = world.maxx,
		"world_max_y" = world.maxy,
		"holomap_width" = 480,
		"holomap_height" = 480,
		"holomap_offset_x" = HOLOMAP_OFFSET_X,
		"holomap_offset_y" = HOLOMAP_OFFSET_Y,
	)

	var/list/all_map_z_levels = list()
	for(var/z_level = 1, z_level <= GLOB.using_map.map_levels.len, z_level++)
		all_map_z_levels += z_level

	.["holomap_images"] = get_holomap_images(all_map_z_levels)

/datum/nano_module/camera_monitor/tgui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	ensure_slot_lists_ready()
	. = ..()
	if(.)
		return TRUE

	var/obj/item/modular_computer/MC = nano_host()
	if(action == "PC_shutdown" || action == "PC_exit" || action == "PC_minimize")
		if(MC)
			SStgui.close_uis(src)
			return MC.tgui_act(action, params)
		return FALSE

	var/mob/user = usr

	switch(action)
		if("refresh")
			invalidateCameraCache()
			return TRUE

		if("switch_network")
			var/new_network = params["network"]
			if(!new_network)
				return TRUE

			if(can_access_network(user, get_camera_access(new_network)))
				current_network = new_network
				sanitize_active_state()
			else
				to_chat(user, "\The [nano_host()] shows an \"Network Access Denied\" error message.")
			return TRUE

		if("set_view_mode")
			var/new_mode = params["mode"]
			if(new_mode in list(CAMERA_VIEW_MODE_SINGLE, CAMERA_VIEW_MODE_MAP, CAMERA_VIEW_MODE_MULTI))
				view_mode = new_mode
				if(view_mode == CAMERA_VIEW_MODE_MULTI)
					ensure_active_slot_valid()
			return TRUE

		if("set_multi_layout")
			var/new_layout = params["layout"]
			if(new_layout in list(CAMERA_LAYOUT_1X2, CAMERA_LAYOUT_2X2, CAMERA_LAYOUT_2X3))
				multi_layout = new_layout
				ensure_active_slot_valid()
			return TRUE

		if("set_active_slot")
			active_slot = text2num(params["slot"])
			ensure_active_slot_valid()
			return TRUE

		if("switch_camera")
			var/obj/machinery/camera/next_camera = find_camera_in_current_network(params["camera"])
			if(next_camera)
				set_current(next_camera)
				if(user)
					playsound(user, 'sound/effects/cctv_switch.ogg', 25, FALSE)
			return TRUE

		if("open_camera_single")
			var/obj/machinery/camera/single_camera = find_camera_in_current_network(params["camera"])
			if(single_camera)
				set_current(single_camera)
				view_mode = CAMERA_VIEW_MODE_SINGLE
				if(user)
					playsound(user, 'sound/effects/cctv_switch.ogg', 25, FALSE)
			return TRUE

		if("pick_camera")
			var/obj/machinery/camera/picked_camera = find_camera_in_current_network(params["camera"])
			if(!picked_camera)
				return TRUE

			if(view_mode == CAMERA_VIEW_MODE_MULTI)
				assign_camera_to_slot(active_slot, picked_camera)
			else
				set_current(picked_camera)

			if(user)
				playsound(user, 'sound/effects/cctv_switch.ogg', 25, FALSE)
			return TRUE

		if("assign_camera")
			var/slot_to_assign = text2num(params["slot"])
			if(!slot_to_assign)
				slot_to_assign = active_slot
			var/obj/machinery/camera/slot_camera = find_camera_in_current_network(params["camera"])
			if(slot_camera)
				assign_camera_to_slot(slot_to_assign, slot_camera)
			return TRUE

		if("clear_slot")
			var/slot_to_clear = text2num(params["slot"])
			if(slot_to_clear >= 1 && slot_to_clear <= CAMERA_MULTI_SLOT_COUNT)
				multi_slots[slot_to_clear] = null
				last_camera_refs[slot_to_clear] = null
				last_camera_turfs[slot_to_clear] = null
			return TRUE

		if("open_slot_single")
			var/slot_to_open = text2num(params["slot"])
			var/obj/machinery/camera/single_camera = get_slot_camera(slot_to_open)
			if(single_camera)
				set_current(single_camera)
				view_mode = CAMERA_VIEW_MODE_SINGLE
			return TRUE

		if("reset")
			reset_current()
			for(var/i = 1, i <= CAMERA_MULTI_SLOT_COUNT, i++)
				multi_slots[i] = null
				last_camera_refs[i] = null
				last_camera_turfs[i] = null
			active_slot = 1
			view_mode = CAMERA_VIEW_MODE_SINGLE
			return TRUE

	return FALSE

/datum/nano_module/camera_monitor/ui_close(mob/user)
	. = ..()
	var/user_ref = ref(user)
	concurrent_users -= user_ref

	if(user?.client)
		for(var/map_ref in map_refs)
			user.client.clear_map(map_ref)

	var/list/user_slots = user_plane_masters[user_ref]
	if(islist(user_slots))
		for(var/i = 1, i <= CAMERA_VIEWPORT_COUNT, i++)
			var/list/slot_renderers = user_slots[i]
			if(!islist(slot_renderers))
				continue
			for(var/atom/movable/map_obj as anything in slot_renderers)
				qdel(map_obj)

	user_plane_masters -= user_ref

/datum/nano_module/camera_monitor/proc/register_user_maps(mob/user)
	ensure_slot_lists_ready()
	if(!user?.client)
		return

	var/user_ref = ref(user)
	if(user_ref in concurrent_users)
		return

	concurrent_users += user_ref

	ensure_user_plane_masters(user)

	var/list/user_slots = user_plane_masters[user_ref]

	for(var/i = 1, i <= CAMERA_VIEWPORT_COUNT, i++)
		if(i > length(cam_screens) || i > length(cam_skyboxes) || i > length(cam_backgrounds))
			continue

		var/atom/movable/screen/map_view/cam_screen = cam_screens[i]
		var/atom/movable/screen/camera_skybox/cam_skybox = cam_skyboxes[i]
		var/atom/movable/screen/background/cam_background = cam_backgrounds[i]
		var/list/slot_renderers = user_slots[i]

		if(cam_screen)
			user.client.register_map_obj(cam_screen)

		if(cam_skybox)
			user.client.register_map_obj(cam_skybox)

		if(islist(slot_renderers))
			for(var/atom/movable/map_obj as anything in slot_renderers)
				user.client.register_map_obj(map_obj)

		if(cam_background)
			user.client.register_map_obj(cam_background)

/datum/nano_module/camera_monitor/proc/get_available_networks(mob/user)
	var/list/all_networks = list()
	for(var/network in GLOB.using_map.station_networks)
		all_networks += list(list(
			"tag" = network,
			"has_access" = can_access_network(user, get_camera_access(network))
		))

	return modify_networks_list(all_networks)

// Intended to be overriden by subtypes to manually add non-station networks to the list.
/datum/nano_module/camera_monitor/proc/modify_networks_list(list/networks)
	return networks

/datum/nano_module/camera_monitor/proc/can_access_network(mob/user, network_access)
	// No access passed, or 0 which is considered no access requirement. Allow it.
	if(!network_access)
		return TRUE

	return check_access(user, access_security) || check_access(user, network_access)

/datum/nano_module/camera_monitor/proc/ensure_current_network(mob/user, list/networks)
	if(!length(networks))
		current_network = null
		return

	if(current_network)
		for(var/list/network_data as anything in networks)
			if(network_data["tag"] != current_network)
				continue
			if(network_data["has_access"])
				return
			break

	for(var/list/network_data as anything in networks)
		if(network_data["has_access"])
			current_network = network_data["tag"]
			return

	current_network = null

/datum/nano_module/camera_monitor/proc/get_cameras_for_current_network()
	if(!current_network)
		return list()

	var/list/cameras = camera_repository.cameras_in_network(current_network)
	if(islist(cameras) && length(cameras))
		return cameras

	// Fallback 1: cache key case mismatch between station network tag and camera network tag.
	camera_repository.setup_cache()
	var/target_network = lowertext("[current_network]")
	for(var/network_name in camera_repository.networks)
		if(lowertext("[network_name]") != target_network)
			continue
		var/list/case_fixed_list = camera_repository.networks[network_name]
		if(islist(case_fixed_list) && length(case_fixed_list))
			return case_fixed_list

	// Fallback 2: direct scan of cameranet if repository is stale or incomplete.
	var/list/direct_list = list()
	for(var/obj/machinery/camera/C in cameranet.cameras)
		if(!islist(C.network))
			continue
		var/has_network = FALSE
		for(var/network_name in C.network)
			if(lowertext("[network_name]") == target_network)
				has_network = TRUE
				break
		if(has_network)
			direct_list += list(C.nano_structure())

	if(length(direct_list))
		return direct_list

	return list()

/datum/nano_module/camera_monitor/proc/find_camera_in_current_network(camera_ref_or_name)
	if(!camera_ref_or_name || !current_network)
		return null

	var/obj/machinery/camera/C = locate(camera_ref_or_name) in cameranet.cameras
	if(istype(C, /obj/machinery/camera) && (current_network in C.network))
		return C

	var/list/cameras = get_cameras_for_current_network()
	for(var/list/cam_data as anything in cameras)
		if(cam_data["name"] != camera_ref_or_name)
			continue
		var/obj/machinery/camera/found = locate(cam_data["camera"]) in cameranet.cameras
		if(istype(found, /obj/machinery/camera))
			return found

	return null

/datum/nano_module/camera_monitor/proc/set_current(obj/machinery/camera/C)
	if(current_camera == C)
		return

	if(current_camera)
		var/mob/living/old_target = current_camera.loc
		if(istype(old_target))
			old_target.tracking_cancelled()

	current_camera = C

	if(current_camera)
		var/mob/living/new_target = current_camera.loc
		if(istype(new_target))
			new_target.tracking_initiated()

/datum/nano_module/camera_monitor/proc/reset_current()
	if(current_camera)
		var/mob/living/current_target = current_camera.loc
		if(istype(current_target))
			current_target.tracking_cancelled()
	current_camera = null

/datum/nano_module/camera_monitor/proc/assign_camera_to_slot(slot, obj/machinery/camera/C)
	if(slot < 1 || slot > CAMERA_MULTI_SLOT_COUNT)
		return
	multi_slots[slot] = C ? ref(C) : null
	last_camera_refs[slot] = null
	last_camera_turfs[slot] = null

/datum/nano_module/camera_monitor/proc/get_slot_camera(slot)
	if(slot < 1 || slot > CAMERA_MULTI_SLOT_COUNT)
		return null
	if(slot > length(multi_slots))
		return null

	var/slot_ref = multi_slots[slot]
	if(!slot_ref)
		return null

	var/obj/machinery/camera/C = locate(slot_ref) in cameranet.cameras
	if(!istype(C))
		multi_slots[slot] = null
		return null

	return C

/datum/nano_module/camera_monitor/proc/get_visible_slot_count()
	switch(multi_layout)
		if(CAMERA_LAYOUT_1X2)
			return 2
		if(CAMERA_LAYOUT_2X3)
			return 6
		else
			return 4

/datum/nano_module/camera_monitor/proc/ensure_active_slot_valid()
	var/visible_slots = get_visible_slot_count()
	if(active_slot < 1)
		active_slot = 1
	if(active_slot > visible_slots)
		active_slot = visible_slots

/datum/nano_module/camera_monitor/proc/sanitize_active_state()
	if(current_camera)
		if(QDELETED(current_camera))
			reset_current()

	for(var/i = 1, i <= CAMERA_MULTI_SLOT_COUNT, i++)
		get_slot_camera(i) // resolves deleted/unavailable refs.

	ensure_active_slot_valid()

/datum/nano_module/camera_monitor/proc/get_multi_slots_ui_data()
	var/list/result = list()
	for(var/i = 1, i <= CAMERA_MULTI_SLOT_COUNT, i++)
		var/obj/machinery/camera/C = get_slot_camera(i)
		result += list(list(
			"index" = i,
			"camera" = C ? C.nano_structure() : null,
			"active" = (i == active_slot),
			"render_ready" = is_slot_feed_ready(i, C)
		))
	return result

/datum/nano_module/camera_monitor/proc/is_slot_feed_ready(slot, obj/machinery/camera/C = null)
	if(slot < 1 || slot > CAMERA_VIEWPORT_COUNT)
		return FALSE
	if(slot > length(last_camera_refs) || slot > length(last_camera_turfs))
		return FALSE

	if(!C)
		C = (slot == CAMERA_SINGLE_VIEW_SLOT) ? current_camera : get_slot_camera(slot)

	if(!C || !C.can_use())
		return FALSE

	var/turf/camera_turf = get_turf(C)
	if(!camera_turf)
		return FALSE

	return last_camera_refs[slot] == ref(C) && last_camera_turfs[slot] == camera_turf

/datum/nano_module/camera_monitor/proc/update_active_camera_screens(force = FALSE)
	ensure_slot_lists_ready()
	update_slot_screen(CAMERA_SINGLE_VIEW_SLOT, current_camera, force)

	// Preserve multi-view buffers off-tab so switching back does not blank/recreate
	// every viewport before the new frame is ready.
	if(view_mode != CAMERA_VIEW_MODE_MULTI && !force)
		return

	for(var/i = 1, i <= CAMERA_MULTI_SLOT_COUNT, i++)
		var/obj/machinery/camera/camera_to_render = get_slot_camera(i)

		update_slot_screen(i, camera_to_render, force)

/datum/nano_module/camera_monitor/proc/update_slot_screen(slot, obj/machinery/camera/C, force = FALSE)
	if(slot < 1 || slot > CAMERA_VIEWPORT_COUNT)
		return
	if(slot > length(cam_screens) || slot > length(cam_skyboxes) || slot > length(cam_backgrounds))
		return
	if(slot > length(last_camera_refs) || slot > length(last_camera_turfs))
		return

	var/atom/movable/screen/map_view/cam_screen = cam_screens[slot]
	var/atom/movable/screen/camera_skybox/cam_skybox = cam_skyboxes[slot]
	var/atom/movable/screen/background/cam_background = cam_backgrounds[slot]
	if(!cam_screen || !cam_skybox || !cam_background)
		return

	if(!C || !C.can_use())
		show_camera_static(slot)
		return

	var/turf/camera_turf = get_turf(C)
	if(!camera_turf)
		show_camera_static(slot)
		return

	var/current_camera_ref = ref(C)
	if(!force && last_camera_refs[slot] == current_camera_ref && last_camera_turfs[slot] == camera_turf)
		update_slot_effects(slot, TRUE)
		return

	var/list/visible_turfs = list()
	for(var/turf/T in (C.isXRay() \
			? range(C.view_range, C) \
			: view(C.view_range, C)))
		visible_turfs += T

	if(!visible_turfs.len)
		show_camera_static(slot)
		return

	var/list/bbox = get_bbox_of_atoms(visible_turfs)
	var/size_x = bbox[3] - bbox[1] + 1
	var/size_y = bbox[4] - bbox[2] + 1

	cam_screen.vis_contents = visible_turfs

	cam_skybox.refresh_appearance()
	cam_skybox.update_view(camera_turf, size_x, size_y)
	cam_skybox.alpha = 255

	cam_background.plane = LOWEST_PLANE
	cam_background.icon = 'icons/hud/screen.dmi'
	cam_background.icon_state = "clear"
	cam_background.color = null
	cam_background.alpha = 255
	cam_background.maptext = null
	cam_background.fill_rect(1, 1, size_x, size_y)
	update_slot_effects(slot, TRUE)

	last_camera_refs[slot] = current_camera_ref
	last_camera_turfs[slot] = camera_turf

/datum/nano_module/camera_monitor/proc/show_camera_static(slot)
	if(slot < 1 || slot > CAMERA_VIEWPORT_COUNT)
		return
	if(slot > length(cam_screens) || slot > length(cam_skyboxes) || slot > length(cam_backgrounds))
		return
	if(slot > length(last_camera_refs) || slot > length(last_camera_turfs))
		return

	var/atom/movable/screen/map_view/cam_screen = cam_screens[slot]
	var/atom/movable/screen/camera_skybox/cam_skybox = cam_skyboxes[slot]
	var/atom/movable/screen/background/cam_background = cam_backgrounds[slot]
	if(!cam_screen || !cam_skybox || !cam_background)
		return

	cam_screen.vis_contents.Cut()
	cam_skybox.alpha = 0
	cam_background.plane = DEFAULT_PLANE
	cam_background.icon = 'icons/hud/screen.dmi'
	cam_background.alpha = 255
	cam_background.icon_state = "blank"
	cam_background.color = null
	cam_background.maptext = null
	cam_background.fill_rect(1, 1, DEFAULT_CAMERA_MAP_SIZE, DEFAULT_CAMERA_MAP_SIZE)
	update_slot_effects(slot, FALSE)

	last_camera_refs[slot] = null
	last_camera_turfs[slot] = null

	if(!islist(user_plane_masters))
		user_plane_masters = list()

/datum/nano_module/camera_monitor/check_eye(mob/user as mob)
	// Camera view is rendered in-window via ByondUi map controls.
	return 0

/datum/nano_module/camera_monitor/proc/ensure_slot_lists_ready()
	if(length(multi_slots) < CAMERA_MULTI_SLOT_COUNT)
		multi_slots = list(null, null, null, null, null, null)
	if(length(map_refs) < CAMERA_VIEWPORT_COUNT)
		map_refs = list(null, null, null, null, null, null, null)
	if(length(cam_screens) < CAMERA_VIEWPORT_COUNT)
		cam_screens = list(null, null, null, null, null, null, null)
	if(length(cam_skyboxes) < CAMERA_VIEWPORT_COUNT)
		cam_skyboxes = list(null, null, null, null, null, null, null)
	if(length(cam_backgrounds) < CAMERA_VIEWPORT_COUNT)
		cam_backgrounds = list(null, null, null, null, null, null, null)
	if(length(last_camera_refs) < CAMERA_VIEWPORT_COUNT)
		last_camera_refs = list(null, null, null, null, null, null, null)
	if(length(last_camera_turfs) < CAMERA_VIEWPORT_COUNT)
		last_camera_turfs = list(null, null, null, null, null, null, null)

/datum/nano_module/camera_monitor/proc/update_slot_effects(slot, has_signal)
	if(slot < 1 || slot > CAMERA_VIEWPORT_COUNT)
		return

	var/atom/movable/screen/map_view/cam_screen = cam_screens[slot]
	if(!cam_screen)
		return

	cam_screen.remove_filter("camera_scanlines")
	cam_screen.remove_filter("camera_interference")
	cam_screen.remove_filter("camera_soften")
	cam_screen.color = null

/datum/nano_module/camera_monitor/proc/ensure_user_plane_masters(mob/user)
	ensure_slot_lists_ready()
	if(!user)
		return

	var/user_ref = ref(user)
	if(user_ref in user_plane_masters)
		return

	var/list/user_slots = list(null, null, null, null, null, null, null)

	for(var/i = 1, i <= CAMERA_VIEWPORT_COUNT, i++)
		var/map_ref = map_refs[i]
		user_slots[i] = create_camera_plane_masters_for_map(map_ref, user)

	user_plane_masters[user_ref] = user_slots

/datum/nano_module/camera_monitor/proc/create_camera_plane_masters_for_map(map_ref, mob/user)
	var/list/renderers = list()
	if(!map_ref)
		return renderers

	// Group renderers
	renderers += new /atom/movable/renderer/camera_map/final_group(null, map_ref, user)
	renderers += new /atom/movable/renderer/camera_map/scene_group(null, map_ref, user)
	renderers += new /atom/movable/renderer/camera_map/screen_group(null, map_ref, user)

	// Base planes
	renderers += new /atom/movable/renderer/camera_map/letterbox(null, map_ref, user)
	renderers += new /atom/movable/renderer/camera_map/space(null, map_ref, user)
	renderers += new /atom/movable/renderer/camera_map/skybox(null, map_ref, user)
	renderers += new /atom/movable/renderer/camera_map/turf(null, map_ref, user)
	renderers += new /atom/movable/renderer/camera_map/game(null, map_ref, user)
	renderers += new /atom/movable/renderer/camera_map/runechat(null, map_ref, user)
	renderers += new /atom/movable/renderer/camera_map/observers(null, map_ref, user)
	renderers += new /atom/movable/renderer/camera_map/lighting(null, map_ref, user)
	renderers += new /atom/movable/renderer/camera_map/above_lighting(null, map_ref, user)
	renderers += new /atom/movable/renderer/camera_map/lighting_lamps_source_renderer(null, map_ref, user)
	renderers += new /atom/movable/renderer/camera_map/lighting_lamps_selfglow_renderer(null, map_ref, user)
	renderers += new /atom/movable/renderer/camera_map/lighting_lamps_glare_renderer(null, map_ref, user)
	renderers += new /atom/movable/renderer/camera_map/additive_lighting(null, map_ref, user)
	renderers += new /atom/movable/renderer/camera_map/screen_effects(null, map_ref, user)
	renderers += new /atom/movable/renderer/camera_map/obfuscation(null, map_ref, user)
	renderers += new /atom/movable/renderer/camera_map/interface(null, map_ref, user)
	renderers += new /atom/movable/renderer/camera_map/open_space(null, map_ref, user)
	renderers += new /atom/movable/renderer/camera_map/over_open_space(null, map_ref, user)

	// Effect renderers
	renderers += new /atom/movable/renderer/camera_map/warp(null, map_ref, user)
	renderers += new /atom/movable/renderer/camera_map/heat(null, map_ref, user)
	renderers += new /atom/movable/renderer/camera_map/emissive(null, map_ref, user)

	// Map-local helpers for special-case lighting composition.
	var/atom/movable/screen/fullscreen/lighting_backdrop/camera_lighting_backdrop = new
	camera_lighting_backdrop.assigned_map = map_ref
	camera_lighting_backdrop.del_on_map_removal = FALSE
	camera_lighting_backdrop.screen_loc = "[map_ref]:CENTER"
	renderers += camera_lighting_backdrop

	var/atom/movable/screen/map_render_source/lighting_overlay/camera_lighting_overlay = new
	camera_lighting_overlay.assigned_map = map_ref
	camera_lighting_overlay.del_on_map_removal = FALSE
	camera_lighting_overlay.screen_loc = "[map_ref]:CENTER"
	camera_lighting_overlay.render_source = camera_map_target(LIGHTING_RENDER_TARGET, map_ref)
	renderers += camera_lighting_overlay

	return renderers

/datum/nano_module/camera_monitor/proc/get_holomap_images(list/map_z_levels)
	var/list/result = list()
	if(!length(map_z_levels))
		return result

	for(var/z_entry in map_z_levels)
		var/z_level = text2num("[z_entry]")
		if(!z_level)
			continue
		var/image_data = get_holomap_image_base64(z_level)
		if(image_data)
			result["[z_level]"] = image_data

	return result

/datum/nano_module/camera_monitor/proc/get_holomap_image_base64(z_level)
	if(!z_level)
		return null

	var/cache_key = "[z_level]"
	if(cache_key in holomap_cache)
		return holomap_cache[cache_key]

	var/icon/map_icon = null
	if(z_level in GLOB.holomaps)
		map_icon = GLOB.holomaps[z_level]
	if(!map_icon)
		map_icon = generate_holomap_z(z_level)
	if(!map_icon)
		return null

	var/encoded = icon2base64(map_icon)
	if(!encoded)
		return null

	var/data_uri = "data:image/png;base64,[encoded]"
	holomap_cache[cache_key] = data_uri
	return data_uri

/datum/computer_file/program/camera_monitor/ert
	filename = "ntcammon"
	filedesc = "Advanced Camera Monitoring"
	extended_desc = "This program allows remote access to the camera system. Some camera networks may have additional access requirements. This version has an integrated database with additional encrypted keys."
	size = 14
	nanomodule_path = /datum/nano_module/camera_monitor/ert
	available_on_ntnet = 0

/datum/nano_module/camera_monitor/ert
	name = "Advanced Camera Monitoring Program"
	available_to_ai = FALSE

// The ERT variant has access to ERT and crescent cams, but still checks for accesses. ERT members should be able to use it.
/datum/nano_module/camera_monitor/ert/modify_networks_list(list/networks)
	..()
	networks.Add(list(list("tag" = NETWORK_ERT, "has_access" = 1)))
	networks.Add(list(list("tag" = NETWORK_CRESCENT, "has_access" = 1)))
	return networks

/datum/nano_module/camera_monitor/apply_visual(mob/M)
	return

/datum/nano_module/camera_monitor/remove_visual(mob/M)
	return

#undef DEFAULT_CAMERA_MAP_SIZE

#undef CAMERA_VIEW_MODE_SINGLE
#undef CAMERA_VIEW_MODE_MAP
#undef CAMERA_VIEW_MODE_MULTI

#undef CAMERA_LAYOUT_1X2
#undef CAMERA_LAYOUT_2X2
#undef CAMERA_LAYOUT_2X3

#undef CAMERA_MULTI_SLOT_COUNT
#undef CAMERA_VIEWPORT_COUNT
#undef CAMERA_SINGLE_VIEW_SLOT
