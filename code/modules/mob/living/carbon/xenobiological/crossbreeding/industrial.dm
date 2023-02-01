/*
Industrial extracts:
	Slowly consume plasma, produce items with it.
*/
/obj/item/metroidcross/industrial
	name = "industrial extract"
	desc = "A gel-like, sturdy extract, fond of plasma and industry."
	effect = "industrial"
	icon_state = "industrial_still"
	var/plasmarequired = 2 //Units of plasma required to be consumed to produce item.
	var/itempath = /obj/item //The item produced by the extract.
	var/plasmaabsorbed = 0 //Units of plasma aborbed by the extract already. Absorbs at a rate of 2u/obj tick.
	var/itemamount = 1 //How many items to spawn

/obj/item/metroidcross/industrial/_examine_text(mob/user)
	. = ..()
	. += "It currently has [plasmaabsorbed] units of plasma floating inside the outer shell, out of [plasmarequired] units."

/obj/item/metroidcross/industrial/proc/do_after_spawn(obj/item/spawned)
	return

/obj/item/metroidcross/industrial/Initialize(mapload)
	. = ..()
	create_reagents(100)
	//FIXME START_PROCESSING(SSobj,src)

/obj/item/metroidcross/industrial/Destroy()
	//FIXME STOP_PROCESSING(SSobj,src)
	return ..()

/obj/item/metroidcross/industrial/think()
	var/IsWorking = FALSE
	if(reagents.has_reagent(/datum/reagent/toxin/plasma,amount = 2) && plasmarequired > 1) //Can absorb as much as 2
		IsWorking = TRUE
		reagents.remove_reagent(/datum/reagent/toxin/plasma,2)
		plasmaabsorbed += 2
	else if(reagents.has_reagent(/datum/reagent/toxin/plasma,amount = 1)) //Can absorb as little as 1
		IsWorking = TRUE
		reagents.remove_reagent(/datum/reagent/toxin/plasma,1)
		plasmaabsorbed += 1

	if(plasmaabsorbed >= plasmarequired)
		playsound(src, 'sound/effects/attackblob.ogg', 50, TRUE)
		plasmaabsorbed -= plasmarequired
		for(var/i in 1 to itemamount)
			do_after_spawn(new itempath(get_turf(src)))
	else if(IsWorking)
		playsound(src, 'sound/effects/bubbles.ogg', 5, TRUE)
	if(IsWorking)
		icon_state = "industrial"
	else
		icon_state = "industrial_still"

/obj/item/metroidcross/industrial/grey
	colour = "grey"
	effect_desc = "Produces monkey cubes."
	itempath = /obj/item/reagent_containers/food/monkeycube
	itemamount = 5

/obj/item/metroidcross/industrial/orange
	colour = "orange"
	effect_desc = "Produces slime zippo lighters."
	plasmarequired = 6
	//FIXME itempath = /obj/item/lighter/slime

/obj/item/metroidcross/industrial/purple
	colour = "purple"
	effect_desc = "Produces autoinjectors with regen jelly inside."
	plasmarequired = 5
	itempath = /obj/item/metroidcrossbeaker/autoinjector/regenpack

/obj/item/metroidcross/industrial/blue
	colour = "blue"
	effect_desc = "Produces full fire extinguishers."
	plasmarequired = 10
	itempath = /obj/item/extinguisher

/obj/item/metroidcross/industrial/metal
	colour = "metal"
	effect_desc = "Produces iron sheets."
	plasmarequired = 3
	//FIXME itempath = /obj/item/stack/sheet/iron/ten

/obj/item/metroidcross/industrial/yellow
	colour = "yellow"
	effect_desc = "Produces high capacity power cells, which are not fully charged on creation."
	plasmarequired = 5
	//FIXME itempath = /obj/item/stock_parts/cell/high

/obj/item/metroidcross/industrial/yellow/do_after_spawn(obj/item/spawned)
	var/obj/item/cell/high/C = spawned
	if(istype(C))
		C.charge = rand(0,C.maxcharge/2)

/obj/item/metroidcross/industrial/darkpurple
	colour = "dark purple"
	effect_desc = "Produces plasma... for plasma."
	plasmarequired = 10
	//FIXME itempath = /obj/item/stack/sheet/mineral/plasma

