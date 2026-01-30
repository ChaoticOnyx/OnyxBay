
/obj/item/reagent_containers/food/bun
	name = "bun"
	desc = "A base for any self-respecting burger."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "bun"
	center_of_mass = "x=16;y=12"
	nutriment_desc = list("bread" = 3)
	nutriment_amt = 12
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 3
		)
	bitesize = 2.5 // 195 nutrition, 6 bites

/obj/item/reagent_containers/food/bun/attackby(obj/item/W, mob/user)
	// Bun + faggot = burger
	if(istype(W, /obj/item/reagent_containers/food/faggot))
		new /obj/item/reagent_containers/food/plainburger(src)
		to_chat(user, "You make a burger.")
		qdel(W)
		qdel(src)

	// Bun + cutlet = hamburger
	else if(istype(W, /obj/item/reagent_containers/food/cutlet))
		new /obj/item/reagent_containers/food/plainburger(src)
		to_chat(user, "You make a burger.")
		qdel(W)
		qdel(src)

	// Bun + sausage = hotdog
	else if(istype(W, /obj/item/reagent_containers/food/sausage))
		new /obj/item/reagent_containers/food/hotdog(src)
		to_chat(user, "You make a hotdog.")
		qdel(W)
		qdel(src)

/obj/item/reagent_containers/food/bunbun
	name = "\improper Bun Bun"
	desc = "A small bread monkey fashioned from two burger buns."
	icon_state = "bunbun"
	center_of_mass = "x=16;y=8"
	nutriment_desc = list("bread" = 3)
	nutriment_amt = 24
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 6
		)
	bitesize = 2.5 // 390 nutrition, 12 bites. In other words, exactly two buns.

/obj/item/reagent_containers/food/flatbread
	name = "flatbread"
	desc = "Bland but filling."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "flatbread"
	center_of_mass = "x=16;y=16"
	nutriment_desc = list("bread" = 3)
	nutriment_amt = 12
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 3
		)
	bitesize = 2.5 // 195 nutrition, 6 bites

/obj/item/reagent_containers/food/baguette
	name = "Baguette"
	desc = "Bon appetit!"
	icon_state = "baguette"
	filling_color = "#e3d796"
	center_of_mass = "x=18;y=12"
	nutriment_desc = list("french bread" = 3)
	nutriment_amt = 24
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 5,
		/datum/reagent/blackpepper = 1,
		/datum/reagent/salt = 1
		)
	bitesize = 3.5 // ~373 nutrition, 10 bites

/obj/item/reagent_containers/food/cracker
	name = "Cracker"
	desc = "It's a salted cracker."
	icon_state = "cracker"
	filling_color = "#f5deb8"
	center_of_mass = "x=17;y=6"
	nutriment_desc = list("cracker" = 1)
	nutriment_amt = 3
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 5,
		/datum/reagent/salt = 1
		)
	bitesize = 2 // 32.5 nutrition, 2 bites

/obj/item/reagent_containers/food/poppypretzel
	name = "Poppy pretzel"
	desc = "It's all twisted up!"
	icon_state = "poppypretzel"
	bitesize = 2
	filling_color = "#916e36"
	center_of_mass = "x=16;y=10"
	nutriment_desc = list("pretzel" = 3, "poppy seeds" = 2)
	nutriment_amt = 2
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 5
		)
	bitesize = 3 // 32.5 nutrition, 1 bite

/obj/item/reagent_containers/food/tortilla
	name = "Tortilla"
	desc = "Hasta la vista, baby"
	icon_state = "tortilla"
	center_of_mass = "x=15;y=15"
	nutriment_desc = list("tortilla" = 1)
	nutriment_amt = 6
	bitesize = 2 // 60 nutrition, 3 bites

/obj/item/reagent_containers/food/bruschetta
	name = "Bruschetta"
	desc = "..."
	icon_state = "bruschetta"
	trash = /obj/item/trash/dish/plate
	center_of_mass = "x=15;y=15"
	nutriment_desc = list("bread" = 3)
	nutriment_amt = 12
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 3,
		/datum/reagent/salt = 5,
		/datum/reagent/drink/juice/tomato = 1,
		/datum/reagent/drink/juice/garlic = 5
		)
	bitesize = 3 // ~202.5 nutrition, 6 bites

/obj/item/reagent_containers/food/twobread
	name = "Two Bread"
	desc = "It is very bitter and winy."
	icon_state = "twobread"
	filling_color = "#dbcc9a"
	center_of_mass = "x=15;y=12"
	nutriment_desc = list("sourness" = 2, "bread" = 3)
	nutriment_amt = 7.2
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 1.8
		)
	bitesize = 3 // 100 nutrition, 3 bites

/obj/item/reagent_containers/food/threebread
	name = "Three Bread"
	desc = "Is such a thing even possible?"
	icon_state = "threebread"
	filling_color = "#dbcc9a"
	center_of_mass = "x=15;y=12"
	nutriment_desc = list("sourness" = 2, "bread" = 3)
	nutriment_amt = 10.8
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 2.7
		)
	bitesize = 3 // 100 nutrition, 5 bites

/obj/item/reagent_containers/food/pizzarim
	name = "pizza rim"
	desc = "Even pineapples can't cause such violent conflicts."
	icon_state = "pizzarim"
	center_of_mass = "x=15;y=13"
	nutriment_desc = list("bread" = 3)
	nutriment_amt = 2.4
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 0.6
		)
	bitesize = 2 // 39 nutrition, 2 bites
