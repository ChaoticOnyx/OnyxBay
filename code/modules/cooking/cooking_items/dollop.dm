/obj/item/reagent_containers/food/dollop
	name = "dollop of frosting"
	desc = "A fresh serving of just frosting and nothing but frosting."
	icon = 'icons/obj/cooking/kitchen.dmi'
	icon_state = "dollop"
	bitesize = 4
	var/reagent_id = "frosting"
	startswith = list(/datum/reagent/organic/sugar/frosting = 30)

/obj/item/reagent_containers/food/dollop/New(loc, new_reagent_id = "frosting", new_amount = 30)
	. = ..()
	if(new_reagent_id)
		var/reagent_name = get_reagent_name_by_id(reagent_id)
		if(reagent_name)
			name = "dollop of [reagent_name]"
			desc = "A fresh serving of just [reagent_name] and nothing but [reagent_name]."
		startswith = list("[new_reagent_id]" = new_amount)

/obj/item/reagent_containers/food/dollop/Initialize()
	. = ..()
	update_icon()

/obj/item/reagent_containers/food/dollop/update_icon()
	color=reagents.get_color()
