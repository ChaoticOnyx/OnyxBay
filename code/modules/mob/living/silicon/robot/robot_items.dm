//A portable analyzer, for research borgs.  This is better then giving them a gripper which can hold anything and letting them use the normal analyzer.
/obj/item/weapon/portable_destructive_analyzer
	name = "Portable Destructive Analyzer"
	icon = 'icons/obj/items.dmi'
	icon_state = "portable_analyzer"
	desc = "Similar to the stationary version, this rather unwieldy device allows you to break down objects in the name of science."

	var/min_reliability = 90 //Can't upgrade, call it laziness or a drawback

	var/datum/research/techonly/files 	//The device uses the same datum structure as the R&D computer/server.
										//This analyzer can only store tech levels, however.

	var/obj/item/weapon/loaded_item	//What is currently inside the analyzer.

/obj/item/weapon/portable_destructive_analyzer/New()
	..()
	files = new /datum/research/techonly(src) //Setup the research data holder.

/obj/item/weapon/portable_destructive_analyzer/attack_self(user as mob)
	var/response = alert(user, 	"Analyzing the item inside will *DESTROY* the item for good.\n\
							Syncing to the research server will send the data that is stored inside to research.\n\
							Ejecting will place the loaded item onto the floor.",
							"What would you like to do?", "Analyze", "Sync", "Eject")
	if(response == "Analyze")
		if(loaded_item)
			var/confirm = alert(user, "This will destroy the item inside forever.  Are you sure?","Confirm Analyze","Yes","No")
			if(confirm == "Yes") //This is pretty copypasta-y
				to_chat(user, "You activate the analyzer's microlaser, analyzing \the [loaded_item] and breaking it down.")
				flick("portable_analyzer_scan", src)
				playsound(src.loc, 'sound/items/Welder2.ogg', 50, 1)
				for(var/T in loaded_item.origin_tech)
					files.UpdateTech(T, loaded_item.origin_tech[T])
					to_chat(user, "\The [loaded_item] had level [loaded_item.origin_tech[T]] in [CallTechName(T)].")
				loaded_item = null
				for(var/obj/I in contents)
					for(var/mob/M in I.contents)
						M.death()
					if(istype(I,/obj/item/stack/material))//Only deconstructs one sheet at a time instead of the entire stack
						var/obj/item/stack/material/S = I
						if(S.get_amount() > 1)
							S.use(1)
							loaded_item = S
						else
							qdel(S)
							desc = initial(desc)
							icon_state = initial(icon_state)
					else
						qdel(I)
						desc = initial(desc)
						icon_state = initial(icon_state)
			else
				return
		else
			to_chat(user, "The [src] is empty.  Put something inside it first.")
	if(response == "Sync")
		var/success = 0
		for(var/obj/machinery/r_n_d/server/S in SSmachines.machinery)
			for(var/datum/tech/T in files.known_tech) //Uploading
				S.files.AddTech2Known(T)
			for(var/datum/tech/T in S.files.known_tech) //Downloading
				files.AddTech2Known(T)
			success = 1
			files.RefreshResearch()
		if(success)
			to_chat(user, "You connect to the research server, push your data upstream to it, then pull the resulting merged data from the master branch.")
			playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 1)
		else
			to_chat(user, "Reserch server ping response timed out.  Unable to connect.  Please contact the system administrator.")
			playsound(src.loc, 'sound/machines/buzz-two.ogg', 50, 1)
	if(response == "Eject")
		if(loaded_item)
			loaded_item.loc = get_turf(src)
			desc = initial(desc)
			icon_state = initial(icon_state)
			loaded_item = null
		else
			to_chat(user, "The [src] is already empty.")


/obj/item/weapon/portable_destructive_analyzer/afterattack(var/atom/target, var/mob/living/user, proximity)
	if(!target)
		return
	if(!proximity)
		return
	if(!isturf(target.loc)) // Don't load up stuff if it's inside a container or mob!
		return
	if(istype(target,/obj/item))
		if(loaded_item)
			to_chat(user, "Your [src] already has something inside.  Analyze or eject it first.")
			return
		var/obj/item/I = target
		I.loc = src
		loaded_item = I
		for(var/mob/M in viewers())
			M.show_message(text("<span class='notice'>[user] adds the [I] to the [src].</span>"), 1)
		desc = initial(desc) + "<br>It is holding \the [loaded_item]."
		flick("portable_analyzer_load", src)
		icon_state = "portable_analyzer_full"

//This is used to unlock other borg covers.
/obj/item/weapon/card/robot //This is not a child of id cards, as to avoid dumb typechecks on computers.
	name = "access code transmission device"
	icon_state = "id-robot"
	desc = "A circuit grafted onto the bottom of an ID card.  It is used to transmit access codes into other robot chassis, \
	allowing you to lock and unlock other robots' panels."

