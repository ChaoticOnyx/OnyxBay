///
/// Presets for /obj/item/reagent_containers/vessel/carton
///

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

/obj/item/reagent_containers/vessel/carton/milk
	name = "small milk carton"
	volume = 30
	icon_state = "mini-milk"
	startswith = list(/datum/reagent/drink/milk)

/obj/item/reagent_containers/vessel/carton/milk/chocolate
	name = "small chocolate milk carton"
	desc = "It's milk! This one is in delicious chocolate flavour."
	icon_state = "mini-milk_choco"
	startswith = list(/datum/reagent/drink/milk/chocolate)