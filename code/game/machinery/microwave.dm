/datum/recipe
	var/list/needs = list()
	var/creates = "" // The item that is spawned when the recipe is made

/datum/recipe/donut
	needs = list("egg" = 1, "flour" = 1)
	creates = "donut"

/datum/recipe/dwbiscuits
	needs = list("plump" = 2)
	creates = "dwbiscuits"

/datum/recipe/monkeyburger
	needs = list("monkeymeat" = 1, "flour" = 1)
	creates = "monkeyburger"

/datum/recipe/humanburger
	needs = list("flour" = 1, "humanmeat" = 1)
	creates = "humanburger"

/datum/recipe/brainburger
	needs = list("flour" = 1, "/obj/item/brain" = 1)
	creates = "brainburger"

/datum/recipe/roburger/
	needs = list("flour" = 1, "/obj/item/robot_parts/head" = 1)
	creates = "roburger"

/datum/recipe/waffles
	needs = list("egg" = 2, "flour" = 2)
	creates = "waffles"

/datum/recipe/meatball
	needs = list("monkeymeat" = 1, "humanmeat" = 1)
	creates = "meatball"

/datum/recipe/pie
	needs = list("flour" = 2, "/obj/item/weapon/banana" = 1)
	creates = "pie"

/datum/recipe/donkpocket
	needs = list("flour" = 1, "meatball" = 1)
	creates = "donkpocket"

/datum/recipe/donkpocket_warm
	needs = list("donkpocket" = 1)
	creates = "donkpocket"


/obj/machinery/microwave/New() // *** After making the recipe in defines\obj\food.dmi, add it in here! ***
	..()
	src.available_recipes += new /datum/recipe/donut(src)
	src.available_recipes += new /datum/recipe/monkeyburger(src)
	src.available_recipes += new /datum/recipe/humanburger(src)
	src.available_recipes += new /datum/recipe/waffles(src)
	src.available_recipes += new /datum/recipe/brainburger(src)
	src.available_recipes += new /datum/recipe/meatball(src)
//	src.available_recipes += new /datum/recipe/roburger(src)
	src.available_recipes += new /datum/recipe/donkpocket(src)
	src.available_recipes += new /datum/recipe/dwbiscuits(src)
	src.available_recipes += new /datum/recipe/donkpocket_warm(src)
	src.available_recipes += new /datum/recipe/pie(src)


/*******************
*   Item Adding
********************/

obj/machinery/microwave/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(src.broken > 0)
		if(src.broken == 2 && istype(O, /obj/item/weapon/screwdriver)) // If it's broken and they're using a screwdriver
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] starts to fix part of the microwave."))
			sleep(20)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] fixes part of the microwave."))
			src.broken = 1 // Fix it a bit
		else if(src.broken == 1 && istype(O, /obj/item/weapon/wrench)) // If it's broken and they're doing the wrench
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] starts to fix part of the microwave."))
			sleep(20)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] fixes the microwave!"))
			src.icon_state = "mw"
			src.broken = 0 // Fix it!
		else
			user << "It's broken!"
	else if(src.dirty) // The microwave is all dirty so can't be used!
		if(istype(O, /obj/item/weapon/cleaner)) // If they're trying to clean it then let them
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] starts to clean the microwave."))
			sleep(20)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] has cleaned the microwave!"))
			src.dirty = 0 // It's cleaned!
			src.icon_state = "mw"
		else //Otherwise bad luck!!
			return
	else if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/humanmeat))
		var/obj/item/weapon/reagent_containers/food/snacks/humanmeat/m = O
		src.humanmeat_name = m.subjectname
		src.humanmeat_job = m.subjectjob
		for(var/mob/V in viewers(src, null))
			V.show_message(text("\blue [user] adds \a [O.name] to the microwave."))
		user.u_equip(O)
		O.loc = src
		if((user.client  && user.s_active != src))
			user.client.screen -= O
		O.dropped(user)
	else
		for(var/mob/V in viewers(src, null))
			V.show_message(text("\blue [user] adds \a [O.name] to the microwave."))
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
<A href='?src=\ref[src];cook=2'>Dispose contents!<BR>
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
			var/operation = text2num(href_list["cook"])

			var/cook_time = 200 // The time to wait before spawning the item
			var/cooked_item = ""

			if(operation == 1) // If cook was pressed
				var/list/has = list()
				var/nonfood
				for(var/obj/O in src.contents)
					if(!istype(O, /obj/item/weapon/reagent_containers/food/))
						nonfood = 1
					has["[O.type]"]++

				for(var/mob/V in viewers(src, null))
					V.show_message(text("\blue The microwave turns on."))
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


				if(cooked_item == "") //Oops that wasn't a recipe dummy!!!
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
							V.show_message(text("\red The microwave gets covered in muck!"))
						src.dirty = 1 // Make it dirty so it can't be used util cleaned
						src.icon_state = "mwbloody" // Make it look dirty too
						src.operating = 0 // Turn it off again aferwards
						// Don't clear the extra item though so important stuff can't be deleted this way and
						// it prolly wouldn't make a mess anyway
						for(var/obj/O in src.contents)
							src.contents.Remove(O)
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
							V.show_message(text("\red The microwave breaks!")) //Let them know they're stupid
						src.broken = 2 // Make it broken so it can't be used util fixed
						src.operating = 0 // Turn it off again aferwards
						for(var/obj/O in src.contents)
							if(findtext("/obj/item/weapon/reagent_containers/food/snacks/", O.type))
								del O
						for(var/obj/O in src.contents)
							src.contents.Remove(O)
							O.loc = get_turf(src)

					else //Otherwise it was empty, so just turn it on then off again with nothing happening
						src.operating = 1
						src.icon_state = "mw1"
						src.updateUsrDialog()
						sleep(80)
						src.icon_state = "mw"
						playsound(src.loc, 'ding.ogg', 50, 1)
						src.operating = 0

			if(operation == 2) // If dispose was pressed, empty the microwave
				for(var/obj/O in src.contents)
					if(findtext("/obj/item/weapon/reagent_containers/food/snacks/", O.type))
						del O
				for(var/obj/O in src.contents)
					src.contents.Remove(O)
					O.loc = get_turf(src)
				usr << "You dispose of the microwave contents."

			if(operation == 3) // If dispense was pressed, empty the microwave
				for(var/obj/O in src.contents)
					O.loc = get_turf(src)
				usr << "You empty the microwave of contents."

			var/cooking = text2path(cooked_item) // Get the item that needs to be spanwed
			if(!isnull(cooking))
				for(var/mob/V in viewers(src, null))
					V.show_message(text("\blue The microwave begins cooking something!"))
				src.operating = 1 // Turn it on so it can't be used again while it's cooking
				src.icon_state = "mw1" //Make it look on too
				src.updateUsrDialog()
				src.being_cooked = new cooking(src)

				spawn(cook_time) //After the cooking time
					if(!isnull(src.being_cooked))
						playsound(src.loc, 'ding.ogg', 50, 1)
						if(istype(src.being_cooked, /obj/item/weapon/reagent_containers/food/snacks/humanburger))
							src.being_cooked.name = src.humanmeat_name + src.being_cooked.name
							src.being_cooked:job = src.humanmeat_job
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