/obj/item/weapon/card/robot_sec //This is not a child of id cards, as to avoid dumb typechecks on computers.
	name = "access code transmission device"
	icon_state = "id-robot"
	desc = "A circuit grafted onto the bottom of an ID card.  It is used to transmit access codes into security deployable barriers, \
	allowing you to lock and unlock them."

//A harvest item for serviceborgs.
/obj/item/weapon/robot_harvester
	name = "auto harvester"
	desc = "A hand-held harvest tool that resembles a sickle.  It uses energy to cut plant matter very efficently."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "autoharvester"

/obj/item/weapon/robot_harvester/afterattack(var/atom/target, var/mob/living/user, proximity)
	if(!target)
		return
	if(!proximity)
		return
	if(istype(target,/obj/machinery/portable_atmospherics/hydroponics))
		var/obj/machinery/portable_atmospherics/hydroponics/T = target
		if(T.harvest) //Try to harvest, assuming it's alive.
			T.harvest(user)
		else if(T.dead) //It's probably dead otherwise.
			T.remove_dead(user)
	else
		to_chat(user, "Harvesting \a [target] is not the purpose of this tool. \The [src] is for plants being grown.")

// A special tray for the service droid. Allow droid to pick up and drop items as if they were using the tray normally
// Click on table to unload, click on item to load. Otherwise works identically to a tray.
// Unlike the base item "tray", robotrays ONLY pick up food, drinks and condiments.

/obj/item/weapon/tray/robotray
	name = "RoboTray"
	desc = "An autoloading tray specialized for carrying refreshments."

/obj/item/weapon/tray/robotray/afterattack(atom/target, mob/user as mob, proximity)
	if(!proximity)
		return
	if ( !target )
		return
	// pick up items, mostly copied from base tray pickup proc
	// see code/game/objects/items/weapons/kitchen.dm line 241
	if ( istype(target,/obj/item))
		if ( !isturf(target.loc) ) // Don't load up stuff if it's inside a container or mob!
			return
		var turf/pickup = target.loc

		var addedSomething = 0

		for(var/obj/item/weapon/reagent_containers/food/I in pickup)


			if( I != src && !I.anchored && !istype(I, /obj/item/clothing/under) && !istype(I, /obj/item/clothing/suit) && !istype(I, /obj/item/projectile) )
				var/add = I.get_storage_cost()
				if(calc_carry() + add >= max_carry)
					break

				I.loc = src
				carrying.Add(I)
				overlays += image("icon" = I.icon, "icon_state" = I.icon_state, "layer" = 30 + I.layer)
				addedSomething = 1
		if ( addedSomething )
			user.visible_message("<span class='notice'>\The [user] load some items onto their service tray.</span>")

		return

	// Unloads the tray, copied from base item's proc dropped() and altered
	// see code/game/objects/items/weapons/kitchen.dm line 263

	if ( isturf(target) || istype(target,/obj/structure/table) )
		var foundtable = istype(target,/obj/structure/table/)
		if ( !foundtable ) //it must be a turf!
			for(var/obj/structure/table/T in target)
				foundtable = 1
				break

		var turf/dropspot
		if ( !foundtable ) // don't unload things onto walls or other silly places.
			dropspot = user.loc
		else if ( isturf(target) ) // they clicked on a turf with a table in it
			dropspot = target
		else					// they clicked on a table
			dropspot = target.loc


		overlays = null

		var droppedSomething = 0

		for(var/obj/item/I in carrying)
			I.loc = dropspot
			carrying.Remove(I)
			droppedSomething = 1
			if(!foundtable && isturf(dropspot))
				// if no table, presume that the person just shittily dropped the tray on the ground and made a mess everywhere!
				spawn()
					for(var/i = 1, i <= rand(1,2), i++)
						if(I)
							step(I, pick(NORTH,SOUTH,EAST,WEST))
							sleep(rand(2,4))
		if ( droppedSomething )
			if ( foundtable )
				user.visible_message("<span class='notice'>[user] unloads their service tray.</span>")
			else
				user.visible_message("<span class='notice'>[user] drops all the items on their tray.</span>")

	return ..()




// A special pen for service droids. Can be toggled to switch between normal writting mode, and paper rename mode
// Allows service droids to rename paper items.

/obj/item/weapon/pen/robopen
	desc = "A black ink printing attachment with a paper naming mode."
	name = "Printing Pen"
	var/mode = 1

/obj/item/weapon/pen/robopen/attack_self(mob/user as mob)

	var/choice = input("Would you like to change colour or mode?") as null|anything in list("Colour","Mode")
	if(!choice) return

	playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)

	switch(choice)

		if("Colour")
			var/newcolour = input("Which colour would you like to use?") as null|anything in list("black","blue","red","green","yellow")
			if(newcolour) colour = newcolour

		if("Mode")
			if (mode == 1)
				mode = 2
			else
				mode = 1
			to_chat(user, "Changed printing mode to '[mode == 2 ? "Rename Paper" : "Write Paper"]'")

	return

// Copied over from paper's rename verb
// see code/modules/paperwork/paper.dm line 62

