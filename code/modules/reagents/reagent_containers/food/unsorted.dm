
//////////////////////////////////////////////////
//////////////////////////////////////////// Formerly known as Snacks
//////////////////////////////////////////////////
//Items in this category are food items that people actually eat. The key points are that they are created
//	already filled with reagents and are destroyed when empty. Additionally, they make a "munching" noise when eaten.

//Notes by Darem: Food in the "snacks" subtype can hold a maximum of 50 ml Generally speaking, you don't want to go over 40
//	total for the item because you want to leave space for extra condiments. If you want effect besides healing, add a reagent for
//	it. Try to stick to existing reagents when possible (so if you want a stronger healing effect, just use Tricordrazine). On use
//	effect (such as the old officer eating a donut code) requires a unique reagent (unless you can figure out a better way).

//The nutriment reagent and bitesize variable replace the old heal_amt and amount variables. Each ml of nutriment is equal to
//	2 of the old heal_amt variable. Bitesize is the rate at which the reagents are consumed. So if you have 6 nutriment and a
//	bitesize of 2, then it'll take 3 bites to eat. Unlike the old system, the contained reagents are evenly spread among all
//	the bites. No more contained reagents = no more bites.

//Here is an example of the new formatting for anyone who wants to add more food items.
///obj/item/reagent_containers/food/xenoburger			//Identification path for the object.
//	name = "Xenoburger"													//Name that displays in the UI.
//	desc = "Smells caustic. Tastes like heresy."						//Duh
//	icon_state = "xburger"												//Refers to an icon in food.dmi
//	New()																//Don't mess with this.
//		..()															//Same here.
//		reagents.add_reagent(/datum/reagent/xenomicrobes, 10)						//This is what is in the food item. you may copy/paste
//		reagents.add_reagent(/datum/reagent/nutriment, 2)							//	this line of code for all the contents.
//		bitesize = 3													//This is the amount each bite consumes.

/obj/item/reagent_containers/food/ingested_chunk
	name = "chewed mess"
	desc = "Disguisting, half-digested chunk of some sort of food."
	icon_state = "ingested_chunk"
	nutriment_amt = 0
	volume = 0.1 LITER
	static_volume = TRUE
	bitesize = 3
	w_class = ITEM_SIZE_TINY

/obj/item/reagent_containers/food/ingested_chunk/proc/split_from(obj/item/reagent_containers/food/RC, mob/M)
	if(!RC)
		qdel(src)
		return
	if(RC.reagents.total_volume > RC.bitesize)
		RC.reagents.trans_to(src, RC.bitesize)
	else
		RC.reagents.trans_to(src, RC.reagents.total_volume)
	color = reagents.get_color()
	if(prob(50))
		desc += " It appears to still have tiny bits of [RC] in it... Gross."
	else
		desc += " It's impossible to tell what it was prior to getting chewed and swallowed... Gross."
	RC.bitecount++
	RC.update_icon()
	RC.On_Consume(M)

// Mystery soup base
/obj/item/reagent_containers/food/badrecipe
	name = "Burned mess"
	desc = "Someone should be demoted from chef for this."
	icon_state = "badrecipe"
	filling_color = "#211f02"
	center_of_mass = "x=16;y=12"
	startswith = list(
		/datum/reagent/toxin = 0.5,
		/datum/reagent/nutriment/oil/burned = 0.5,
		/datum/reagent/carbon = 1
		)
	bitesize = 0.5 // 15 nutrition, 4 bites

// MRE
/obj/item/reagent_containers/food/liquidfood
	name = "\improper LiquidFood MRE"
	desc = "A prepackaged grey slurry for all of the essential nutrients a soldier requires to survive. No expiration date is visible..."
	icon_state = "liquidfood"
	trash = /obj/item/trash/liquidfood
	filling_color = "#a8a8a8"
	center_of_mass = "x=16;y=15"
	nutriment_desc = list("wet dust" = 1)
	nutriment_amt = 16
	startswith = list(
		/datum/reagent/iron = 0.5,
		/datum/reagent/nutriment/glucose = 3)
	bitesize = 2.5 // 315 nutrition, 8 bites

// Meaty stuff
/obj/item/reagent_containers/food/meatsteak
	name = "Meat steak"
	desc = "A piece of hot spicy meat."
	icon_state = "meatstake"
	trash = /obj/item/trash/dish/plate
	filling_color = "#7a3d11"
	center_of_mass = "x=16;y=13"
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 15,
		/datum/reagent/salt = 1,
		/datum/reagent/blackpepper = 1
		)
	bitesize = 2.5 // 370 nutrition, 6 bites

