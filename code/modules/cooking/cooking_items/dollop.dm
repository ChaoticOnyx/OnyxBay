/obj/item/reagent_containers/food/dollop
	name = "dollop of frosting"
	desc = "A fresh serving of just frosting and nothing but frosting."
	icon = 'icons/obj/cooking/kitchen.dmi'
	icon_state = "dollop"
	bitesize = 4
	var/datum/reagent/reagent = /datum/reagent/organic/sugar/frosting
	startswith = list(/datum/reagent/organic/sugar/frosting = 30)

/obj/item/reagent_containers/food/dollop/New(loc, new_reagent = /datum/reagent/organic/sugar/frosting, new_amount = 30)
	. = ..()
	if(new_reagent)
		reagent = new_reagent
		var/reagent_name = reagent.name
		if(reagent_name)
			name = "dollop of [reagent_name]"
			desc = "A fresh serving of just [reagent_name] and nothing but [reagent_name]."
		startswith = list(reagent = new_amount)

/obj/item/reagent_containers/food/dollop/Initialize()
	. = ..()
	update_icon()

/obj/item/reagent_containers/food/dollop/update_icon()
	color=reagents.get_color()
