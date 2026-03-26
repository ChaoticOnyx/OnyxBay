
/obj/item/reagent_containers/food/faggotsoup
	name = "Meatball soup"
	desc = "You've got balls kid, BALLS!"
	icon_state = "faggotsoup"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#785210"
	center_of_mass = "x=16;y=8"
	nutriment_desc = list("meatballs" = 3, "potato" = 2, "carrot" = 2)
	nutriment_amt = 150
	startswith = list(
		/datum/reagent/nutriment/protein = 25,
		/datum/reagent/water = 125
		)
	bitesize = 40 // 212.5 nutrition, 8 bites

/obj/item/reagent_containers/food/fathersoup
	name = "Father's soup"
	desc = "A hellish meal. It's better to refuse politely."
	icon_state = "fathersoup"
	trash = /obj/item/trash/pan
	filling_color = "#f85210"
	center_of_mass = "x=16;y=16"
	nutriment_desc = list("peeling wallpaper" = 1)
	nutriment_amt = 150
	startswith = list(
		/datum/reagent/water = 10,
		/datum/reagent/thermite = 2,
		/datum/reagent/capsaicin = 5)
	bitesize = 40 // God know how many nutrition, some bites, ooh blya

/obj/item/reagent_containers/food/metroidsoup
	name = "metroid soup"
	desc = "If no water is available, you may substitute tears."
	icon_state = "rorosoup"
	filling_color = "#c4dba0"
	nutriment_desc = list("xenoscience" = 1)
	nutriment_amt = 150
	startswith = list(
		/datum/reagent/metroidjelly = 10,
		/datum/reagent/water = 40
		)
	bitesize = 28 // 100 nutrition, 8 bites

/obj/item/reagent_containers/food/bloodsoup
	name = "Tomato soup"
	desc = "Smells like copper."
	icon_state = "tomatosoup"
	filling_color = "#ff0000"
	center_of_mass = "x=16;y=7"
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 40,
		/datum/reagent/blood = 100,
		/datum/reagent/water = 100
		)
	bitesize = 40 // 200 nutrition, 6 bites

/obj/item/reagent_containers/food/clownstears
	name = "Clown's Tears"
	desc = "Not very funny."
	icon_state = "clownstears"
	filling_color = "#c4fbff"
	center_of_mass = "x=16;y=7"
	nutriment_desc = list("salt" = 1, "the worst joke" = 3)
	nutriment_amt = 100
	startswith = list(
		/datum/reagent/drink/juice/banana = 50,
		/datum/reagent/water = 50
		)
	bitesize = 25 // 125 nutrition, 8 bites

/obj/item/reagent_containers/food/vegetablesoup
	name = "Vegetable soup"
	desc = "A highly nutritious blend of vegetative goodness. Guaranteed to leave you with a, er, \"souped-up\" sense of wellbeing."
	icon_state = "vegetablesoup"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#afc4b5"
	center_of_mass = "x=16;y=8"
	nutriment_desc = list("carrot" = 2, "corn" = 2, "eggplant" = 2, "potato" = 2)
	nutriment_amt = 200
	startswith = list(
		/datum/reagent/water = 75
		)
	bitesize = 45 // 200+ nutrition, 7+ bites

/obj/item/reagent_containers/food/nettlesoup
	name = "Nettle soup"
	desc = "A mean, green, calorically lean dish derived from a poisonous plant. It has a rather acidic bite to its taste."
	icon_state = "nettlesoup"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#afc4b5"
	center_of_mass = "x=16;y=7"
	nutriment_desc = list("salad" = 4, "egg" = 2, "potato" = 2)
	nutriment_amt = 125
	startswith = list(
		/datum/reagent/nutriment/protein/egg/cooked = 45,
		/datum/reagent/water = 70,
		/datum/reagent/tricordrazine = 10
		)
	bitesize = 40 // 237.5 nutrition, 7+ bites

/obj/item/reagent_containers/food/mysterysoup
	name = "Mystery soup"
	desc = "The mystery is, why aren't you eating it?"
	icon_state = "mysterysoup"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#f082ff"
	center_of_mass = "x=16;y=6"
	nutriment_desc = list("backwash" = 1)
	nutriment_amt = 50
	bitesize = 40 // No fucking clue

/obj/item/reagent_containers/food/mysterysoup/Initialize()
	. = ..()
	var/mysteryselect = rand(1, 10)
	switch(mysteryselect)
		if(1)
			reagents.add_reagent(/datum/reagent/nutriment, 60)
			reagents.add_reagent(/datum/reagent/capsaicin, 30)
			reagents.add_reagent(/datum/reagent/drink/juice/tomato, 20)
		if(2)
			reagents.add_reagent(/datum/reagent/nutriment, 60)
			reagents.add_reagent(/datum/reagent/frostoil, 3)
			reagents.add_reagent(/datum/reagent/drink/juice/tomato, 20)
		if(3)
			reagents.add_reagent(/datum/reagent/nutriment, 50)
			reagents.add_reagent(/datum/reagent/water, 50)
			reagents.add_reagent(/datum/reagent/tricordrazine, 5)
		if(4)
			reagents.add_reagent(/datum/reagent/nutriment, 50)
			reagents.add_reagent(/datum/reagent/water, 100)
		if(5)
			reagents.add_reagent(/datum/reagent/nutriment, 20)
			reagents.add_reagent(/datum/reagent/drink/juice/banana, 100)
		if(6)
			reagents.add_reagent(/datum/reagent/nutriment, 60)
			reagents.add_reagent(/datum/reagent/blood, 100)
		if(7)
			reagents.add_reagent(/datum/reagent/metroidjelly, 10)
			reagents.add_reagent(/datum/reagent/water, 100)
		if(8)
			reagents.add_reagent(/datum/reagent/nutriment, 50)
			reagents.add_reagent(/datum/reagent/carbon, 10)
			reagents.add_reagent(/datum/reagent/toxin, 10)
		if(9)
			reagents.add_reagent(/datum/reagent/nutriment, 50)
			reagents.add_reagent(/datum/reagent/drink/juice/tomato, 100)
		if(10)
			reagents.add_reagent(/datum/reagent/nutriment, 60)
			reagents.add_reagent(/datum/reagent/drink/juice/tomato, 50)
			reagents.add_reagent(/datum/reagent/imidazoline, 5)