/obj/item/reagent_containers/food/loadedsteak
	name = "Loaded steak"
	desc = "A steak slathered in sauce with sauteed onions and mushrooms."
	icon_state = "meatstake"
	trash = /obj/item/trash/dish/plate
	filling_color = "#7a3d11"
	center_of_mass = "x=16;y=13"
	nutriment_desc = list("onion" = 2, "mushrooms" = 2)
	nutriment_amt = 1.5
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 15,
		/datum/reagent/salt = 1,
		/datum/reagent/blackpepper = 1,
		/datum/reagent/nutriment/protein/fungal = 3.5,
		/datum/reagent/nutriment/garlicsauce = 1
		)
	bitesize = 3 // 458.75 nutrition, 7 bites

/obj/item/reagent_containers/food/porkchop
	name = "Pork chop"
	desc = "This steak tastes like haram."
	icon_state = "porkchop"
	trash = /obj/item/trash/dish/plate
	filling_color = "#7a3d11"
	center_of_mass = "x=16;y=13"
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 15,
		/datum/reagent/salt = 1,
		/datum/reagent/blackpepper = 1
		)
	bitesize = 2.5 // 370 nutrition, 6 bites

/obj/item/reagent_containers/food/meatbun
	name = "Meatbun"
	desc = "Has the potential to not be a dog."
	icon_state = "meatbun"
	center_of_mass = "x=15;y=15"
	nutriment_desc = list("bread" = 2, "cabbage" = 1)
	nutriment_amt = 18
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 3,
		/datum/reagent/nutriment/protein/cooked = 2.5,
		/datum/reagent/nutriment/soysauce = 0.5
		)
	bitesize = 3 // 322.5 nutrition, 8 bites

/obj/item/reagent_containers/food/wingfangchu
	name = "Wing Fang Chu"
	desc = "A savory dish of alien wing wang in soy."
	icon_state = "wingfangchu"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#43de18"
	center_of_mass = "x=17;y=9"
	nutriment_desc = list("alien wing wang" = 5)
	nutriment_amt = 4.5
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 10,
		/datum/reagent/nutriment/soysauce = 0.5
		)
	bitesize = 3.0 // 300 nutrition, 5 bites

/obj/item/reagent_containers/food/meatkabob
	name = "Meat-kabob"
	icon_state = "kabob"
	desc = "Delicious meat, on a stick."
	trash = /obj/item/stack/rods
	filling_color = "#a85340"
	center_of_mass = "x=17;y=15"
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 10
		)
	bitesize = 2 // 250 nutrition, 5 bites

// Tofu
/obj/item/reagent_containers/food/tofukabob
	name = "Tofu-kabob"
	icon_state = "kabob"
	desc = "Vegan meat, on a stick."
	trash = /obj/item/stack/rods
	filling_color = "#fffee0"
	center_of_mass = "x=17;y=15"
	nutriment_amt = 15
	nutriment_desc = list("tofu" = 2, "metal" = 1)
	bitesize = 3 // 150 nutrition, 5 bites

/obj/item/reagent_containers/food/stewedsoymeat
	name = "Stewed Soy Meat"
	desc = "Even non-vegetarians will LOVE this!"
	icon_state = "stewedsoymeat"
	trash = /obj/item/trash/dish/plate
	center_of_mass = "x=16;y=10"
	nutriment_desc = list("soy" = 4, "tomato" = 4)
	nutriment_amt = 22.5
	bitesize = 3 // 225 nutrition, 8 bites

/obj/item/reagent_containers/food/tofurkey
	name = "Tofurkey"
	desc = "A fake turkey made from tofu."
	icon_state = "tofurkey"
	filling_color = "#fffee0"
	center_of_mass = "x=16;y=8"
	nutriment_amt = 12
	nutriment_desc = list("turkey" = 3, "tofu" = 5, "goeyness" = 4)
	bitesize = 3

/obj/item/reagent_containers/food/stuffing
	name = "Stuffing"
	desc = "Moist, peppery breadcrumbs for filling the body cavities of dead birds. Dig in!"
	icon_state = "stuffing"
	filling_color = "#c9ac83"
	center_of_mass = "x=16;y=10"
	nutriment_amt = 3
	nutriment_desc = list("dryness" = 2, "bread" = 2)
	bitesize = 1