/obj/item/weapon/pen/robopen/proc/RenamePaper(mob/user as mob,obj/paper as obj)
	if ( !user || !paper )
		return
	var/n_name = sanitizeSafe(input(user, "What would you like to label the paper?", "Paper Labelling", null)  as text, 32)
	if ( !user || !paper )
		return

	//n_name = copytext(n_name, 1, 32)
	if(( get_dist(user,paper) <= 1  && user.stat == 0))
		paper.SetName("paper[(n_name ? text("- '[n_name]'") : null)]")
	add_fingerprint(user)
	return

//TODO: Add prewritten forms to dispense when you work out a good way to store the strings.
/obj/item/weapon/form_printer
	//name = "paperwork printer"
	name = "paper dispenser"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper_bin1"
	item_state = "sheet-metal"

/obj/item/weapon/form_printer/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	return

/obj/item/weapon/form_printer/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag, params)

	if(!target || !flag)
		return

	if(istype(target,/obj/structure/table))
		deploy_paper(get_turf(target))

/obj/item/weapon/form_printer/attack_self(mob/user as mob)
	deploy_paper(get_turf(src))

/obj/item/weapon/form_printer/proc/deploy_paper(var/turf/T)
	T.visible_message("<span class='notice'>\The [src.loc] dispenses a sheet of crisp white paper.</span>")
	new /obj/item/weapon/paper(T)


//Personal shielding for the combat module.
/obj/item/borg/combat/shield
	name = "personal shielding"
	desc = "A powerful experimental module that turns aside or absorbs incoming attacks at the cost of charge."
	icon = 'icons/obj/decals.dmi'
	icon_state = "shock"
	var/shield_level = 0.5 //Percentage of damage absorbed by the shield.

/obj/item/borg/combat/shield/verb/set_shield_level()
	set name = "Set shield level"
	set category = "Object"
	set src in range(0)

	var/N = input("How much damage should the shield absorb?") in list("5","10","25","50","75","100")
	if (N)
		shield_level = text2num(N)/100

/obj/item/borg/combat/mobility
	name = "mobility module"
	desc = "By retracting limbs and tucking in its head, a combat android can roll at high speeds."
	icon = 'icons/obj/decals.dmi'
	icon_state = "shock"

/obj/item/weapon/inflatable_dispenser
	name = "inflatables dispenser"
	desc = "Hand-held device which allows rapid deployment and removal of inflatables."
	icon = 'icons/obj/storage.dmi'
	icon_state = "inf_deployer"
	w_class = ITEM_SIZE_LARGE

	var/stored_walls = 5
	var/stored_doors = 2
	var/max_walls = 5
	var/max_doors = 2
	var/mode = 0 // 0 - Walls   1 - Doors

/obj/item/weapon/inflatable_dispenser/robot
	w_class = ITEM_SIZE_HUGE
	stored_walls = 10
	stored_doors = 5
	max_walls = 10
	max_doors = 5

/obj/item/weapon/inflatable_dispenser/examine(var/mob/user)
	if(!..(user))
		return
	to_chat(user, "It has [stored_walls] wall segment\s and [stored_doors] door segment\s stored.")
	to_chat(user, "It is set to deploy [mode ? "doors" : "walls"]")

/obj/item/weapon/inflatable_dispenser/attack_self()
	mode = !mode
	to_chat(usr, "You set \the [src] to deploy [mode ? "doors" : "walls"].")

/obj/item/weapon/inflatable_dispenser/afterattack(var/atom/A, var/mob/user)
	..(A, user)
	if(!user)
		return
	if(!user.Adjacent(A))
		to_chat(user, "You can't reach!")
		return
	if(istype(A, /turf))
		try_deploy_inflatable(A, user)
	if(istype(A, /obj/item/inflatable) || istype(A, /obj/structure/inflatable))
		pick_up(A, user)

/obj/item/weapon/inflatable_dispenser/proc/try_deploy_inflatable(var/turf/T, var/mob/living/user)
	if(mode) // Door deployment
		if(!stored_doors)
			to_chat(user, "\The [src] is out of doors!")
			return

		if(T && istype(T))
			new /obj/structure/inflatable/door(T)
			stored_doors--

	else // Wall deployment
		if(!stored_walls)
			to_chat(user, "\The [src] is out of walls!")
			return

		if(T && istype(T))
			new /obj/structure/inflatable/wall(T)
			stored_walls--

	playsound(T, 'sound/items/zip.ogg', 75, 1)
	to_chat(user, "You deploy the inflatable [mode ? "door" : "wall"]!")

