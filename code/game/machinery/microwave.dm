/datum/recipe
	var/list/needs = list()
	var/creates = "" // The item that is spawned when the recipe is made

/datum/recipe/cereal
	needs = list("flour" = 1)
	creates = "cereal"

/datum/recipe/candycane
	needs = list("sugar" = 2)
	creates = "candycane"

/datum/recipe/sweetapple
	needs = list("plant/apple" = 1, "sugar" = 1)
	creates = "sweetapple"

/datum/recipe/bun
	needs = list("dough" = 1)
	creates = "bun"

/datum/recipe/flatbread
	needs = list("flatdough" = 1)
	creates = "flatbread"

/datum/recipe/pie
	needs = list("flour" = 2, "/obj/item/weapon/banana" = 1)
	creates = "pie"

/datum/recipe/waffles
	needs = list("flatdough" = 1, "sugar" = 1)
	creates = "waffles"

/datum/recipe/boiledegg
	needs = list("egg" = 1)
	creates = "boiledegg"

/datum/recipe/omelette
	needs = list("egg" = 2)
	creates = "omelette"

/datum/recipe/donut
	needs = list("egg" = 1, "flour" = 1)
	creates = "donut"

/datum/recipe/loaf
	needs = list("dough" = 1, "egg" = 1)
	creates = "breadsys/loaf"

/datum/recipe/steak
	needs = list("meat" = 1)
	creates = "steak"

/datum/recipe/chips
	needs = list("rawsticks" = 1)
	creates = "chips"

/datum/recipe/frenchfries
	needs = list("rawsticks" = 1, "breadsys/ontop/butter" = 1)
	creates = "frenchfries"

/datum/recipe/cutlet
	needs = list("rawcutlet" = 1)
	creates = "cutlet"

/datum/recipe/meatball
	needs = list("rawmeatball" = 1)
	creates = "meatball"

/datum/recipe/sausage
	needs = list("cutlet" = 1)
	creates = "sausage"

/datum/recipe/bakedpotato
	needs = list("plant/potato" = 1)
	creates = "bakedpotato"

/datum/recipe/spaghetti
	needs = list("noodles" = 1)
	creates = "spaghetti"

/datum/recipe/meatspaghetti
	needs = list("noodles" = 1, "rawmeatball" = 1)
	creates = "meatspaghetti"

/datum/recipe/pieapple
	needs = list("dough" = 1, "sugar" = 1, "plant/apple" = 1)
	creates = "pieapple"

/datum/recipe/pattyapple
	needs = list("doughslice" = 1, "plant/apple" = 1)
	creates = "pattyapple"

/datum/recipe/piepotato
	needs = list("dough" = 1, "breadsys/ontop/butter" = 1, "plant/potato" = 1)
	creates = "piepotato"

/datum/recipe/pieshroom
	needs = list("dough" = 1, "breadsys/ontop/butter" = 1, "mushroom" = 1)
	creates = "pieshroom"

/datum/recipe/piemeat
	needs = list("dough" = 1, "breadsys/ontop/butter" = 1, "meat" = 1)
	creates = "piemeat"

/datum/recipe/taco
	needs = list("doughslice" = 1, "cutlet" = 1, "breadsys/ontop/cheese" = 1)
	creates = "taco"

/datum/recipe/donkpocket
	needs = list("doughslice" = 1, "meatball" = 1)
	creates = "donkpocket"

/datum/recipe/pizza
	needs = list("flatdough" = 1, "breadsys/ontop/cheese" = 1, "ketchup" = 1)
	creates = "pizza"

/datum/recipe/pizzashroom
	needs = list("flatdough" = 1, "breadsys/ontop/cheese" = 1, "ketchup" = 1, "mushroom" = 1)
	creates = "pizzashroom"

/datum/recipe/pizzameat
	needs = list("flatdough" = 1, "breadsys/ontop/cheese" = 1, "ketchup" = 1, "cutlet" = 2)
	creates = "pizzameat"

/datum/recipe/pizzameatshroom
	needs = list("flatdough" = 1, "breadsys/ontop/cheese" = 1, "ketchup" = 1, "cutlet" = 2, "mushroom" = 1)
	creates = "pizzameatshroom"