// Fish
/obj/item/reagent_containers/food/fishfingers
	name = "Fish Fingers"
	desc = "A finger of fish."
	icon_state = "fishfingers"
	filling_color = "#ffdefe"
	center_of_mass = "x=16;y=13"
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 6.5,
		/datum/reagent/nutriment/protein/gluten/cooked = 1.5,
		)
	bitesize = 2 // 200 nutrition, 4 bites

/obj/item/reagent_containers/food/fishandchips
	name = "Fish and Chips"
	desc = "I do say so myself chap."
	icon_state = "fishandchips"
	filling_color = "#e3d796"
	center_of_mass = "x=16;y=16"
	nutriment_desc = list("fish" = 2, "chips" = 2)
	nutriment_amt = 6
	startswith = list(
		/datum/reagent/nutriment/protein = 11,
		/datum/reagent/nutriment/oil = 3
		)
	bitesize = 2.5 // 425 nutrition, 8 bites

/obj/item/reagent_containers/food/cubancarp
	name = "Cuban Carp"
	desc = "A sandwich that burns your tongue and then leaves it numb!"
	icon_state = "cubancarp"
	trash = /obj/item/trash/dish/plate
	filling_color = "#e9adff"
	center_of_mass = "x=12;y=5"
	nutriment_desc = list("fish" = 3, "toasted bread" = 2)
	nutriment_amt = 12
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 3,
		/datum/reagent/nutriment/protein/cooked = 10,
		/datum/reagent/capsaicin = 0.5
		)
	bitesize = 3 // 445 nutrition, 9 bites

// Popcorn
/obj/item/reagent_containers/food/popcorn
	name = "Popcorn"
	desc = "Now let's find some cinema."
	icon_state = "popcorn"
	trash = /obj/item/trash/popcorn
	var/unpopped = 0
	filling_color = "#fffad4"
	center_of_mass = "x=16;y=8"
	nutriment_desc = list("popcorn" = 3)
	nutriment_amt = 11
	bitesize = 0.1

	startswith = list(
		/datum/reagent/salt = 1,
		/datum/reagent/nutriment/oil = 3
		)
	bitesize = 1 // 200 nutrition, 20 bites

/obj/item/reagent_containers/food/popcorn/Initialize()
	. = ..()
	unpopped = rand(1, 10)

/obj/item/reagent_containers/food/popcorn/On_Consume()
	if(prob(unpopped))	//lol ...what's the point?
		to_chat(usr, SPAN("warning", "You bite down on an un-popped kernel!"))
		unpopped = max(0, unpopped - 1)
	..()

// Veggies
/obj/item/reagent_containers/food/eggplantparm
	name = "Eggplant Parmigiana"
	desc = "The only good recipe for eggplant."
	icon_state = "eggplantparm"
	trash = /obj/item/trash/dish/plate
	filling_color = "#4d2f5e"
	center_of_mass = "x=16;y=11"
	nutriment_desc = list("cheese" = 3, "eggplant" = 3)
	nutriment_amt = 13
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 2
		)
	bitesize = 3 // 180 nutrition, 5 bites

/obj/item/reagent_containers/food/loadedbakedpotato
	name = "Loaded Baked Potato"
	desc = "Totally baked."
	icon_state = "loadedbakedpotato"
	filling_color = "#9c7a68"
	center_of_mass = "x=16;y=10"
	nutriment_desc = list("baked potato" = 2, "cheese" = 2)
	nutriment_amt = 11
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 1
		)
	bitesize = 2.5 // 140 nutrition, 5 bites

// Fries
/obj/item/reagent_containers/food/fries
	name = "Space Fries"
	desc = "AKA: French Fries, Freedom Fries, etc."
	icon_state = "fries"
	trash = /obj/item/trash/dish/plate
	filling_color = "#eddd00"
	center_of_mass = "x=16;y=11"
	nutriment_desc = list("fresh fries" = 4)
	nutriment_amt = 6
	startswith = list(
		/datum/reagent/nutriment/oil = 3
		)
	bitesize = 1.5 // 150 nutrition, 6 bites

/obj/item/reagent_containers/food/cheesyfries
	name = "Cheesy Fries"
	desc = "Fries. Covered in cheese. Duh."
	icon_state = "cheesyfries"
	trash = /obj/item/trash/dish/plate
	filling_color = "#eddd00"
	center_of_mass = "x=16;y=11"
	nutriment_desc = list("fresh fries" = 4, "cheese" = 3)
	nutriment_amt = 10
	startswith = list(
		/datum/reagent/nutriment/oil = 3,
		/datum/reagent/nutriment/protein/cooked = 1
		)
	bitesize = 2.5 // 215 nutrition, 6 bites