/obj/item/metroidcross/industrial/darkblue
	colour = "dark blue"
	effect_desc = "Produces one-use fireproofing potions."
	plasmarequired = 6
	//FIXME itempath = /obj/item/metroidpotion/fireproof

/obj/item/metroidcross/industrial/darkblue/do_after_spawn(obj/item/spawned)
	/*FIXME var/obj/item/metroidpotion/fireproof/potion = spawned
	if(istype(potion))
		potion.uses = 1*/

/obj/item/metroidcross/industrial/silver
	colour = "silver"
	effect_desc = "Produces random food and drink items."
	plasmarequired = 1
	//Item picked below.

/obj/item/metroidcross/industrial/silver/think()
	//FIXME itempath = pick(list(get_random_food(), get_random_drink()))

/obj/item/metroidcross/industrial/silver/do_after_spawn(obj/item/spawned)
	if(istype(spawned, /obj/item/reagent_containers/food))
		var/obj/item/reagent_containers/food/food_object = spawned
		//FIXME food_object.mark_silver_slime_reaction()

/obj/item/metroidcross/industrial/bluespace
	colour = "bluespace"
	effect_desc = "Produces synthetic bluespace crystals."
	plasmarequired = 7
	//FIXME itempath = /obj/item/stack/ore/bluespace_crystal/artificial

/obj/item/metroidcross/industrial/sepia
	colour = "sepia"
	effect_desc = "Produces cameras."
	plasmarequired = 2
	//FIXME itempath = /obj/item/camera

/obj/item/metroidcross/industrial/cerulean
	colour = "cerulean"
	effect_desc = "Produces normal slime extract enhancers."
	plasmarequired = 5
	//FIXME itempath = /obj/item/metroidpotion/enhancer

/obj/item/metroidcross/industrial/pyrite
	colour = "pyrite"
	effect_desc = "Produces cans of spraypaint."
	plasmarequired = 2
	//FIXME itempath = /obj/item/toy/crayon/spraycan

/obj/item/metroidcross/industrial/red
	colour = "red"
	effect_desc = "Produces blood orbs."
	plasmarequired = 5
	itempath = /obj/item/metroidcrossbeaker/bloodpack

/obj/item/metroidcross/industrial/green
	colour = "green"
	effect_desc = "Produces self-use-only slime jelly autoinjectors."
	plasmarequired = 7
	//FIXME itempath = /obj/item/metroidcrossbeaker/autoinjector/slimejelly

/obj/item/metroidcross/industrial/pink
	colour = "pink"
	effect_desc = "Produces synthpax and space drug autoinjectors."
	plasmarequired = 6
	itempath = /obj/item/metroidcrossbeaker/autoinjector/peaceandlove

/obj/item/metroidcross/industrial/gold
	colour = "gold"
	effect_desc = "Produces random coins."
	plasmarequired = 10

/obj/item/metroidcross/industrial/gold/think()
	//FIXME itempath = pick(/obj/item/material/coin/silver, /obj/item/material/coin/iron, /obj/item/material/coin/gold, /obj/item/material/coin/diamond, /obj/item/material/coin/plasma, /obj/item/material/coin/uranium)

/obj/item/metroidcross/industrial/oil
	colour = "oil"
	effect_desc = "Produces IEDs."
	plasmarequired = 4
	//FIXME itempath = /obj/item/grenade/iedcasing/spawned

/obj/item/metroidcross/industrial/black //What does this have to do with black slimes? No clue! Fun, though
	colour = "black"
	effect_desc = "Produces slime brand regenerative cigarettes."
	plasmarequired = 6
	//FIXME itempath = /obj/item/storage/fancy/cigarettes/cigpack_xeno

/obj/item/metroidcross/industrial/lightpink
	colour = "light pink"
	effect_desc = "Produces heart shaped boxes that have candies in them."
	plasmarequired = 3
	//FIXME itempath = /obj/item/storage/fancy/heart_box

/obj/item/metroidcross/industrial/adamantine
	colour = "adamantine"
	effect_desc = "Produces sheets of adamantine."
	plasmarequired = 10
	//FIXME itempath = /obj/item/stack/sheet/mineral/adamantine

/obj/item/metroidcross/industrial/rainbow
	colour = "rainbow"
	effect_desc = "Produces random slime extracts."
	plasmarequired = 5
	//Item picked below.

/obj/item/metroidcross/industrial/rainbow/think()
	itempath = pick(subtypesof(/obj/item/metroid_extract))
