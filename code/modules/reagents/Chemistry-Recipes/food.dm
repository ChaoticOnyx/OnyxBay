
/* Food */

/datum/chemical_reaction/tofu
	name = "Tofu"
	result = null
	required_reagents = list(/datum/reagent/drink/milk/soymilk = 100)
	catalysts = list(/datum/reagent/enzyme = 5)
	result_amount = 1

/datum/chemical_reaction/tofu/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/tofu(location)

/datum/chemical_reaction/chocolate_bar
	name = "Chocolate Bar"
	result = null
	required_reagents = list(/datum/reagent/drink/milk/soymilk = 50, /datum/reagent/nutriment/coco = 20, /datum/reagent/sugar = 10)
	result_amount = 1

/datum/chemical_reaction/chocolate_bar/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/chocolatebar(location)

/datum/chemical_reaction/chocolate_bar2
	name = "Chocolate Bar"
	result = null
	required_reagents = list(/datum/reagent/drink/milk = 50, /datum/reagent/nutriment/coco = 20, /datum/reagent/sugar = 10)
	result_amount = 1

/datum/chemical_reaction/chocolate_bar2/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/chocolatebar(location)

/datum/chemical_reaction/soysauce
	name = "Soy Sauce"
	result = /datum/reagent/nutriment/soysauce
	required_reagents = list(/datum/reagent/drink/milk/soymilk = 4, /datum/reagent/acid = 1)
	result_amount = 5

/datum/chemical_reaction/ketchup
	name = "Ketchup"
	result = /datum/reagent/nutriment/ketchup
	required_reagents = list(/datum/reagent/drink/juice/tomato = 2, /datum/reagent/water = 1, /datum/reagent/sugar = 1)
	result_amount = 4

/datum/chemical_reaction/barbecue
	name = "Barbecue Sauce"
	result = /datum/reagent/nutriment/barbecue
	required_reagents = list(/datum/reagent/nutriment/ketchup = 2, /datum/reagent/blackpepper = 1, /datum/reagent/salt = 1)
	result_amount = 4

/datum/chemical_reaction/garlicsauce
	name = "Garlic Sauce"
	result = /datum/reagent/nutriment/garlicsauce
	required_reagents = list(/datum/reagent/drink/juice/garlic = 1, /datum/reagent/nutriment/oil = 1)
	result_amount = 2

/datum/chemical_reaction/cheesewheel
	name = "Cheesewheel"
	result = null
	required_reagents = list(/datum/reagent/drink/milk = 500)
	catalysts = list(/datum/reagent/enzyme = 5)
	result_amount = 1

/datum/chemical_reaction/cheesewheel/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/sliceable/cheesewheel(location)

/datum/chemical_reaction/faggot
	name = "Faggot"
	result = null
	required_reagents = list(/datum/reagent/nutriment/protein = 25, /datum/reagent/nutriment/flour = 25)
	result_amount = 1

/datum/chemical_reaction/faggot/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/faggot/raw(location)

/datum/chemical_reaction/dough
	name = "Dough"
	result = null
	required_reagents = list(/datum/reagent/nutriment/protein/egg = 15, /datum/reagent/nutriment/flour = 100, /datum/reagent/water = 50)
	result_amount = 1

/datum/chemical_reaction/dough/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/dough(location)

/datum/chemical_reaction/syntiflesh
	name = "Syntiflesh"
	result = null
	required_reagents = list(/datum/reagent/blood = 50, /datum/reagent/clonexadone = 1)
	result_amount = 1

/datum/chemical_reaction/syntiflesh/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/meat/syntiflesh(location)

/datum/chemical_reaction/hot_ramen
	name = "Hot Ramen"
	result = /datum/reagent/drink/hot_ramen
	required_reagents = list(/datum/reagent/water = 5, /datum/reagent/drink/dry_ramen = 1)
	result_amount = 2

/datum/chemical_reaction/hell_ramen
	name = "Hell Ramen"
	result = /datum/reagent/drink/hell_ramen
	required_reagents = list(/datum/reagent/capsaicin = 1, /datum/reagent/drink/hot_ramen = 50)
	result_amount = 6

/datum/chemical_reaction/chicken_soup
	name = "Chicken Soup"
	result = /datum/reagent/drink/chicken_soup
	required_reagents = list(/datum/reagent/water = 5, /datum/reagent/drink/chicken_powder = 1)
	result_amount = 3