/obj/item/reagent_containers/food/onionrings
	name = "Onion Rings"
	desc = "Like circular fries but better."
	icon_state = "onionrings"
	trash = /obj/item/trash/dish/plate
	filling_color = "#eddd00"
	center_of_mass = "x=16;y=11"
	nutriment_desc = list("fried onions" = 3)
	nutriment_amt = 7.5
	startswith = list(
		/datum/reagent/nutriment/protein/gluten = 1,
		/datum/reagent/nutriment/oil = 1.5
		)
	bitesize = 2.5 // 145 nutrition, 4 bites

// Pelmeni
/obj/item/reagent_containers/food/pelmeni
	name = "Pelmeni"
	desc = "Meat wrapped in thin uneven dough."
	icon_state = "pelmeni"
	filling_color = "#d9be29"
	center_of_mass = "x=16;y=4"
	nutriment_amt = 15
	nutriment_desc = list("raw pelmeni" = 1)
	startswith = list(
		/datum/reagent/nutriment/protein/gluten = 3,
		/datum/reagent/nutriment/protein = 2.5
		)
	bitesize = 2.5 // 282.5 nutrition, 8 bites

/obj/item/reagent_containers/food/boiledpelmeni
	name = "Boiled Pelmeni"
	desc = "We don't know what was Siberia, but these tasty pelmeni definitely arrived from there."
	icon_state = "boiledpelmeni"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#d9be29"
	center_of_mass = "x=16;y=4"
	nutriment_amt = 15
	nutriment_desc = list("pelmeni" = 1)
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 3,
		/datum/reagent/nutriment/protein/cooked = 2.5
		)
	bitesize = 2.5 // 282.5 nutrition, 8 bites

// Noodles
/obj/item/reagent_containers/food/boiledspagetti
	name = "Boiled Spaghetti"
	desc = "A plain dish of noodles, this sucks."
	icon_state = "spagettiboiled"
	trash = /obj/item/trash/dish/plate
	filling_color = "#fcee81"
	center_of_mass = "x=16;y=10"
	nutriment_desc = list("noodles" = 2)
	nutriment_amt = 4
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 1
		)
	bitesize = 1.5 // 65 nutrition, 4 bites

/obj/item/reagent_containers/food/pastatomato
	name = "Spaghetti"
	desc = "Spaghetti and crushed tomatoes. Just like your abusive father used to make!"
	icon_state = "pastatomato"
	trash = /obj/item/trash/dish/plate
	filling_color = "#de4545"
	center_of_mass = "x=16;y=10"
	nutriment_desc = list("tomato" = 3, "noodles" = 3)
	nutriment_amt = 6
	startswith = list(/datum/reagent/drink/juice/tomato = 2.5)
	bitesize = 4

	nutriment_amt = 16
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 1,
		/datum/reagent/drink/juice/tomato = 3
		)
	bitesize = 2.5 // 200 nutrition, 8 bites

/obj/item/reagent_containers/food/faggotspagetti
	name = "Spaghetti & Faggots"
	desc = "Now thats a nic'e faggot!"
	icon_state = "faggotspagetti"
	trash = /obj/item/trash/dish/plate
	filling_color = "#de4545"
	center_of_mass = "x=16;y=10"
	nutriment_desc = list("noodles" = 4)
	nutriment_amt = 6
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 1,
		/datum/reagent/nutriment/protein/cooked = 5
		)
	bitesize = 2 // 210 nutrition, 6 bites

/obj/item/reagent_containers/food/spesslaw
	name = "Spesslaw"
	desc = "A lawyers favourite."
	icon_state = "spesslaw"
	filling_color = "#de4545"
	center_of_mass = "x=16;y=10"
	nutriment_desc = list("noodles" = 4)
	nutriment_amt = 6
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 1,
		/datum/reagent/nutriment/protein/cooked = 10
		)
	bitesize = 3 // 335 nutrition, 6 bites

/obj/item/reagent_containers/food/beefnoodles
	name = "Beef noodles"
	desc = "So simple, but so yummy!"
	icon_state = "beefnoodles"
	trash = /obj/item/trash/dish/bowl
	center_of_mass = "x=15;y=15"
	nutriment_amt = 4
	startswith = list(/datum/reagent/nutriment/protein = 7)
	bitesize = 2

