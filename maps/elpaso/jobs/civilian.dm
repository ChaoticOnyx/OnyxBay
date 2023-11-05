//Food
/datum/job/farmer
	title = "Farmer"
	department = "Service"
	department_flag = SRV
	total_positions = 2
	spawn_positions = 1
	supervisors = "the clerk"
	selection_color = "#515151"
	access = list(access_hydroponics, access_bar, access_kitchen)
	minimal_access = list(access_hydroponics)
	alt_titles = list("Rancher")
	outfit_type = /decl/hierarchy/outfit/job/service/gardener

//Cargo
/datum/job/gd
	title = "Gun Dealer"
	department = "Supply"
	department_flag = SUP
	total_positions = 1
	spawn_positions = 2
	supervisors = "the clerk"
	selection_color = "#515151"
	economic_modifier = 5
	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mining, access_mining_station)
	minimal_access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mining, access_mining_station)
	minimal_player_age = 7
	ideal_character_age = 40
	outfit_type = /decl/hierarchy/outfit/job/cargo/qm
