/datum/job/captain
	title = "Captain"
	department = "Command"
	head_position = 1
	department_flag = COM

	total_positions = 1
	spawn_positions = 1
	supervisors = "company officials and Corporate Regulations"
	selection_color = "#1d1d4f"
	req_admin_notify = 1
	access = list() 			//See get_access()
	minimal_access = list() 	//See get_access()
	minimal_player_age = 30
	minimum_character_age = 25
	economic_modifier = 20
	faction_restricted = TRUE

	ideal_character_age = 70 // Old geezer captains ftw
	outfit_type = /decl/hierarchy/outfit/job/captain

/datum/job/captain/equip(mob/living/carbon/human/H)
	. = ..()
	if(.)
		H.implant_loyalty(src)

/datum/job/captain/get_access()
	return get_all_station_access()
