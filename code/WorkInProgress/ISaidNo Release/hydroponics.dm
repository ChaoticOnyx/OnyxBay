// the entire hydroponics.dm file

// Harvesting is on Line 785

/datum/plantgenes/
	var/growtime = 0
	var/harvtime = 0
	var/harvests = 0
	var/cropsize = 0
	var/potency = 0
	var/endurance = 0
	var/mutantvar = 0 // Automatic
	var/list/commuts = list() // General transferrable mutations

/datum/plant/
	// Standard variables for plants are added here
	var/name = "plant species name" // Name of the plant species
	var/harvtype = null
	var/crop = null // What crop does this plant produce?
	var/seed = null // What seed does this plant produce?
	var/growthmode = "normal" // What mode this plant normally grows as
	var/starthealth = 0 // What health does this plant start at?
	var/growtime = 0 // How long it takes this plant to mature
	var/harvtime = 0 // How long it takes this plant to produce harvests after maturing
	var/cropsize = 0 // How many items you get per harvest
	var/harvestable = 1 // Does this plant even produce anything
	var/harvests = 0 // How many times you can harvest this species
	var/endurance = 0 // How much endurance this species normally has
	var/mutcrop1 = null // If mutantvar = 1, what crop does this plant produce
	var/mutcrop2 = null // If mutantvar = 2, what crop does this plant produce
	var/mutcrop3 = null // If mutantvar = 3, what crop does this plant produce
	var/mutable = 0 // Can it mutate? If so how many mutant variants does it have
	var/isvine = 0 // Minor sprite based thing
	var/isgrass = 0 // Always dies after one harvest
	var/list/commuts = list() // What general mutations can occur in this plant?

/datum/plant/tomato
	name = "tomato"
	harvtype = "fruit"
	crop = /obj/item/weapon/reagent_containers/food/snacks/plant/tomato
	seed = /obj/item/weapon/seed/tomato
	starthealth = 20
	growtime = 75
	harvtime = 110
	cropsize = 3
	harvests = 3
	endurance = 3
	mutable = 0
	//mutcrop1 = /obj/item/weapon/reagent_containers/food/snacks/plant/tomato/explosive
	//mutcrop2 = /obj/critter/killertomato

/datum/plant/grape
	name = "grape"
	harvtype = "fruit"
	crop = /obj/item/weapon/reagent_containers/food/snacks/plant/grape
	seed = /obj/item/weapon/seed/grape
	starthealth = 5
	growtime = 40
	harvtime = 120
	cropsize = 5
	harvests = 2
	endurance = 0
	isvine = 1

/datum/plant/orange
	name = "orange"
	harvtype = "fruit"
	crop = /obj/item/weapon/reagent_containers/food/snacks/plant/orange
	seed = /obj/item/weapon/seed/orange
	starthealth = 20
	growtime = 60
	harvtime = 100
	cropsize = 2
	harvests = 3
	endurance = 3

/datum/plant/melon
	name = "melon"
	harvtype = "fruit"
	crop = /obj/item/weapon/reagent_containers/food/snacks/plant/melon
	seed = /obj/item/weapon/seed/melon
	starthealth = 80
	growtime = 120
	harvtime = 200
	cropsize = 2
	harvests = 5
	endurance = 5
	commuts = list("immortal","seedless")

/datum/plant/cannabis
	name = "cannabis"
	harvtype = "plant"
	crop = /obj/item/weapon/plant/cannabis
	seed = /obj/item/weapon/seed/cannabis
	starthealth = 10
	growtime = 30
	harvtime = 80
	cropsize = 6
	harvests = 1
	endurance = 0
	isgrass = 1
	mutable = 3
	mutcrop1 = /obj/item/weapon/plant/cannabis/mega
	mutcrop2 = /obj/item/weapon/plant/cannabis/black
	mutcrop3 = /obj/item/weapon/plant/cannabis/white

/datum/plant/chili
	name = "chili"
	harvtype = "fruit"
	crop = /obj/item/weapon/reagent_containers/food/snacks/plant/chili
	seed = /obj/item/weapon/seed/chili
	starthealth = 20
	growtime = 60
	harvtime = 100
	cropsize = 3
	harvests = 3
	endurance = 3
	mutable = 1
	mutcrop1 = /obj/item/weapon/reagent_containers/food/snacks/plant/chili/chilly

/datum/plant/synthmeat
	name = "synthmeat"
	crop = /obj/item/weapon/reagent_containers/food/snacks/ingredient/meat/synthmeat
	seed = /obj/item/weapon/seed/synthmeat
	starthealth = 5
	growtime = 60
	harvtime = 120
	cropsize = 3
	harvests = 2
	endurance = 3

/datum/plant/apple
	name = "apple"
	harvtype = "fruit"
	crop = /obj/item/weapon/reagent_containers/food/snacks/plant/apple
	seed = /obj/item/weapon/seed/apple
	starthealth = 40
	growtime = 200
	harvtime = 260
	cropsize = 3
	harvests = 10
	endurance = 5

/datum/plant/banana
	name = "banana"
	harvtype = "fruit"
	crop = /obj/item/weapon/reagent_containers/food/snacks/plant/banana
	seed = /obj/item/weapon/seed/banana
	starthealth = 15
	growtime = 120
	harvtime = 160
	cropsize = 5
	harvests = 4
	endurance = 3

/datum/plant/lime
	name = "lime"
	harvtype = "fruit"
	crop = /obj/item/weapon/reagent_containers/food/snacks/plant/lime
	seed = /obj/item/weapon/seed/lime
	starthealth = 30
	growtime = 30
	harvtime = 100
	cropsize = 3
	harvests = 3
	endurance = 3

/datum/plant/lemon
	name = "lemon"
	harvtype = "fruit"
	crop = /obj/item/weapon/reagent_containers/food/snacks/plant/lemon
	seed = /obj/item/weapon/seed/lemon
	starthealth = 30
	growtime = 100
	harvtime = 130
	cropsize = 3
	harvests = 3
	endurance = 3

/datum/plant/wheat
	name = "wheat"
	harvtype = "plant"
	crop = /obj/item/weapon/plant/wheat
	seed = /obj/item/weapon/seed/wheat
	starthealth = 15
	growtime = 40
	harvtime = 80
	cropsize = 5
	harvests = 1
	isgrass = 1
	endurance = 0
	mutable = 1
	mutcrop1 = /obj/item/weapon/plant/wheat/metal

/datum/plant/sugar
	name = "sugar"
	harvtype = "plant"
	crop = /obj/item/weapon/plant/sugar
	seed = /obj/item/weapon/seed/sugar
	starthealth = 10
	growtime = 30
	harvtime = 60
	cropsize = 7
	harvests = 1
	isgrass = 1
	endurance = 0

/datum/plant/contusine
	name = "contusine"
	harvtype = "plant"
	crop = /obj/item/weapon/plant/contusine
	seed = /obj/item/weapon/seed/contusine
	starthealth = 20
	growtime = 30
	harvtime = 100
	cropsize = 5
	harvests = 1
	isgrass = 1
	endurance = 0

/datum/plant/nureous
	name = "nureous"
	harvtype = "plant"
	crop = /obj/item/weapon/plant/nureous
	seed = /obj/item/weapon/seed/nureous
	starthealth = 20
	growtime = 30
	harvtime = 100
	cropsize = 5
	harvests = 1
	isgrass = 1
	endurance = 0

/datum/plant/asomna
	name = "asomna"
	harvtype = "plant"
	crop = /obj/item/weapon/plant/asomna
	seed = /obj/item/weapon/seed/asomna
	starthealth = 20
	growtime = 30
	harvtime = 100
	cropsize = 5
	harvests = 1
	isgrass = 1
	endurance = 0

/datum/plant/commol
	name = "commol"
	harvtype = "plant"
	crop = /obj/item/weapon/plant/commol
	seed = /obj/item/weapon/seed/commol
	starthealth = 20
	growtime = 30
	harvtime = 100
	cropsize = 5
	harvests = 1
	isgrass = 1
	endurance = 0

/datum/plant/venne
	name = "venne"
	harvtype = "plant"
	crop = /obj/item/weapon/plant/venne
	seed = /obj/item/weapon/seed/venne
	starthealth = 20
	growtime = 30
	harvtime = 100
	cropsize = 5
	harvests = 1
	isgrass = 1
	endurance = 0

/datum/plant/lettuce
	name = "lettuce"
	harvtype = "fruit"
	crop = /obj/item/weapon/reagent_containers/food/snacks/plant/lettuce
	seed = /obj/item/weapon/seed/lettuce
	starthealth = 30
	growtime = 40
	harvtime = 80
	cropsize = 8
	harvests = 1
	isgrass = 1
	endurance = 5

/datum/plant/carrot
	name = "carrot"
	harvtype = "fruit"
	crop = /obj/item/weapon/reagent_containers/food/snacks/plant/carrot
	seed = /obj/item/weapon/seed/carrot
	starthealth = 20
	growtime = 50
	harvtime = 100
	cropsize = 6
	harvests = 1
	isgrass = 1
	endurance = 5

/datum/plant/potato
	name = "potato"
	harvtype = "fruit"
	crop = /obj/item/weapon/reagent_containers/food/snacks/plant/potato
	seed = /obj/item/weapon/seed/potato
	starthealth = 40
	growtime = 80
	harvtime = 160
	cropsize = 4
	harvests = 1
	isgrass = 1
	endurance = 10
/* Strumpetplaya - commenting this out as it has components we don't support.
/datum/plant/pumpkin
	name = "pumpkin"
	harvtype = "fruit"
	crop = /obj/item/weapon/reagent_containers/food/snacks/plant/pumpkin
	seed = /obj/item/weapon/seed/pumpkin
	starthealth = 60
	growtime = 100
	harvtime = 175
	cropsize = 2
	harvests = 4
	endurance = 10
*/
/datum/plant/fungus
	name = "fungus"
	growthmode = "weed"
	crop = /obj/item/weapon/reagent_containers/food/snacks/mushroom
	seed = /obj/item/weapon/seed/fungus
	starthealth = 20
	growtime = 30
	harvtime = 250
	harvests = 10
	endurance = 40
	mutable = 2
	cropsize = 3
	mutcrop1 = /obj/item/weapon/reagent_containers/food/snacks/mushroom/amanita
	mutcrop2 = /obj/item/weapon/reagent_containers/food/snacks/mushroom/psilocybin

/datum/plant/lasher
	name = "lasher"
	growthmode = "weed"
	seed = /obj/item/weapon/seed/lasher
	starthealth = 45
	growtime = 50
	harvtime = 100
	harvestable = 0
	endurance = 50
	isgrass = 1

/datum/plant/creeper
	name = "creeper"
	growthmode = "weed"
	seed = /obj/item/weapon/seed/creeper
	starthealth = 30
	growtime = 30
	harvtime = 100
	harvestable = 0
	endurance = 40
	isgrass = 1

/datum/plant/radweed
	name = "radweed"
	growthmode = "weed"
	seed = /obj/item/weapon/seed/radweed
	starthealth = 40
	growtime = 140
	harvtime = 200
	harvestable = 0
	endurance = 80

/datum/plant/slurrypod
	name = "slurrypod"
	growthmode = "weed"
	harvtype = "fruit"
	crop = /obj/item/weapon/reagent_containers/food/snacks/plant/slurryfruit
	seed = /obj/item/weapon/seed/slurrypod
	starthealth = 25
	growtime = 30
	harvtime = 60
	harvests = 1
	cropsize = 3
	endurance = 30
	mutcrop1 = /obj/item/weapon/reagent_containers/food/snacks/plant/slurryfruit/omega

