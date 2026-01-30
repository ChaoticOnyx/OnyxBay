
/obj/item/reagent_containers/food/spacetwinkie
	name = "Space Twinkie"
	icon_state = "space_twinkie"
	desc = "Guaranteed to survive longer then you will."
	filling_color = "#ffe591"
	center_of_mass = "x=15;y=11"
	nutriment_amt = 3
	startswith = list(
		/datum/reagent/sugar = 2,
		/datum/reagent/flavoring/banana = 1
		)
	bitesize = 2 // 130 nutrition, 3 bites

/obj/item/reagent_containers/food/appletart
	name = "golden apple streusel tart"
	desc = "A tasty dessert that won't make it through a metal detector."
	icon_state = "gappletart"
	trash = /obj/item/trash/dish/plate
	filling_color = "#ffff00"
	center_of_mass = "x=16;y=18"
	nutriment_desc = list("apple" = 8)
	nutriment_amt = 12
	startswith = list(
		/datum/reagent/sugar = 1,
		/datum/reagent/gold = 1,
		/datum/reagent/nutriment/protein/gluten = 3
		)
	bitesize = 3 // 245 nutrition, 6 bites

/obj/item/reagent_containers/food/candiedapple
	name = "Candied Apple"
	desc = "An apple coated in sugary sweetness."
	icon_state = "candiedapple"
	filling_color = "#f21873"
	center_of_mass = "x=15;y=13"
	nutriment_desc = list("apple" = 3, "caramel" = 3)
	nutriment_amt = 7.5
	startswith = list(/datum/reagent/sugar/caramel = 2.5)
	bitesize = 0.5 // 200 nutrition, 4 bites

/obj/item/reagent_containers/food/mint
	name = "mint"
	desc = "it is only wafer thin."
	icon_state = "mint"
	filling_color = "#f2f2f2"
	center_of_mass = "x=16;y=14"
	volume = 2 // Oh, exploitable!
	startswith = list(
		/datum/reagent/nutriment/mint = 1
		)
	bitesize = 2

/obj/item/reagent_containers/food/candy_corn
	name = "candy corn"
	desc = "It's a handful of candy corn. Cannot be stored in a detective's hat, alas."
	icon_state = "candy_corn"
	filling_color = "#fffcb0"
	center_of_mass = "x=14;y=10"
	nutriment_desc = list("candy corn" = 8)
	nutriment_amt = 4
	startswith = list(
		/datum/reagent/sugar = 2
		)
	bitesize = 1.5 // 140 nutrition, 4 bites

/obj/item/reagent_containers/food/cream_puff
	name = "Cream Puff"
	desc = "Goes well before a workout. Goes even better after a workout. And most importantly, it's highkey perfect DURING a workout."
	icon_state = "cream_puff"
	filling_color = "#FFE6A3"
	center_of_mass = "x=17;y=14"
	nutriment_desc = list("magic" = 1)
	nutriment_amt = 9
	startswith = list(/datum/reagent/nutriment/magical_custard = 3)
	bitesize = 3 // 240 nutrition, 4 bites

/obj/item/reagent_containers/food/muffin
	name = "Muffin"
	desc = "A delicious and spongy little cake."
	icon_state = "muffin"
	filling_color = "#e0cf9b"
	center_of_mass = "x=17;y=4"
	nutriment_desc = list("muffin" = 3)
	nutriment_amt = 5.5
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 1,
		/datum/reagent/sugar = 10
		)
	bitesize = 2.5 // 130 nutrition, 3 bites

/obj/item/reagent_containers/food/pancakes
	name = "pancakes"
	desc = "Pancakes with blueberries, delicious."
	icon_state = "pancakes"
	trash = /obj/item/trash/dish/plate
	center_of_mass = "x=15;y=11"
	nutriment_desc = list("pancake" = 3)
	nutriment_amt = 8
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 2
		)
	bitesize = 2 // 195 nutrition, 5 bites

/obj/item/reagent_containers/food/cookie
	name = "cookie"
	desc = "COOKIE!!!"
	icon_state = "COOKIE!!!"
	filling_color = "#dbc94f"
	center_of_mass = "x=17;y=18"
	nutriment_desc = list("cookie" = 3)
	nutriment_amt = 2.5
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 0.5,
		/datum/reagent/sugar = 1,
		/datum/reagent/nutriment/coco = 0.2
		)
	bitesize = 2 // 77.5 nutrition, 2 bites

/obj/item/reagent_containers/food/fortunecookie
	name = "Fortune cookie"
	desc = "A true prophecy in each cookie!"
	icon_state = "fortune_cookie"
	filling_color = "#e8e79e"
	center_of_mass = "x=15;y=14"
	nutriment_desc = list("fortune cookie" = 2)
	nutriment_amt = 4
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 1,
		/datum/reagent/sugar = 0.5
		)
	bitesize = 3 // 90 nutrition, 2 bites

/obj/item/reagent_containers/food/chocolatebar
	name = "Chocolate Bar"
	desc = "Such sweet, fattening food."
	icon_state = "chocolatebar"
	filling_color = "#7d5f46"
	center_of_mass = "x=15;y=15"
	nutriment_amt = 7.5
	nutriment_desc = list("chocolate" = 5)
	startswith = list(
		/datum/reagent/sugar = 1,
		/datum/reagent/nutriment/coco = 1.5
		)
	bitesize = 2.5 // 162.5 nutrition, 4 bites

/obj/item/reagent_containers/food/chocolateegg
	name = "Chocolate Egg"
	desc = "Such sweet, fattening food."
	icon_state = "chocolateegg"
	filling_color = "#7d5f46"
	center_of_mass = "x=16;y=13"
	nutriment_amt = 7.5
	nutriment_desc = list("chocolate" = 5)
	center_of_mass = "x=16;y=13"
	startswith = list(
		/datum/reagent/sugar = 1,
		/datum/reagent/nutriment/coco = 1.5,
		/datum/reagent/nutriment/protein/cooked = 4.5
		)
	bitesize = 3 // 275 nutrition, 5 bites

/obj/item/reagent_containers/food/sundae
	name = "Sundae"
	desc = "Creamy satisfaction"
	icon_state = "sundae"
	center_of_mass = "x=15;y=15"
	nutriment_amt = 4
	startswith = list(
		/datum/reagent/drink/juice/banana = 2,
		/datum/reagent/drink/milk/cream = 1)
	bitesize = 5