/obj/item/weapon/inflatable_dispenser/proc/pick_up(var/obj/A, var/mob/living/user)
	if(istype(A, /obj/structure/inflatable))
		if(istype(A, /obj/structure/inflatable/wall))
			if(stored_walls >= max_walls)
				to_chat(user, "\The [src] is full.")
				return
			stored_walls++
			qdel(A)
		else
			if(stored_doors >= max_doors)
				to_chat(user, "\The [src] is full.")
				return
			stored_doors++
			qdel(A)
		playsound(loc, 'sound/machines/hiss.ogg', 75, 1)
		visible_message("\The [user] deflates \the [A] with \the [src]!")
		return
	if(istype(A, /obj/item/inflatable))
		if(istype(A, /obj/item/inflatable/wall))
			if(stored_walls >= max_walls)
				to_chat(user, "\The [src] is full.")
				return
			stored_walls++
			qdel(A)
		else
			if(stored_doors >= max_doors)
				to_chat(usr, "\The [src] is full!")
				return
			stored_doors++
			qdel(A)
		visible_message("\The [user] picks up \the [A] with \the [src]!")
		return

	to_chat(user, "You fail to pick up \the [A] with \the [src]")
	return

/obj/item/weapon/reagent_containers/spray/cleaner/drone
	name = "space cleaner"
	desc = "BLAM!-brand non-foaming space cleaner!"
	volume = 150

/obj/item/robot_rack
	name = "a generic robot rack"
	desc = "A rack for carrying large items as a robot."
	var/list/object_type                    //The types of object the rack holds (subtypes are allowed).
	var/interact_type = null                  //Things of this type will trigger attack_hand when attacked by this.
	var/capacity = 1                   //How many objects can be held.
	var/list/obj/item/held = list()    //What is being held.
	var/icon_state_active = null
	var/pickup_time = 20
	var/deploy_time = 10
	var/pickup_sound = null
	var/deploy_sound = null
	var/inuse = 0

/obj/item/robot_rack/Destroy()
	if (length(held))
		while(length(held))
			var/obj/item/R = held[length(held)]
			R.forceMove(get_turf(src))
			held -= R
	return ..()

/obj/item/robot_rack/emp_act(var/severity)
	if (length(held))
		if (prob(40))
			var/obj/item/R = held[length(held)]
			R.forceMove(get_turf(src))
			visible_message("<span class='danger'[held[length(held)]] drops on the [get_turf(src)]!</span>")
			held -= R
			if(R && istype(R.loc,/turf))
				held.throw_at(get_edge_target_turf(R.loc,pick(GLOB.alldirs)),rand(1,3),30)

/obj/item/robot_rack/examine(mob/user)
	. = ..()
	to_chat(user, "It can hold up to [capacity] item[capacity == 1 ? "" : "s"].")
	if (length(held))
		var/text = "| "
		for (var/obj/O in held)
			text += "[O] | "
		to_chat(user, "Contains: [text]")

/obj/item/robot_rack/Initialize(mapload, starting_objects = 0)
	. = ..()
	for(var/i = 1, i <= min(starting_objects, capacity), i++)
		var/o_type = pick(object_type)
		held += new o_type(src)

/obj/item/robot_rack/proc/deploy(var/loc, mob/user)
	if (!inuse)
		if(!length(held))
			to_chat(user, "<span class='notice'>The rack is empty.</span>")
			return
		if (deploy_sound)
			playsound(src.loc, deploy_sound, 10, 1)
		inuse = 1
		var/obj/item/R = held[length(held)]
		if(do_after(user,deploy_time,src))
			R.forceMove(loc)
			held -= R
			if (istype(R, /obj/item/bodybag))
				R.attack_self(user) // deploy it
			inuse = 0
			user.visible_message("<span class='notice'>\The [user]'s \the [src] delpoys [R].</span>")
			update_icon()
		else
			to_chat(user, "<span class='notice'>You failed to deploy [R].</span>")

/obj/item/robot_rack/attack_self(mob/user)
	deploy(get_turf(src),user)

/obj/item/robot_rack/resolve_attackby(obj/O, mob/user, click_params)
	if (!inuse)
		for (var/T in object_type)
			if(istype(O, T))
				if(length(held) < capacity)
					var/mob/living/silicon/robot/R = user
					for (var/I in R.module.modules)
						if (I == O)
							return
					inuse = 1
					user.visible_message("<span class='notice'>\The [user] started picking up [O].</span>")
					if (pickup_sound)
						playsound(src.loc, pickup_sound, 20, 1)
					if(do_after(user,pickup_time,src))
						inuse = 0
						to_chat(user, "<span class='notice'>You collect [O].</span>")
						O.forceMove(src)
						held += O
						update_icon()
					else
						inuse = 0
						to_chat(user, "<span class='notice'>You failed to pick up [O].</span>")
					return
				to_chat(user, "<span class='notice'>\The [src] is full and can't store any more items.</span>")
				return
		if(interact_type && istype(O, interact_type))
			O.attack_hand(user)
			return
	. = ..()

/obj/item/robot_rack/afterattack(atom/A, mob/user as mob, proximity)
	if(!proximity) return
	if(istype(A, /obj/structure/table) || istype(A, /turf/simulated/floor))
		deploy(get_turf(A),user)


