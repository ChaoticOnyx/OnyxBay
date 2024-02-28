/obj/machinery/turretcp/ai_upload
	name = "AI Upload turret control"

	control_area = list(
		/area/turret_protected/ai_upload,
	)
	req_access = list(access_ai_upload)

	enabled = TRUE
	lethal = FALSE
	check_synth = FALSE
	check_weapons = FALSE
	check_arrest = TRUE
	check_access = TRUE
	check_records = TRUE
	check_anomalies = TRUE

/obj/machinery/turretcp/ai_chamber
	name = "AI Chamber turret control"

	control_area = list(
		/area/turret_protected/ai,
	)
	check_synth = TRUE
	req_access = list(access_ai_upload)

	enabled = TRUE
	lethal = FALSE
	check_synth = TRUE
	check_weapons = FALSE
	check_arrest = TRUE
	check_access = TRUE
	check_records = TRUE
	check_anomalies = TRUE

/obj/machinery/turretcp/station_ghetto
	control_area = list(
		/area/maintenance/exterior
	)
	req_access = list(access_ai_upload)

	enabled = TRUE
	lethal = FALSE
	check_synth = FALSE
	check_weapons = FALSE
	check_arrest = TRUE
	check_access = TRUE
	check_records = TRUE
	check_anomalies = TRUE

/obj/machinery/turretcp/tcomms_lethal
	name = "Telecoms lethal turret control"

	control_area = list(
		/area/tcommsat/chamber
	)
	lethal = TRUE
	req_access = list(access_tcomsat)

/obj/machinery/turretcp/tcomms_foyer
	name = "Telecoms Foyer turret control"

	control_area = list(
		/area/turret_protected/tcomsat/port
	)
	req_access = list(access_tcomsat)

/obj/machinery/turretcp/sensor_array
	name = "Sensor Array turret control"

	control_area = list(
		/area/turret_protected/sensor_array_foyer
	)
/obj/machinery/turretcp/centcomm
	control_area = list(
		/area/centcom/control
	)
	req_access = list(access_cent_general)

/obj/machinery/turret/network/station
	installed_gun = /obj/item/gun/energy/rifle

/obj/machinery/turret/network/centcomm
	installed_gun = /obj/item/gun/energy/egun/elite

	enabled = FALSE
	ailock = TRUE
	check_synth = FALSE
	check_access = TRUE
	check_arrest = TRUE
	check_records = TRUE
	check_weapons = TRUE
	check_anomalies = TRUE
