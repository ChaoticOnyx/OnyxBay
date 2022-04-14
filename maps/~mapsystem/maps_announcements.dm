/datum/map
	var/emergency_shuttle_called_message_l
	var/emergency_shuttle_called_sound

	var/command_report_sound

	var/electrical_storm_moderate_sound
	var/electrical_storm_major_sound

	var/grid_check_message_l = L10N_ANNOUNCE_GRID_CHECK
	var/grid_check_sound

	var/grid_restored_message_l = L10N_ANNOUNCE_GRID_RESTORED
	var/grid_restored_sound

	var/meteor_detected_sound

	var/radiation_detected_message_l = L10N_ANNOUNCE_RADIATION_DETECTED
	var/radiation_detected_sound

	var/space_time_anomaly_sound

	var/unidentified_lifesigns_message_l = L10N_ANNOUNCE_UNIDENTIFIED_LIFESIGNS
	var/unidentified_lifesigns_sound

	var/unknown_biological_entities_message_l = L10N_ANNOUNCE_UNKNOWN_BIOLOGICAL_ENTITIES

	var/xenomorph_spawn_sound = 'sound/AI/aliens.ogg'

/datum/map/proc/emergency_shuttle_called_announcement()
	evacuation_controller.evac_called.AnnounceLocalizeable(
		TR_DATA(emergency_shuttle_called_message_l, null, list("eta" = round(evacuation_controller.get_eta() / 60))),
		new_sound = emergency_shuttle_called_sound
	)

/datum/map/proc/grid_check_announcement()
	command_announcement.AnnounceLocalizeable(
		TR_DATA(grid_check_message_l, null, list("station_name" = station_name()))
	)

/datum/map/proc/grid_restored_announcement()
	command_announcement.AnnounceLocalizeable(
		TR_DATA(grid_restored_message_l, null, list("station_name" = station_name())),
		TR_DATA(L10N_ANNOUNCE_GRID_RESTORED_TITLE, null, null),
		new_sound = grid_restored_sound
	)

/datum/map/proc/level_x_biohazard_announcement(bio_level)
	if(!isnum(bio_level))
		CRASH("Expected a number, was: [log_info_line(bio_level)]")
	if(bio_level < 1 || bio_level > 9)
		CRASH("Expected a number between 1 and 9, was: [log_info_line(bio_level)]")

	command_announcement.AnnounceLocalizeable(
		TR_DATA(L10N_ANNOUNCE_LEVEL_X, null, list("bio_level" = bio_level, "station_name" = station_name())),
		TR_DATA(L10N_ANNOUNCE_LEVEL_X_TITLE, null, null),
		new_sound = level_x_biohazard_sound(bio_level)
	)

/datum/map/proc/level_x_biohazard_sound(bio_level)
	return

/datum/map/proc/radiation_detected_announcement()
	command_announcement.AnnounceLocalizeable(
		TR_DATA(radiation_detected_message_l, null, list("station_name" = station_name())),
		TR_DATA(L10N_ANNOUNCE_RADIATION_DETECTED_TITLE, null, null),
		new_sound = radiation_detected_sound
	)

/datum/map/proc/space_time_anomaly_detected_annoncement()
	command_announcement.AnnounceLocalizeable(
		TR_DATA(L10N_ANNOUNCE_SPACE_TIME_ANOMALY_DETECTED, null, list("station_name" = station_name())),
		TR_DATA(L10N_ANNOUNCE_SPACE_TIME_ANOMALY_DETECTED_TITLE, null, null),
		new_sound = space_time_anomaly_sound
	)

/datum/map/proc/unidentified_lifesigns_announcement()
	command_announcement.AnnounceLocalizeable(
		TR_DATA(unidentified_lifesigns_message_l, null, list("station_name" = station_name())),
		TR_DATA(L10N_ANNOUNCE_UNIDENTIFIED_LIFESIGNS_TITLE, null, null),
		new_sound = unidentified_lifesigns_sound
	)

/datum/map/proc/unknown_biological_entities_announcement()
	command_announcement.AnnounceLocalizeable(
		TR_DATA(unknown_biological_entities_message_l, null, list("station_name" = station_name())),
		TR_DATA(L10N_ANNOUNCE_UNKNOWN_BIOLOGICAL_ENTITIES_TITLE, null, null),
		new_sound = command_report_sound
	)
