/datum/job/rd
	title = "Research Director"
	head_position = 1
	department = "Science"
	department_flag = COM|SCI

	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ad6bad"
	req_admin_notify = 1
	economic_modifier = 15
	faction_restricted = TRUE
	access = list(access_rd, access_heads, access_tox, access_morgue, access_eva,
			            access_tox_storage, access_teleporter, access_sec_doors, access_maint_tunnels,
			            access_research, access_robotics, access_xenobiology, access_ai_upload, access_tech_storage,
			            access_RC_announce, access_keycard_auth, access_tcomsat, access_gateway, access_xenoarch, access_network, access_change_ids)
	minimal_access = list(access_rd, access_heads, access_tox, access_morgue, access_eva,
			            access_tox_storage, access_teleporter, access_sec_doors, access_maint_tunnels,
			            access_research, access_robotics, access_xenobiology, access_ai_upload, access_tech_storage,
			            access_RC_announce, access_keycard_auth, access_tcomsat, access_gateway, access_xenoarch, access_network, access_change_ids)
	minimal_player_age = 30
	minimum_character_age = 25
	ideal_character_age = 50
	outfit_type = /decl/hierarchy/outfit/job/science/rd

/datum/job/scientist
	title = "Scientist"
	department = "Science"
	department_flag = SCI

	total_positions = 5
	spawn_positions = 3
	supervisors = "the research director"
	selection_color = "#633d63"
	economic_modifier = 7
	access = list(access_robotics, access_tox, access_tox_storage, access_research, access_xenobiology, access_xenoarch)
	minimal_access = list(access_tox, access_tox_storage, access_research, access_xenoarch)
	alt_titles = list("Xenoarcheologist", "Anomalist", "Plasma Researcher")
	minimal_player_age = 7
	outfit_type = /decl/hierarchy/outfit/job/science/scientist

/datum/job/xenobiologist
	title = "Xenobiologist"
	department = "Science"
	department_flag = SCI

	total_positions = 3
	spawn_positions = 2
	supervisors = "the research director"
	selection_color = "#633d63"
	economic_modifier = 7
	access = list(access_robotics, access_tox, access_tox_storage, access_research, access_xenobiology)
	minimal_access = list(access_research, access_xenobiology)
	minimal_player_age = 7
	outfit_type = /decl/hierarchy/outfit/job/science/xenobiologist

/datum/job/roboticist
	title = "Roboticist"
	department = "Science"
	department_flag = SCI

	total_positions = 2
	spawn_positions = 2
	supervisors = "research director"
	selection_color = "#633d63"
	economic_modifier = 5
	access = list(access_robotics, access_tox, access_tox_storage, access_tech_storage, access_morgue, access_research) //As a job that handles so many corpses, it makes sense for them to have morgue access.
	minimal_access = list(access_robotics, access_tech_storage, access_morgue, access_research) //As a job that handles so many corpses, it makes sense for them to have morgue access.
	alt_titles = list("Biomechanical Engineer","Mechatronic Engineer")
	minimal_player_age = 3
	outfit_type = /decl/hierarchy/outfit/job/science/roboticist
