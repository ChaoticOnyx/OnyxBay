
/obj/item/reagent_containers/food/dough
	name = "dough"
	desc = "A piece of dough."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "dough"
	center_of_mass = "x=16;y=13"
	nutriment_amt = 120
	nutriment_desc = list("dough" = 1)
	startswith = list(
		/datum/reagent/nutriment/protein/gluten = 30
		)
	bitesize = 25 // 157.5 nutrition, 6 bites

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
	nutriment_amt = 40
	startswith = list(
		/datum/reagent/nutriment/protein/gluten = 10
		)
	bitesize = 25 // 52.5 nutrition, 2 bites

/obj/item/reagent_containers/food/cutlet
	name = "cutlet"
	desc = "A tasty meat slice."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "cutlet"
	filling_color = "#7a3d11"
	center_of_mass = "x=16;y=16"
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 50
		)
	bitesize = 25 // 125 nutrition, 2 bites

/obj/item/reagent_containers/food/cutlet/raw
	name = "raw cutlet"
	desc = "A thin piece of raw meat."
	icon_state = "rawcutlet"
	startswith = list(
		/datum/reagent/nutriment/protein = 50
		)
	bitesize = 25 // 62.5 nutrition, 2 bites

/obj/item/reagent_containers/food/faggot
	name = "faggot"
	desc = "A great meal all round."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "faggot"
	filling_color = "#7a3d11"
	center_of_mass = "x=16;y=16"
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 25
		)
	bitesize = 25 // 62.5 nutrition, 1 bite

/obj/item/reagent_containers/food/faggot/raw
	name = "raw faggot"
	desc = "A raw faggot."
	icon_state = "rawfaggot"
	startswith = list(
		/datum/reagent/nutriment/protein = 25
		)
	bitesize = 25 // 31.25 nutrition, 1 bite

/obj/item/reagent_containers/food/bacon
	name = "bacon"
	desc = "A thin slice of pork."
	icon = 'icons/obj/food.dmi'
	icon_state = "bacon"
	center_of_mass = "x=17;y=20"
	startswith = list(
		/datum/reagent/nutriment/protein = 50
		)
	bitesize = 25 // 62.5 nutrition, 2 bites

/obj/item/reagent_containers/food/sausage
	name = "Sausage"
	desc = "A piece of mixed, long meat."
	icon_state = "sausage"
	filling_color = "#db0000"
	center_of_mass = "x=16;y=16"
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 75
		)
	bitesize = 25 // 187.5 nutrition, 3 bites

/obj/item/reagent_containers/food/smokedsausage
	name = "Smoked sausage"
	desc = "Piece of smoked sausage. Oh, really?"
	icon_state = "smokedsausage"
	center_of_mass = "x=16;y=9"
	nutriment_desc = list("smoke" = 5)
	nutriment_amt = 20
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 70,
		/datum/reagent/salt = 5,
		/datum/reagent/blackpepper = 5
		)
	bitesize = 25 // 195 nutrition, 4 bites

/obj/item/reagent_containers/food/carpmeat
	name = "carp fillet"
	desc = "A fillet of spess carp meat."
	icon_state = "fishfillet"
	filling_color = "#ffdefe"
	center_of_mass = "x=17;y=13"
	startswith = list(
		/datum/reagent/nutriment/protein = 142.5,
		/datum/reagent/toxin/carpotoxin = 7.5
		)
	bitesize = 30 // 178 nutrition, 5 bites

/obj/item/reagent_containers/food/hugemushroomslice
	name = "huge mushroom slice"
	desc = "A slice from a huge mushroom."
	icon_state = "hugemushroomslice"
	filling_color = "#e0d7c5"
	center_of_mass = "x=17;y=16"
	startswith = list(
		/datum/reagent/nutriment/protein/fungal = 145,
		/datum/reagent/psilocybin = 5
		)
	bitesize = 30 // 181.25 nutrition, 5 bites

/obj/item/reagent_containers/food/tomatomeat
	name = "tomato slice"
	desc = "A slice from a huge tomato."
	icon_state = "tomatomeat"
	filling_color = "#db0000"
	center_of_mass = "x=17;y=16"
	nutriment_amt = 50
	nutriment_desc = list("raw" = 2, "tomato" = 3)
	startswith = list(
		/datum/reagent/drink/juice/tomato = 100
		)
	bitesize = 30 // 100 nutrition, 5 bites

/obj/item/reagent_containers/food/tofu
	name = "Tofu"
	icon_state = "tofu"
	desc = "We all love tofu."
	filling_color = "#fffee0"
	center_of_mass = "x=17;y=10"
	nutriment_amt = 75
	nutriment_desc = list("tofu" = 2, "goeyness" = 1)
	bitesize = 25 // 75 nutrition, 3 bites

/obj/item/reagent_containers/food/soydope
	name = "Soy Dope"
	desc = "Dope from a soy."
	icon_state = "soydope"
	trash = /obj/item/trash/dish/plate
	filling_color = "#c4bf76"
	center_of_mass = "x=16;y=10"
	nutriment_amt = 75
	nutriment_desc = list("tofu" = 2, "slime" = 1)
	bitesize = 25 // 75 nutrition, 3 bites

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
	nutriment_amt = 85 // The same nutritional value as a default potato.
	bitesize = 25 // 85 nutrition, 4 bites

/obj/item/reagent_containers/food/carrotfries
	name = "Carrot Fries"
	desc = "Tasty fries from fresh Carrots."
	icon_state = "carrotfries"
	trash = /obj/item/trash/dish/plate
	filling_color = "#faa005"
	center_of_mass = "x=16;y=11"
	nutriment_desc = list("carrot" = 3)
	nutriment_amt = 85
	startswith = list(
		/datum/reagent/imidazoline = 3
		)
	bitesize = 25 // 85 nutrition, 4 bites
