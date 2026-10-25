/obj/item/reagent_containers/food
	var/food_quality = 1
	var/food_tier
	var/cooking_description_modifier
	var/food_descriptor
	var/bite_descriptor
	var/cooked = FALSE

/obj/item/reagent_containers/food/proc/get_food_tier()
	var/quality = round(food_quality)
	if(quality < -9)
		food_tier = CWJ_QUALITY_GARBAGE
		food_descriptor = "It looks gross. Someone cooked this poorly."
		bite_descriptor = " Eating this makes you regret every decision that led you to this moment."
	else if(quality >= 100)
		food_tier = CWJ_QUALITY_ELDRITCH
		food_descriptor = "What cruel twist of fate it must be, for this unparalleled artistic masterpiece can only be truly appreciated through its destruction. Does this dish's transient form belie the true nature of all things? You see the totality of existence reflected through \the [src]."
		bite_descriptor = " It's like reliving the happiest moments of your life, nothing is better than this!"
	else
		switch(quality)
			if(-9 to 0)
				food_tier = CWJ_QUALITY_GROSS
				food_descriptor = "It looks like an unappetizing meal."
				bite_descriptor = " Your stomach turns as you chew."
			if(1 to 10)
				food_tier = CWJ_QUALITY_MEH
				food_descriptor = "The food is edible, but frozen dinners have been reheated with more skill."
				bite_descriptor = " It could be worse, but it certainly isn't good."
			if(11 to 20)
				food_tier = CWJ_QUALITY_NORMAL
				food_descriptor = "It looks adequately made."
				bite_descriptor = " It's food, alright."
			if(21 to 30)
				food_tier = CWJ_QUALITY_GOOD
				food_descriptor = "The quality of the food is pretty good."
				bite_descriptor = " This ain't half bad!"
			if(31 to 50)
				food_tier = CWJ_QUALITY_VERY_GOOD
				food_descriptor = "This food looks very tasty."
				bite_descriptor = " So tasty!"
			if(51 to 80)
				food_tier = CWJ_QUALITY_CUISINE
				food_descriptor = "There's a special spark in this cooking, a measure of love and care unseen by the casual chef."
				bite_descriptor = " You can taste the attention to detail like a fine spice on top of the excellently prepared dish."
			if(81 to 99)
				food_tier = CWJ_QUALITY_LEGENDARY
				food_descriptor = "The quality of this food is legendary. Words fail to describe it further. It must be eaten."
				bite_descriptor = " This food is unreal, the textures blend perfectly with the flavor, could food get any better than this?"

/obj/item/reagent_containers/food/doughslice/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/material/kitchen/rollingpin))
		new /obj/item/reagent_containers/food/flatdoughslice(get_turf(src))
		to_chat(user, SPAN_NOTICE("You flatten the dough slice."))
		qdel(src)
		return
	return ..()

/obj/item/reagent_containers/food/cutlet/raw/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/material/kitchen/rollingpin))
		new /obj/item/reagent_containers/food/faggot/raw(get_turf(src))
		new /obj/item/reagent_containers/food/faggot/raw(get_turf(src))
		to_chat(user, SPAN_NOTICE("You grind the sliced meat and shape it into balls."))
		qdel(src)
		return
	return ..()

/obj/item/reagent_containers/food/faggot/raw/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/material/kitchen/rollingpin))
		new /obj/item/reagent_containers/food/patty_raw(get_turf(src))
		to_chat(user, SPAN_NOTICE("You flatten the raw meatball."))
		qdel(src)
		return
	return ..()

/obj/item/reagent_containers/food/meat/chicken
	slice_path = /obj/item/reagent_containers/food/chickenbreast
	slices_num = 4

/obj/item/reagent_containers/food/meat/pork
	slice_path = /obj/item/reagent_containers/food/rawbacon
	slices_num = 4

/obj/item/reagent_containers/food/jelliedtoast/amanita
	startswith = list(/datum/reagent/toxin/amatoxin = 6, /datum/reagent/psilocybin = 3)

/obj/item/reagent_containers/food/jellyburger/amanita
	startswith = list(/datum/reagent/toxin/amatoxin = 6, /datum/reagent/psilocybin = 3)

/obj/item/reagent_containers/food/jellysandwich/amanita
	startswith = list(/datum/reagent/toxin/amatoxin = 6, /datum/reagent/psilocybin = 3)

/obj/item/reagent_containers/food/flatdoughslice
	name = "flat dough slice"
	desc = "A flattened building block of an impressive dish."
	icon = 'icons/obj/cwj_cooking/cwj_food.dmi'
	icon_state = "flatdoughslice"
	slice_path = /obj/item/reagent_containers/food/spagetti
	slices_num = 1
	bitesize = 10
	nutriment_desc = list("dough" = 1)
	nutriment_amt = 10