/datum/recipe/pizzasalami
	needs = list("flatdough" = 1, "breadsys/ontop/cheese" = 1, "ketchup" = 1, "breadsys/ontop/salami" = 2)
	creates = "pizzasalami"

/datum/recipe/pizzasalamishroom
	needs = list("flatdough" = 1, "breadsys/ontop/cheese" = 1, "ketchup" = 1, "breadsys/ontop/salami" = 2, "mushroom" = 1)
	creates = "pizzasalamishroom"

/datum/recipe/pizzapotato
	needs = list("flatdough" = 1, "breadsys/ontop/cheese" = 1, "ketchup" = 1, "plant/potato" = 1)
	creates = "pizzapotato"
////////////////////////////////////////////////////


/datum/recipe/dwbiscuits
	needs = list("plump" = 2)
	creates = "dwbiscuits"

/datum/recipe/donkpocket_warm
	needs = list("donkpocket" = 1)
	creates = "donkpocket"

/obj/machinery/microwave
	name = "Microwave"
	icon = 'kitchen.dmi'
	icon_state = "mw"
	density = 1
	anchored = 1
	var/operating = 0 // Is it on?
	var/dirty = 0 // Does it need cleaning?
	var/broken = 0 // How broken is it???
	var/list/available_recipes = list() // List of the recipes you can use
	var/obj/item/weapon/reagent_containers/food/snacks/being_cooked = null // The item being cooked
	var/humanmeat_name
	var/humanmeat_job

/obj/machinery/microwave/New() // *** After making the recipe in defines\obj\food.dmi, add it in here! ***
	..()
	src.available_recipes += new /datum/recipe/cereal(src)
	src.available_recipes += new /datum/recipe/candycane(src)
	src.available_recipes += new /datum/recipe/sweetapple(src)
	src.available_recipes += new /datum/recipe/bun(src)
	src.available_recipes += new /datum/recipe/flatbread(src)
	src.available_recipes += new /datum/recipe/pie(src)
	src.available_recipes += new /datum/recipe/waffles(src)
	src.available_recipes += new /datum/recipe/boiledegg(src)
	src.available_recipes += new /datum/recipe/omelette(src)
	src.available_recipes += new /datum/recipe/donut(src)
	src.available_recipes += new /datum/recipe/loaf(src)
	src.available_recipes += new /datum/recipe/steak(src)
	src.available_recipes += new /datum/recipe/cutlet(src)
	src.available_recipes += new /datum/recipe/meatball(src)
	src.available_recipes += new /datum/recipe/sausage(src)
	src.available_recipes += new /datum/recipe/chips(src)
	src.available_recipes += new /datum/recipe/frenchfries(src)
	src.available_recipes += new /datum/recipe/bakedpotato(src)
	src.available_recipes += new /datum/recipe/spaghetti(src)
	src.available_recipes += new /datum/recipe/meatspaghetti(src)
	src.available_recipes += new /datum/recipe/pieapple(src)
	src.available_recipes += new /datum/recipe/pattyapple(src)
	src.available_recipes += new /datum/recipe/pieshroom(src)
	src.available_recipes += new /datum/recipe/piemeat(src)
	src.available_recipes += new /datum/recipe/taco(src)
	src.available_recipes += new /datum/recipe/donkpocket(src)
	src.available_recipes += new /datum/recipe/pizza(src)
	src.available_recipes += new /datum/recipe/pizzashroom(src)
	src.available_recipes += new /datum/recipe/pizzameat(src)
	src.available_recipes += new /datum/recipe/pizzameatshroom(src)
	src.available_recipes += new /datum/recipe/pizzasalami(src)
	src.available_recipes += new /datum/recipe/pizzasalamishroom(src)
	src.available_recipes += new /datum/recipe/pizzapotato(src)
	src.available_recipes += new /datum/recipe/donkpocket_warm(src)
	src.available_recipes += new /datum/recipe/dwbiscuits(src)

/*******************
*   Item Adding
********************/

