
/obj/item/reagent_containers/food/dough
	name = "dough"
	desc = "A piece of dough."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "dough"
	center_of_mass = "x=16;y=13"
	nutriment_amt = 12
	nutriment_desc = list("dough" = 1)
	startswith = list(
		/datum/reagent/nutriment/protein/gluten = 3
		)
	bitesize = 2.5 // 157.5 nutrition, 6 bites

// Dough + rolling pin = flat dough
/obj/item/reagent_containers/food/dough/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/material/kitchen/rollingpin))
		new /obj/item/reagent_containers/food/sliceable/flatdough(src)
		to_chat(user, "You flatten the dough.")
		qdel(src)
		return
	return ..()

/obj/item/reagent_containers/food/spagetti
	name = "Spaghetti"
	desc = "A bundle of raw spaghetti."
	icon_state = "spagetti"
	filling_color = "#eddd00"
	center_of_mass = "x=16;y=16"
	nutriment_desc = list("crunchy dough" = 1)
	nutriment_amt = 4
	startswith = list(
		/datum/reagent/nutriment/protein/gluten = 1
		)
	bitesize = 2.5 // 52.5 nutrition, 2 bites

/obj/item/reagent_containers/food/rawcutlet
	name = "raw cutlet"
	desc = "A thin piece of raw meat."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "rawcutlet"
	center_of_mass = "x=17;y=20"
	startswith = list(
		/datum/reagent/nutriment/protein = 5
		)
	bitesize = 2.5 // 62.5 nutrition, 2 bites

/obj/item/reagent_containers/food/cutlet
	name = "cutlet"
	desc = "A tasty meat slice."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "cutlet"
	center_of_mass = "x=17;y=20"
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 5
		)
	bitesize = 2.5 // 125 nutrition, 2 bites

/obj/item/reagent_containers/food/rawfaggot
	name = "raw faggot"
	desc = "A raw faggot."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "rawfaggot"
	center_of_mass = "x=16;y=15"
	startswith = list(
		/datum/reagent/nutriment/protein = 2.5
		)
	bitesize = 2.5 // 31.25 nutrition, 1 bite

/obj/item/reagent_containers/food/faggot
	name = "faggot"
	desc = "A great meal all round."
	icon_state = "faggot"
	filling_color = "#db0000"
	center_of_mass = "x=16;y=16"
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 2.5
		)
	bitesize = 2.5 // 62.5 nutrition, 1 bite

/obj/item/reagent_containers/food/bacon
	name = "bacon"
	desc = "A thin slice of pork."
	icon = 'icons/obj/food.dmi'
	icon_state = "bacon"
	center_of_mass = "x=17;y=20"
	startswith = list(
		/datum/reagent/nutriment/protein = 5
		)
	bitesize = 2.5 // 62.5 nutrition, 2 bites

/obj/item/reagent_containers/food/sausage
	name = "Sausage"
	desc = "A piece of mixed, long meat."
	icon_state = "sausage"
	filling_color = "#db0000"
	center_of_mass = "x=16;y=16"
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 7.5
		)
	bitesize = 2.5 // 187.5 nutrition, 3 bites

/obj/item/reagent_containers/food/smokedsausage
	name = "Smoked sausage"
	desc = "Piece of smoked sausage. Oh, really?"
	icon_state = "smokedsausage"
	center_of_mass = "x=16;y=9"
	nutriment_desc = list("smoke" = 5)
	nutriment_amt = 2
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 7,
		/datum/reagent/salt = 2,
		/datum/reagent/blackpepper = 2
		)
	bitesize = 2.5 // ~195 nutrition, 4 bites

/obj/item/reagent_containers/food/carpmeat
	name = "carp fillet"
	desc = "A fillet of spess carp meat."
	icon_state = "fishfillet"
	filling_color = "#ffdefe"
	center_of_mass = "x=17;y=13"
	startswith = list(
		/datum/reagent/nutriment/protein = 14,
		/datum/reagent/toxin/carpotoxin = 2
		)
	bitesize = 3 // ~178 nutrition, 5 bites

/obj/item/reagent_containers/food/hugemushroomslice
	name = "huge mushroom slice"
	desc = "A slice from a huge mushroom."
	icon_state = "hugemushroomslice"
	filling_color = "#e0d7c5"
	center_of_mass = "x=17;y=16"
	startswith = list(
		/datum/reagent/nutriment/protein/fungal = 14,
		/datum/reagent/psilocybin = 2
		)
	bitesize = 3 // ~181.25 nutrition, 5 bites

/obj/item/reagent_containers/food/tomatomeat
	name = "tomato slice"
	desc = "A slice from a huge tomato."
	icon_state = "tomatomeat"
	filling_color = "#db0000"
	center_of_mass = "x=17;y=16"
	nutriment_amt = 5
	nutriment_desc = list("raw" = 2, "tomato" = 3)
	startswith = list(
		/datum/reagent/drink/juice/tomato = 10
		)
	bitesize = 3 // 100 nutrition, 5 bites

/obj/item/reagent_containers/food/tofu
	name = "Tofu"
	icon_state = "tofu"
	desc = "We all love tofu."
	filling_color = "#fffee0"
	center_of_mass = "x=17;y=10"
	nutriment_amt = 7.5
	nutriment_desc = list("tofu" = 2, "goeyness" = 1)
	bitesize = 2.5 // ~75 nutrition, 3 bites

/obj/item/reagent_containers/food/soydope
	name = "Soy Dope"
	desc = "Dope from a soy."
	icon_state = "soydope"
	trash = /obj/item/trash/dish/plate
	filling_color = "#c4bf76"
	center_of_mass = "x=16;y=10"
	nutriment_amt = 7.5
	nutriment_desc = list("tofu" = 2, "slime" = 1)
	bitesize = 2.5 // ~75 nutrition, 3 bites

// potato + knife = raw sticks
/obj/item/reagent_containers/food/grown/potato/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/material/kitchen/utensil/knife))
		new /obj/item/reagent_containers/food/rawsticks(src)
		to_chat(user, "You cut the potato.")
		qdel(src)
	else
		..()

/obj/item/reagent_containers/food/rawsticks
	name = "raw potato sticks"
	desc = "Raw fries, not very tasty."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "rawsticks"
	center_of_mass = "x=16;y=12"
	nutriment_desc = list("raw potato" = 3)
	nutriment_amt = 8.5 // The same nutritional value as a default potato.
	bitesize = 2.5 // 85 nutrition, 4 bites

/obj/item/reagent_containers/food/carrotfries
	name = "Carrot Fries"
	desc = "Tasty fries from fresh Carrots."
	icon_state = "carrotfries"
	trash = /obj/item/trash/dish/plate
	filling_color = "#faa005"
	center_of_mass = "x=16;y=11"
	nutriment_desc = list("carrot" = 3)
	nutriment_amt = 8.5
	startswith = list(
		/datum/reagent/imidazoline = 3
		)
	bitesize = 2.5 // 85 nutrition, 4 bites
