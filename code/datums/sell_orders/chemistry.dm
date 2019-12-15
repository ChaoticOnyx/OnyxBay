decl/hierarchy/sell_order/chemistry/
	name = "Chemistry Item"

decl/hierarchy/sell_order/chemistry/add_item(var/atom/A)
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
	. = ..()
	return .

decl/hierarchy/sell_order/chemistry/check_progress()
	progress = max_progress
	for(var/i in wanted)
		progress -= wanted[i]
	if(progress >= max_progress) //if request complete - get reward
		reward()

decl/hierarchy/sell_order/chemistry/New()
	max_progress = 0
	for(var/i in wanted)
		max_progress += wanted[i]
	. = ..()
	return .

decl/hierarchy/sell_order/chemistry/inaprovaline
	name = "Inaprovaline"
	description = "Our medics need some Inaprovaline (60u) to heal people."
	wanted = list(/datum/reagent/inaprovaline = 60)
	cost = 15

decl/hierarchy/sell_order/chemistry/chloralhydrate
	name = "Chloral Hydrate"
	description = "Our medics need some Cloral Hydrate (20u) to KILL people."
	wanted = list(/datum/reagent/chloralhydrate = 20)
	cost = 30

decl/hierarchy/sell_order/chemistry/dylovene
	name = "Dylovene"
	description = "Our medics need some Dylovene (30u) to cure people."
	wanted = list(/datum/reagent/dylovene = 30)
	cost = 20