/datum/plant/grass
	name = "grass"
	growthmode = "weed"
	harvtype = "seedonly"
	crop = /obj/item/weapon/seed/grass
	seed = /obj/item/weapon/seed/grass
	isgrass = 1
	starthealth = 5
	growtime = 15
	harvtime = 50
	harvests = 1
	cropsize = 8
	endurance = 10

/datum/plant/maneater
	name = "maneater"
	growthmode = "carnivore"
	seed = /obj/item/weapon/seed/maneater
	starthealth = 40
	growtime = 30
	harvtime = 60
	harvestable = 0
	endurance = 10

/datum/plant/crystal
	name = "crystal"
	growthmode = "boring"
	seed = /obj/item/weapon/shard/crystal
	starthealth = 50
	growtime = 300
	harvtime = 600
	harvestable = 0
	endurance = 100

/datum/plant/plasmabloom
	name = "plasmabloom"
	growthmode = "plasmavore"
	seed = /obj/item/weapon/seed/plasmabloom
	starthealth = 8
	growtime = 120
	harvtime = 360
	harvestable = 0
	endurance = 100

/area/hydroponics
	name = "Hydroponics"
	icon_state = "hydroponics"

/obj/item/clothing/under/rank/hydro
	name = "Hydroponics Jumpsuit"
	icon_state = "hy_suit"
	color = "hydro"

/obj/machinery/plantpot
	name = "plant pot"
	desc = "A tub filled with soil capable of sustaining plantlife."
	icon = 'hydroponics.dmi'
	icon_state = "pot-empty"
	anchored = 1
	density = 1
	//flags = NOSPLASH	 Strumpetplaya - commenting this out as it has components we don't support.
	var/current = null // What is currently growing in the plant pot
	var/plantgenes = null // Set this up in New
	var/plantcond = "normal"  // Automatic. How healthy the plant is.
	var/growth = 0    // Automatic. How developed the plant is.
	var/health = 0    // Set this when you plant a seed. Plant dies when this hits 0.
	var/harvests = 0  // Set this when you plant a seed. How many times you can harvest it before it dies. Plant dies when it hits 0.
	var/endurance = 0 // Automatic. Probability from 0-100 of not losing health/dying to hazards.
	var/isready = 0   // Automatic. Signals whether or not a plant is harvestable right now.
	var/generation = 0 // Automatic. Just a fun thing to track how many generations a plant has been bred.

	New()
		..()
		src.plantgenes = new /datum/plantgenes(src)
		var/datum/reagents/R = new/datum/reagents(360)
		reagents = R
		R.maximum_volume = 360
		R.my_atom = src
		R.add_reagent("water", 200)

	process()
		..()
		if (!src.current && prob(1) && prob(8))
			switch (rand(1,6))
				if (1)
					var/obj/item/weapon/seed/fungus/WS = new(src)
					var/datum/plant/stored = WS.planttype
					var/datum/plantgenes/DNA = WS.plantgenes
					if (stored.mutable && prob(3)) DNA.mutantvar = rand(1,stored.mutable)
					HYPnewplant(WS)
					sleep(5)
					del WS
				if (2)
					var/obj/item/weapon/seed/lasher/WS = new(src)
					HYPnewplant(WS)
					sleep(5)
					del WS
				if (3)
					var/obj/item/weapon/seed/creeper/WS = new(src)
					HYPnewplant(WS)
					sleep(5)
					del WS
				if (4)
					var/obj/item/weapon/seed/radweed/WS = new(src)
					HYPnewplant(WS)
					sleep(5)
					del WS
				if (5)
					var/obj/item/weapon/seed/slurrypod/WS = new(src)
					var/datum/plant/stored = WS.planttype
					var/datum/plantgenes/DNA = WS.plantgenes
					if (stored.mutable && prob(3)) DNA.mutantvar = rand(1,stored.mutable)
					HYPnewplant(WS)
					sleep(5)
					del WS
				if (6)
					var/obj/item/weapon/seed/grass/WS = new(src)
					HYPnewplant(WS)
					sleep(5)
					del WS
			return
		update_icon()
		if (!src.current) return
		if (src.plantcond == "dead") return
		var/datum/plant/growing = src.current
		var/datum/plantgenes/DNA = src.plantgenes
		// BUG CHECKS
		if (growing.growtime < 1) growing.growtime = 1 // negative/null growtime might fuck things up
		if (growing.growtime + DNA.growtime >= growing.harvtime) growing.harvtime = growing.growtime + 2 // harvest must always be higher than grow or bugs will happen
		if (growing.endurance > 100) src.endurance = 100
		if (src.endurance < 0) src.endurance = 0 // want these to always fall within a 0-100 range since it uses prob
		// SOIL REAGENT PROCESSING
		if (src.growth >= growing.harvtime + DNA.harvtime && growing.harvestable) src.isready = 1
		if (growing.growthmode != "nothing" && growing.growthmode != "boring")
			if (src.reagents.has_reagent("water"))
				if (growing.growthmode == "carnivore" && src.growth < 20) src.growth += 1
				if (growing.growthmode == "plasmavore" && src.growth < 40) src.growth += 1
				if (src.reagents.get_reagent_amount("water") <= 200) src.growth += 1
			else
				if (growing.growthmode == "normal" && !prob(src.endurance)) src.health -= 1
				if (growing.growthmode == "carnivore" && !prob(src.endurance)) src.health -= rand(0,1)
			if (src.reagents.has_reagent("poo"))
				src.health += 1
				if (src.reagents.has_reagent("water")) src.reagents.remove_reagent("water", 1)
			if (src.reagents.has_reagent("phosphorus"))
				src.health += 2
				src.growth += 1
				if (src.reagents.has_reagent("water")) src.reagents.remove_reagent("water", 1)
			if (src.reagents.has_reagent("ammonia"))
				src.growth += 2
				src.health += 1
				if (src.reagents.has_reagent("water")) src.reagents.remove_reagent("water", 1)
			if (src.reagents.has_reagent("diethylamine"))
				src.growth += rand(1,2)
				src.health += rand(1,2)
				if (src.reagents.has_reagent("water")) src.reagents.remove_reagent("water", 1)
			if (src.reagents.has_reagent("plant_nutrients"))
				src.growth += 2
				src.health += 2
				if (src.reagents.has_reagent("water")) src.reagents.remove_reagent("water", 1)
			if (src.reagents.has_reagent("plant_nutrients_plus"))
				src.growth += rand(2,4)
				src.health += rand(2,4)
				if (src.reagents.has_reagent("water")) src.reagents.remove_reagent("water", 1)
			if (src.reagents.has_reagent("mutagen") || src.reagents.has_reagent("dna_mutagen") || src.reagents.has_reagent("radium"))
				if (prob(12))
					HYPmutateplant("normal")
					if (!prob(src.endurance)) src.health -= 2
			if (growing.growthmode == "carnivore" && src.reagents.has_reagent("blood") || src.reagents.has_reagent("synthflesh")) src.growth += 3
			if (src.reagents.has_reagent("acid") || src.reagents.has_reagent("pacid"))
				src.growth -= 3
				if (!prob(src.endurance)) src.health -= 2
			if (src.reagents.has_reagent("plasma"))
				if (!growing.growthmode == "plasmavore") src.health -= 5
				else src.growth += 1
			if (src.reagents.has_reagent("fuel") || src.reagents.has_reagent("chlorine") || src.reagents.has_reagent("mercury") || src.reagents.has_reagent("toxin") || src.reagents.has_reagent("toxic_slurry"))
				if (!istype(growing,/datum/plant/slurrypod) && !istype(growing,/datum/plant/radweed) && !prob(src.endurance)) src.health -= 1
			if (src.reagents.has_reagent("weedkiller") && growing.growthmode == "weed") src.health -= 2
			src.reagents.remove_any(1)
		if (growing.growthmode == "weed")
			if (!src.reagents.has_reagent("weedkiller")) src.growth += 1
		if (growing.growthmode == "boring") src.growth += 1

		// SPECIAL PROCS
		if (istype(growing,/datum/plant/plasmabloom) && src.growth > 360)
			var/turf/T = get_turf(src.loc)
			var/datum/gas_mixture/environment = T.return_air()
			if (environment.oxygen > 2)
				environment.oxygen -= 2
				environment.toxins += 2
		if (istype(growing,/datum/plant/maneater) && src.growth > 60 && prob(1))
			var/MEspeech = pick("Feed me!", "I'm hungryyyy...", "Give me blood!", "I'm starving!", "What's for dinner?")
			for(var/mob/O in viewers(src, null)) O.show_message(text("<B>Man-Eating Plant</B> gurgles, '[]'", MEspeech), 1)
		if (istype(growing,/datum/plant/maneater) && src.growth > 120)
			var/obj/critter/maneater/P = new(src.loc)
			P.health = src.health * 2
			for(var/mob/O in viewers(src, null)) O.show_message(text("\blue The man-eating plant climbs out of the pot!"), 1)
			HYPdestroyplant()
			return
		if (istype(growing,/datum/plant/creeper) && src.growth > 35 && src.plantcond != "poor" && prob(15))
			for (var/obj/machinery/plantpot/C in range(1,src))
				if (C.plantcond != "dead" && C.current && !istype(growing,/datum/plant/crystal) && !istype(growing,/datum/plant/creeper)) C.health -= 10
				else if (C.plantcond == "dead") C.HYPdestroyplant()
				else if (!C.current)
					var/obj/item/weapon/seed/creeper/WS = new(src)
					C.HYPnewplant(WS)
					sleep(5)
					del WS
		if (istype(growing,/datum/plant/lasher) && src.growth > 60 && prob(25))
			for (var/mob/living/M in range(1,src))
				if (src.plantcond != "poor") M.bruteloss += 2
				if (prob(25) && src.plantcond != "poor") M.weakened += 3
				for(var/mob/O in viewers(src, null))
					if (src.plantcond == "poor") O.show_message(text("\red <b>[]</b> weakly slaps [] with a vine!", src, M), 1)
					else O.show_message(text("\red <b>[]</b> slashes [] with thorny vines!", src, M), 1)
		if (istype(growing,/datum/plant/radweed) && src.growth > 160 && prob(5))
			for (var/mob/living/carbon/M in range(1,src))
				if (src.plantcond == "poor") M.radiation += 5
				if (src.plantcond == "normal") M.radiation += 10
				if (src.plantcond == "good") M.radiation += 20
				if (src.plantcond == "excellent") M.radiation += 40
				M << "\red You feel uneasy for a moment."
			for (var/obj/machinery/plantpot/C in range(1,src))
				if (src.plantcond == "poor") break
				if (istype(growing,/datum/plant/radweed)) continue
				HYPmutateplant("wild")
				C.health -= rand(0,2)
		if (istype(growing,/datum/plant/slurrypod) && src.growth >= 30) src.reagents.add_reagent("toxic_slurry", 1)
		if (istype(growing,/datum/plant/slurrypod) && src.growth >= 64 && prob(5))
			for(var/mob/O in viewers(src, null)) O.show_message(text("\red <b>[]</b> bursts, sending toxic goop everywhere!", src), 1)
			playsound(src.loc, 'splat.ogg', 50, 1)
			for (var/mob/living/carbon/M in range(3,src))
				if(istype(M:wear_suit, /obj/item/clothing/suit/bio_suit) && istype(M:head, /obj/item/clothing/head/bio_hood))
					M << "\blue You are splashed by toxic goop, but your biosuit protects you!"
					continue
				M << "\red You are splashed by toxic goop!"
				M.reagents.add_reagent("toxic_slurry", rand(5,20))
			for (var/obj/machinery/plantpot/C in range(3,src)) src.reagents.add_reagent("toxic_slurry", rand(5,10))
			src.HYPdestroyplant()
			return
		// CONDITION CHECK
		if (src.health <= growing.starthealth / 2) src.plantcond = "poor"
		else if (src.health >= growing.starthealth * 2)
			if (src.health >= growing.starthealth * 4) src.plantcond = "excellent"
			else src.plantcond = "good"
		else src.plantcond = "normal"
		// DEATH CHECK CODE
		if (src.health < 1)
			HYPkillplant()
			return
		if (src.growth < 0)
			HYPkillplant()
			return
		if (growing.harvestable && src.harvests < 1) HYPkillplant()
		return

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (src.current)
			if (istype(src.current,/datum/plant/crystal))
				if (W.force < 0) user << "\red Your [W] bounces off [src] uselessly!"
				else
					if (prob(W.force))
						for(var/mob/O in viewers(user, null)) O.show_message(text("\blue [] shatters!", src), 1)
						playsound(src.loc, pick('Glassbr1.ogg','Glassbr2.ogg','Glassbr3.ogg'), 100, 1)
						while (src.growth > 100)
							new/obj/item/weapon/shard/crystal(usr.loc)
							src.growth -= 100
						HYPdestroyplant()
					else
						playsound(src.loc, pick('Glasshit.ogg'), 100, 1)
						..()
			if (istype(src.current,/datum/plant/maneater))
				if (istype(W, /obj/item/weapon/grab) && istype(W:affecting, /mob/living/carbon) && istype(src.current,/datum/plant/maneater))
					if (src.growth < 60)
						user << "\red It's not big enough to eat that yet."
						return
					user.visible_message("\red [user] starts to feed [W:affecting] to the plant!")
					src.add_fingerprint(user)
					sleep(50)
					if(W:affecting)
						user.visible_message("\red [user] feeds [W:affecting] to the plant!")
						var/mob/M = W:affecting
						if(M.client)
							var/mob/dead/observer/newmob
							newmob = new/mob/dead/observer(M)
							M:client:mob = newmob
							newmob:client:eye = newmob
							del(M)
						else
							del(M)
						playsound(src.loc, 'eatfood.ogg', 30, 1, -2)
						src.reagents.add_reagent("blood", 60)
						sleep(25)
						//playsound(src.loc, pick('burp_alien.ogg'), 50, 0)	 Strumpetplaya - commenting this out as it has components we don't support.
						return
				else if (istype(W, /obj/item/weapon/reagent_containers/food/snacks/ingredient/meat))
					if (src.growth > 60) user << "\red It's going to need something more substantial than that now..."
					else
						src.reagents.add_reagent("blood", 5)
						user << "\red You toss the [W] to the plant."
						del W