/obj/item/reagent_containers/food/medialuna
	name = "croissant"
	desc = "A flakey, buttery pastry shaped like a crescent moon. Soft and fluffy on the inside, crunchy on the outside, makes a perfect pair with a good cup of espresso."
	icon = 'icons/obj/cwj_cooking/cwj_food.dmi'
	icon_state = "medialuna"
	bitesize = 15
	nutriment_amt = 60
	nutriment_desc = list("crunchy pastry" = 5, "buttery goodness" = 5)
	cooked = TRUE

/obj/item/reagent_containers/food/sliceable/butterstick
	name = "stick of butter"
	desc = "A whole stick of butter, an excellent flavor booster or spread."
	icon = 'icons/obj/cwj_cooking/cwj_food.dmi'
	icon_state = "butter"
	slice_path = /obj/item/reagent_containers/food/butterslice
	slices_num = 5
	nutriment_amt = 100
	nutriment_desc = list("your arteries clogging themselves" = 10)

/obj/item/reagent_containers/food/butterslice
	name = "pat of butter"
	desc = "A small slice of butter, ready to melt."
	icon = 'icons/obj/cwj_cooking/cwj_food.dmi'
	icon_state = "butterslice"
	bitesize = 10
	nutriment_amt = 20
	nutriment_desc = list("butter" = 2)

/obj/item/reagent_containers/food/cinnamonroll
	name = "cinnamon roll"
	desc = "A warm, sweet pastry swirled with cinnamon and topped with cream cheese icing."
	icon = 'icons/obj/cwj_cooking/cwj_food.dmi'
	icon_state = "cinnamonroll"
	bitesize = 15
	nutriment_amt = 50
	nutriment_desc = list("warm cinnamon" = 5, "sweet icing" = 5)
	cooked = TRUE

/obj/item/reagent_containers/food/chickenbreast
	name = "raw poultry breast"
	desc = "A cut of raw poultry breast."
	icon = 'icons/obj/cwj_cooking/cwj_food.dmi'
	icon_state = "chickenbreast"
	bitesize = 15
	startswith = list(/datum/reagent/nutriment/protein = 20)

/obj/item/reagent_containers/food/chickensteak
	name = "cooked poultry breast"
	desc = "A juicy, seasoned poultry breast."
	icon = 'icons/obj/cwj_cooking/cwj_food.dmi'
	icon_state = "chickenbreast_cooked"
	trash = /obj/item/trash/dish/plate
	bitesize = 20
	startswith = list(/datum/reagent/nutriment/protein/cooked = 40)
	nutriment_desc = list("juicy chicken" = 5)
	cooked = TRUE

/obj/item/reagent_containers/food/roastchicken
	name = "roast chicken"
	desc = "A whole roasted chicken, golden brown and delicious."
	icon = 'icons/obj/cwj_cooking/cwj_food.dmi'
	icon_state = "chickenroast"
	trash = /obj/item/trash/dish/plate
	slice_path = /obj/item/reagent_containers/food/chickensteak
	slices_num = 4
	bitesize = 30
	startswith = list(/datum/reagent/nutriment/protein/cooked = 120)
	nutriment_desc = list("roast chicken" = 10)
	cooked = TRUE

/obj/item/reagent_containers/food/friedchicken
	name = "fried chicken"
	desc = "Crispy, golden-brown fried poultry."
	icon = 'icons/obj/cwj_cooking/cwj_food.dmi'
	icon_state = "friedchicken"
	bitesize = 20
	startswith = list(/datum/reagent/nutriment/protein/cooked = 40)
	nutriment_desc = list("crispy fried chicken" = 5)
	cooked = TRUE

/obj/item/reagent_containers/food/rawbacon
	name = "raw bacon"
	desc = "A thin strip of raw pork belly."
	icon = 'icons/obj/cwj_cooking/cwj_food.dmi'
	icon_state = "bacon_raw"
	bitesize = 10
	startswith = list(/datum/reagent/nutriment/protein = 20)

/obj/item/reagent_containers/food/patty_raw
	name = "raw patty"
	desc = "A flattened patty of raw ground meat."
	icon = 'icons/obj/cwj_cooking/cwj_food.dmi'
	icon_state = "patty_raw"
	bitesize = 15
	startswith = list(/datum/reagent/nutriment/protein = 20)

/obj/item/reagent_containers/food/patty
	name = "cooked patty"
	desc = "A juicy cooked burger patty."
	icon = 'icons/obj/cwj_cooking/cwj_food.dmi'
	icon_state = "patty"
	bitesize = 15
	startswith = list(/datum/reagent/nutriment/protein/cooked = 30)
	cooked = TRUE

