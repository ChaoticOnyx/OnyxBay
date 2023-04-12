/datum/job/assistant
	title = "Syndicate Operative"
	department = "Civilian"
	department_flag = CIV

	total_positions = 999
	spawn_positions = 999
	supervisors = "syndicate higher command"
	selection_color = "#880808"
	economic_modifier = 1
	access = list()			//See /datum/job/assistant/get_access()
	minimal_access = list()	//See /datum/job/assistant/get_access()
	alt_titles = list("Mercenary","Privateer")
	outfit_type = /decl/hierarchy/outfit/job/assistant
	latejoin_at_spawnpoints = 0
	can_be_hired = FALSE
	announced = FALSE

/datum/job/assistant/get_access()
	if(config.game.assistant_maint)
		return list(access_maint_tunnels)
	else
		return list()