/obj/item/reagent_containers/food/wishsoup
	name = "Wish Soup"
	desc = "I wish this was soup."
	icon_state = "wishsoup"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#d1f4ff"
	center_of_mass = "x=16;y=11"
	startswith = list(/datum/reagent/water = 100)
	bitesize = 25 // 0 or 100 nutrition, 8 bites

/obj/item/reagent_containers/food/wishsoup/Initialize()
	. = ..()
	if(prob(25))
		desc = "A wish come true!"
		reagents.add_reagent(/datum/reagent/nutriment, 100, list("something good" = 8))
	else
		reagents.add_reagent(/datum/reagent/water, 100)

/obj/item/reagent_containers/food/hotchili
	name = "Hot Chili"
	desc = "A five alarm Texan Chili!"
	icon_state = "hotchili"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#ff3c00"
	center_of_mass = "x=15;y=9"
	nutriment_desc = list("chilli peppers" = 3)
	nutriment_amt = 20
	startswith = list(
		/datum/reagent/nutriment/protein = 150,
		/datum/reagent/capsaicin = 5,
		/datum/reagent/drink/juice/tomato = 25)
	bitesize = 25 // 407.5 nutrition, 8 bites

/obj/item/reagent_containers/food/coldchili
	name = "Cold Chili"
	desc = "This slush is barely a liquid!"
	icon_state = "coldchili"
	filling_color = "#2b00ff"
	center_of_mass = "x=15;y=9"
	nutriment_desc = list("chilly peppers" = 3)
	nutriment_amt = 20
	startswith = list(
		/datum/reagent/nutriment/protein = 150,
		/datum/reagent/frostoil = 5,
		/datum/reagent/drink/juice/tomato = 25)
	bitesize = 25 // 407.5 nutrition, 8 bites

/obj/item/reagent_containers/food/tomatosoup
	name = "Tomato Soup"
	desc = "Drinking this feels like being a vampire! A tomato vampire..."
	icon_state = "tomatosoup"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#d92929"
	center_of_mass = "x=16;y=7"
	nutriment_desc = list("soup" = 5)
	nutriment_amt = 150
	startswith = list(
		/datum/reagent/drink/juice/tomato = 50
		)
	bitesize = 25 // 175 nutrition, 8 bites

/obj/item/reagent_containers/food/stew
	name = "Stew"
	desc = "A nice and warm stew. Healthy and strong."
	icon_state = "stew"
	filling_color = "#9e673a"
	center_of_mass = "x=16;y=5"
	nutriment_desc = list("tomato" = 2, "potato" = 2, "carrot" = 2, "eggplant" = 2, "mushroom" = 2)
	nutriment_amt = 100
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 150,
		/datum/reagent/drink/juice/tomato = 25,
		/datum/reagent/imidazoline = 5,
		/datum/reagent/water = 20)
	bitesize = 40 // 487.5 nutrition, 8 bites

/obj/item/reagent_containers/food/milosoup
	name = "Milosoup"
	desc = "The universes best soup! Yum!!!"
	icon_state = "milosoup"
	trash = /obj/item/trash/dish/bowl
	center_of_mass = "x=16;y=7"
	nutriment_desc = list("soy" = 8)
	nutriment_amt = 250
	startswith = list(
		/datum/reagent/water = 50
		)
	bitesize = 40 // 250 nutrition, 8 bites

/obj/item/reagent_containers/food/mushroomsoup
	name = "chantrelle soup"
	desc = "A delicious and hearty mushroom soup."
	icon_state = "mushroomsoup"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#e386bf"
	center_of_mass = "x=17;y=10"
	nutriment_desc = list("mushroom" = 8, "milk" = 2)
	nutriment_amt = 200
	bitesize = 25 // 200 nutrition, 8 bites

/obj/item/reagent_containers/food/beetsoup
	name = "beet soup"
	desc = "Wait, how do you spell it again..?"
	icon_state = "beetsoup"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#fac9ff"
	center_of_mass = "x=15;y=8"
	nutriment_desc = list("tomato" = 4, "beet" = 4)
	nutriment_amt = 200
	bitesize = 25 // 200 nutrition, 8 bites

/obj/item/reagent_containers/food/beetsoup/Initialize()
	. = ..()
	name = pick(list("borsch","bortsch","borstch","borsh","borshch","borscht"))