/obj/item/robot_rack/proc/add_item_type(var/obj/T, var/text) //adds type of item in list of pickable items
	object_type += T
	if (text)
		desc += text

/obj/item/robot_rack/medical
	name = "medical rack"
	desc = "A rack for carrying folded stasis bags, body bags, blood packs and medical utensils."
	icon = 'icons/obj/storage.dmi'
	icon_state = "med_borg_box"
	object_type = list(
		/obj/item/bodybag,
		/obj/item/weapon/reagent_containers/ivbag,
		/obj/item/weapon/reagent_containers/pill,
		/obj/item/weapon/reagent_containers/glass,
		/obj/item/stack/material/phoron,
		/obj/item/clothing/mask,
		/obj/item/clothing/gloves/latex,
		/obj/item/weapon/paper
		)
	interact_type = /obj/item/bodybag
	capacity = 3
/obj/item/robot_rack/medical/surgical/New()
	..()
	object_type += list(/obj/item/organ)

/obj/item/robot_rack/general
	name = "item rack"
	desc = "A rack for carrying various items."
	icon = 'icons/obj/storage.dmi'
	icon_state = "gen_borg_box"
	object_type = list(
		/obj/item
		)
	capacity = 12

/obj/item/robot_rack/weapon
	name = "weapon rack"
	desc = "A rack for carrying melee weapons, energy weapons and firearms."
	icon = 'icons/obj/storage.dmi'
	icon_state = "weaponcrate"
	object_type = list(
		/obj/item/weapon/melee,
		/obj/item/weapon/gun
		)
	capacity = 3

/obj/item/robot_rack/cargo
	name = "small cargo rack"
	desc = "A rack for carrying small and medium cargo parcels."
	icon = 'icons/obj/storage.dmi'
	icon_state = "cargo_borg_box"
	object_type = list(
		/obj/item/smallDelivery
		)
	capacity = 3

/obj/item/robot_rack/detective
	name = "detective rack"
	desc = "A rack for carrying evidence."
	icon = 'icons/obj/forensics.dmi'
	icon_state = "case"
	object_type = list(
		/obj/item/weapon/sample/fibers,
		/obj/item/weapon/forensics/swab,
		/obj/item/weapon/sample/print
		)
	capacity = 8

/obj/item/robot_rack/archeologist
	name = "archeologist rack"
	desc = "A rack for carrying artifacts and science samples."
	icon = 'icons/obj/storage.dmi'
	icon_state = "arch_borg_box"
	object_type = list(
		/obj/item/weapon/evidencebag,
		/obj/item/weapon/rocksliver,
		/obj/item/weapon/ore/strangerock,
		/obj/item/weapon/archaeological_find,
		/obj/item/weapon/fossil
		)
	capacity = 8

/obj/item/robot_rack/engineer
	name = "engineer rack"
	desc = "A rack for construction components."
	icon = 'icons/obj/storage.dmi'
	icon_state = "eng_borg_box"
	object_type = list(
		/obj/item/weapon/tank,
		/obj/item/weapon/circuitboard,
		/obj/item/weapon/smes_coil,
		/obj/item/weapon/stock_parts,
		/obj/item/weapon/cell,
		/obj/item/weapon/airlock_electronics,
		/obj/item/weapon/tracker_electronics,
		/obj/item/weapon/airalarm_electronics,
		/obj/item/weapon/firealarm_electronics,
		/obj/item/weapon/module/power_control,
		/obj/item/weapon/camera_assembly,
		/obj/item/weapon/computer_hardware,
		/obj/item/weapon/fuel_assembly,
		/obj/item/stack/material,
		/obj/item/clamp,
		/obj/item/pipe,
		/obj/item/frame

		)
	capacity = 5

/obj/item/robot_rack/miner
	name = "miner rack"
	desc = "A rack for carrying ore box."
	icon = 'icons/obj/storage.dmi'
	icon_state = "miner_borg_box_empty"
	icon_state_active = "miner_borg_box_full"
	pickup_sound = 'sound/effects/lift_heavy_start.ogg'
	deploy_sound = 'sound/effects/lift_heavy_stop.ogg'
	pickup_time = 50
	deploy_time = 50
	object_type = list(
		/obj/structure/ore_box,
		)
	capacity = 1

/obj/item/robot_rack/update_icon()
	..()
	if (length(held) < capacity)
		icon_state = initial(icon_state)
	else if (icon_state_active && length(held) == capacity)
		icon_state = icon_state_active

/obj/item/weapon/robot_item_dispenser
	name = "item synthesizer"
	desc = "A device used to rapidly synthesize items."
	icon = 'icons/obj/items.dmi'
	icon_state = "rcd"
	var/mode = 1
	var/inuse = 0
	var/list/datum/item_types = list()
	var/datum/dispense_type/selected = null
	var/activate_sound = 'sound/items/palaroid3.ogg'

	/datum/dispense_type
		var/name = ""
		var/item_type = null
		var/delay = 30
		var/energy = 200

	/datum/dispense_type/pipe
		var/pipe_type = null

	/datum/dispense_type/New(var/name, var/type, var/delay = 30, var/energy = 200)
		src.name = name
		src.item_type = type
		src.delay = delay
		src.energy = energy

	/datum/dispense_type/pipe/New(var/name, var/type, var/p_type, var/delay = 30, var/energy = 200)
		..(name,type,delay,energy)
		pipe_type = p_type