/obj/item/reagent_containers/food/chowmein
	name = "Chowmein"
	desc = "Nihao!"
	icon_state = "chowmein"
	trash = /obj/item/trash/dish/plate
	center_of_mass = "x=15;y=15"
	nutriment_amt = 6
	startswith = list(/datum/reagent/nutriment/protein = 6)
	bitesize = 3

/obj/item/reagent_containers/food/lasagna
	name = "Lasagna"
	desc = "You can hide a bomb in the lasagna"
	icon_state = "lasagna"
	center_of_mass = "x=15;y=15"
	nutriment_amt = 75
	nutriment_desc = list("lasagna" = 3)
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 7.5,
		/datum/reagent/nutriment/protein/gluten = 1.5)
	bitesize = 3 // 300 nutrition, 6 bites

// Rice
/obj/item/reagent_containers/food/boiledrice
	name = "Boiled Rice"
	desc = "A boring dish of boring rice."
	icon_state = "boiledrice"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#fffbdb"
	center_of_mass = "x=17;y=11"
	nutriment_desc = list("rice" = 2)
	nutriment_amt = 12.5
	bitesize = 2.5 // 125 nutrition, 5 bites

/obj/item/reagent_containers/food/ricepudding
	name = "Rice Pudding"
	desc = "Where's the jam?"
	icon_state = "rpudding"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#fffbdb"
	center_of_mass = "x=17;y=11"
	nutriment_desc = list("milk" = 2, "rice" = 2)
	nutriment_amt = 12.5
	startswith = list(
		/datum/reagent/drink/milk/cream = 2.5
		)
	bitesize = 3 // 162.5 nutrition, 5 bites

/obj/item/reagent_containers/food/risotto
	name = "Risotto"
	desc = "An offer you daga kotowaru."
	icon_state = "risotto"
	center_of_mass = "x=15;y=15"
	nutriment_desc = list("rice" = 2)
	nutriment_amt = 7.5
	startswith = list(
		/datum/reagent/ethanol/wine = 2.5,
		/datum/reagent/nutriment/protein/cooked = 1
		)
	bitesize = 2.5 // 200 nutrition, 5 bites

/obj/item/reagent_containers/food/ricewithmeat
	name = "Rice with meat"
	desc = "This is rice and... 'pork'."
	icon_state = "ricewithmeat"
	trash = /obj/item/trash/dish/bowl
	center_of_mass = "x=15;y=15"
	nutriment_amt = 10
	startswith = list(/datum/reagent/nutriment/protein = 5)
	bitesize = 3

/obj/item/reagent_containers/food/eggbowl
	name = "Eggbowl"
	desc = "Bowl of eggs. Of course."
	icon_state = "eggbowl"
	trash = /obj/item/trash/dish/bowl
	center_of_mass = "x=15;y=15"
	nutriment_amt = 10
	bitesize = 3

/obj/item/reagent_containers/food/boiledmetroidcore
	name = "Boiled metroid Core"
	desc = "A boiled red thing."
	icon_state = "boiledrorocore"
	startswith = list(/datum/reagent/metroidjelly = 1)
	bitesize = 5

/obj/item/reagent_containers/food/plumphelmetbiscuit
	name = "plump helmet biscuit"
	desc = "This is a finely-prepared plump helmet biscuit. The ingredients are exceptionally minced plump helmet, and well-minced dwarven wheat flour."
	icon_state = "phelmbiscuit"
	filling_color = "#cfb4c4"
	center_of_mass = "x=16;y=13"
	nutriment_desc = list("heartiness" = 2, "mushroom" = 4)
	nutriment_amt = 12.5
	bitesize = 3 // 125+ nutrition, 5+ bites

