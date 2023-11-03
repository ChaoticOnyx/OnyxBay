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
	var/itempath = null //The item produced by the extract.
	var/plasmaabsorbed = 0 //Units of plasma aborbed by the extract already. Absorbs at a rate of 2u/obj per every 3 seconds.
	var/itemamount = 1 //How many items to spawn

/obj/item/metroidcross/industrial/_examine_text(mob/user)
	. = ..()
	. += "It currently has [plasmaabsorbed] units of plasma floating inside the outer shell, out of [plasmarequired] units."

/obj/item/metroidcross/industrial/proc/do_after_spawn(obj/item/spawned)
	return

/obj/item/metroidcross/industrial/Initialize(mapload)
	. = ..()
	create_reagents(100)
	set_next_think(world.time + 5 SECOND)


/obj/item/metroidcross/industrial/Destroy()
	set_next_think(0)
	return ..()

/obj/item/metroidcross/industrial/think()
	var/IsWorking = FALSE
	if(reagents.has_reagent(/datum/reagent/toxin/plasma, 2) && plasmarequired > 1) //Can absorb as much as 2
		IsWorking = TRUE
		reagents.remove_reagent(/datum/reagent/toxin/plasma,2)
		plasmaabsorbed += 2
	else if(reagents.has_reagent(/datum/reagent/toxin/plasma, 1)) //Can absorb as little as 1
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

	set_next_think(world.time + 5 SECOND)

/obj/item/metroidcross/industrial/grey
	colour = "grey"
	effect_desc = "Produces self-use-only metroid jelly autoinjectors."
	plasmarequired = 20
	itempath = /obj/item/metroidcrossbeaker/autoinjector/metroidjelly

/obj/item/metroidcross/industrial/orange
	colour = "orange"
	effect_desc = "Produces metroid zippo lighters."
	plasmarequired = 20
	itempath = /obj/item/flame/lighter/zippo/metroid

/obj/item/metroidcross/industrial/purple
	colour = "purple"
	effect_desc = "Produces autoinjectors with regen jelly inside."
	plasmarequired = 20
	itempath = /obj/item/metroidcrossbeaker/autoinjector/regenpack

/obj/item/metroidcross/industrial/blue
	colour = "blue"
	effect_desc = "Produces full fire extinguishers."
	plasmarequired = 20
	itempath = /obj/item/extinguisher

/obj/item/metroidcross/industrial/metal
	colour = "metal"
	effect_desc = "Produces iron sheets."
	plasmarequired = 10
	itempath = /obj/item/stack/material/steel/ten

/obj/item/metroidcross/industrial/yellow
	colour = "yellow"
	effect_desc = "Produces high capacity power cells, which are not fully charged on creation."
	plasmarequired = 15
	itempath = /obj/item/cell/high

/obj/item/metroidcross/industrial/yellow/do_after_spawn(obj/item/spawned)
	var/obj/item/cell/high/C = spawned
	if(istype(C))
		C.charge = rand(0,C.maxcharge/2)

/obj/item/metroidcross/industrial/darkpurple
	colour = "dark purple"
	effect_desc = "Produces plasma... for plasma."
	plasmarequired = 20
	itempath = /obj/item/stack/material/plasma

/obj/item/metroidcross/industrial/darkblue
	colour = "dark blue"
	effect_desc = "Produces one-use fireproofing potions."
	plasmarequired = 20
	itempath = /obj/item/chill_potion

/obj/item/metroidcross/industrial/darkblue/do_after_spawn(obj/item/spawned)
	var/obj/item/chill_potion/potion = spawned
	if(istype(potion))
		potion.uses = 1

/obj/item/metroidcross/industrial/silver
	colour = "silver"
	effect_desc = "Produces random food and drink items."
	plasmarequired = 30
	itempath = /obj/item/reagent_containers/food/candy_corn

/obj/item/metroidcross/industrial/silver/do_after_spawn(obj/item/spawned)
	itempath = pick(typesof(/obj/item/reagent_containers/food) - /obj/item/reagent_containers/food)
	new itempath(get_turf(src.loc))

/obj/item/metroidcross/industrial/bluespace
	colour = "bluespace"
	effect_desc = "Produces bluespace crystals."
	plasmarequired = 10
	itempath = /obj/item/stack/telecrystal/bluespace_crystal

/obj/item/metroidcross/industrial/sepia
	colour = "sepia"
	effect_desc = "Produces cameras."
	plasmarequired = 20
	itempath = /obj/item/device/camera

/obj/item/metroidcross/industrial/cerulean
	colour = "cerulean"
	effect_desc = "Produces normal metroid extract enhancers."
	plasmarequired = 30
	itempath = /obj/item/metroidsteroid2

/obj/item/metroidcross/industrial/pyrite
	colour = "pyrite"
	effect_desc = "Produces crayons."
	plasmarequired = 20
	itempath = /obj/item/storage/fancy/crayons

/obj/item/metroidcross/industrial/red
	colour = "red"
	effect_desc = "Produces blood orbs."
	plasmarequired = 30
	itempath = /obj/item/metroidcrossbeaker/bloodpack

/obj/item/metroidcross/industrial/green
	colour = "green"
	effect_desc = "Produces monkey cubes."
	itempath = /obj/item/reagent_containers/food/monkeycube
	itemamount = 1
	plasmarequired = 10

/obj/item/metroidcross/industrial/pink
	colour = "pink"
	effect_desc = "Produces paroxetine and space drug autoinjectors."
	plasmarequired = 15
	itempath = /obj/item/metroidcrossbeaker/autoinjector/peaceandlove

/obj/item/metroidcross/industrial/gold
	colour = "gold"
	effect_desc = "Produces random coins."
	plasmarequired = 20

/obj/item/metroidcross/industrial/gold/think()
	itempath = pick(/obj/item/material/coin/silver, /obj/item/material/coin/iron, /obj/item/material/coin/gold, /obj/item/material/coin/diamond, /obj/item/material/coin/plasma, /obj/item/material/coin/uranium)
	set_next_think(world.time + 1 MINUTE)

/obj/item/metroidcross/industrial/oil
	colour = "oil"
	effect_desc = "Produces grenade casings."
	plasmarequired = 20
	itempath = /obj/item/grenade/chem_grenade

/obj/item/metroidcross/industrial/black //What does this have to do with black metroids? No clue! Fun, though
	colour = "black"
	effect_desc = "Produces cigarettes."
	plasmarequired = 20

/obj/item/metroidcross/industrial/black/Initialize()
	itempath = pick(subtypesof(/obj/item/storage/fancy/cigarettes))
	..()

/obj/item/metroidcross/industrial/lightpink
	colour = "light pink"
	effect_desc = "Produces heart shaped boxes that have food in them."
	plasmarequired = 20
	itempath = /obj/item/storage/lunchbox/heart/filled

/obj/item/metroidcross/industrial/adamantine
	colour = "adamantine"
	effect_desc = "Produces sheet of platinum!."
	plasmarequired = 50
	itempath = /obj/item/stack/material/platinum

/obj/item/metroidcross/industrial/rainbow
	colour = "rainbow"
	effect_desc = "Produces random metroid extracts."
	plasmarequired = 40
	//Item picked below.

/obj/item/metroidcross/industrial/rainbow/Initialize()
	itempath = pick(subtypesof(/obj/item/metroid_extract))
	..()