/obj/item/weapon/robot_item_dispenser/examine(mob/user)
	. = ..()
	to_chat(user, "[selected.name] is chosen to be produced.")


/obj/item/weapon/robot_item_dispenser/New()
	selected = item_types[1]

/obj/item/weapon/robot_item_dispenser/attack_self(mob/user as mob)
	var/t = ""
	for(var/i = 1 to item_types.len)
		if(t)
			t += ", "
		if(mode == i)
			t += "<b>[item_types[i]]</b>"
		else
			t += "<a href='?src=\ref[src];product_index=[i]'>[item_types[i]]</a>"
	t = "Available products: [t]."
	to_chat(user, t)

/obj/item/weapon/robot_item_dispenser/OnTopic(var/href, var/list/href_list)
	if(href_list["product_index"])
		var/index = text2num(href_list["product_index"])
		if(index > 0 && index <= item_types.len)
			playsound(loc, 'sound/effects/pop.ogg', 50, 0)
			mode = index
			selected = item_types[mode]
			to_chat(usr, "Changed dispensing mode to [selected.name].")
		return TOPIC_REFRESH


/obj/item/weapon/robot_item_dispenser/afterattack(atom/A, mob/user as mob, proximity)
	if(!proximity) return
	if (!inuse)
		if(istype(user,/mob/living/silicon/robot))
			var/mob/living/silicon/robot/R = user
			if(R.stat || !R.cell || R.cell.charge <= selected.energy)
				to_chat(user, "<span class='notice'>Not enough energy.</span>")
				return

		if(!istype(A, /obj/structure/table) && !istype(A, /turf/simulated/floor))
			return
		if (!selected.item_type)
			return
		playsound(src.loc, activate_sound, 10, 1)
		to_chat(user, "<span class='notice'>Dispensing [selected.name]...</span>")
		inuse = 1
		if(do_after(user,selected.delay,src))
			inuse = 0
			var/obj/product = null
			if (selected.item_type == /obj/item/pipe)
				var/datum/dispense_type/pipe/PD = selected
				var/pipe_dir = 1
				if (PD.pipe_type == 1 || PD.pipe_type == 30 || PD.pipe_type == 32) //if it bend we need to change direction
					pipe_dir = 5
				var/obj/item/pipe/O = new (get_turf(A), PD.pipe_type, pipe_dir) //apparently you need to call New() if you want icon and name change
				O.update()
				product = O 
			else
				var/type = selected.item_type
				product = new type()
				if (istype(product,/obj/item/organ))
					var/obj/item/organ/O = product
					O.robotize()
					O.status |= ORGAN_CUT_AWAY 
				else if (istype(product,/obj/structure/disposalconstruct)) 
					var/datum/dispense_type/pipe/PD = selected
					var/obj/structure/disposalconstruct/O = product
					O.ptype = PD.pipe_type
					if (O.ptype == 6 || O.ptype == 7 || O.ptype == 8)
						O.set_density(1)
					O.update()
				else if (istype(product,/obj/item/weapon/reagent_containers/ivbag/blood/OMinus))
					product.name = "synthesised blood pack"

			user.visible_message("<span class='notice'>\The [user]'s \the [src] spits out \the [selected.name].</span>")
			product.loc = get_turf(A)
			if(isrobot(user))
				var/mob/living/silicon/robot/R = user
				if(R.cell)
					R.cell.use(selected.energy)
		else
			inuse = 0
			to_chat(user, "<span class='danger'>You failed to dispense the product</span>")

/obj/item/weapon/robot_item_dispenser/crates
	name = "crates assembler"
	desc = "A device used to rapidly construct crates."
	icon = 'icons/obj/robot_device.dmi'
	icon_state = "printer"

/obj/item/weapon/robot_item_dispenser/crates/New()
	item_types += new /datum/dispense_type("crate",/obj/structure/closet/crate, 50, 100)
	item_types += new /datum/dispense_type("large crate",/obj/structure/closet/crate/large, 80, 100)
	item_types += new /datum/dispense_type("secure crate",/obj/structure/closet/crate/secure, 80, 100)
	item_types += new /datum/dispense_type("secure large crate",/obj/structure/closet/crate/secure/large, 100, 100)
	item_types += new /datum/dispense_type("freezer",/obj/structure/closet/crate/freezer, 80, 100)
	item_types += new /datum/dispense_type("biohazard crate",/obj/structure/closet/crate/secure/biohazard, 100, 100)
	..()