//				else if (istype(W, /obj/item/brain) || istype(W, /obj/item/clothing/head/butt))	 Strumpetplaya - commenting this out as it has components we don't support.
//					src.reagents.add_reagent("blood", 20)
//					user << "\red You toss the [W] to the plant."
//					del W
		if (istype(W, /obj/item/weapon/screwdriver))
			if (src.anchored == 1)
				for(var/mob/O in viewers(user, null))
					O.show_message(text("<b>[]</b> unfastens the [] from the floor.", user, src), 1)
				playsound(src.loc, 'Screwdriver.ogg', 100, 1)
				src.anchored = 0
			else
				for(var/mob/O in viewers(user, null))
					O.show_message(text("<b>[]</b> fastens the [] to the floor.", user, src), 1)
				playsound(src.loc, 'Screwdriver.ogg', 100, 1)
				src.anchored = 1
		else if (istype(W, /obj/item/weapon/weldingtool) || istype(W, /obj/item/weapon/zippo) || istype(W, /obj/item/device/igniter))
			if (istype(W, /obj/item/weapon/weldingtool) && !W:welding)
				user << "\red It would help if you lit it first, dumbass!"
				return
			else if (istype(W, /obj/item/weapon/weldingtool) && W:welding)
				if (W:get_fuel() > 3)
					W:eyecheck(user)
					W:use_fuel(3)
				else
					user << "\red Need more fuel."
					return
			else if (istype(W, /obj/item/weapon/zippo) && !W:lit)
				user << "\red It would help if you lit it first, dumbass!"
				return
			if (src.current)
				if (!prob(src.endurance) || src.plantcond == "dead")
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red [] goes up in flames!", src), 1)
					src.reagents.add_reagent("plant_nutrients", src.growth)
					HYPdestroyplant()
				else
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red [] resists the fire!", src), 1)
					if (istype(src.current,/datum/plant/lasher) && src.growth > 60 && prob(90))
						usr << "\red The plant lashes out at you violently!"
						usr.bruteloss += 3
						if (prob(50))
							usr << "\red The lasher grabs and smashes your [W]!"
							del W
						return
/* Strumpetplaya - commenting this out as it has components we don't support.
		else if(istype(W,/obj/item/weapon/saw))
			if (src.current)
				if (!prob(src.endurance) || src.plantcond == "dead")
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red [] is cut apart!", src), 1)
					HYPdestroyplant()
				else
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red [] resists the []!", src,W), 1)
					if (istype(src.current,/datum/plant/lasher) && src.growth > 60 && prob(90))
						usr << "\red The plant lashes out at you violently!"
						usr.bruteloss += 3
						if (prob(50))
							usr << "\red The lasher hits your [W]!"
							W:damage_health(2)
						return
*/
		else if (istype(W, /obj/item/weapon/seed/))
			var/obj/item/weapon/seed/SEED = W
			if (src.current)
				user << "\red Something is already in that plant pot."
				return
			for(var/mob/O in viewers(user, null)) O.show_message(text("\blue [] plants a seed in the [].", user, src), 1)
			if (SEED.planttype)
				src.HYPnewplant(W)
			else del W
		else if (istype(W, /obj/item/weapon/seedplanter/))
			if (src.current)
				user << "\red Something is already in that plant pot."
				return
			for(var/mob/O in viewers(user, null)) O.show_message(text("\blue [] plants a seed in the [].", user, src), 1)
			var/obj/item/weapon/seed/WS = new W:seedpath(src)
			HYPnewplant(WS)
			sleep(5)
			del WS
		else if (istype(W, /obj/item/weapon/reagent_containers/glass/))
			if (!W.reagents.total_volume)
				user << "\red There is nothing in [W] to pour!"
				return
			else
				for(var/mob/O in viewers(user, null)) O.show_message(text("\blue [] pours [] units of []'s contents into [].", user, W:amount_per_transfer_from_this, W, src), 1)
				playsound(src.loc, 'slosh.ogg', 100, 1)
				W.reagents.trans_to(src, W:amount_per_transfer_from_this)
				if (!W.reagents.total_volume) user << "\red <b>[W] is now empty.</b>"
				return
		else if (istype(W, /obj/item/weapon/shard/crystal))
			for(var/mob/O in viewers(user, null)) O.show_message(text("\blue [] plants [] in the soil.", user, W), 1)
			var/obj/item/weapon/seed/crystal/WS = new(src)
			HYPnewplant(WS)
			del W
			sleep(5)
			del WS
