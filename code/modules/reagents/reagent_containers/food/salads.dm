
/obj/item/reagent_containers/food/fruitcup
	name = "Dina's fruit cup"
	desc = "Single salad with edible plate"
	icon_state = "fruitcup"
	center_of_mass = "x=15;y=15"
	nutriment_amt = 3
	startswith = list(
		/datum/reagent/drink/juice/watermelon = 5,
		/datum/reagent/drink/juice/orange = 5)
	bitesize = 4

/obj/item/reagent_containers/food/fruitsalad
	name = "Fruit salad"
	desc = "So sweety!"
	icon_state = "fruitsalad"
	trash = /obj/item/trash/dish/bowl
	center_of_mass = "x=15;y=15"
	nutriment_amt = 6
	startswith = list(
		/datum/reagent/drink/juice/watermelon = 3,
		/datum/reagent/drink/juice/orange = 3)
	bitesize = 3

/obj/item/reagent_containers/food/junglesalad
	name = "Jungle salad"
	desc = "From the depths of the jungle."
	icon_state = "junglesalad"
	trash = /obj/item/trash/dish/bowl
	center_of_mass = "x=15;y=15"
	nutriment_amt = 6
	startswith = list(/datum/reagent/drink/juice/watermelon = 3)
	bitesize = 3

/obj/item/reagent_containers/food/delightsalad
	name = "Delight salad"
	desc = "Truly citrus delight."
	icon_state = "delightsalad"
	trash = /obj/item/trash/dish/bowl
	center_of_mass = "x=15;y=15"
	nutriment_amt = 3
	startswith = list(
		/datum/reagent/drink/juice/lime = 4,
		/datum/reagent/drink/juice/lemon = 4,
		/datum/reagent/drink/juice/orange = 4)
	bitesize = 4

/obj/item/reagent_containers/food/tossedsalad
	name = "tossed salad"
	desc = "A proper salad, basic and simple, with little bits of carrot, tomato and apple intermingled. Vegan!"
	icon_state = "herbsalad"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#76b87f"
	center_of_mass = "x=17;y=11"
	nutriment_desc = list("salad" = 2, "tomato" = 2, "carrot" = 2, "apple" = 2)
	nutriment_amt = 8
	bitesize = 3

/obj/item/reagent_containers/food/validsalad
	name = "valid salad"
	desc = "It's just a salad of questionable 'herbs' with faggots and fried potato slices. Nothing suspicious about it."
	icon_state = "validsalad"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#76b87f"
	center_of_mass = "x=17;y=11"
	nutriment_desc = list("100% real salad")
	nutriment_amt = 6
	startswith = list(/datum/reagent/nutriment/protein = 2)
	bitesize = 3

/obj/item/reagent_containers/food/aesirsalad
	name = "Aesir salad"
	desc = "Probably too incredible for mortal men to fully enjoy."
	icon_state = "aesirsalad"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#468c00"
	center_of_mass = "x=17;y=11"
	nutriment_amt = 16
	nutriment_desc = list("apples" = 3,"salad" = 5)
	startswith = list(
		/datum/reagent/drink/doctor_delight = 1,
		/datum/reagent/tricordrazine = 1)
	bitesize = 3 // 160 nutrition, 4 bites
