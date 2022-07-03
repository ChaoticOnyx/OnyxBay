
/datum/map/polar
	name = "Pathos-I"
	full_name = "Pathos-I"
	path = "polar"

	shuttle_types = list(
		/datum/shuttle/autodock/ferry/supply/drone/polar,
		/datum/shuttle/autodock/multi/antag/rescue/polar,
		/datum/shuttle/autodock/ferry/emergency/centcom/polar,
		/datum/shuttle/autodock/ferry/administration/polar,
		/datum/shuttle/autodock/multi/antag/syndicate/polar,
		/datum/shuttle/autodock/multi/antag/elite_syndicate/polar,
		/datum/shuttle/autodock/ferry/deathsquad/polar,
		/datum/shuttle/autodock/multi/antag/merchant/polar,
		/datum/shuttle/autodock/multi/antag/skipjack/polar,
		/datum/shuttle/autodock/ferry/train
	)

	map_levels = list(
		new /datum/space_level/polar_1,
		new /datum/space_level/polar_2,
		new /datum/space_level/polar_3,
		new /datum/space_level/polar_4,
		new /datum/space_level/polar_5,
		new /datum/space_level/null_frozen,
		new /datum/space_level/jungle_level
	)

	station_name  = "Pathos-I"
	station_short = "Pathos-I"
	dock_name     = "Pathos-I - Landing Zone"
	boss_name     = "Central Command"
	boss_short    = "Centcomm"
	company_name  = "NanoTrasen"
	company_short = "NT"
	system_name   = "Nyx"

	shuttle_docked_message = "The scheduled Crew Transfer Shuttle to %Dock_name% has docked with the station. It will depart in approximately %ETD%"
	shuttle_leaving_dock = "The Crew Transfer Shuttle has left the station. Estimate %ETA% until the shuttle docks at %dock_name%."
	shuttle_called_message = "A crew transfer to %Dock_name% has been scheduled. The shuttle has been called. It will arrive in approximately %ETA%"
	shuttle_recall_message = "The scheduled crew transfer has been cancelled."

	emergency_shuttle_called_message = "The emergency shuttle begins preparations for departure to Pathos-I. Prepare valuable property, wounded and arrested people for evacuation. Estimate %ETA% until the shuttle docks at %dock_name%."
	emergency_shuttle_called_sound = 'sound/AI/polar/emergency_shuttle_called.ogg'
	command_report_sound = 'sound/AI/polar/command_report_created.ogg'
	grid_check_message = "Abnormal activity detected in the Pathos-I's power system. As a precaution, the Pathos-I's power must be shut down for an indefinite duration."
	grid_check_sound = 'sound/AI/polar/grid_check_announce.ogg'
	grid_restored_message = "Station power to the Pathos-I's will be restored at this time. We apologize for the inconvenience."
	grid_restored_sound = 'sound/AI/polar/grid_check_end.ogg'
	unidentified_lifesigns_message = "Unidentified lifesigns detected coming aboard the Pathos-I. Please lockdown all exterior access points, including ducting and ventilation."
	unidentified_lifesigns_sound = 'sound/AI/polar/unidentified_lifesigns.ogg'
	unknown_biological_entities_message = "Unknown biological entities have been detected near the Pathos-I, please stand-by."
	space_time_anomaly_message = "Space-time anomalies detected on the station. There is no additional data."
	space_time_anomaly_sound = 'sound/AI/polar/space_time_anomaly_announce.ogg'

	// NOT IN USE
	electrical_storm_moderate_sound = null
	electrical_storm_major_sound = null
	meteor_detected_message = null
	meteor_detected_sound = null
	radiation_detected_message = null
	radiation_detected_sound = null

	evac_controller_type = /datum/evacuation_controller/shuttle

	base_floor_type = /turf/simulated/floor/natural/frozenground/cave
	base_floor_area = /area/polarplanet/street

	station_networks = list(
		NETWORK_CIVILIAN_EAST,
		NETWORK_CIVILIAN_WEST,
		NETWORK_COMMAND,
		NETWORK_ENGINE,
		NETWORK_ENGINEERING,
		NETWORK_ENGINEERING_OUTPOST,
		NETWORK_EXODUS,
		NETWORK_MAINTENANCE,
		NETWORK_MEDICAL,
		NETWORK_RESEARCH,
		NETWORK_RESEARCH_OUTPOST,
		NETWORK_ROBOTS,
		NETWORK_PRISON,
		NETWORK_SECURITY,
		NETWORK_ALARM_ATMOS,
		NETWORK_ALARM_CAMERA,
		NETWORK_ALARM_FIRE,
		NETWORK_ALARM_MOTION,
		NETWORK_ALARM_POWER,
		NETWORK_THUNDER,
		NETWORK_TELECOM,
		NETWORK_MASTER,
		NETWORK_APPARAT_VORON
	)

	available_events = list(
		/datum/event/nothing,
		/datum/event/apc_damage,
		/datum/event/brand_intelligence/polar,
		/datum/event/camera_damage,
		/datum/event/economic_event,
		/datum/event/money_hacker/polar,
		/datum/event/money_lotto,
		/datum/event/mundane_news,
		/datum/event/shipping_error,
		/datum/event/sensor_suit_jamming,
		/datum/event/trivial_news,
		/datum/event/infestation/polar,
		/datum/event/wallrot/polar,
		/datum/event/space_cold,
		/datum/event/spontaneous_appendicitis,
		/datum/event/communications_blackout/polar,
		/datum/event/grid_check,
		/datum/event/prison_break/polar,
		/datum/event/random_antag,
		/datum/event/virus_minor,
		/datum/event/stray_facehugger,
		/datum/event/wormholes,
		/datum/event/spacevine,
		/datum/event/virus_major,
		/datum/event/xenomorph_infestation,
		/datum/event/biohazard_outbreak,
		/datum/event/mimic_invasion
	)

/datum/map/polar
	post_round_safe_areas = list (
		/area/polarplanet/centcom,
		/area/polarplanet/shuttle/escape/centcom,
		/area/polarplanet/shuttle/escape_pod1,
		/area/polarplanet/shuttle/escape_pod2,
		/area/polarplanet/shuttle/escape_pod3,
		/area/polarplanet/shuttle/escape_pod5,
		/area/polarplanet/shuttle/administration,
		/area/polarplanet/shuttle/specops/centcom,
	)

/datum/map/polar/setup_map()
	. = ..()

	AddComponent(/datum/component/polar_weather)

/datum/map/polar/unknown_biological_entities_announcement()
	command_announcement.Announce(
		unknown_biological_entities_message,
		"Lifesign Alert",
		new_sound = 'sound/AI/polar/unknown_biological_entities.ogg')

/datum/map/polar/level_x_biohazard_sound()
	return 'sound/AI/polar/biohazard_outbreak_announce.ogg'