/obj/item/reagent_containers/food/baconeggs
	name = "bacon and eggs"
	desc = "A hearty breakfast of crispy bacon and sunny-side-up eggs."
	icon = 'icons/obj/cwj_cooking/cwj_food.dmi'
	icon_state = "baconegg"
	trash = /obj/item/trash/dish/plate
	bitesize = 20
	startswith = list(/datum/reagent/nutriment/protein/cooked = 60)
	nutriment_desc = list("bacon" = 5, "eggs" = 5)
	cooked = TRUE

/obj/item/reagent_containers/food/benedict
	name = "eggs benedict"
	desc = "Poached eggs and crispy bacon atop toasted bread, drizzled with rich hollandaise."
	icon = 'icons/obj/cwj_cooking/cwj_food.dmi'
	icon_state = "benedict"
	trash = /obj/item/trash/dish/plate
	bitesize = 20
	nutriment_amt = 40
	startswith = list(/datum/reagent/nutriment/protein/cooked = 60)
	nutriment_desc = list("poached egg" = 5, "bacon" = 5, "toasted bread" = 3)
	cooked = TRUE

/obj/item/reagent_containers/food/bearchili
	name = "bear meat chili"
	desc = "A chili so manly you'll end up growing hair on your chest."
	icon = 'icons/obj/cwj_cooking/cwj_food.dmi'
	icon_state = "bearchili"
	trash = /obj/item/trash/dish/bowl
	bitesize = 25
	nutriment_amt = 30
	startswith = list(/datum/reagent/nutriment/protein/cooked = 80, /datum/reagent/capsaicin = 3)
	nutriment_desc = list("manliest meat" = 10, "hot chili peppers" = 3)
	cooked = TRUE

/obj/item/reagent_containers/food/sliceable/brownie
	name = "brownies"
	desc = "A huge rectangular brownie ready to be sliced and shared."
	icon = 'icons/obj/cwj_cooking/cwj_food.dmi'
	icon_state = "brownies"
	trash = /obj/item/trash/dish/tray
	filling_color = "#362008"
	slice_path = /obj/item/reagent_containers/food/brownieslice
	slices_num = 5
	nutriment_amt = 150
	nutriment_desc = list("buttery goodness" = 10, "sweetness" = 10, "chocolate" = 15)
	cooked = TRUE

/obj/item/reagent_containers/food/brownieslice
	name = "brownie slice"
	desc = "A delicious and buttery chocolate brownie, pairs perfectly with ice cream!"
	icon = 'icons/obj/cwj_cooking/cwj_food.dmi'
	icon_state = "brownieslice"
	filling_color = "#362008"
	trash = /obj/item/trash/dish/plate
	bitesize = 15
	nutriment_amt = 30
	nutriment_desc = list("buttery goodness" = 5, "sweetness" = 5, "chocolate" = 10)
	cooked = TRUE

/obj/item/reagent_containers/food/beefcurry
	name = "beef curry"
	desc = "A piping hot plate of spicy beef curry atop fluffy, steamed white rice."
	icon = 'icons/obj/cwj_cooking/cwj_food.dmi'
	icon_state = "beefcurry"
	trash = /obj/item/trash/dish/bowl
	bitesize = 25
	startswith = list(/datum/reagent/nutriment/protein/cooked = 60, /datum/reagent/capsaicin = 2)
	nutriment_desc = list("beef" = 5, "curry" = 5, "spiciness" = 2)
	cooked = TRUE

/obj/item/reagent_containers/food/chickencurry
	name = "poultry curry"
	desc = "A piping hot plate of spicy poultry curry atop fluffy, steamed white rice."
	icon = 'icons/obj/cwj_cooking/cwj_food.dmi'
	icon_state = "chickencurry"
	trash = /obj/item/trash/dish/bowl
	bitesize = 25
	startswith = list(/datum/reagent/nutriment/protein/cooked = 60, /datum/reagent/capsaicin = 2)
	nutriment_desc = list("chicken" = 5, "curry" = 5, "spiciness" = 2)
	cooked = TRUE

/obj/item/reagent_containers/food/mashpotatoes
	name = "mashed potatoes"
	desc = "Soft and fluffy mashed potatoes, the perfect side dish for a variety of meats."
	icon = 'icons/obj/cwj_cooking/cwj_food.dmi'
	icon_state = "mashpotatoes"
	trash = /obj/item/trash/dish/plate
	bitesize = 25
	nutriment_amt = 60
	nutriment_desc = list("mashed potatoes" = 5, "butter" = 2)
	cooked = TRUE

/obj/item/reagent_containers/food/sashimi
	name = "sashimi"
	desc = "Raw cuts of carp fillet with a side of soy sauce, apparently an eastern earth delicacy."
	icon = 'icons/obj/cwj_cooking/cwj_food.dmi'
	icon_state = "sashimi"
	trash = /obj/item/trash/dish/plate
	bitesize = 15
	nutriment_amt = 30
	startswith = list(/datum/reagent/nutriment/protein = 30)
	nutriment_desc = list("raw fish" = 2, "soy sauce" = 2)
	cooked = TRUE

