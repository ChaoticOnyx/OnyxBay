// TODO: add names & update maps
/datum/map_template/holodeck
	returns_created_atoms = TRUE

	var/template_id

	var/restricted = FALSE

// TODO: replace type checks with flags
/datum/map_template/holodeck/update_blacklist(turf/source_turf, centered, list/turf_blacklist)
	for(var/turf/affecting_turf as anything in get_affected_turfs(source_turf, centered))
		if(istype(affecting_turf, /turf/simulated/floor/holofloor) || istype(affecting_turf, /turf/simulated/floor/reinforced)) // Kinda crude, but we'll manage for now...
			continue

		turf_blacklist[affecting_turf] = TRUE

/datum/map_template/holodeck/basketball
	template_id = "holodeck_basketball"
	mappaths = list("maps/templates/holodeck_basketball.dmm")

/datum/map_template/holodeck/beach
	template_id = "holodeck_beach"
	mappaths = list("maps/templates/holodeck_beach.dmm")

/datum/map_template/holodeck/boxing
	template_id = "holodeck_boxing"
	mappaths = list("maps/templates/holodeck_boxing.dmm")

/datum/map_template/holodeck/chess
	template_id = "holodeck_chess"
	mappaths = list("maps/templates/holodeck_chess.dmm")

/datum/map_template/holodeck/courtempty
	template_id = "holodeck_courtempty"
	mappaths = list("maps/templates/holodeck_courtempty.dmm")

/datum/map_template/holodeck/courtroom
	template_id = "holodeck_courtroom"
	mappaths = list("maps/templates/holodeck_courtroom.dmm")

/datum/map_template/holodeck/desert
	template_id = "holodeck_desert"
	mappaths = list("maps/templates/holodeck_desert.dmm")

/datum/map_template/holodeck/meetingroom
	template_id = "holodeck_meetingroom"
	mappaths = list("maps/templates/holodeck_meetingroom.dmm")

/datum/map_template/holodeck/offline
	template_id = "holodeck_offline"
	mappaths = list("maps/templates/holodeck_offline.dmm")

/datum/map_template/holodeck/picnic
	template_id = "holodeck_picnic"
	mappaths = list("maps/templates/holodeck_picnic.dmm")

/datum/map_template/holodeck/snow
	template_id = "holodeck_snow"
	mappaths = list("maps/templates/holodeck_snow.dmm")

/datum/map_template/holodeck/space
	template_id = "holodeck_space"
	mappaths = list("maps/templates/holodeck_space.dmm")

/datum/map_template/holodeck/thunderdome
	template_id = "holodeck_thunderdome"
	mappaths = list("maps/templates/holodeck_thunderdome.dmm")

/datum/map_template/holodeck/wildlife
	template_id = "holodeck_wildlife"
	mappaths = list("maps/templates/holodeck_wildlife.dmm")

/datum/map_template/holodeck/theatre
	template_id = "holodesck_theatre"
	mappaths = list("maps/templates/holodesck_theatre.dmm")