/* Strumpetplaya - commenting this out as it has components we don't support.
		else if (istype(W, /obj/item/weapon/reagent_containers/poo))
			src.reagents.add_reagent("poo", 15)
			for(var/mob/O in viewers(user, null)) O.show_message(text("\blue [] adds [] to the soil.", user, W), 1)
			del W
			return
*/
		else if (istype(W, /obj/item/weapon/plantanalyzer/))
		// PLANTANZ
			if (!src.current || src.plantcond == "dead")
				user << "\red Cannot scan."
				return
			var/datum/plant/growing = src.current
			var/datum/plantgenes/DNA = src.plantgenes
			for(var/mob/O in viewers(user, null)) O.show_message(text("\blue [] uses the [] on [].", user, W, src), 1)
			user << "\blue <B>Analysis of [src.name]:</B>"
			user << "<B>Species:</B> [growing.name]"
			user << "<B>Generation:</B> [src.generation]"
			user << ""
			user << "<B>Maturation Rate:</B> [DNA.growtime]"
			user << "<B>Production Rate:</B> [DNA.harvtime]"
			if (growing.harvestable) user << "<B>Lifespan:</B> [DNA.harvests]"
			else user << "<B>Lifespan:</B> Limited"
			user << "<B>Yield:</B> [DNA.cropsize]"
			user << "<B>Potency:</B> [DNA.potency]"
			user << "<B>Endurance:</B> [DNA.endurance]"
			if (growing.mutable && DNA.mutantvar) user << "\red <B>ALERT:</B> Abnormal genetic patterns detected!"
			for (var/X in DNA.commuts)
				if (X == "immortal") user << "\red <B>ALERT:</B> Detected Immortality gene strain."
				if (X == "seedless") user << "\red <B>ALERT:</B> Detected Seedless gene strain."
		else ..()

	attack_ai(mob/user as mob)
		if (istype(user, /mob/living/silicon/robot) && get_dist(src, user) <= 1) return src.attack_hand(user)

	attack_hand(var/mob/user as mob)
		if (istype(user, /mob/living/silicon/ai) || istype(user, /mob/dead/)) return // naughty AIs used to be able to harvest plants
		src.add_fingerprint(user)
		if (src.current)
			if (src.isready == 1)
				src.isready = 0
				var/datum/plant/growing = src.current
				var/datum/plantgenes/DNA = src.plantgenes
				src.growth = growing.growtime
				//score_stuffharvested += 1	 Strumpetplaya - commenting this out as it has components we don't support.
				var/getamount = growing.cropsize + DNA.cropsize
				if (src.plantcond == "good" && prob(50))
					user << "\blue This looks like a good harvest!"
					getamount += rand(1,3)
				if (src.plantcond == "excellent" && prob(50))
					user << "\blue It's a bumper crop!"
					getamount += rand(2,6)
				if (src.plantcond == "poor" && prob(50))
					user << "\red This is kind of a crappy harvest..."
					getamount -= rand(1,3)

				var/getitem = null
				var/getseed = null
				var/dogenes = 0
				if (growing.crop)
					if (growing.mutable && DNA.mutantvar)
						if (DNA.mutantvar == 1) getitem = growing.mutcrop1
						if (DNA.mutantvar == 2) getitem = growing.mutcrop2
						if (DNA.mutantvar == 3) getitem = growing.mutcrop3
					else getitem = growing.crop
				if (growing.isgrass && growing.seed) getseed = growing.seed
				if (growing.harvtype == "fruit") dogenes = 1
				if (growing.harvtype == "plant") dogenes = 2
				if (growing.harvtype == "seedonly") dogenes = 3

				// Special cases
				//if (growing.name == "tomato") Commenting this out incase I bring ktomatoes back in some other form
				//	if (growing.mutable && DNA.mutantvar == 2)
				//		dogenes = 0
				//		getseed = growing.seed
				if (growing.name == "synthmeat") getseed = growing.seed // Meat wasnt giving seeds, not being a plant

				if (getamount < 1) user << "\red You weren't able to harvest anything worth salvaging."
				else
					while (getamount > 0)
						if (dogenes == 1)
							var/obj/item/weapon/reagent_containers/food/snacks/plant/F = new getitem(user.loc)
							var/datum/plantgenes/PLDNA = src.plantgenes
							var/datum/plantgenes/FDNA = F.plantgenes
							FDNA.growtime = PLDNA.growtime
							FDNA.harvtime = PLDNA.harvtime
							FDNA.harvests = PLDNA.harvests
							FDNA.cropsize = PLDNA.cropsize
							FDNA.potency = PLDNA.potency
							FDNA.endurance = PLDNA.endurance
							FDNA.mutantvar = PLDNA.mutantvar
							FDNA.commuts = PLDNA.commuts
							F.generation = src.generation
						else if (dogenes == 2)
							var/obj/item/weapon/plant/P = new getitem(user.loc)
							var/datum/plantgenes/PDNA = src.plantgenes
							P.potency = PDNA.potency
						else if (dogenes == 3)
							var/obj/item/weapon/seed/S = new getseed(user.loc)
							var/datum/plantgenes/HDNA = src.plantgenes
							var/datum/plantgenes/SDNA = S.plantgenes
							SDNA.growtime = HDNA.growtime
							SDNA.harvtime = HDNA.harvtime
							SDNA.harvests = HDNA.harvests
							SDNA.cropsize = HDNA.cropsize
							SDNA.potency = HDNA.potency
							SDNA.endurance = HDNA.endurance
							SDNA.mutantvar = HDNA.mutantvar
							SDNA.commuts = HDNA.commuts
							S.generation = src:generation
						else new getitem(user.loc)
						if (getseed && prob(80))
							var/obj/item/weapon/seed/S = new getseed(user.loc)
							var/datum/plantgenes/HDNA = src.plantgenes
							var/datum/plantgenes/SDNA = S.plantgenes
							SDNA.growtime = HDNA.growtime
							SDNA.harvtime = HDNA.harvtime
							SDNA.harvests = HDNA.harvests
							SDNA.cropsize = HDNA.cropsize
							SDNA.potency = HDNA.potency
							SDNA.endurance = HDNA.endurance
							SDNA.mutantvar = HDNA.mutantvar
							SDNA.commuts = HDNA.commuts
							S.generation = src:generation
						getamount--
				var/immortal = 0
				for (var/X in DNA.commuts)
					if (X == "immortal") immortal = 1
				if (!immortal)
					if (src.plantcond == "excellent")
						if (prob(10)) user << "\blue The plant glistens with good health!"
						else src.harvests--
					else src.harvests--
				if (growing.isgrass) HYPkillplant()
			else if (src.plantcond == "dead")
				user << "\blue You clear the dead plant out of the plant pot."
				HYPdestroyplant()
			else
				var/datum/plant/growing = src.current
				var/datum/plantgenes/DNA = src.plantgenes
				user << "You check the [src.name]."
				if (!src.reagents.has_reagent("water")) user << "\red The soil is completely dry."
				else
					if (src.reagents.get_reagent_amount("water") > 200)  user << "\red The soil is too soggy."
					if (src.reagents.get_reagent_amount("water") < 40) user << "\red The soil looks a little dry."
				if (src.reagents.has_reagent("poo") || src.reagents.has_reagent("phosphorus") || src.reagents.has_reagent("ammonia") || src.reagents.has_reagent("diethylamine") || src.reagents.has_reagent("plant_nutrients") || src.reagents.has_reagent("plant_nutrients_plus")) user << "\blue The soil seems rich and fertile."
				if (src.reagents.has_reagent("mutagen") || src.reagents.has_reagent("dna_mutagen") || src.reagents.has_reagent("radium")) user << "\red The plant seems to be growing irregularly!"
				if (src.reagents.has_reagent("plasma") || src.reagents.has_reagent("fuel") || src.reagents.has_reagent("chlorine") || src.reagents.has_reagent("mercury") || src.reagents.has_reagent("toxin") || src.reagents.has_reagent("toxic_slurry"))
					if (!istype(growing,/datum/plant/slurrypod) && !istype(growing,/datum/plant/radweed)) user << "\red The plant seems to be withering!"
				if (src.plantcond == "excellent") user << "\blue The plant is flourishing!"
				else if (src.plantcond == "good") user << "\blue The plant looks very healthy."
				else if (src.plantcond == "poor") user << "\red The plant is in a poor condition."
				if (DNA.mutantvar && growing.mutable) user << "\red The plant looks strange..."
		else
		// CHECKING
			user << "You check the [src.name]."
			if (!src.reagents.has_reagent("water")) user << "\red The soil is completely dry."
			else
				if (src.reagents.get_reagent_amount("water") > 200)  user << "\red The soil is too soggy."
				if (src.reagents.get_reagent_amount("water") < 40) user << "\red The soil looks a little dry."
			if (src.reagents.has_reagent("poo") || src.reagents.has_reagent("phosphorus") || src.reagents.has_reagent("ammonia") || src.reagents.has_reagent("diethylamine") || src.reagents.has_reagent("plant_nutrients") || src.reagents.has_reagent("plant_nutrients_plus")) user << "\blue The soil seems rich and fertile."
			if (src.reagents.has_reagent("mutagen") || src.reagents.has_reagent("dna_mutagen") || src.reagents.has_reagent("radium")) user << "\red The soil is shifting weirdly."
			if (src.reagents.has_reagent("plasma") || src.reagents.has_reagent("fuel") || src.reagents.has_reagent("chlorine") || src.reagents.has_reagent("mercury") || src.reagents.has_reagent("toxin") || src.reagents.has_reagent("toxic_slurry")) user << "\red There is a noxious smell coming from the soil."
		return

	MouseDrop(over_object, src_location, over_location)
		..()
		if ((over_object == usr && ((get_dist(src, usr) <= 1) || usr.contents.Find(src))))
			if (usr.s_active)
				usr.s_active.close(usr)
			if (!istype(usr, /mob/living/)) return // ghosts killing plants fix
			if (src.current)
				var/datum/plant/growing = src.current
				if (growing.growthmode == "weed")
					if (istype(growing,/datum/plant/lasher) && src.growth > 60)
						usr << "\red The plant lashes out at you violently!"
						usr.bruteloss += 3
						return
					usr << "\blue You empty out and clean the plant pot."
					usr << "\red It looks like the weed infestation is still here..."
					src.name = "plant pot"
					src.icon_state = "pot-empty"
					src.growth = 0
					src.reagents.clear_reagents()
				else
					if (istype(growing,/datum/plant/maneater))
						if (src.growth > 60) for(var/mob/O in viewers(src, null)) O.show_message(text("<B>Man-Eating Plant</B> gurgles, 'Hands off, asshole!'"), 1)
						usr << "\red The plant angrily bites you!"
						usr.bruteloss += 9
						return
					usr << "\blue You empty out and clean the plant pot."
					src.reagents.clear_reagents()
					HYPdestroyplant()
			else
				usr << "\blue You empty out and clean the plant pot."
				src.reagents.clear_reagents()
		return

	temperature_expose(null, temp, volume)
		//if(reagents) reagents.temperature_reagents(temp, volume)	Strumpetplaya - commenting this out as it has components we don't support.
		if (src.current)
			if (!prob(src.endurance))
				src.reagents.add_reagent("plant_nutrients", src.growth)
				HYPdestroyplant()

	proc/update_icon()
		var/datum/plant/growing = src.current
		var/datum/plantgenes/DNA = src.plantgenes
		src.overlays = null
		switch (src.reagents.get_reagent_amount("water"))
			if (0) src.overlays += image('hydroponics.dmi', "wbar-0")
			if (1 to 40) src.overlays += image('hydroponics.dmi', "wbar-1")
			if (41 to 100) src.overlays += image('hydroponics.dmi', "wbar-2")
			if (101 to 200) src.overlays += image('hydroponics.dmi', "wbar-3")
			if (201 to INFINITY) src.overlays += image('hydroponics.dmi', "wbar-4")
		if (src.current)
			if (growing.harvestable && src.isready && src.plantcond != "dead") src.overlays += image('hydroponics.dmi', "harv-1")
			else src.overlays += image('hydroponics.dmi', "harv-0")
		else src.overlays += image('hydroponics.dmi', "harv-0")

		if (src.current)
			if (src.plantcond != "dead")
				if (src.growth >= 1)
					src.name = "[growing.name] plant"
					src.icon_state = "[growing.name]-G1"
					if (DNA.mutantvar && growing.mutable) src.icon_state += "-M[DNA.mutantvar]"
				if (src.growth >= growing.growtime  + DNA.growtime && src.growth < growing.harvtime  + DNA.harvtime)
					src.icon_state = "[growing.name]-G2"
					if (DNA.mutantvar && growing.mutable) src.icon_state += "-M[DNA.mutantvar]"
				if (src.growth >= growing.harvtime + DNA.harvtime)
					src.icon_state = "[growing.name]"
					if (growing.isgrass) src.icon_state += "-G2"
					else src.icon_state += "-G3"
					if (DNA.mutantvar && growing.mutable) src.icon_state += "-M[DNA.mutantvar]"
				for (var/X in DNA.commuts)
					if (X == "immortal") src.overlays += image('hydroponics.dmi', "mut-sparkle")
			else src.icon_state = "[growing.name]-G0"
		else src.icon_state = "pot-empty"

		return

	proc/HYPmutateplant(var/severity = "normal")
		var/datum/plant/growing = src.current
		var/datum/plantgenes/DNA = src.plantgenes

		switch(severity)
			if("normal")
				DNA.growtime += rand(-10,10)
				DNA.harvtime += rand(-10,10)
				DNA.cropsize += rand(-2,2)
				if (prob(33)) DNA.harvests += rand(-1,1)
				DNA.potency += rand(-5,5)
				DNA.endurance += rand(-3,3)
				if (growing.mutable && prob(2)) DNA.mutantvar = rand(1,growing.mutable)
				if (prob(2) && growing.commuts.len > 0) DNA.commuts.Add(pick(growing.commuts))
			if("wild")
				DNA.growtime += rand(-25,25)
				DNA.harvtime += rand(-25,25)
				DNA.cropsize += rand(-5,5)
				DNA.harvests += rand(-3,3)
				DNA.potency += rand(-10,10)
				DNA.endurance += rand(-10,10)
				if (growing.mutable && prob(5)) DNA.mutantvar = rand(1,growing.mutable)
				if (prob(5) && growing.commuts.len > 0) DNA.commuts.Add(pick(growing.commuts))

	proc/HYPnewplant(var/obj/item/weapon/seed/SEED)
		src.current = SEED.planttype
		var/datum/plant/growing = src.current
		src.health = growing.starthealth
		src.plantcond = "normal"

		src.generation = SEED.generation
		src.generation += 1
		if (growing.isvine) src.icon_state = "pot-vine"

		var/datum/plantgenes/DNA = src.plantgenes
		var/datum/plantgenes/SDNA = SEED.plantgenes

		DNA.growtime = SDNA.growtime
		DNA.harvtime = SDNA.harvtime
		DNA.cropsize = SDNA.cropsize
		DNA.harvests = SDNA.harvests
		DNA.potency = SDNA.potency
		DNA.endurance = SDNA.endurance
		DNA.mutantvar = SDNA.mutantvar
		DNA.commuts = SDNA.commuts

		if (growing.harvestable) src.harvests = growing.harvests + DNA.harvests
		if (src.harvests < 1) src.harvests = 1
		src.endurance = growing.endurance + DNA.endurance
		del SEED
		HYPmutateplant("normal")

	proc/HYPkillplant()
		var/datum/plant/growing = src.current
		src.health = 0
		src.harvests = 0
		src.isready = 0
		src.icon_state = "[growing.name]-G0"
		src.plantcond = "dead"
		update_icon()

	proc/HYPdestroyplant()
		src.name = "plant pot"
		src.icon_state = "pot-empty"
		src.plantcond = "normal"
		src.current = null
		src.growth = 0
		src.harvests = 0
		src.endurance = 0
		var/datum/plantgenes/DNA = src.plantgenes

		DNA.growtime = 0
		DNA.harvtime = 0
		DNA.cropsize = 0
		DNA.harvests = 0
		DNA.potency = 0
		DNA.endurance = 0
		DNA.commuts = 0

		src.isready = 0
		src.generation = 0
		update_icon()