/obj/item/reagent_containers/food/plumphelmetbiscuit/Initialize()
	. = ..()
	var/quality = rand(1, 100)
	switch(quality)
		if(100)
			name = "Planepacked Pie"
			desc = "This is a plump helmet biscuit. All craftsdwarfship is of the highest quality. It is encrusted with Limestone, Gypsum, Native platinum, Magnetite, Limonite and Malachite, studded with Pig iron, decorated with cave lobster shell and dog leather and encircled with bands of Limestone, Gypsum, Magnetite, Native gold, Malachite, Limonite and Oak. This object is adorned with hanging rings of Limestone, Gypsum, Native platinum, Magnetite and Limonite and menaces with spikes of Limestone, Gypsum, Magnetite, Limonite, Malachite, Orthoclase, Steel and Brown jasper. On the item is an image of Fok'Byiond the Invisible virology airlock in Limestone."
			reagents.add_reagent(/datum/reagent/adminordrazine, 1)
		if(97 to 99)
			name = "¤plump helmet biscuit¤"
			desc = "Microwave is taken by a fey mood! It has cooked a masterful plump helmet biscuit!"
			reagents.add_reagent(/datum/reagent/tricordrazine, 1.5)
			reagents.add_reagent(/datum/reagent/drink/doctor_delight, 3)
		if(91 to 96)
			name = "≡plump helmet biscuit≡"
			desc = "It's an exceptional plump helmet biscuit. I bet you love stuff made out of plump helmets!"
			reagents.add_reagent(/datum/reagent/tricordrazine, 1.5)
			reagents.add_reagent(/datum/reagent/drink/doctor_delight, 1.5)
		if(81 to 90)
			name = "*plump helmet biscuit*"
			desc = "It's a superior quality plump helmet biscuit. I bet you love stuff made out of plump helmets!"
			reagents.add_reagent(/datum/reagent/tricordrazine, 1.5)
		if(66 to 80)
			name = "+plump helmet biscuit+"
			desc = "It's a finely-cooked plump helmet biscuit. I bet you love stuff made out of plump helmets!"
			reagents.add_reagent(/datum/reagent/tricordrazine, 1)
		if(46 to 65)
			name = "-plump helmet biscuit-"
			desc = "It's a well-cooked plump helmet biscuit. I bet you love stuff made out of plump helmets!"
			reagents.add_reagent(/datum/reagent/tricordrazine, 0.5)

/obj/item/reagent_containers/food/dionaroast
	name = "roast diona"
	desc = "It's like an enormous, leathery carrot. With an eye."
	icon_state = "dionaroast"
	trash = /obj/item/trash/dish/plate
	filling_color = "#75754b"
	center_of_mass = "x=16;y=7"
	nutriment_desc = list("a chorus of flavor" = 6)
	nutriment_amt = 30
	startswith = list(
		/datum/reagent/radium = 1
	)
	bitesize = 3 // 298 nutrition, 10 bites

/obj/item/reagent_containers/food/monkeysdelight
	name = "monkey's Delight"
	desc = "Eeee Eee!"
	icon_state = "monkeysdelight"
	trash = /obj/item/trash/dish/tray
	filling_color = "#5c3c11"
	center_of_mass = "x=16;y=13"
	startswith = list(
		/datum/reagent/nutriment/protein = 1,
		/datum/reagent/drink/juice/banana = 0.5,
		/datum/reagent/blackpepper = 1,
		/datum/reagent/salt = 1
		)
	bitesize = 3

/obj/item/reagent_containers/food/julienne
	name = "Julienne"
	desc = "This is not the Julien, which you can think of, but also nice."
	icon_state = "julienne"
	center_of_mass = "x=15;y=15"
	nutriment_amt = 1
	startswith = list(
		/datum/reagent/nutriment/protein = 1,
		/datum/reagent/drink/juice/onion = 1
		)
	bitesize = 3

/obj/item/reagent_containers/food/quiche
	name = "Quiche"
	desc = "Makes you feel more intelligent. Give to lower lifeforms!"
	icon_state = "quiche"
	trash = /obj/item/trash/dish/plate
	center_of_mass = "x=15;y=15"
	nutriment_amt = 3
	nutriment_desc = list("intelligence" = 3)
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 5.5,
		/datum/reagent/drink/juice/tomato = 1,
		/datum/reagent/drink/juice/garlic = 0.5
		)
	bitesize = 3 // 175 nutrition, 4 bites

// Mexican
/obj/item/reagent_containers/food/taco
	name = "taco"
	desc = "Take a bite!"
	icon_state = "taco"
	center_of_mass = "x=21;y=12"
	nutriment_desc = list("cheese" = 2,"taco shell" = 2)
	nutriment_amt = 8
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 6,
		/datum/reagent/nutriment/protein/gluten = 1
		)
	bitesize = 3 // 255 nutrition, 5 bites

/obj/item/reagent_containers/food/enchiladas
	name = "Enchiladas"
	desc = "Viva La Mexico!"
	icon_state = "enchiladas"
	trash = /obj/item/trash/dish/tray
	filling_color = "#a36a1f"
	center_of_mass = "x=16;y=13"
	nutriment_desc = list("tortilla" = 3, "corn" = 3)
	nutriment_amt = 12.5
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 5
		)
	bitesize = 3 // 250 nutrition, 6 bites