obj/machinery/microwave/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(src.broken > 0)
		if(src.broken == 2 && istype(O, /obj/item/weapon/screwdriver)) // If it's broken and they're using a screwdriver
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] starts to fix part of the [name]."))
			sleep(20)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] fixes part of the [name]."))
			src.broken = 1 // Fix it a bit
		else if(src.broken == 1 && istype(O, /obj/item/weapon/wrench)) // If it's broken and they're doing the wrench
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] starts to fix part of the [name]."))
			sleep(20)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] fixes the [name]!"))
			src.icon_state = "mw"
			src.broken = 0 // Fix it!
		else
			user << "It's broken!"
	else if(src.dirty) // The microwave is all dirty so can't be used!
		if(istype(O, /obj/item/weapon/cleaner)) // If they're trying to clean it then let them
			var/obj/item/weapon/cleaner/C = O
			if(C.saftey == 1)
				user << "\blue The catch is still on!"
				return
			if (C.reagents.total_volume < 1)
				user << "\blue Its empty!"
				return
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] starts to clean the [name]."))
			sleep(20)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] has cleaned the [name]!"))
			src.dirty = 0 // It's cleaned!
			src.icon_state = "mw"
		else //Otherwise bad luck!!
			return
	else if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/meat))
		var/obj/item/weapon/reagent_containers/food/snacks/meat/M = O
		src.humanmeat_name = M.subjectname
		src.humanmeat_job = M.subjectjob
		for(var/mob/V in viewers(src, null))
			V.show_message(text("\blue [user] adds \a [O.name] to the [name]."))
		user.u_equip(O)
		O.loc = src
		if((user.client  && user.s_active != src))
			user.client.screen -= O
		O.dropped(user)
	else
		for(var/mob/V in viewers(src, null))
			V.show_message(text("\blue [user] adds \a [O.name] to the [name]."))
		user.u_equip(O)
		O.loc = src
		if((user.client  && user.s_active != src))
			user.client.screen -= O
		O.dropped(user)


obj/machinery/microwave/attack_paw(user as mob)
	return src.attack_hand(user)


/*******************
*   Microwave Menu
********************/

