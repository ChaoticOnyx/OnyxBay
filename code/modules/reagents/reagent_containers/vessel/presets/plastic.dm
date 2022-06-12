///
/// Presets for /obj/item/reagent_containers/vessel/plastic
///

/obj/item/reagent_containers/vessel/plastic/limejuice
	name = "Lime Juice"
	desc = "Sweet-sour goodness."
	icon_state = "limejuice"
	startswith = list(/datum/reagent/drink/juice/lime)

/obj/item/reagent_containers/vessel/plastic/milk
	name = "milk bottle"
	desc = "It's milk. White and nutritious goodness!"
	icon_state = "milk"
	item_state = "carton"
	center_of_mass = "x=16;y=9"
	startswith = list(/datum/reagent/drink/milk)

/obj/item/reagent_containers/vessel/plastic/soymilk
	name = "soymilk bottle"
	desc = "It's soy milk. White and nutritious... goodness?"
	icon_state = "soymilk"
	item_state = "carton"
	center_of_mass = "x=16;y=9"
	startswith = list(/datum/reagent/drink/milk/soymilk)

/obj/item/reagent_containers/vessel/plastic/waterbottle
	name = "bottled water"
	desc = "Pure drinking water, imported from the Martian poles."
	icon_state = "waterbottle"
	item_state = "bottle"
	center_of_mass = "x=15;y=8"
	startswith = list(/datum/reagent/water)

/obj/item/reagent_containers/vessel/plastic/waterbottle/fi4i
	name = "\improper FI4I water"
	desc = "Said to be NanoTrasen's finest water. In fact, it's just an expensive water container."
	icon_state = "fi4i"
	center_of_mass = "x=17;y=9"