// Nachos
/obj/item/reagent_containers/food/nachos
	name = "Nachos"
	desc = "Hola!"
	icon_state = "nachos"
	trash = /obj/item/trash/dish/plate
	center_of_mass = "x=15;y=15"
	nutriment_amt = 5
	startswith = list(
		/datum/reagent/salt = 1)
	bitesize = 3

/obj/item/reagent_containers/food/cheesenachos
	name = "Cheese nachos"
	desc = "Cheese hola!"
	icon_state = "cheesenachos"
	trash = /obj/item/trash/dish/plate
	center_of_mass = "x=15;y=15"
	nutriment_amt = 7
	startswith = list(
		/datum/reagent/salt = 1
		)
	bitesize = 4

/obj/item/reagent_containers/food/cubannachos
	name = "Cuban nachos"
	desc = "Very hot hola!"
	icon_state = "cubannachos"
	trash = /obj/item/trash/dish/plate
	center_of_mass = "x=15;y=15"
	nutriment_amt = 7
	startswith = list(
		/datum/reagent/salt = 1,
		/datum/reagent/capsaicin = 3
		)
	bitesize = 4

// Burritos
/obj/item/reagent_containers/food/burrito
	name = "Burrito"
	desc = "Some really tasty."
	icon_state = "burrito"
	center_of_mass = "x=15;y=15"
	nutriment_amt = 8
	startswith = list(
		/datum/reagent/nutriment/soysauce = 2
		)
	bitesize = 4

/obj/item/reagent_containers/food/cheeseburrito
	name = "Cheese burrito"
	desc = "Is it really necessary to say something here?"
	icon_state = "cheeseburrito"
	center_of_mass = "x=15;y=15"
	nutriment_amt = 10
	startswith = list(
		/datum/reagent/nutriment/soysauce = 2
		)
	bitesize = 4

/obj/item/reagent_containers/food/carnaburrito
	name = "Carna de Asada burrito"
	desc = "Like a classical burrito, but with some meat."
	icon_state = "carnaburrito"
	center_of_mass = "x=15;y=15"
	nutriment_amt = 8
	startswith = list(
		/datum/reagent/nutriment/protein = 3,
		/datum/reagent/nutriment/soysauce = 1
		)
	bitesize = 4

/obj/item/reagent_containers/food/plasmaburrito
	name = "Fuego Plasma Burrito"
	desc = "Very hot, amigos."
	icon_state = "plasmaburrito"
	center_of_mass = "x=15;y=15"
	nutriment_amt = 8
	startswith = list(
		/datum/reagent/capsaicin = 4
		)
	bitesize = 4

// Waffles
/obj/item/reagent_containers/food/waffles
	name = "waffles"
	desc = "Mmm, waffles."
	icon_state = "waffles"
	trash = /obj/item/trash/dish/baking_sheet
	filling_color = "#e6deb5"
	center_of_mass = "x=15;y=11"
	nutriment_desc = list("waffle" = 3)
	nutriment_amt = 9
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 2,
		/datum/reagent/sugar = 1
		)
	bitesize = 2.5 // 190 nutrition, 6 bites

/obj/item/reagent_containers/food/rofflewaffles
	name = "Roffle Waffles"
	desc = "Waffles from Roffle. Co."
	icon_state = "rofflewaffles"
	trash = /obj/item/trash/dish/baking_sheet
	filling_color = "#ff00f7"
	center_of_mass = "x=15;y=11"
	nutriment_desc = list("waffle" = 3)
	nutriment_amt = 9
	startswith = list(
		/datum/reagent/nutriment/protein/gluten/cooked = 2,
		/datum/reagent/sugar = 1,
		/datum/reagent/psilocybin = 1
		)
	bitesize = 2.5 // 187 nutrition, 6 bites

/obj/item/reagent_containers/food/soylentgreen
	name = "Soylent Green"
	desc = "Not made of people. Honest." //Totally people.
	icon_state = "soylent_green"
	trash = /obj/item/trash/dish/baking_sheet
	filling_color = "#b8e6b5"
	center_of_mass = "x=15;y=11"
	nutriment_amt = 5
	nutriment_desc = list("some sort of protein" = 10)
	startswith = list(
		/datum/reagent/nutriment/protein/cooked = 10
		)
	bitesize = 3 // 300 nutrition, 5 bites