/obj/reagent_dispensers/compostbin
	name = "compost tank"
	desc = "A device that mulches up unwanted produce into usable fertiliser."
	icon = 'hydroponics.dmi'
	icon_state = "compost"
	amount_per_transfer_from_this = 30

	New()
		..()

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		var/load = 1
		if (istype(W,/obj/item/weapon/reagent_containers/food/snacks/plant/)) src.reagents.add_reagent("poo", 20)
		else if (istype(W,/obj/item/weapon/reagent_containers/food/snacks/mushroom/)) src.reagents.add_reagent("poo", 25)
		else if (istype(W,/obj/item/weapon/seed/)) src.reagents.add_reagent("poo", 2)
		else if (istype(W,/obj/item/weapon/plant/)) src.reagents.add_reagent("poo", 15)
		//else if (istype(W,/obj/item/weapon/reagent_containers/poo)) src.reagents.add_reagent("poo", 20)	 Strumpetplaya - commenting this out as it has components we don't support.
		else load = 0

		if(load)
			user << "\blue [src] mulches up [W]."
			playsound(src.loc, 'blobattack.ogg', 50, 1)
			user.u_equip(W)
			if ((user.client && user.s_active != src)) user.client.screen -= W
			W.dropped()
			del W
			return
		else ..()

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (istype(O, /obj/item/weapon/reagent_containers/food/snacks/plant/) || istype(O, /obj/item/weapon/reagent_containers/food/snacks/mushroom/) || istype(O, /obj/item/weapon/seed/) || istype(O, /obj/item/weapon/plant/))
			for(var/mob/V in viewers(user, null)) V.show_message(text("\blue [] begins quickly stuffing items into []!", user, src), 1)
			var/staystill = user.loc
			for(var/obj/item/weapon/P in view(1,user))
				if (src.reagents.total_volume >= src.reagents.maximum_volume)
					user << "\red [src] is full!"
					break
				if (user.loc != staystill) break
				if (istype(P,/obj/item/weapon/reagent_containers/food/snacks/plant/))
					src.reagents.add_reagent("poo", 20)
					playsound(src.loc, 'blobattack.ogg', 50, 1)
					del P
					sleep(3)
				else if (istype(P,/obj/item/weapon/reagent_containers/food/snacks/mushroom/))
					src.reagents.add_reagent("poo", 25)
					playsound(src.loc, 'blobattack.ogg', 50, 1)
					del P
					sleep(3)
				else if (istype(P,/obj/item/weapon/seed/))
					src.reagents.add_reagent("poo", 2)
					playsound(src.loc, 'blobattack.ogg', 50, 1)
					del P
					sleep(3)
				else if (istype(P,/obj/item/weapon/plant/))
					src.reagents.add_reagent("poo", 15)
					playsound(src.loc, 'blobattack.ogg', 50, 1)
					del P
					sleep(3)
/*				else if (istype(P,/obj/item/weapon/reagent_containers/poo))	 Strumpetplaya - commenting this out as it has components we don't support.
					src.reagents.add_reagent("poo", 20)
					playsound(src.loc, 'blobattack.ogg', 50, 1)
					del P
					sleep(3)*/
				else continue
			user << "\blue You finish stuffing items into [src]!"
		else ..()

