
/obj/item/reagent_containers/vessel/carton
	name = "carton"
	desc = "A carton."
	item_state = "carton"
	center_of_mass = "x=16;y=8"
	matter = list(MATERIAL_CARDBOARD = 2000)
	lid_state = LID_SEALED
	brittle = FALSE

//////////////////////////JUICES AND STUFF ///////////////////////
/obj/item/reagent_containers/vessel/carton/orangejuice
	name = "Orange Juice"
	desc = "Full of vitamins and deliciousness!"
	icon_state = "orangejuice"
	item_state = "carton"
	startswith = list(/datum/reagent/drink/juice/orange)

/obj/item/reagent_containers/vessel/carton/cream
	name = "Milk Cream"
	desc = "It's cream. Made from milk. What else did you think you'd find in there?"
	icon_state = "cream"
	startswith = list(/datum/reagent/drink/milk/cream)

/obj/item/reagent_containers/vessel/carton/tomatojuice
	name = "Tomato Juice"
	desc = "Well, at least it LOOKS like tomato juice. You can't tell with all that redness."
	icon_state = "tomatojuice"
	startswith = list(/datum/reagent/drink/juice/tomato)

/obj/item/reagent_containers/vessel/carton/limejuice
	name = "Lime Juice"
	desc = "Sweet-sour goodness."
	icon_state = "limejuice"
	startswith = list(/datum/reagent/drink/juice/lime)
