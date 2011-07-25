// new sodas that Apples was too laaaaaaazy to add

// also probably had something to do with the supplied code having horrific formatting and causing millions of errors

/obj/item/weapon/reagent_containers/food/drinks/cola_diet
	name = "diet space cola"
	desc = "Cola... in space! Now with extra self-confidence."
	icon_state = "cola-blue"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("cola", 30)

/obj/item/weapon/reagent_containers/food/drinks/cola_rootbeer
	name = "Rocket Root Beer"
	desc = "Blast away with Rocket Root Beer!"
	icon_state = "cola-brown"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("cola", 30)

/obj/item/weapon/reagent_containers/food/drinks/cola_apple
	name = "Andromeda Apple"
	desc = "Look to the stars with Andromeda Apple!"
	icon_state = "cola-green"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("cola", 30)

/obj/item/weapon/reagent_containers/food/drinks/cola_orange
	name = "Orbital Orange"
	desc = "Feel out-of-this-world with Orbital Orange!"
	icon_state = "cola-orange"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("cola", 30)

/obj/item/weapon/reagent_containers/food/drinks/cola_grape
	name = "Gravity Grape"
	desc = "Feel the planetfall with Gravity Grape!"
	icon_state = "cola-purple"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("cola", 30)

/obj/item/weapon/reagent_containers/food/drinks/cola_lemonlime
	name = "Citrus Star"
	desc = "Shoot to space with Citrus Star!"
	icon_state = "cola-yellow"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("cola", 30)

/obj/item/weapon/reagent_containers/food/drinks/cola_strawberry
	name = "Sirius Strawberry"
	desc = "See stars with Sirius Strawberry!"
	icon_state = "cola-pink"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent("cola", 30)

// also modified fridges to contain three of each type of soda now

// added that hacked coffee machines will dispense all types of soda until I make a soda machine object