/obj/submachine/chem_extractor/
	name = "Reagent Extractor"
	desc = "A machine which can extract reagents from organic matter."
	density = 1
	anchored = 1
	icon = 'hydroponics.dmi'
	icon_state = "reex-off"
	//flags = NOSPLASH	 Strumpetplaya - commenting this out as it has components we don't support.
	var/obj/item/weapon/reagent_containers/beaker = null
	var/list/ingredients = list()
	var/working = 0
	var/list/allowed = list(/obj/item/weapon/reagent_containers/food/snacks/plant/,\
	/obj/item/weapon/reagent_containers/food/snacks/mushroom/,\
	/obj/item/weapon/plant/,\
	/obj/item/weapon/medical/ointment,\
	/obj/item/weapon/dnainjector)
	///obj/item/weapon/reagent_containers/poo)	/* Strumpetplaya - commenting this out as it has components we don't support.

	attack_hand(var/mob/user as mob)
		user.machine = src
		if (src.working)
			var/dat = {"<B>Reagent Extractor</B><BR>
			<HR><BR>
			The Extractor is currently busy.<BR>
			Please wait until the processing completes."}
			user << browse(dat, "window=rextractor;size=400x250")
			onclose(user, "rextractor")
		else
			var/dat = "<B>Reagent Extractor</B><BR><HR>"
			if (src.beaker)
				dat += "<B>Receptacle:</B> [src.beaker]<BR>"
				dat += "<b>Capacity:</b> [src.beaker.reagents.total_volume]/[src.beaker.reagents.maximum_volume]<BR>"
				dat += "<b>Contents:</b> "
				if(src.beaker.reagents.reagent_list.len)
					for(var/datum/reagent/R in src.beaker.reagents.reagent_list)
						dat += "<BR><i>[R.volume] units of [R.name]</i>"
				else dat += "Empty<BR>"
			else dat += "<B>Receptacle:</B> None<BR>"
			if(src.ingredients.len)
				dat += "<BR><B>Items:</B>"
				for(var/obj/item/I in src.ingredients)
					dat += "<BR><i>[I]</i>"
			else dat += "<BR><B>Items:</B> None"
			dat += {"<HR>
			<A href='?src=\ref[src];ops=1'>Begin Extraction<BR>
			<A href='?src=\ref[src];ops=2'>Eject Receptacle<BR>
			<A href='?src=\ref[src];ops=3'>Eject Ingredients<BR>"}
			user << browse(dat, "window=rextractor;size=400x250")
			onclose(user, "rextractor")
	Topic(href, href_list)
		if(href_list["ops"])
			if (src.working) return
			var/operation = text2num(href_list["ops"])
			if(operation == 1) // Begin Working
				if (!src.beaker)
					usr << "\red You need to insert something the machine can extract into."
					return
				if (!src.ingredients.len)
					usr << "\red You need to insert something the machine can extract from."
					return
				var/obj/item/weapon/reagent_containers/G = src.beaker
				if(G.reagents.total_volume == G.reagents.maximum_volume)
					usr << "\red [G] is already full."
					return
				src.updateUsrDialog()
				for(var/mob/O in viewers(src, null)) O.show_message(text("The [] begins the extraction process.", src), 1)
				icon_state = "reex-on"
				src.working = 1
				src.updateUsrDialog()
				for(var/obj/item/I in src.contents)
					if(G.reagents.total_volume == G.reagents.maximum_volume) break
					if(istype(I,/obj/item/weapon/reagent_containers/glass)) continue
					else if(istype(I,/obj/item/weapon/reagent_containers/food/drinks)) continue
					if(istype(I,/obj/item/weapon/reagent_containers/food/snacks/plant/chili/chilly)) G.reagents.add_reagent("cryostylane", 20)
					else if(istype(I,/obj/item/weapon/reagent_containers/food/snacks/plant/chili)) G.reagents.add_reagent("capsaicin", 20)
					else if(istype(I,/obj/item/weapon/reagent_containers/food/snacks/plant/orange)) G.reagents.add_reagent("juice_orange", 20)
					else if(istype(I,/obj/item/weapon/reagent_containers/food/snacks/plant/lime)) G.reagents.add_reagent("juice_lime", 20)
					else if(istype(I,/obj/item/weapon/reagent_containers/food/snacks/plant/lemon)) G.reagents.add_reagent("juice_lemon", 20)
					else if(istype(I,/obj/item/weapon/reagent_containers/food/snacks/plant/tomato)) G.reagents.add_reagent("juice_tomato", 20)
					else if(istype(I,/obj/item/weapon/medical/ointment)) G.reagents.add_reagent("kelotane", 20)
					else if(istype(I,/obj/item/weapon/dnainjector)) G.reagents.add_reagent("mutagen", 20)
					else if(istype(I,/obj/item/weapon/plant/sugar)) G.reagents.add_reagent("sugar", 20)
					else if(istype(I,/obj/item/weapon/reagent_containers/food/snacks/ingredient/sugar)) G.reagents.add_reagent("sugar", 20)
					else if(istype(I,/obj/item/weapon/reagent_containers/food/snacks/mushroom/psilocybin)) G.reagents.add_reagent("psilocybin", 20)
					else if(istype(I,/obj/item/weapon/reagent_containers/food/snacks/mushroom/amanita)) G.reagents.add_reagent("amanitin", 20)
					else if(istype(I,/obj/item/weapon/reagent_containers/food/snacks/mushroom)) G.reagents.add_reagent("space_fungus", 20)
					else if(istype(I,/obj/item/weapon/reagent_containers/food/snacks/plant/slurryfruit)) G.reagents.add_reagent("toxic_slurry", 20)
					else if(istype(I,/obj/item/weapon/reagent_containers/food/snacks/plant/slurryfruit/omega))
						G.reagents.add_reagent("toxic_slurry", 20)
						if (prob(3)) G.reagents.add_reagent("necrovirus", 5)
					else if(istype(I,/obj/item/weapon/plant))
						var/obj/item/weapon/plant/P = I
						if(istype(I,/obj/item/weapon/plant/contusine)) G.reagents.add_reagent("bicaridine", 20 + P.potency)
						else if(istype(I,/obj/item/weapon/plant/nureous)) G.reagents.add_reagent("hyronalin", 20 + P.potency)
						else if(istype(I,/obj/item/weapon/plant/asomna)) G.reagents.add_reagent("inaprovaline", 20 + P.potency)
						else if(istype(I,/obj/item/weapon/plant/commol)) G.reagents.add_reagent("kelotane", 20 + P.potency)
						else if(istype(I,/obj/item/weapon/plant/venne)) G.reagents.add_reagent("anti_toxin", 20 + P.potency)
						else if(istype(I,/obj/item/weapon/plant/cannabis/black)) G.reagents.add_reagent("cyanide", 20 + P.potency)
						else if(istype(I,/obj/item/weapon/plant/cannabis/mega)) G.reagents.add_reagent("LSD", 20 + P.potency)
						else if(istype(I,/obj/item/weapon/plant/cannabis/white)) G.reagents.add_reagent("tricordrazine", 2 + (P.potency / 3))
						else if(istype(I,/obj/item/weapon/plant/cannabis)) G.reagents.add_reagent("THC", 20 + P.potency)
					src.ingredients -= I
					del I
				sleep(50)
				for(var/mob/O in viewers(src, null)) O.show_message(text("[] finishes the extraction.", src), 1)
				src.working = 0
				icon_state = "reex-off"
				src.updateUsrDialog()
			if(operation == 2) // Eject Beaker
				src.beaker.loc = src.loc
				src.beaker = null
				src.updateUsrDialog()
			if(operation == 3) // Eject Ingredient
				for(var/obj/item/I in src.contents)
					if (istype(I, /obj/item/weapon/reagent_containers/glass) || istype(I, /obj/item/weapon/reagent_containers/food/drinks/)) continue
					I.loc = src.loc
				src.updateUsrDialog()

	attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
		if (src.working)
			user << "\red The extractor is busy!"
			return
		if(istype(W, /obj/item/weapon/reagent_containers/glass/) || istype(W, /obj/item/weapon/reagent_containers/food/drinks/))
			if(src.beaker)
				user << "\red A beaker is already loaded into the machine."
				return
			src.beaker =  W
			user.drop_item()
			W.loc = src
			user << "\blue You add [W] to the machine!"
			src.updateUsrDialog()
		else
			var/proceed = 0
			for(var/check_path in src.allowed)
				if(istype(W, check_path))
					proceed = 1
					break
			if (!proceed)
				user << "\red The extractor cannot accept that!"
				return
			user << "\blue You add [W] to the machine!"
			user.u_equip(W)
			if ((user.client && user.s_active != src)) user.client.screen -= W
			W.loc = src
			src.ingredients += W
			W.dropped()
			src.updateUsrDialog()
			return

/obj/submachine/seedextractor
	name = "Seed Extractor"
	desc = "Carefully extracts viable seeds from produce."
	icon = 'hydroponics.dmi'
	icon_state = "extractor-off"
	anchored = 1
	density = 1
	var/working = 0

	attack_hand(var/mob/user as mob)
		user << "Insert fruit into the extractor to begin seed extraction."

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (!istype(W, /obj/item/weapon/reagent_containers/food/snacks/plant/))
			user << "\red That cannot be used in the extractor!"
			return
		if (src.working == 1)
			user << "\red The extractor is busy!"
			return
		src.icon_state = "extractor-on"
		for(var/mob/O in viewers(src, null)) O.show_message(text("The [] begins the extraction process.", src), 1)
		src.working = 1
		var/give = rand(2,5)
		var/datum/plantgenes/SRCDNA = W:plantgenes
		for (var/X in SRCDNA.commuts)
			if (X == "seedless") give = 0
		user.u_equip(W)
		if ((user.client && user.s_active != src)) user.client.screen -= W
		W.loc = src
		W.dropped()
		if (!give)
			for(var/mob/O in hearers(src, null)) O.show_message(text("<b>[]</b> states, Alert. No seeds detected in produce.", src), 1)
		while (give > 0)
			var/obj/item/weapon/reagent_containers/food/snacks/plant/P = W
			var/datum/plant/stored = P.planttype
			var/datum/plantgenes/DNA = P.plantgenes
			var/obj/item/weapon/seed/S = new stored.seed(src)
			sleep(2)
			var/datum/plantgenes/SDNA = S.plantgenes
			SDNA.growtime = DNA.growtime
			SDNA.harvtime = DNA.harvtime
			SDNA.harvests = DNA.harvests
			SDNA.cropsize = DNA.cropsize
			SDNA.potency = DNA.potency
			SDNA.endurance = DNA.endurance
			SDNA.mutantvar = DNA.mutantvar
			SDNA.commuts = DNA.commuts
			S.generation = P.generation
			give -= 1
		sleep(50)
		src.icon_state = "extractor-off"
		for (var/obj/item/weapon/seed/SEED in src.contents) SEED.loc = src.loc
		for (var/obj/item/I in src.contents) del I
		src.working = 0
		for(var/mob/O in hearers(src, null)) O.show_message(text("<b>[]</b> states, Extraction complete.", src), 1)
		return

/obj/submachine/seedmutator
	name = "Plant Gene Manipulator"
	desc = "Exposes plant seeds to mutagenic radiation."
	icon = 'hydroponics.dmi'
	icon_state = "geneman-off"
	anchored = 1
	density = 1
	var/screen = 1
	var/current = 1
	var/obj/item/weapon/seed/seed1 = null
	var/obj/item/weapon/seed/seed2 = null

	attack_hand(var/mob/user as mob)
		user.machine = src
		if (src.seed1 || src.seed2)
			if (src.screen == 1)
				var/currentseed = null
				var/datum/plantgenes/DNA = null
				if (src.current == 1 && src.seed1)
					currentseed = src.seed1
					DNA = src.seed1.plantgenes
				else if (src.current == 2 && src.seed2)
					currentseed = src.seed2
					DNA = src.seed2.plantgenes
				else return
				var/dat = {"<B>Plant Gene Manipulator</B><BR>
				<HR><BR>
				<B>Currently Viewing:</B> Seed Slot [src.current]<BR>
				<B>Seed:</B> [currentseed]<BR>
				<B>Seed Radiation Level:</B> [currentseed:radiation]<BR><BR>
				<B>Maturation Gene:</B> [DNA.growtime]<BR>
				<B>Production Gene:</B> [DNA.harvtime]<BR>
				<B>Lifespan Gene:</B> [DNA.harvests]<BR>
				<B>Yield Gene:</B> [DNA.cropsize]<BR>
				<B>Potency Gene:</B> [DNA.potency]<BR>
				<B>Endurance Gene:</B> [DNA.endurance]<BR><BR>
				<HR><BR>
				<A href='?src=\ref[src];ops=1'>Irradiate Maturation Gene<BR>
				<A href='?src=\ref[src];ops=2'>Irradiate Production Gene<BR>
				<A href='?src=\ref[src];ops=3'>Irradiate Lifespan Gene<BR>
				<A href='?src=\ref[src];ops=4'>Irradiate Yield Gene<BR>
				<A href='?src=\ref[src];ops=5'>Irradiate Potency Gene<BR>
				<A href='?src=\ref[src];ops=6'>Irradiate Endurance Gene<BR>
				<A href='?src=\ref[src];ops=7'>Eject Seeds<BR>
				<A href='?src=\ref[src];ops=8'>Change Slot<BR>
				<A href='?src=\ref[src];ops=9'>Seed Splicing<BR>"}
				user << browse(dat, "window=gmanipulator;size=400x500")
				onclose(user, "gmanipulator")
			else if (src.screen == 2)
				if (src.seed1 && src.seed2)
					var/datum/plantgenes/DNA1 = src.seed1.plantgenes
					var/datum/plantgenes/DNA2 = src.seed2.plantgenes
					var/dat = {"<B>Plant Gene Manipulator</B><BR>
					<HR><BR>
					<u><B>Seed #1:</B> [src.seed1]</u><BR>
					<B>Maturation Gene:</B> [DNA1.growtime]<BR>
					<B>Production Gene:</B> [DNA1.harvtime]<BR>
					<B>Lifespan Gene:</B> [DNA1.harvests]<BR>
					<B>Yield Gene:</B> [DNA1.cropsize]<BR>
					<B>Potency Gene:</B> [DNA1.potency]<BR>
					<B>Endurance Gene:</B> [DNA1.endurance]<BR><BR>
					<u><B>Seed #2:</B> [src.seed2]</u><BR>
					<B>Maturation Gene:</B> [DNA2.growtime]<BR>
					<B>Production Gene:</B> [DNA2.harvtime]<BR>
					<B>Lifespan Gene:</B> [DNA2.harvests]<BR>
					<B>Yield Gene:</B> [DNA2.cropsize]<BR>
					<B>Potency Gene:</B> [DNA2.potency]<BR>
					<B>Endurance Gene:</B> [DNA2.endurance]<BR><BR>
					<HR><BR>
					<A href='?src=\ref[src];ops=10'>Splice Seeds<BR>
					<A href='?src=\ref[src];ops=7'>Eject Seeds<BR>
					<A href='?src=\ref[src];ops=9'>Seed Irradiation<BR>"}
					user << browse(dat, "window=gmanipulator;size=400x500")
					onclose(user, "gmanipulator")
				else
					var/dat = {"<B>Plant Gene Manipulator</B><BR>
					<HR><BR>
					<B>Seed Splicing requires two seeds to be inserted.</B><BR>
					<A href='?src=\ref[src];ops=9'>Seed Irradiation
					<A href='?src=\ref[src];ops=7'>Eject Seeds<BR>"}
					user << browse(dat, "window=gmanipulator;size=400x500")
					onclose(user, "gmanipulator")
		else
			var/dat = {"<B>Plant Gene Manipulator</B><BR>
			<HR><BR>
			<B>No seeds inserted.</B>"}
			user << browse(dat, "window=gmanipulator;size=400x500")
			onclose(user, "gmanipulator")
	Topic(href, href_list)
		if(href_list["ops"])
			var/operation = text2num(href_list["ops"])
			var/obj/item/weapon/seed/SEED = null
			if (src.current == 1) SEED = src.seed1
			else SEED = src.seed2
			var/datum/plantgenes/DNA = SEED.plantgenes
			if(operation == 1) // Maturation Gene
				IrradiateP1()
				for(var/obj/item/weapon/seed/S in src.contents) DNA.growtime -= rand(5,10)
			if(operation == 2) // Production Gene
				IrradiateP1()
				for(var/obj/item/weapon/seed/S in src.contents) DNA.harvtime -= rand(5,10)
			if(operation == 3) // Lifespan Gene
				IrradiateP1()
				for(var/obj/item/weapon/seed/S in src.contents)
					if (prob(75)) DNA.harvests += 1
			if(operation == 4) // Yield Gene
				IrradiateP1()
				for(var/obj/item/weapon/seed/S in src.contents)
					if (prob(75)) DNA.cropsize += rand(1,2)
			if(operation == 5) // Potency Gene
				IrradiateP1()
				for(var/obj/item/weapon/seed/S in src.contents)
					DNA.potency += rand(3,10)
			if(operation == 6) // Endurance Gene
				IrradiateP1()
				for(var/obj/item/weapon/seed/S in src.contents)
					DNA.endurance += rand(3,6)
			if(operation == 7) // Eject Seeds
				for(var/obj/item/weapon/seed/S in src.contents) S.loc = get_turf(src)
				src.seed1 = null
				src.seed2 = null
			if(operation == 8) // Switch Current Seed Slot
				if (src.current == 1)
					if (src.seed2) src.current = 2
					else usr << "\red No seed in Slot 2."
				else
					if (src.seed1) src.current = 1
					else usr << "\red No seed in Slot 1."
			if(operation == 9) // Switch Screen
				if (src.screen == 1)
					if (src.seed1 && src.seed2) src.screen = 2
					else usr << "\red Splice Mode requires both seed slots to be filled."
				else src.screen = 1
			if(operation == 10) // Splice seeds
				var/obj/item/weapon/seed/SEED1 = src.seed1
				var/obj/item/weapon/seed/SEED2 = src.seed2
				var/datum/plant/store1 = SEED1.planttype
				var/datum/plant/store2 = SEED2.planttype
				var/datum/plantgenes/DNA1 = SEED1.plantgenes
				var/datum/plantgenes/DNA2 = SEED2.plantgenes
				var/getseed = null
				if (prob(50)) getseed = store1.seed
				else getseed = store2.seed
				var/obj/item/weapon/seed/S = new getseed(src.loc)
				var/datum/plantgenes/DNA3 = S.plantgenes
				// Splicing Growtime - lower is better
				DNA3.growtime = Splice_Variable(DNA1.growtime, DNA2.growtime, 66, 0)
				DNA3.harvtime = Splice_Variable(DNA1.harvtime, DNA2.harvtime, 66, 0)
				DNA3.harvests = Splice_Variable(DNA1.harvests, DNA2.harvests, 66)
				DNA3.cropsize = Splice_Variable(DNA1.cropsize, DNA2.cropsize, 66)
				DNA3.potency = Splice_Variable(DNA1.potency, DNA2.potency, 66)
				DNA3.endurance = Splice_Variable(DNA1.endurance, DNA2.endurance, 66)
				DNA3.mutantvar = Splice_Variable(DNA1.mutantvar, DNA2.mutantvar, 66)
				if (SEED2.generation > SEED1.generation) S.generation = SEED2.generation + 1
				else S.generation = SEED1.generation + 1
				var/list/allmuts = list()
				for (var/X in DNA1.commuts) allmuts.Add(X)
				for (var/X in DNA2.commuts) allmuts.Add(X)
				DNA3.commuts = allmuts
				src.seed1 = null
				src.seed2 = null
				for(var/obj/item/weapon/seed/D in src.contents) del D

			src.updateUsrDialog()

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (istype(W, /obj/item/weapon/seed/))
			// Load Object
			if (src.seed1 && src.seed2)
				user << "\red Two seeds are already loaded into the machine."
				return
			user << "\blue You add [W] to the machine!"
			user.drop_item()
			if ((user.client && user.s_active != src)) user.client.screen -= W
			W.loc = src
			if (!src.seed1) src.seed1 = W
			else src.seed2 = W
			src.updateUsrDialog()
		else
			user << "\red The Manipulator cannot accept that!"
			return

	proc/Splice_Variable(var/val1, var/val2, var/chance, var/favor = 1)
		// Favor 1 for higher variables being desirable, otherwise 0
		if (val1 == val2) return val1
		if (favor == 1)
			if (val1 > val2)
				if (prob(chance)) return val1
				else return val2
			else
				if (prob(chance)) return val2
				else return val1
		else
			if (val1 < val2)
				if (prob(chance)) return val1
				else return val2
			else
				if (prob(chance)) return val2
				else return val1

	proc/IrradiateP1()
		var/obj/item/weapon/seed/S = null
		if (src.current == 1) S = src.seed1
		else S = src.seed2
		if (!S) return
		var/destroychance = rand(S.radiation,5)
		if (destroychance == 5)
			for(var/obj/item/weapon/seed/X in src.contents)
				if (S == X) del X
				if (src.current == 1) src.seed1 = null
				else src.seed2 = null
			for(var/mob/O in hearers(src, null)) O.show_message(text("Alert. Seed destroyed by radiation."), 1)
			src.updateUsrDialog()
			return
		var/datum/plantgenes/DNA = S.plantgenes
		var/datum/plant/stored = S.planttype
		if (prob(15)) DNA.growtime += rand(3,5)
		if (prob(15)) DNA.harvtime += rand(3,5)
		if (!stored.isgrass && prob(10)) DNA.harvests -= 1
		if (prob(15)) DNA.cropsize -= rand(1,2)
		if (prob(15)) DNA.potency -= rand(1,3)
		if (prob(15)) DNA.endurance -= rand(1,3)
		if (stored.mutable && prob(7)) DNA.mutantvar = rand(1,stored.mutable)
		S.radiation += 1

/obj/submachine/seed_vendor
	name = "Seed Fabricator"
	desc = "Fabricates basic plant seeds."
	icon = 'hydroponics.dmi'
	icon_state = "seeds"
	density = 1
	anchored = 1
	var/vendamt = 1
	var/hacked = 0
	var/panelopen = 0
	var/malfunction = 0
	var/working = 1
	var/wires = 15
	var/can_vend = 1
	var/seedcount = 0
	var/maxseed = 25
	var/const
		WIRE_EXTEND = 1
		WIRE_MALF = 2
		WIRE_POWER = 3
		WIRE_INERT = 4

	attack_ai(mob/user as mob)
		return src.attack_hand(user)

	attack_paw(mob/user as mob)
		return src.attack_hand(user)

	attack_hand(var/mob/user as mob)
		user.machine = src
		var/dat = "<B>[src.name]</B><BR><HR>"
		dat += "<b>Amount to Vend</b>: <A href='?src=\ref[src];amount=1'>[src.vendamt]</A><br><br>"
		dat += "<b>Tomato</b>: <A href='?src=\ref[src];vend=1'><U>Vend</U></A><br>"
		dat += "<b>Grape</b>: <A href='?src=\ref[src];vend=2'><U>Vend</U></A><br>"
		dat += "<b>Orange</b>: <A href='?src=\ref[src];vend=3'><U>Vend</U></A><br>"
		dat += "<b>Melon</b>: <A href='?src=\ref[src];vend=4'><U>Vend</U></A><br>"
		dat += "<b>Chili</b>: <A href='?src=\ref[src];vend=5'><U>Vend</U></A><br>"
		dat += "<b>Apple</b>: <A href='?src=\ref[src];vend=6'><U>Vend</U></A><br>"
		dat += "<b>Banana</b>: <A href='?src=\ref[src];vend=7'><U>Vend</U></A><br>"
		dat += "<b>Lemon</b>: <A href='?src=\ref[src];vend=8'><U>Vend</U></A><br>"
		dat += "<b>Lime</b>: <A href='?src=\ref[src];vend=9'><U>Vend</U></A><br>"
		dat += "<b>Wheat</b>: <A href='?src=\ref[src];vend=11'><U>Vend</U></A><br>"
		dat += "<b>Sugar</b>: <A href='?src=\ref[src];vend=12'><U>Vend</U></A><br>"
		dat += "<b>Synthmeat</b>: <A href='?src=\ref[src];vend=13'><U>Vend</U></A><br>"
		dat += "<b>Lettuce</b>: <A href='?src=\ref[src];vend=15'><U>Vend</U></A><br>"
		dat += "<b>Carrot</b>: <A href='?src=\ref[src];vend=14'><U>Vend</U></A><br>"
		dat += "<b>Pumpkin</b>: <A href='?src=\ref[src];vend=16'><U>Vend</U></A><br>"
		dat += "<b>Asomna</b>: <A href='?src=\ref[src];vend=17'><U>Vend</U></A><br>"
		dat += "<b>Nureous</b>: <A href='?src=\ref[src];vend=18'><U>Vend</U></A><br>"
		dat += "<b>Contusine</b>: <A href='?src=\ref[src];vend=19'><U>Vend</U></A><br>"
		dat += "<b>Commol</b>: <A href='?src=\ref[src];vend=20'><U>Vend</U></A><br>"
		dat += "<b>Venne</b>: <A href='?src=\ref[src];vend=21'><U>Vend</U></A><br>"
		dat += "<b>Potato</b>: <A href='?src=\ref[src];vend=28'><u>Vend</u></A><br>"
		if (src.hacked)
			dat += "<b>Cannabis</b>: <A href='?src=\ref[src];vend=22'><U>Vend</U></A><br>"
			dat += "<b>Fungus</b>: <A href='?src=\ref[src];vend=23'><U>Vend</U></A><br>"
			dat += "<b>Lasher</b>: <A href='?src=\ref[src];vend=24'><U>Vend</U></A><br>"
			dat += "<b>Creeper</b>: <A href='?src=\ref[src];vend=25'><U>Vend</U></A><br>"
			dat += "<b>Radweed</b>: <A href='?src=\ref[src];vend=26'><U>Vend</U></A><br>"
			dat += "<b>Slurrypod</b>: <A href='?src=\ref[src];vend=27'><U>Vend</U></A><br>"
			dat += "<b>Space Grass</b>: <A href='?src=\ref[src];vend=29'><U>Vend</U></A><br>"

		user << browse(dat, "window=seedfab;size=400x500")
		onclose(user, "seedfab")

		if (src.panelopen)
			var/list/fabwires = list(
			"Puce" = 1,
			"Mauve" = 2,
			"Ochre" = 3,
			"Slate" = 4,
			)
			var/pdat = "<B>[src.name] Maintenance Panel</B><hr>"
			for(var/wiredesc in fabwires)
				var/is_uncut = src.wires & APCWireColorToFlag[fabwires[wiredesc]]
				pdat += "[wiredesc] wire: "
				if(!is_uncut)
					pdat += "<a href='?src=\ref[src];cutwire=[fabwires[wiredesc]]'>Mend</a>"
				else
					pdat += "<a href='?src=\ref[src];cutwire=[fabwires[wiredesc]]'>Cut</a> "
					pdat += "<a href='?src=\ref[src];pulsewire=[fabwires[wiredesc]]'>Pulse</a> "
				pdat += "<br>"

			pdat += "<br>"
			pdat += "The yellow light is [(src.working == 0) ? "off" : "on"].<BR>"
			pdat += "The blue light is [src.malfunction ? "flashing" : "on"].<BR>"
			pdat += "The white light is [src.hacked ? "on" : "off"].<BR>"

			user << browse(pdat, "window=fabpanel")
			onclose(user, "fabpanel")

	Topic(href, href_list)
		if(href_list["amount"])
			var/amount = input(usr, "How many seeds do you want?", "[src.name]", 0) as null|num
			if(!amount) return
			if(amount < 0) return
			if(amount > 10) amount = 10
			src.vendamt = amount
			src.updateUsrDialog()
		if(href_list["vend"])
			if (src.can_vend == 0)
				usr << "\red It's charging."
				return
			var/getseed = null
			var/ops = text2num(href_list["vend"])
			if (src.malfunction) ops = rand(1,27)
			switch(ops)
				if(1) getseed = /obj/item/weapon/seed/tomato
				if(2) getseed = /obj/item/weapon/seed/grape
				if(3) getseed = /obj/item/weapon/seed/orange
				if(4) getseed = /obj/item/weapon/seed/melon
				if(5) getseed = /obj/item/weapon/seed/chili
				if(6) getseed = /obj/item/weapon/seed/apple
				if(7) getseed = /obj/item/weapon/seed/banana
				if(8) getseed = /obj/item/weapon/seed/lemon
				if(9) getseed = /obj/item/weapon/seed/lime
				if(11) getseed = /obj/item/weapon/seed/wheat
				if(12) getseed = /obj/item/weapon/seed/sugar
				if(13) getseed = /obj/item/weapon/seed/synthmeat
				if(14) getseed = /obj/item/weapon/seed/carrot
				if(15) getseed = /obj/item/weapon/seed/lettuce
				if(16) getseed = /obj/item/weapon/seed/lettuce	//Strumpetplaya - Changed this to lettuce temporarily.  Was pumpkin
				if(17) getseed = /obj/item/weapon/seed/asomna
				if(18) getseed = /obj/item/weapon/seed/nureous
				if(19) getseed = /obj/item/weapon/seed/contusine
				if(20) getseed = /obj/item/weapon/seed/commol
				if(21) getseed = /obj/item/weapon/seed/venne
				if(22) getseed = /obj/item/weapon/seed/cannabis
				if(23) getseed = /obj/item/weapon/seed/fungus
				if(24) getseed = /obj/item/weapon/seed/lasher
				if(25) getseed = /obj/item/weapon/seed/creeper
				if(26) getseed = /obj/item/weapon/seed/radweed
				if(27) getseed = /obj/item/weapon/seed/slurrypod
				if(28) getseed = /obj/item/weapon/seed/potato
				if(29) getseed = /obj/item/weapon/seed/grass
			if (!src.working)
				usr << "\red [src.name] fails to dispense anything."
				return
			var/vend = src.vendamt
			while(vend > 0)
				new getseed(src.loc)
				vend--
				src.seedcount++
			if(src.seedcount >= src.maxseed)
				src.can_vend = 0
				spawn(100)
					src.can_vend = 1
					src.seedcount = 0

		if ((href_list["cutwire"]) && (src.panelopen))
			var/twire = text2num(href_list["cutwire"])
			if (!( istype(usr.equipped(), /obj/item/weapon/wirecutters) ))
				usr << "You need wirecutters!"
				return
			else if (src.isWireColorCut(twire)) src.mend(twire)
			else src.cut(twire)
			src.updateUsrDialog()

		if ((href_list["pulsewire"]) && (src.panelopen))
			var/twire = text2num(href_list["pulsewire"])
			if (!istype(usr.equipped(), /obj/item/device/multitool))
				usr << "You need a multitool!"
				return
			else if (src.isWireColorCut(twire))
				usr << "You can't pulse a cut wire."
				return
			else src.pulse(twire)
			src.updateUsrDialog()

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(istype(W, /obj/item/weapon/screwdriver))
			if (!src.panelopen)
				src.overlays += image('vending.dmi', "grife-panel")
				src.panelopen = 1
			else
				src.overlays = null
				src.panelopen = 0
			user << "You [src.panelopen ? "open" : "close"] the maintenance panel."
			src.updateUsrDialog()
		else if(istype(W, /obj/item/weapon/card/emag))
			if (!src.hacked)
				user << "\blue You disable the [src]'s product locks!"
				src.hacked = 1
				src.name = "Feed Sabricator"
				src.updateUsrDialog()
			else user << "The [src] is already unlocked!"
		else ..()

	proc/isWireColorCut(var/wireColor)
		var/wireFlag = APCWireColorToFlag[wireColor]
		return ((src.wires & wireFlag) == 0)

	proc/isWireCut(var/wireIndex)
		var/wireFlag = APCIndexToFlag[wireIndex]
		return ((src.wires & wireFlag) == 0)

	proc/cut(var/wireColor)
		var/wireFlag = APCWireColorToFlag[wireColor]
		var/wireIndex = APCWireColorToIndex[wireColor]
		src.wires &= ~wireFlag
		switch(wireIndex)
			if(WIRE_EXTEND)
				src.hacked = 0
				src.name = "Seed Fabricator"
			if(WIRE_MALF) src.malfunction = 1
			if(WIRE_POWER) src.working = 0

	proc/mend(var/wireColor)
		var/wireFlag = APCWireColorToFlag[wireColor]
		var/wireIndex = APCWireColorToIndex[wireColor]
		src.wires |= wireFlag
		switch(wireIndex)
			if(WIRE_MALF) src.malfunction = 0

	proc/pulse(var/wireColor)
		var/wireIndex = APCWireColorToIndex[wireColor]
		switch(wireIndex)
			if(WIRE_EXTEND)
				if (src.hacked)
					src.hacked = 0
					src.name = "Seed Fabricator"
				else
					src.hacked = 1
					src.name = "Feed Sabricator"
			if (WIRE_MALF)
				if (src.malfunction) src.malfunction = 0
				else src.malfunction = 1
			if (WIRE_POWER)
				if (src.working) src.working = 0
				else src.working = 1

/obj/machinery/vending/seeds
	name = "Seed Vendor"
	desc = "Gardening made easy."
	icon_state = "cigs"
	product_paths = "/obj/item/weapon/seed/tomato;/obj/item/weapon/seed/orange;/obj/item/weapon/seed/grape;/obj/item/weapon/seed/melon;/obj/item/weapon/seed/chili;/obj/item/weapon/seed/apple;/obj/item/weapon/seed/banana;/obj/item/weapon/seed/lemon;/obj/item/weapon/seed/lime;/obj/item/weapon/seed/carrot;/obj/item/weapon/seed/wheat;/obj/item/weapon/seed/synthmeat;/obj/item/weapon/seed/sugar;/obj/item/weapon/seed/contusine;/obj/item/weapon/seed/nureous;/obj/item/weapon/seed/asomna;/obj/item/weapon/seed/commol;/obj/item/weapon/seed/venne"
	product_amounts = "20;20;20;20;20;20;20;20;20;20;20;20;20;20;20;20;20;20;20;20"
	vend_delay = 10
	product_hidden = "/obj/item/weapon/seed/cannabis;/obj/item/weapon/seed/pumpkin"
	vend_delay = 1

/obj/item/weapon/plantanalyzer/
	name = "Plant Analyzer"
	desc = "A device which examines the genes of plant seeds."
	icon = 'hydromisc.dmi'
	icon_state = "plantanalyzer"
	w_class = 1.0
	flags = ONBELT
	//mats = 4	 Strumpetplaya - commenting this out as it has components we don't support.

/obj/item/weapon/reagent_containers/glass/wateringcan/
	name = "watering can"
	desc = "Used to water things. Obviously."
	icon = 'hydromisc.dmi'
	icon_state = "watercan"
	amount_per_transfer_from_this = 10
	w_class = 3.0

	New()
		var/datum/reagents/R = new/datum/reagents(120)
		reagents = R
		R.my_atom = src
		R.add_reagent("water", 120)

/obj/item/weapon/reagent_containers/glass/compostbag/
	name = "compost bag"
	desc = "A big bag of compost."
	icon = 'hydromisc.dmi'
	icon_state = "compost"
	amount_per_transfer_from_this = 10
	w_class = 3.0

	New()
		var/datum/reagents/R = new/datum/reagents(60)
		reagents = R
		R.my_atom = src
		R.add_reagent("poo", 60)

/obj/item/weapon/reagent_containers/glass/bottle/weedkiller
	name = "atrazine bottle"
	desc = "A small bottle filled with Atrazine, an effective weedkiller."
	icon = 'chemical.dmi'
	icon_state = "bottle10"
	amount_per_transfer_from_this = 10

	New()
		var/datum/reagents/R = new/datum/reagents(30)
		reagents = R
		R.my_atom = src
		R.add_reagent("weedkiller", 30)

/obj/item/weapon/seedplanter
	name = "Portable Seed Fabricator"
	desc = "A tool for cyborgs used to create plant seeds."
	icon = 'device.dmi'
	icon_state = "forensic0"
	var/seedpath = /obj/item/weapon/seed/apple

	attack_self(var/mob/user as mob)
		playsound(src.loc, 'click.ogg', 100, 1)
		var/input = input(usr, "Enter the name of the seed you want.", "Seed Fabricator", null)
		switch(input)
			if("Apple", "apple") src.seedpath = /obj/item/weapon/seed/apple
			if("Asomna", "asomna") src.seedpath = /obj/item/weapon/seed/asomna
			if("Banana", "banana") src.seedpath = /obj/item/weapon/seed/banana
			if("Lettuce", "lettuce") src.seedpath = /obj/item/weapon/seed/lettuce
			if("Carrot", "carrot") src.seedpath = /obj/item/weapon/seed/carrot
			if("Chili", "chili") src.seedpath = /obj/item/weapon/seed/chili
			if("Commol", "commol") src.seedpath = /obj/item/weapon/seed/commol
			if("Contusine", "contusine") src.seedpath = /obj/item/weapon/seed/contusine
			if("Grape", "grape") src.seedpath = /obj/item/weapon/seed/grape
			if("Lemon", "lemon") src.seedpath = /obj/item/weapon/seed/lemon
			if("Lime", "lime") src.seedpath = /obj/item/weapon/seed/lime
			if("Melon", "melon", "Watermelon", "watermelon") src.seedpath = /obj/item/weapon/seed/melon
			if("Nureous", "nureous") src.seedpath = /obj/item/weapon/seed/nureous
			if("Orange", "orange") src.seedpath = /obj/item/weapon/seed/orange
			if("Potato", "potato") src.seedpath = /obj/item/weapon/seed/potato
			//if("Pumpkin", "pumpkin") src.seedpath = /obj/item/weapon/seed/pumpkin	Strumpetplaya - commented out
			if("Sugar", "sugar", "Sugarcane", "sugarcane") src.seedpath = /obj/item/weapon/seed/sugar
			if("Synthmeat", "synthmeat", "Meat", "meat") src.seedpath = /obj/item/weapon/seed/synthmeat
			if("Tomato", "tomato") src.seedpath = /obj/item/weapon/seed/tomato
			if("Venne", "venne") src.seedpath = /obj/item/weapon/seed/venne
			if("Wheat", "wheat") src.seedpath = /obj/item/weapon/seed/wheat
			if(null) return
			else user << "\red ERROR: Seed type not recognised."

//
// AWKWARD MISC/EXPERIMENTAL SHIT STARTS HERE
//

// SPACE VINE OR KUDZU

/obj/spacevine
	name = "Space Kudzu"
	desc = "An extremely expansionistic species of vine."
	icon = 'objects.dmi'
	icon_state = "vine-light1"
	anchored = 1
	density = 0
	var/growth = 0
	var/waittime = 40

	New()
		if(istype(src.loc, /turf/space))
			del(src)
			return

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (!W) return
		if (!user) return
		if (istype(W, /obj/item/weapon/axe)) del src
		if (istype(W, /obj/item/weapon/circular_saw)) del src
		if (istype(W, /obj/item/weapon/kitchen/utensil/knife)) del src
		if (istype(W, /obj/item/weapon/scalpel)) del src
		if (istype(W, /obj/item/weapon/screwdriver)) del src
		if (istype(W, /obj/item/weapon/shard)) del src
		if (istype(W, /obj/item/weapon/sword)) del src
		//if (istype(W, /obj/item/weapon/saw)) del src		Strumpetplaya - Commented out as it uses components we do not support
		if (istype(W, /obj/item/weapon/weldingtool)) del src
		if (istype(W, /obj/item/weapon/wirecutters)) del src
		..()

/obj/spacevine/proc/Life()
	if (!src) return
	var/Vspread
	if (prob(50)) Vspread = locate(src.x + rand(-1,1),src.y,src.z)
	else Vspread = locate(src.x,src.y + rand(-1, 1),src.z)
	var/dogrowth = 1
	if (!istype(Vspread, /turf/simulated/floor)) dogrowth = 0
	for(var/obj/O in Vspread)
		if (istype(O, /obj/window) || istype(O, /obj/forcefield) || istype(O, /obj/blob) || istype(O, /obj/alien/weeds) || istype(O, /obj/spacevine)) dogrowth = 0
		if (istype(O, /obj/machinery/door/))
			if(O:p_open == 0 && prob(50)) O:open()
			else dogrowth = 0
	if (dogrowth == 1)
		var/obj/spacevine/B = new /obj/spacevine(Vspread)
		B.icon_state = pick("vine-light1", "vine-light2", "vine-light3")
		spawn(20)
			if(B)
				B.Life()
	src.growth += 1
	if (src.growth == 10)
		src.name = "Thick Space Kudzu"
		src.icon_state = pick("vine-med1", "vine-med2", "vine-med3")
		src.opacity = 1
		src.waittime = 80
	if (src.growth == 20)
		src.name = "Dense Space Kudzu"
		src.icon_state = pick("vine-hvy1", "vine-hvy2", "vine-hvy3")
		src.density = 1
	spawn(src.waittime)
		if (src.growth < 20) src.Life()

/obj/spacevine/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			if (prob(66))
				del(src)
				return
		if(3.0)
			if (prob(33))
				del(src)
				return
		else
	return

/obj/spacevine/temperature_expose(null, temp, volume)
	del src

// CRYSTAL

/obj/item/weapon/shard/crystal
	name = "crystal shard"
	icon = 'shards.dmi'
	icon_state = "clarge"
	desc = "A shard of Plasma Crystal. Very hard and sharp."
	w_class = 3.0
	force = 10.0
	throwforce = 20.0
	item_state = "shard-glass"
	g_amt = 0
	New()
		src.icon_state = pick("clarge", "cmedium", "csmall")
		switch(src.icon_state)
			if("csmall")
				src.pixel_x = rand(1, 18)
				src.pixel_y = rand(1, 18)
			if("cmedium")
				src.pixel_x = rand(1, 16)
				src.pixel_y = rand(1, 16)
			if("clarge")
				src.pixel_x = rand(1, 10)
				src.pixel_y = rand(1, 5)
			else
		return
	attackby(obj/item/weapon/W as obj, mob/user as mob)
		..()
		if (!( istype(W, /obj/item/weapon/weldingtool) && W:welding )) return
		W:eyecheck(user)
		user << "\red The crystal shard resists the heat!"
		return
	HasEntered(AM as mob|obj)
		if(ismob(AM))
			var/mob/M = AM
			M << "\red <B>You step on the crystal shard!</B>"
			playsound(src.loc, 'glass_step.ogg', 50, 1)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				var/datum/organ/external/affecting = H.organs[pick("l_foot", "r_foot")]
				H.weakened = max(3, H.weakened)
				affecting.take_damage(10, 0)
				H.UpdateDamageIcon()
				H.updatehealth()