/obj/item/weapon/robot_item_dispenser/bodybag
	name = "bodybag synthesizer"
	desc = "A device used to rapidly synthesize bodybags and stasis bags."
	icon = 'icons/obj/robot_device.dmi'
	icon_state = "mini_printer"

/obj/item/weapon/robot_item_dispenser/bodybag/New()
	item_types += new /datum/dispense_type("stasis bag",/obj/structure/closet/body_bag/cryobag, 50, 250)
	item_types += new /datum/dispense_type("body bag",/obj/structure/closet/body_bag, 30, 50)
	..()

/obj/item/weapon/robot_item_dispenser/organs
	name = "organ synthesizer"
	desc = "A device used to rapidly synthesize prosthetic organs and bodyparts."
	icon = 'icons/obj/robot_device.dmi'
	icon_state = "organ_printer"

/obj/item/weapon/robot_item_dispenser/organs/New()
	item_types += new /datum/dispense_type("heart",/obj/item/organ/internal/heart,  50, 100)
	item_types += new /datum/dispense_type("lungs",/obj/item/organ/internal/lungs,  70, 150)
	item_types += new /datum/dispense_type("kidneys",/obj/item/organ/internal/kidneys,50, 50)
	item_types += new /datum/dispense_type("eyes",/obj/item/organ/internal/eyes,   50, 50)
	item_types += new /datum/dispense_type("liver",/obj/item/organ/internal/liver,  50, 100)
	item_types += new /datum/dispense_type("left arm",/obj/item/organ/external/arm,  70, 250)
	item_types += new /datum/dispense_type("right arm",/obj/item/organ/external/arm/right,  70, 250)
	item_types += new /datum/dispense_type("left leg",/obj/item/organ/external/leg,  70, 250)
	item_types += new /datum/dispense_type("right leg",/obj/item/organ/external/leg/right,  70, 250)
	item_types += new /datum/dispense_type("left foot",/obj/item/organ/external/foot,  50, 50)
	item_types += new /datum/dispense_type("right foot",/obj/item/organ/external/foot/right,  50, 50)
	item_types += new /datum/dispense_type("left hand",/obj/item/organ/external/hand,  50, 50)
	item_types += new /datum/dispense_type("right hand",/obj/item/organ/external/hand/right,  50, 50)
	..()

/obj/item/weapon/robot_item_dispenser/blood
	name = "blood synthesizer"
	desc = "A device used to create bloodpacks with synthesised blood."
	icon = 'icons/obj/robot_device.dmi'
	icon_state = "blood_printer"

/obj/item/weapon/robot_item_dispenser/blood/New()
	item_types += new /datum/dispense_type("synthesized blood pack",/obj/item/weapon/reagent_containers/ivbag/blood/OMinus, 100, 300)
	..()


/obj/item/weapon/robot_item_dispenser/engineer
	name = "construction part synthesizer"
	desc = "A device used to rapidly synthesize construction part and basic circuits."
	icon = 'icons/obj/robot_device.dmi'
	icon_state = "printer"

/obj/item/weapon/robot_item_dispenser/engineer/New()
	item_types += new /datum/dispense_type("airlock circuit",/obj/item/weapon/airlock_electronics, 70, 200)
	item_types += new /datum/dispense_type("air alarm circuit",/obj/item/weapon/airalarm_electronics, 70, 200)
	item_types += new /datum/dispense_type("fire alarm circuit",/obj/item/weapon/firealarm_electronics, 70, 200)
	item_types += new /datum/dispense_type("power cell",/obj/item/weapon/cell, 50, 200)

	item_types += new /datum/dispense_type("console screen",/obj/item/weapon/stock_parts/console_screen , 50, 100)
	item_types += new /datum/dispense_type("matter bin",/obj/item/weapon/stock_parts/matter_bin , 80, 250)
	item_types += new /datum/dispense_type("capacitor",/obj/item/weapon/stock_parts/capacitor , 80, 250)
	item_types += new /datum/dispense_type("micro-laser",/obj/item/weapon/stock_parts/micro_laser, 80, 250)
	item_types += new /datum/dispense_type("micro-manipulator",/obj/item/weapon/stock_parts/manipulator, 80, 250)
	item_types += new /datum/dispense_type("scanning module",/obj/item/weapon/stock_parts/scanning_module , 80, 250)
	..()

/obj/item/weapon/robot_item_dispenser/pipe
	name = "pipe dispenser"
	desc = "A device that can manufacture various types of pipes."
	icon = 'icons/obj/robot_device.dmi'
	icon_state = "pipe_printer"

