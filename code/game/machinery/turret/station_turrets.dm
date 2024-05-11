/obj/machinery/turret_control_panel/ai_upload
	name = "AI Upload turret control"

	control_area = list(
		/area/turret_protected/ai_upload,
	)
	req_access = list(access_ai_upload)

	enabled = TRUE
	targeting_settings = /datum/targeting_settings/ai_upload

/datum/targeting_settings/ai_upload
	lethal_mode = FALSE
	check_synth = FALSE
	check_weapons = FALSE
	check_arrest = TRUE
	check_access = TRUE
	check_records = TRUE
	check_anomalies = TRUE

/obj/machinery/turret_control_panel/ai_chamber
	name = "AI Chamber turret control"

	control_area = list(
		/area/turret_protected/ai,
	)
	req_access = list(access_ai_upload)

	enabled = TRUE

	targeting_settings = /datum/targeting_settings/ai_chamber

/datum/targeting_settings/ai_chamber
	lethal_mode = FALSE
	check_synth = TRUE
	check_weapons = FALSE
	check_arrest = TRUE
	check_access = TRUE
	check_records = TRUE
	check_anomalies = TRUE

/obj/machinery/turret_control_panel/station_ghetto
	control_area = list(
		/area/maintenance/exterior
	)
	req_access = list(access_ai_upload)

	enabled = TRUE

	targeting_settings = /datum/targeting_settings/station_ghetto

/datum/targeting_settings/station_ghetto
	lethal_mode = FALSE
	check_synth = FALSE
	check_weapons = FALSE
	check_arrest = TRUE
	check_access = TRUE
	check_records = TRUE
	check_anomalies = TRUE

/obj/machinery/turret_control_panel/tcomms_lethal
	name = "Telecoms lethal turret control"

	control_area = list(
		/area/turret_protected/tcomsat/port
	)
	req_access = list(access_tcomsat)

	targeting_settings = /datum/targeting_settings/tcomms_lethal

/datum/targeting_settings/tcomms_lethal
	lethal_mode = TRUE
	check_synth = FALSE
	check_weapons = TRUE
	check_arrest = TRUE
	check_access = TRUE
	check_records = TRUE
	check_anomalies = TRUE

/obj/machinery/turret_control_panel/tcomms_foyer
	name = "Telecoms Foyer turret control"

	control_area = list(
		/area/turret_protected/tcomfoyer
	)
	req_access = list(access_tcomsat)

	targeting_settings = /datum/targeting_settings/tcomms_foyer

/datum/targeting_settings/tcomms_foyer
	lethal_mode = FALSE
	check_synth = FALSE
	check_weapons = FALSE
	check_arrest = TRUE
	check_access = TRUE
	check_records = TRUE
	check_anomalies = TRUE

/obj/machinery/turret_control_panel/sensor_array
	name = "Sensor Array turret control"

	control_area = list(
		/area/turret_protected/sensor_array_foyer
	)

	targeting_settings = /datum/targeting_settings/sensor_array

/datum/targeting_settings/sensor_array
	lethal_mode = TRUE
	check_synth = FALSE
	check_weapons = FALSE
	check_arrest = TRUE
	check_access = TRUE
	check_records = TRUE
	check_anomalies = TRUE

/obj/machinery/turret_control_panel/centcomm
	control_area = list(
		/area/centcom/control
	)
	req_access = list(access_cent_general)

	targeting_settings = /datum/targeting_settings/centcomm

/obj/machinery/turret/network/station
	idle_power_usage = 50 WATTS
	active_power_usage = 300 WATTS
	cell_charge_modifier = 20
	installed_gun = /obj/item/gun/energy/egun/elite
	targeting_settings = /datum/targeting_settings/ai_upload

/obj/machinery/turret/network/centcomm
	installed_gun = /obj/item/gun/energy/egun/elite

	cell_charge_modifier = 30

	enabled = FALSE
	ailock = TRUE

	targeting_settings = /datum/targeting_settings/centcomm

/datum/targeting_settings/centcomm
	lethal_mode = FALSE
	check_synth = FALSE
	check_access = TRUE
	check_arrest = TRUE
	check_records = TRUE
	check_weapons = TRUE
	check_anomalies = TRUE
