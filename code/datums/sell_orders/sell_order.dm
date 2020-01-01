datum/sell_order
	var/name = "Wanted Item"
	var/description = ""
	var/cost = null
	var/progress = 0
	var/max_progress = 1
	var/list/wanted = list() //list of wanted items

	proc/check_progress()
		progress = max_progress
		for(var/i in wanted)
			progress -= wanted[i] //for every wanted entry decrease progress to number of wanted item/reagent

	proc/add_item(var/atom/A)
		if(istype(A, /obj/item/stack))  //if item is stack
			var/obj/item/stack/S = A
			if(wanted[A.type]) //and if we want this stack
				wanted[A.type] -= S.amount //decrease wanted, but it mustn`t be lesser than zero
				if(wanted[A.type] < 0)
					wanted[A.type] = 0
				check_progress() //check progress after adding item
				return 1 //selling successful

		if(istype(A, /obj/item/weapon/reagent_containers)) //if item is reagent container
			var/obj/item/weapon/reagent_containers/P = A
			var/datum/reagents/RS = P.reagents //get reagents datum
			for(var/datum/reagent/R in RS.reagent_list) //for every reagent in datum
				if(wanted[R.type]) //if we want this reagent
					wanted[R.type] -= R.volume //decrease wanted
					if(wanted[R] < 0)
						wanted[R] = 0
					check_progress() //check progress after adding reagent
					return 1 //selling successful

		if(wanted[A.type]) //if it just item and we want it
			wanted[A.type] -= 1
			if(wanted[A.type] < 0)
				wanted[A.type] = 0
			check_progress()
			return 1 //selling successful

		return 0 //we didn`t sold it, so selling unsuccessful

	New()
		max_progress = 0
		for(var/i in wanted)
			max_progress += wanted[i] //set max_progress to number of wanted items
		. = ..()

	//helper procs
	proc/children_types() //returns all childen types
		var/list/childrens = list()
		for(var/children_type in subtypesof(src)) //cycle needed for selecting only childens, not all subtypes
			var/datum/children = new children_type
			if(children.parent_type == type)
				childrens += list(children_type)
		return childrens

	proc/get_category_type() //returns type category of order
		var/datum/so_parent = new parent_type //get order without volume
		return so_parent.parent_type //get category and return it

	proc/reward() //proc for getting rewarded for order
		SSsupply.add_points_from_source(cost, "request")
		SSsupply.respawn(type) //respawns order