/obj/item/weapon/robot_item_dispenser/pipe/New()	//Fuck the guy who coded pipes
	item_types += new /datum/dispense_type/pipe("pipe", /obj/item/pipe, 0, 50, 100)
	item_types += new /datum/dispense_type/pipe("bent pipe", /obj/item/pipe, 1, 50, 100)
	item_types += new /datum/dispense_type/pipe("manifold", /obj/item/pipe, 5, 70, 150)
	item_types += new /datum/dispense_type/pipe("4-way manifold", /obj/item/pipe, 19, 70, 150)
	item_types += new /datum/dispense_type/pipe("pipe cap", /obj/item/pipe, 20, 50, 100)

	item_types += new /datum/dispense_type/pipe("pipe", /obj/item/pipe, 29, 50, 100)
	item_types += new /datum/dispense_type/pipe("bent pipe", /obj/item/pipe, 30, 50, 100)
	item_types += new /datum/dispense_type/pipe("manifold", /obj/item/pipe, 33, 70, 150)
	item_types += new /datum/dispense_type/pipe("4-way manifold", /obj/item/pipe, 35, 70, 150)
	item_types += new /datum/dispense_type/pipe("pipe cap", /obj/item/pipe, 40, 50, 100)

	item_types += new /datum/dispense_type/pipe("pipe", /obj/item/pipe, 31, 50, 100)
	item_types += new /datum/dispense_type/pipe("bent pipe", /obj/item/pipe, 32, 50, 100)
	item_types += new /datum/dispense_type/pipe("manifold", /obj/item/pipe, 34, 70, 150)
	item_types += new /datum/dispense_type/pipe("4-way manifold", /obj/item/pipe, 36, 70, 150)
	item_types += new /datum/dispense_type/pipe("pipe cap", /obj/item/pipe, 42, 50, 100)
	
	item_types += new /datum/dispense_type("pipe pressure meter", /obj/item/pipe_meter, 80, 250)
	item_types += new /datum/dispense_type/pipe("vent pump", /obj/item/pipe, 7, 50, 100)
	item_types += new /datum/dispense_type/pipe("scrubber pump", /obj/item/pipe, 11, 50, 100)
	item_types += new /datum/dispense_type/pipe("pump", /obj/item/pipe, 10, 70, 150)
	item_types += new /datum/dispense_type/pipe("universal pipe adapter", /obj/item/pipe, 28, 70, 150)
	item_types += new /datum/dispense_type/pipe("shutoff valve", /obj/item/pipe, 44, 70, 150)
	item_types += new /datum/dispense_type/pipe("connector", /obj/item/pipe, 4, 70, 150)

	item_types += new /datum/dispense_type/pipe("pipe", /obj/structure/disposalconstruct, 0, 80, 200)
	item_types += new /datum/dispense_type/pipe("bent pipe", /obj/structure/disposalconstruct, 1, 80, 200)
	item_types += new /datum/dispense_type/pipe("junction", /obj/structure/disposalconstruct, 2, 80, 200)
	item_types += new /datum/dispense_type/pipe("Y junction", /obj/structure/disposalconstruct, 4, 80, 200)
	item_types += new /datum/dispense_type/pipe("trunk", /obj/structure/disposalconstruct, 5, 80, 200)
	item_types += new /datum/dispense_type/pipe("bin", /obj/structure/disposalconstruct, 6, 120, 300)
	item_types += new /datum/dispense_type/pipe("outlet", /obj/structure/disposalconstruct, 7, 120, 300)
	item_types += new /datum/dispense_type/pipe("chute", /obj/structure/disposalconstruct, 8, 120, 300)
	..()

/obj/item/weapon/robot_item_dispenser/pipe/attack_self(mob/user as mob)
	to_chat(user, "Available products:")
	var/t = "Regular pipes: "
	for(var/i = 1 ,i < 6, i++)
		if(i != 1)
			t += ", "
		if(mode == i)
			t += "<b>[item_types[i]]</b>"
		else
			t += "<a href='?src=\ref[src];product_index=[i]'>[item_types[i]]</a>"
	to_chat(user, t)
	t = "Supply pipes: "
	for(var/i = 6 ,i < 11, i++)
		if(i != 6)
			t += ", "
		if(mode == i)
			t += "<b>[item_types[i]]</b>"
		else
			t += "<a href='?src=\ref[src];product_index=[i]'>[item_types[i]]</a>"
	to_chat(user, t)
	t = "Scrubber pipes: "
	for(var/i = 11 ,i < 16, i++)
		if(i != 11)
			t += ", "
		if(mode == i)
			t += "<b>[item_types[i]]</b>"
		else
			t += "<a href='?src=\ref[src];product_index=[i]'>[item_types[i]]</a>"
	to_chat(user, t)
	t = "Pipe devices: "
	for(var/i = 16 ,i < 23, i++)
		if(i != 16)
			t += ", "
		if(mode == i)
			t += "<b>[item_types[i]]</b>"
		else
			t += "<a href='?src=\ref[src];product_index=[i]'>[item_types[i]]</a>"
	to_chat(user, t)
	t = "Disposal Pipes and devices: "
	for(var/i = 23 ,i < 31, i++)
		if(i != 23)
			t += ", "
		if(mode == i)
			t += "<b>[item_types[i]]</b>"
		else
			t += "<a href='?src=\ref[src];product_index=[i]'>[item_types[i]]</a>"
	to_chat(user, t)