/obj/item/reagent_containers/food/blt
	name = "BLT"
	desc = "A classic sandwich composed of nothing more than bacon, lettuce and tomato."
	icon = 'icons/obj/cwj_cooking/cwj_food.dmi'
	icon_state = "blt"
	bitesize = 15
	nutriment_amt = 30
	startswith = list(/datum/reagent/nutriment/protein/cooked = 30)
	nutriment_desc = list("toasted bread" = 3, "bacon" = 3, "tomato" = 2)
	cooked = TRUE

/obj/item/reagent_containers/food/nigiri
	name = "nigiri"
	desc = "Raw cuts of fish on top of rice."
	icon = 'icons/obj/cwj_cooking/cwj_food.dmi'
	icon_state = "nigiri"
	bitesize = 15
	nutriment_amt = 35
	startswith = list(/datum/reagent/nutriment/protein = 35)
	nutriment_desc = list("raw fish" = 1, "rice" = 2)
	cooked = TRUE

/obj/item/reagent_containers/food/makiroll
	name = "maki roll"
	desc = "A long roll of fish, rice and vegetables, ready to cut into multiple makis."
	icon = 'icons/obj/cwj_cooking/cwj_food.dmi'
	icon_state = "makiroll"
	slice_path = /obj/item/reagent_containers/food/maki
	slices_num = 3
	bitesize = 25
	nutriment_amt = 60
	startswith = list(/datum/reagent/nutriment/protein = 45)
	nutriment_desc = list("raw fish" = 1, "rice" = 2, "soy sauce" = 2)
	cooked = TRUE

/obj/item/reagent_containers/food/maki
	name = "maki"
	desc = "Rice, fish, vegetables and soy sauce held together."
	icon = 'icons/obj/cwj_cooking/cwj_food.dmi'
	icon_state = "maki"
	bitesize = 15
	nutriment_amt = 25
	startswith = list(/datum/reagent/nutriment/protein = 15)
	nutriment_desc = list("raw fish" = 1, "rice" = 1, "soy sauce" = 1)
	cooked = TRUE

/datum/reagent/drink/juice/pineapple
	name = "Pineapple Juice"
	description = "Some tangy juice pressed from a pineapple."
	color = "#f7d436"
	taste_description = "pineapple juice"
	glass_name = "pineapple juice"
	glass_desc = "A glass of tangy pineapple juice."

/datum/reagent/nutriment/mayo
	name = "Mayonnaise"
	description = "A thick, creamy dressing made from egg yolks and oil."
	reagent_state = LIQUID
	color = "#ffffe6"
	taste_description = "mayonnaise"

/datum/reagent/nutriment/mustard
	name = "Mustard"
	description = "A tangy yellow condiment made from mustard seeds."
	reagent_state = LIQUID
	color = "#e6b800"
	taste_description = "mustard"

/datum/reagent/nutriment/vinegar
	name = "Vinegar"
	description = "An acidic liquid used in cooking and pickling."
	reagent_state = LIQUID
	color = "#f2e6d9"
	taste_description = "sour vinegar"

/datum/reagent/nutriment/cheddar
	name = "Melted Cheese"
	description = "Warm, gooey melted cheese."
	reagent_state = SOLID
	color = "#ffcc00"
	taste_description = "cheese"

/datum/reagent/nutriment/batter
	name = "Batter"
	description = "A liquid mixture of flour, egg, and milk used for cooking."
	reagent_state = LIQUID
	color = "#fff2cc"
	taste_description = "raw batter"

/datum/reagent/nutriment/cakebatter
	name = "Cake Batter"
	description = "A sweet batter mixture ready for baking into a cake."
	reagent_state = LIQUID
	color = "#fff5cc"
	taste_description = "sweet batter"

/datum/reagent/nutriment/dough
	name = "Dough"
	description = "A malleable mixture of flour and liquid."
	reagent_state = SOLID
	color = "#f5e6cc"
	taste_description = "raw dough"

/datum/reagent/nutriment/butter
	name = "Butter"
	description = "Churned dairy fat used for baking and frying."
	reagent_state = SOLID
	color = "#ffeb99"
	taste_description = "butter"

/datum/reagent/nutriment/peanutbutter
	name = "Peanut Butter"
	description = "A rich paste made from ground roasted peanuts."
	reagent_state = SOLID
	color = "#b37700"
	taste_description = "peanut butter"

/datum/reagent/nutriment/vanilla
	name = "Vanilla Extract"
	description = "A fragrant extract used to flavor baked goods and desserts."
	reagent_state = LIQUID
	color = "#4d2600"
	taste_description = "vanilla"