/obj/item/reagent_containers/food/soylenviridians
	name = "Soylen Virdians"
	desc = "Not made of people. Honest." //Actually honest for once.
	icon_state = "soylent_yellow"
	trash = /obj/item/trash/dish/baking_sheet
	filling_color = "#e6fa61"
	center_of_mass = "x=15;y=11"
	nutriment_amt = 15
	nutriment_desc = list("some sort of protein" = 5)
	bitesize = 3 // 150 nutrition, 5 bites

// Weird jellies
/obj/item/reagent_containers/food/spacylibertyduff
	name = "Spacy Liberty Duff"
	desc = "Jello gelatin, from Alfred Hubbard's cookbook."
	icon_state = "spacylibertyduff"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#42b873"
	center_of_mass = "x=16;y=8"
	nutriment_desc = list("liberty" = 3)
	nutriment_amt = 9
	startswith = list(
		/datum/reagent/ethanol = 1,
		/datum/reagent/psilocybin = 1
		)
	bitesize = 2.5 // 90 nutrition, 4 bites

/obj/item/reagent_containers/food/amanitajelly
	name = "Amanita Jelly"
	desc = "Looks curiously toxic."
	icon_state = "amanitajelly"
	trash = /obj/item/trash/dish/bowl
	filling_color = "#ed0758"
	center_of_mass = "x=16;y=5"
	nutriment_desc = list("jelly" = 3, "mushroom" = 3)
	nutriment_amt = 9
	startswith = list(
		/datum/reagent/ethanol = 1,
		/datum/reagent/psilocybin = 1
		)
	bitesize = 2.5 // 90 nutrition, 4 bites

// Sandwiches
/obj/item/reagent_containers/food/sandwich
	name = "Sandwich"
	desc = "A grand creation of meat, cheese, bread, and several leaves of lettuce! Arthur Dent would be proud."
	icon_state = "sandwich"
	trash = /obj/item/trash/dish/plate
	filling_color = "#d9be29"
	center_of_mass = "x=16;y=4"
	nutriment_desc = list("bread" = 3, "cheese" = 3)
	nutriment_amt = 3
	startswith = list(/datum/reagent/nutriment/protein = 3)
	bitesize = 2

/obj/item/reagent_containers/food/toastedsandwich
	name = "Toasted Sandwich"
	desc = "Now if you only had a pepper bar."
	icon_state = "toastedsandwich"
	trash = /obj/item/trash/dish/plate
	filling_color = "#d9be29"
	center_of_mass = "x=16;y=4"
	nutriment_desc = list("toasted bread" = 3, "cheese" = 3)
	nutriment_amt = 3
	startswith = list(
		/datum/reagent/nutriment/protein = 3,
		/datum/reagent/carbon = 2)
	bitesize = 2

/obj/item/reagent_containers/food/grilledcheese
	name = "Grilled Cheese Sandwich"
	desc = "Goes great with Tomato soup!"
	icon_state = "toastedsandwich"
	trash = /obj/item/trash/dish/plate
	filling_color = "#d9be29"
	nutriment_desc = list("toasted bread" = 3, "cheese" = 3)
	nutriment_amt = 3
	startswith = list(/datum/reagent/nutriment/protein = 4)
	bitesize = 2

/obj/item/reagent_containers/food/jellysandwich
	name = "Jelly Sandwich"
	desc = "You wish you had some peanut butter to go with this..."
	icon_state = "jellysandwich"
	trash = /obj/item/trash/dish/plate
	filling_color = "#9e3a78"
	center_of_mass = "x=16;y=8"
	nutriment_desc = list("bread" = 2)
	nutriment_amt = 2
	bitesize = 3

/obj/item/reagent_containers/food/jellysandwich/metroid
	startswith = list(/datum/reagent/metroidjelly = 5)

/obj/item/reagent_containers/food/jellysandwich/cherry
	startswith = list(/datum/reagent/nutriment/cherryjelly = 5)

/obj/item/reagent_containers/food/jelliedtoast
	name = "Jellied Toast"
	desc = "A slice of bread covered with delicious jam."
	icon_state = "jellytoast"
	trash = /obj/item/trash/dish/plate
	filling_color = "#b572ab"
	center_of_mass = "x=16;y=8"
	nutriment_desc = list("toasted bread" = 2)
	nutriment_amt = 1
	bitesize = 3

/obj/item/reagent_containers/food/jelliedtoast/cherry
	startswith = list(/datum/reagent/nutriment/cherryjelly = 5)

/obj/item/reagent_containers/food/jelliedtoast/metroid
	startswith = list(/datum/reagent/metroidjelly = 5)
