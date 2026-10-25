/obj/item/reagent_containers/food/dollop
	name = "dollop of frosting"
	desc = "A fresh serving of just frosting and nothing but frosting."
	icon = 'icons/obj/cwj_cooking/kitchen.dmi'
	icon_state = "dollop"
	bitesize = 4
	var/reagent_id = /datum/reagent/sugar/frosting
	startswith = list(/datum/reagent/sugar/frosting = 30)

/obj/item/reagent_containers/food/dollop/Initialize(mapload, new_reagent_id = "frosting", new_amount = 30)
	var/rpath = resolve_cwj_reagent_path(new_reagent_id)
	if(rpath)
		reagent_id = rpath
		var/datum/reagent/R = rpath
		SetName("dollop of [initial(R.name)]")
		desc = "A fresh serving of just [initial(R.name)] and nothing but [initial(R.name)]."
		startswith = list()
		startswith[rpath] = new_amount
	. = ..(mapload, FALSE)
	update_icon()

/obj/item/reagent_containers/food/dollop/on_update_icon()
	if(reagents)
		color = reagents.get_color()
