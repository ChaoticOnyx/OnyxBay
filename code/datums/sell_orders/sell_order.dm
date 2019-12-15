decl/hierarchy/sell_order
	name = "Wanted Item"
	var/description = ""
	var/cost = null
	var/progress = 0
	var/max_progress = 1
	var/list/wanted = list() //list of wanted items

	proc/check_progress()
		return 0

	proc/add_item(var/atom/A)
		check_progress()
		return 0

	proc/reward()
		SSsupply.add_points_from_source(cost, "request")
		SSsupply.respawn(type)