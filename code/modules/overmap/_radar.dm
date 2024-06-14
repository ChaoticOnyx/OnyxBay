#define MIN_RADAR_DELAY 5 SECONDS
#define MAX_RADAR_DELAY 60 SECONDS
#define RADAR_VISIBILITY_PENALTY 5 SECONDS
#define SENSOR_MODE_PASSIVE 1
#define SENSOR_MODE_RADAR 2

/obj/machinery/computer/ship/dradis
	name = "\improper DRADIS computer"
	desc = "The DRADIS system is a series of highly sensitive detection, identification, navigation and tracking systems used to determine the range and speed of objects. This forms the most central component of a spaceship's navigational systems, as it can project the whereabouts of enemies that are out of visual sensor range by tracking their engine signatures."
	icon_screen = "teleport"
	req_access = list()
	var/stored = "blank"
	var/on = TRUE
	var/scanning_speed = 2
	var/last_scanning_speed = 2
	var/start_with_sound = FALSE
	var/show_asteroids = FALSE
	var/mining_sensor_tier = 1
	var/last_ship_count = 0
	var/last_missile_warning = 0
	var/showFriendlies = 100
	var/showEnemies= 100
	var/showAsteroids = 100
	var/showAnomalies = 100
	var/sensor_range = 0
	var/zoom_factor = 0.5
	var/zoom_factor_min = 0.25
	var/zoom_factor_max = 2
	var/next_hail = 0
	var/hail_range = 50
	var/usingBeacon = FALSE
	var/obj/item/supplypod_beacon/beacon
	var/sensor_mode = SENSOR_MODE_PASSIVE
	var/radar_delay = MIN_RADAR_DELAY
	var/dradis_targeting = FALSE
	var/can_use_radar = TRUE

/obj/machinery/computer/ship/dradis/proc/can_radar_pulse()
	if(!can_use_radar)
		return FALSE

	var/obj/structure/overmap/OM = get_overmap()
	var/next_pulse = OM.last_radar_pulse + radar_delay
	if(world.time >= next_pulse)
		return TRUE

/obj/machinery/computer/ship/dradis/internal/awacs/can_radar_pulse()
	var/obj/structure/overmap/OM = loc
	if(!OM)
		return

	var/next_pulse = OM.last_radar_pulse + radar_delay
	if(world.time >= next_pulse)
		return TRUE

/obj/structure/overmap/proc/add_sensor_profile_penalty(penalty, remove_in = -1)
	sensor_profile += penalty
	if(remove_in < 1)
		return

/obj/structure/overmap/proc/remove_sensor_profile_penalty(amount)
	sensor_profile -= amount

/obj/structure/overmap/proc/send_radar_pulse()
	var/next_pulse = last_radar_pulse + RADAR_VISIBILITY_PENALTY
	if(world.time < next_pulse)
		return FALSE
	relay('sound/effects/ship/sensor_pulse_send.ogg')
	relay_to_nearby('sound/effects/ship/sensor_pulse_hit.ogg', ignore_self=TRUE, sound_range=255, faction_check=TRUE)
	last_radar_pulse = world.time

/obj/machinery/computer/ship/dradis/proc/send_radar_pulse()
	var/obj/structure/overmap/OM = get_overmap()
	if(!OM || !can_radar_pulse())
		return FALSE
	OM.send_radar_pulse()
	sensor_range = world.maxx
	OM.add_sensor_profile_penalty(sensor_range, RADAR_VISIBILITY_PENALTY)

/obj/machinery/computer/ship/dradis/examine(mob/user)
	. = ..()

/obj/machinery/computer/ship/dradis/Destroy()
	if(linked && linked.dradis == src)
		linked.dradis = null
	return ..()

/obj/machinery/computer/ship/dradis/minor
	name = "air traffic control console"
	can_use_radar = FALSE

/obj/machinery/computer/ship/dradis/minor/cargo
	name = "\improper Cargo freight delivery console"
	var/obj/machinery/ship_weapon/torpedo_launcher/cargo/linked_launcher = null
	var/dradis_id = null

/obj/machinery/computer/ship/dradis/mining
	name = "mining DRADIS computer"
	desc = "A modified dradis console which links to the mining ship's mineral scanners, able to pick up asteroids that can be mined."
	show_asteroids = TRUE

/obj/machinery/computer/ship/dradis/internal
	name = "integrated dradis console"
	use_power = 0
	start_with_sound = FALSE
	hail_range = 30
	can_use_radar = FALSE

/obj/machinery/computer/ship/dradis/internal/large_ship
	can_use_radar = TRUE

/obj/machinery/computer/ship/dradis/internal/has_overmap()
	return linked

/datum/looping_sound/dradis
	mid_sounds = list('sound/effects/ship/dradis.ogg')
	mid_length = 2 SECONDS
	volume = 60

/obj/machinery/computer/ship/dradis/power_change()
	..()

/obj/machinery/computer/ship/dradis/set_position(obj/structure/overmap/OM)
	OM.dradis = src

/obj/machinery/computer/ship/dradis/proc/reset_dradis_contacts()
	last_ship_count = 0

/obj/machinery/computer/ship/dradis/attack_hand(mob/user)
	. = ..()
	if(.)
		tgui_interact(user)

/obj/machinery/computer/ship/dradis/tgui_state(mob/user)
	return GLOB.tgui_always_state

/obj/machinery/computer/ship/dradis/tgui_interact(mob/user, datum/tgui/ui)
	if(!has_overmap())
		to_chat(user, SPAN_WARNING("Failed to initiate ship connection."))
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Dradis")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/ship/dradis/tgui_act(action, params)
	. = ..()

	if(.)
		return

	if(!has_overmap())
		return

	var/alphaSlide = text2num(params["alpha"])
	alphaSlide = Clamp(alphaSlide, 0, 100)
	switch(action)
		if("showFriendlies")
			showFriendlies = alphaSlide
		if("showEnemies")
			showEnemies = alphaSlide
		if("showAsteroids")
			showAsteroids = alphaSlide
		if("showAnomalies")
			showAnomalies = alphaSlide
		if("zoomout")
			zoom_factor = clamp(zoom_factor - zoom_factor_min, zoom_factor_min, zoom_factor_max)
		if("zoomin")
			zoom_factor = clamp(zoom_factor + zoom_factor_min, zoom_factor_min, zoom_factor_max)
		if("setZoom")
			if(!params["zoom"])
				return

			zoom_factor = clamp(params["zoom"] / 100, zoom_factor_min, zoom_factor_max)

/obj/machinery/computer/ship/dradis/tgui_data(mob/user)
	return list()

/obj/machinery/computer/ship/dradis/internal
	name = "integrated dradis console"
	use_power = 0
	start_with_sound = FALSE
	hail_range = 30
	can_use_radar = FALSE

/obj/machinery/computer/ship/dradis/internal/has_overmap()
	return linked
