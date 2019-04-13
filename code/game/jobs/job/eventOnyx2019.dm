//casino
/datum/job/casino
	title = "Ñasino clerk"
	department = "Casino"
	department_flag = CIV

	total_positions = -1
	spawn_positions = -1
	supervisors = "Lady Fortune, Casino Boss"
	selection_color = "#515151"
	economic_modifier = 2
	access = list(access_casino)
	minimal_access = list(access_casino)
	alt_titles = list("Dealer","Cashier","Service girl","Porter")
	outfit_type = /decl/hierarchy/outfit/job/casino

/datum/job/casinoboss
	title = "Ñasino Boss"
	department = "Casino"
	department_flag = CIV

	total_positions = -1
	spawn_positions = -1
	supervisors = "Lady Fortune"
	selection_color = "#515151"
	economic_modifier = 5
	access = list(access_casino)
	minimal_access = list(access_casino)
	outfit_type = /decl/hierarchy/outfit/job/casino