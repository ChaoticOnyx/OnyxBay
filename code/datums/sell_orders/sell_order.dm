decl/hierarchy/sell_order
	name = "Wanted Item"
	var/description = ""
	var/cost = null
	var/progress = 0
	var/max_progress = 1
	var/list/wanted = list() //list of wanted items

	proc/check_progress()
		progress = max_progress
		for(var/i in wanted)
			progress -= wanted[i]
		if(progress >= max_progress) //if request complete - get reward
			reward()

	proc/add_item(var/atom/A)
		if(istype(A, /obj/item/stack))
			var/obj/item/stack/S = A
			if(wanted[A.type])
				wanted[A.type] -= S.amount
				if(wanted[A.type] < 0)
					wanted[A.type] = 0
				check_progress()
				return 1 //selling successful

		if(istype(A, /obj/item/weapon/reagent_containers))
			var/obj/item/weapon/reagent_containers/P = A
			var/datum/reagents/RS = P.reagents
			for(var/datum/reagent/R in RS.reagent_list)
				if(wanted[R.type])
					wanted[R.type] -= R.volume
					if(wanted[R] < 0)
						wanted[R] = 0
					check_progress()
					return 1

		if(wanted[A.type])
			wanted[A.type] -= 1
			if(wanted[A.type] < 0)
				wanted[A.type] = 0
			check_progress()
			return 1

		return 0

	New()
		max_progress = 0
		for(var/i in wanted)
			max_progress += wanted[i]
		. = ..()

	proc/reward()
		SSsupply.add_points_from_source(cost, "request")
		SSsupply.respawn(type)