/obj/machinery/microwave/attack_hand(user as mob) // The microwave Menu
	var/dat
	if(src.broken > 0)
		dat = {"
<TT>Bzzzzttttt</TT>
		"}
	else if(src.operating)
		dat = {"
<TT>Microwaving in progress!<BR>
Please wait...!</TT><BR>
<BR>
"}
	else if(src.dirty)
		dat = {"
<TT>This microwave is dirty!<BR>
Please clean it before use!</TT><BR>
<BR>
"}
	else
		var/c
		for(var/obj/O in src.contents)
			c+="<B>[O.name]<BR>"
		dat = {"
<B>Contents<BR>[c]
<BR>
<A href='?src=\ref[src];cook=1'>Turn on!<BR>
<A href='?src=\ref[src];cook=3'>Dispense contents<BR>
"}

	user << browse("<HEAD><TITLE>Microwave Controls</TITLE></HEAD><TT>[dat]</TT>", "window=microwave")
	onclose(user, "microwave")
	return



/***********************************
*   Microwave Menu Handling/Cooking
************************************/

/obj/machinery/microwave/Topic(href, href_list)
	if(..())
		return

	usr.machine = src
	src.add_fingerprint(usr)

	if(href_list["cook"])
		if(!src.operating)
			if(!contents.len)
				state("Error: No ingredients")
			var/operation = text2num(href_list["cook"])

			var/cook_time = 150 // The time to wait before spawning the item
			var/cooked_item = null

			if(operation == 1) // If cook was pressed
				var/list/has = list()
				var/nonfood
				for(var/obj/O in src.contents)
					if(!istype(O, /obj/item/weapon/reagent_containers/food/))
						nonfood = 1
					has["[O.type]"]++

				for(var/mob/V in viewers(src, null))
					V.show_message(text("\blue The [name] turns on."))
				 // label for skipping failed recipes
				check_recipes:
					for(var/datum/recipe/A in src.available_recipes)
						//usr <<"[A.creates]"
						if(has.len != A.needs.len)
							continue check_recipes
						var/list/req = list()

						for(var/B in A.needs)
							if(findtext("/obj/",B))//If full path is specified
								req["[B]"]=A.needs["[B]"]//Add to list
							else//otherwise
								var/text="/obj/item/weapon/reagent_containers/food/snacks/"+B//add onto end of snacks path
								req["[text]"] =A.needs["[B]"]//add to list
						//	var/a = B
						//	usr << "needs [a] [req[req.len]]"
						for(var/B in has)
						//	usr << "[has[B]] [B],[req[B]] [B]"
							if(has[B]!=req[B])
							//	usr << "fail"
								continue check_recipes
						if(!findtext("/obj/",A.creates))//If full path is not specified
							cooked_item = "/obj/item/weapon/reagent_containers/food/snacks/"+A.creates
						else
							cooked_item = A.creates
						for(var/obj/O in src.contents)
							del O
						break check_recipes


				if(!cooked_item) //Oops that wasn't a recipe dummy!!!
					if(src.contents && !nonfood) //Make sure there's something inside though to dirty it
						src.operating = 1 // Turn it on
						src.icon_state = "mw1"
						src.updateUsrDialog()
						for(var/obj/O in src.contents)
							if(findtext("/obj/item/weapon/reagent_containers/food/snacks/", O.type))
								del O
						sleep(40) // Half way through
						playsound(src.loc, 'splat.ogg', 50, 1) // Play a splat sound
						icon_state = "mwbloody1" // Make it look dirty!!
						sleep(40) // Then at the end let it finish normally
						playsound(src.loc, 'ding.ogg', 50, 1)
						for(var/mob/V in viewers(src, null))
							V.show_message(text("\red The [name] gets covered in muck!"))
						src.dirty = 1 // Make it dirty so it can't be used util cleaned
						src.icon_state = "mwbloody" // Make it look dirty too
						src.operating = 0 // Turn it off again aferwards
						// Don't clear the extra item though so important stuff can't be deleted this way and
						// it prolly wouldn't make a mess anyway
						for(var/obj/O in src.contents)

							O.loc = get_turf(src)

					else if(src.contents && nonfood) // However if there's a weird item inside we want to break it, not dirty it
						src.operating = 1 // Turn it on
						src.icon_state = "mw1"
						src.updateUsrDialog()
						var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
						s.set_up(2, 1, src)
						s.start()
						icon_state = "mwb" // Make it look all busted up and shit
						for(var/mob/V in viewers(src, null))
							V.show_message(text("\red The [name] breaks!")) //Let them know they're stupid
						src.broken = 2 // Make it broken so it can't be used util fixed
						src.operating = 0 // Turn it off again aferwards

						for(var/obj/O in src.contents)
							O.loc = get_turf(src)

					else //Otherwise it was empty, so just turn it on then off again with nothing happening
						src.operating = 1
						src.icon_state = "mw1"
						src.updateUsrDialog()
						sleep(80)
						src.icon_state = "mw"
						playsound(src.loc, 'ding.ogg', 50, 1)
						src.operating = 0

			if(operation == 3) // If dispense was pressed, empty the microwave
				for(var/obj/O in src.contents)
					O.loc = get_turf(src)
				usr << "You empty the [name] of contents."

			var/cooking = text2path(cooked_item) // Get the item that needs to be spawned
			if(!isnull(cooking))
				for(var/mob/V in viewers(src, null))
					V.show_message(text("\blue The [name] begins cooking something!"))
				src.operating = 1 // Turn it on so it can't be used again while it's cooking
				src.icon_state = "mw1" //Make it look on too
				src.updateUsrDialog()
				src.being_cooked = new cooking(src)

				spawn(cook_time) //After the cooking time
					if(!isnull(src.being_cooked))
						playsound(src.loc, 'ding.ogg', 50, 1)
						if(istype(src.being_cooked, /obj/item/weapon/reagent_containers/food/snacks/donkpocket))
							src.being_cooked:warm = 1
							src.being_cooked.name = "warm " + src.being_cooked.name
							src.being_cooked:cooltime()
						src.being_cooked.loc = get_turf(src) // Create the new item
						src.being_cooked = null // We're done!
					src.operating = 0 // Turn the microwave back off
					src.icon_state = "mw"
			else
				return