/obj/machinery/bot/secbot
	name = "Securitron"
	desc = "A little security robot. He looks less than thrilled."
	icon = 'aibots.dmi'
	icon_state = "secbot0"
	layer = 5.0
	density = 1
	anchored = 0
//	weight = 1.0E7

	req_access = list(access_security)

	var/arrest_type = 0 	// if true, don't handcuff
	var/auto_patrol = 0		// set to make bot automatically patrol
	var/check_records = 1 	// does it check security records?
	var/emagged = 0 		// emagged Secbots view everyone as a criminal
	var/frustration = 0 	// when it reaches a preset value (8), it will stop following a criminal
	var/health = 50
	var/idcheck = 1 		// if false, all station IDs are authorized for weapons.
	var/locked = 1  		// behavior Controls lock
	var/secure_arrest = 0 	// capture the items off a target. Contraband or a certain threat level can switch this var to 1.

	var/last_found			// there's a delay when resighting an old target
	var/oldtarget_name
	var/mob/living/carbon/target
	var/target_lastloc 		// location of target when arrested.
	var/threatlevel = 0		// affects the secure_arrest

	var/list/arrestreasons = list()
	var/list/contraband = list()

	var/voice_message = null
	var/voice_name = "secbot"

	var/mode = 0
#define SECBOT_IDLE 		0		// idle
#define SECBOT_HUNT 		1		// found target, hunting
#define SECBOT_PREP_ARREST 	2		// at target, preparing to arrest
#define SECBOT_ARREST		3		// arresting target
#define SECBOT_START_PATROL	4		// start patrol
#define SECBOT_PATROL		5		// patrolling
#define SECBOT_SUMMON		6		// summoned by PDA
#define SECBOT_DROPCONTRABAND		// dropping captured contraband

	var/obj/item/device/radio/radio // radio for Beepsky to communicate
	var/obj/machinery/camera/cam // camera for the AI to find them

	var/beacon_freq = 1445		// navigation beacon frequency
	var/control_freq = 1447		// bot control frequency

	var/turf/patrol_target	// this is turf to navigate to (location of beacon)
	var/new_destination		// pending new destination (waiting for beacon response)
	var/destination			// destination description tag
	var/next_destination	// the next destination in the patrol route

	var/blockcount = 0		//number of times retried a blocked path
	var/awaiting_beacon	= 0	// count of pticks awaiting a beacon response

	var/nearest_beacon			// the nearest beacon's tag
	var/turf/nearest_beacon_loc	// the nearest beacon's location

/obj/machinery/bot/secbot/beepsky
	name = "Officer Beepsky"
	desc = "It's Officer Beepsky! He's a loose cannon but he gets the job done."
	idcheck = 1
	auto_patrol = 1


/obj/item/proc/moveto(var/atom/I) // Moves an item from a living being into another object. Used below for taking equipment off perps
	if(istype(src.loc,/mob/living/carbon))
		var/mob/living/carbon/C = src.loc
		C.u_equip(src)
		if (C.client)
			C.client.screen -= src

		src.captured_by_securitron = 1 // If you plan to use moveto in other cases unrelated to securitrons, move this line before moveto calls below
		src.loc = I
		src.layer = initial(src.layer)
		return

/obj/machinery/bot/secbot/New()
	..()
	src.icon_state = "secbot[src.on]"
	spawn(3)
		src.botcard = new /obj/item/weapon/card/id(src)
		src.botcard.access = get_all_accesses()
		src.cam = new /obj/machinery/camera(src)
		src.cam.c_tag = src.name
		src.cam.network = "Luna"
		if(radio_controller)
			radio_controller.add_object(src, "[control_freq]")
			radio_controller.add_object(src, "[beacon_freq]")
		radio = new /obj/item/device/radio(src)
		radio.set_security_frequency(1399)
		radio.listening = 0


		contraband += /obj/item/weapon/gun/revolver
		contraband += /obj/item/weapon/c_tube //Toy sword ey, not on beepskies watch
		contraband += /obj/item/weapon/sword
		contraband += /obj/item/device/chameleon
		contraband += /obj/item/device/hacktool
		contraband += /obj/item/device/powersink
		contraband += /obj/item/weapon/staff
		contraband += /obj/item/weapon/cloaking_device

/obj/machinery/bot/secbot/examine()
	set src in view()
	..()

	if (src.health < 25)
		if (src.health > 15)
			usr << text("\red [src]'s parts look loose.")
		else
			usr << text("\red <B>[src]'s parts look very loose!</B>")
	return

/obj/machinery/bot/secbot/attack_hand(user as mob)
	var/dat

	dat += text({"
<TT><B>Automatic Security Unit v1.4</B></TT><BR><BR>
Status: []<BR>
Behaviour controls are [src.locked ? "locked" : "unlocked"]"},

"<A href='?src=\ref[src];power=1'>[src.on ? "On" : "Off"]</A>" )

	if(!src.locked)
		dat += text({"<BR>
Check for Weapon Authorization: []<BR>
Check Security Records: []<BR>
Operating Mode: []<BR>
Auto Patrol: []"},

"<A href='?src=\ref[src];operation=idcheck'>[src.idcheck ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=ignorerec'>[src.check_records ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=switchmode'>[src.arrest_type ? "Detain" : "Arrest"]</A>",
"<A href='?src=\ref[src];operation=patrol'>[auto_patrol ? "On" : "Off"]</A><BR><A href='?src=\ref[src];operation=dropcontraband'>Drop Contraband</A>")


	user << browse("<HEAD><TITLE>Securitron v1.4 controls</TITLE></HEAD>[dat]", "window=autosec")
	onclose(user, "autosec")
	return

/obj/machinery/bot/secbot/Topic(href, href_list)
	usr.machine = src
	src.add_fingerprint(usr)
	if ((href_list["power"]) && (src.allowed(usr)))
		src.on = !src.on
		src.target = null
		src.oldtarget_name = null
		src.anchored = 0
		src.mode = SECBOT_IDLE
		walk_to(src,0)
		src.icon_state = "secbot[src.on]"
		src.updateUsrDialog()

	switch(href_list["operation"])
		if ("idcheck")
			src.idcheck = !src.idcheck
			src.updateUsrDialog()
		if ("ignorerec")
			src.check_records = !src.check_records
			src.updateUsrDialog()
		if ("switchmode")
			src.arrest_type = !src.arrest_type
			src.updateUsrDialog()
		if("patrol")
			auto_patrol = !auto_patrol
			mode = SECBOT_IDLE
			updateUsrDialog()
		if("dropcontraband")
			for(var/obj/I in src)
				if(I != src.botcard && I != src.cam && I != src.radio)
					I.loc = src.loc

/obj/machinery/bot/secbot/attack_ai(mob/user as mob)
	src.on = !src.on
	src.target = null
	src.oldtarget_name = null
	mode = SECBOT_IDLE
	src.anchored = 0
	src.icon_state = "secbot[src.on]"
	walk_to(src,0)

/obj/machinery/bot/secbot/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/card/emag)) // E-mag
		if (!src.emagged)
			user << "\red You short out [src]'s target assessment circuits."
			spawn(0)
				for(var/mob/O in hearers(src, null))
					O.show_message("\red <B>[src] buzzes oddly!</B>", 1)
			src.target = null
			src.oldtarget_name = user.name
			src.last_found = world.time
			src.anchored = 0
			src.emagged = 1
			src.on = 1
			src.icon_state = "secbot[src.on]"
			mode = SECBOT_IDLE

		return

	if(istype(W, /obj/item/weapon/card/id)) // Unlocking the controls
		if (src.allowed(user))
			src.locked = !src.locked
			user << "Controls are now [src.locked ? "locked." : "unlocked."]"
		else
			user << "\red Access denied."

		return

	if(istype(W, /obj/item/weapon/screwdriver)) // Repairing the bot
		if (src.health < 25)
			src.health = 25
			for(var/mob/O in viewers(src, null))
				O << "\red [user] repairs [src]!"
		return

	switch(W.damtype) // Damaging the bot
		if("fire")
			src.health -= W.force * 0.75
		if("brute")
			src.health -= W.force * 0.5

	if (src.health <= 0)
		src.explode()
	else if ((W.force) && (!src.target))
		src.target = user
		src.mode = SECBOT_HUNT
		src.arrestreasons += "Damage to ship property."

	return ..()

/obj/machinery/bot/secbot/process()
	set background = 1

	if (!src.on)
		return

	switch(mode)

		if(SECBOT_IDLE)		// idle
			walk_to(src,0)
			look_for_perp()	// see if any criminals are in range
			/*if(has_contraband)
				mode = SECBOT_DROPCONTRABAND*/
			if(!mode && auto_patrol)	// still idle, and set to patrol
				mode = SECBOT_START_PATROL	// switch to patrol mode

		if(SECBOT_HUNT)		// hunting for perp

			// if can't reach perp for long enough, go idle
			if (src.frustration >= 8)
				src.speak("Backup requested! Suspect [src.target.name] has evaded arrest near [src.loc.loc]!")
				src.target = null
				src.last_found = world.time
				src.frustration = 0
				src.mode = 0
				src.secure_arrest = 0
				src.arrestreasons = list()
				walk_to(src,0)

			if (target)		// make sure target exists
				if (get_dist(src, src.target) <= 1&&CanReachThrough(get_turf(src), get_turf(target), target))		// if right next to perp
					playsound(src.loc, 'Egloves.ogg', 50, 1, -1)
					src.icon_state = "secbot-c"
					spawn(2)
						src.icon_state = "secbot[src.on]"
					var/mob/living/carbon/M = src.target
					var/maxstuns = 4
					if (istype(M, /mob/living/carbon/human))
						if (M.weakened < 10 && (!(M.mutations & 8))  /*&& (!istype(M:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
							M.weakened = 10
						if (M.stuttering < 10 && (!(M.mutations & 8))  /*&& (!istype(M:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
							M.stuttering = 10
						if (M.stunned < 10 && (!(M.mutations & 8))  /*&& (!istype(M:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
							M.stunned = 10
					else
						M.weakened = 10
						M.stuttering = 10
						M.stunned = 10
					maxstuns--
					if (maxstuns <= 0)
						target = null
					for(var/mob/O in viewers(src, null))
						O.show_message("\red <B>[src.target] has been stunned by [src]!</B>", 1, "\red You hear someone fall", 2)

					var/gotstuff
					if(src.target:r_hand)
						gotstuff = "Captured items from [src.target.name]: [src.target.r_hand.name]"
						src.target:r_hand.name += " (Captured by [src.name] from [target.name])"
						src.target:r_hand.moveto(src)



					if(src.target:l_hand)
						if(gotstuff == "")
							gotstuff = "Captured items from [src.target.name]: [src.target.l_hand.name]"
						else
							gotstuff += " and [src.target.l_hand.name]"
							src.target:l_hand.name += " (Captured by [src.name] from [target.name])"
							src.target:l_hand.moveto(src)


					if(gotstuff)
						speak(gotstuff)

					mode = SECBOT_PREP_ARREST
					src.anchored = 1
					src.target_lastloc = M.loc
					return

				else								// not next to perp
					var/turf/olddist = get_dist(src, src.target)
					walk_to_3d(src, src.target,1,4)
					if ((get_dist(src, src.target)) >= (olddist))
						src.frustration++
					else
						src.frustration = 0

		if(SECBOT_PREP_ARREST)		// preparing to arrest target

			// see if he got away
			if ((get_dist(src, src.target) > 1) || ((src.target:loc != src.target_lastloc) && src.target:weakened < 2))
				src.anchored = 0
				mode = SECBOT_HUNT
				return

			if (!src.target.handcuffed && !src.arrest_type)
				playsound(src.loc, 'handcuffs.ogg', 30, 1, -2)
				mode = SECBOT_ARREST
				for(var/mob/O in viewers(src, null))
					O.show_message("\red <B>[src] is trying to put handcuffs on [src.target]!</B>", 1)

					if(secure_arrest)
						O.show_message("\red <B> [src] is attempting to remove [src.target]'s gear!</B>",1)

				spawn(60)
					if (get_dist(src, src.target) <= 1)
						if (src.target.handcuffed)
							return

						if(istype(src.target,/mob/living/carbon))
							src.target.handcuffed = new /obj/item/weapon/handcuffs(src.target)



						src.speak("Suspect [src.target.name] has been apprehended near [src.loc.loc].")
						if(secure_arrest)
							if(src.target:belt)
								var/obj/item/I = src.target:belt
								I.name += " (Captured by [src.name] from [target.name])" //Might move this into something embedded within the item that the forenzics scanner can read
								I.moveto(src)
							if(src.target:back)
								var/obj/item/I = src.target:back
								I.name += " (Captured by [src.name] from [target.name])"
								I.moveto(src)
						///	if(src.target:wear_id)
						//		var/obj/item/I = src.target:wear_id
						//		I.name += " (Captured by [src.name] from [target.name])"
						//		I.moveto(src)
							if(src.target:l_store)
								var/obj/item/I = src.target:l_store
								I.name += " (Captured by [src.name] from [target.name])"
								I.moveto(src)
							if(src.target:r_store)
								var/obj/item/I = src.target:r_store
								I.name += " (Captured by [src.name] from [target.name])"
								I.moveto(src)
							if(src.target:glasses)
								var/obj/item/I = src.target:glasses
								I.name += " (Captured by [src.name] from [target.name])"
								I.moveto(src)
							src.speak("Due to suspection of Syndicate affiliation, the person has been stripped of his gear.")

						var/list/txt = arrestreasons
						spawn(0)
							sleep(5)
							src.speak("Arrested due to:")
							for(var/reason in txt)
								sleep(5)
								src.speak("[reason]")


						arrestreasons = list()
						mode = SECBOT_IDLE
						src.target = null
						src.anchored = 0
						src.last_found = world.time
						src.frustration = 0
						src.secure_arrest = 0
						playsound(src.loc, pick('bgod.ogg', 'biamthelaw.ogg', 'bsecureday.ogg', 'bradio.ogg', 'binsult.ogg', 'bcreep.ogg'), 50, 0)

		if(SECBOT_ARREST)		// arresting

			if (src.target.handcuffed)
				src.anchored = 0
				mode = SECBOT_IDLE
				return


		if(SECBOT_START_PATROL)	// start a patrol

			if(path.len > 0 && patrol_target)	// have a valid path, so just resume
				mode = SECBOT_PATROL
				return

			else if(patrol_target)		// has patrol target already
				spawn(0)
					calc_path(patrol_target)		// so just find a route to it
					if(path.len == 0)
						patrol_target = 0
						return
					mode = SECBOT_PATROL


			else					// no patrol target, so need a new one
				find_patrol_target()


		if(SECBOT_PATROL)		// patrol mode
			patrol_step()
			spawn(5)
				if(mode == SECBOT_PATROL)
					patrol_step()

		if(SECBOT_SUMMON)		// summoned to PDA
			patrol_step()
			spawn(4)
				if(mode == SECBOT_SUMMON)
					patrol_step()
					sleep(4)
					patrol_step()

		/*if(SECBOT_DROPCONTRABAND)
			next_destination = destination
			destination = null
			awaiting_beacon = 0
			mode = SECBOT_SUMMON
			calc_path(patrol_target)*/


	return


// perform a single patrol step
/obj/machinery/bot/secbot/proc/patrol_step()

	if(loc == patrol_target)		// reached target
		at_patrol_target()
		return

	else if(path.len > 0 && patrol_target)		// valid path

		var/turf/next = path[1]
		if(next == loc)
			path -= next
			return


		if(istype( next, /turf/simulated))
			var/moved = step_towards_3d(src, next)	// attempt to move
			if(moved)	// successful move
				blockcount = 0
				path -= loc

				look_for_perp()
			else		// failed to move
				blockcount++
				if(blockcount > 5)	// attempt 5 times before recomputing
					// find new path excluding blocked turf
					spawn(2)
						calc_path(patrol_target, next)
						if(path.len == 0)
							find_patrol_target()
						else
							blockcount = 0
					return
				return
		else	// not a valid turf
			mode = SECBOT_IDLE
			return

	else	// no path, so calculate new one
		mode = SECBOT_START_PATROL


// finds a new patrol target
/obj/machinery/bot/secbot/proc/find_patrol_target()
	send_status()
	if(awaiting_beacon)			// awaiting beacon response
		awaiting_beacon++
		if(awaiting_beacon > 5)	// wait 5 secs for beacon response
			find_nearest_beacon()	// then go to nearest instead
		return

	if(next_destination)
		set_destination(next_destination)
	else
		find_nearest_beacon()
	return


// finds the nearest beacon to self
// signals all beacons matching the patrol code
/obj/machinery/bot/secbot/proc/find_nearest_beacon()
	nearest_beacon = null
	new_destination = "__nearest__"
	post_signal(beacon_freq, "findbeacon", "patrol")
	awaiting_beacon = 1
	spawn(10)
		awaiting_beacon = 0
		if(nearest_beacon)
			set_destination(nearest_beacon)
		else
			auto_patrol = 0
			mode = SECBOT_IDLE
			speak("Disengaging patrol mode.")
			send_status()


/obj/machinery/bot/secbot/proc/at_patrol_target()
	find_patrol_target()
	return


// sets the current destination
// signals all beacons matching the patrol code
// beacons will return a signal giving their locations
/obj/machinery/bot/secbot/proc/set_destination(var/new_dest)
	new_destination = new_dest
	post_signal(beacon_freq, "findbeacon", "patrol")
	awaiting_beacon = 1


// receive a radio signal
// used for beacon reception
/obj/machinery/bot/secbot/receive_signal(datum/signal/signal)
	if(!on)
		return

	/*
	world << "rec signal: [signal.source]"
	for(var/x in signal.data)
		world << "* [x] = [signal.data[x]]"
	*/

	var/recv = signal.data["command"]
	// process all-bot input
	if(recv=="bot_status")
		send_status()

	// check to see if we are the commanded bot
	if(signal.data["active"] == src)
	// process control input
		switch(recv)
			if("stop")
				mode = SECBOT_IDLE
				auto_patrol = 0
				src.speak("Halting patrol.")
				return

			if("go")
				mode = SECBOT_IDLE
				auto_patrol = 1
				src.speak("Starting patrol.")
				return

			if("summon")
				patrol_target = signal.data["target"]
				next_destination = destination
				destination = null
				awaiting_beacon = 0
				mode = SECBOT_SUMMON
				calc_path(patrol_target)
				speak("Responding.")
				return

	// receive response from beacon
	recv = signal.data["beacon"]
	var/valid = signal.data["patrol"]
	if(!recv || !valid)
		return

	if(recv == new_destination)	// if the recvd beacon location matches the set destination then will navigate there
		destination = new_destination
		patrol_target = signal.source.loc
		next_destination = signal.data["next_patrol"]
		awaiting_beacon = 0

	// if looking for nearest beacon
	else if(new_destination == "__nearest__")
		var/dist = get_dist(src,signal.source.loc)
		if(nearest_beacon)
			// note we ignore the beacon we are located at
			if(dist>1 && dist<get_dist(src,nearest_beacon_loc))
				nearest_beacon = recv
				nearest_beacon_loc = signal.source.loc
				return
			else
				return
		else if(dist > 1)
			nearest_beacon = recv
			nearest_beacon_loc = signal.source.loc
	return


// send a radio signal with a single data key/value pair
/obj/machinery/bot/secbot/proc/post_signal(var/freq, var/key, var/value)
	post_signal_multiple(freq, list("[key]" = value) )

// send a radio signal with multiple data key/values
/obj/machinery/bot/secbot/proc/post_signal_multiple(var/freq, var/list/keyval)
	var/datum/radio_frequency/frequency = radio_controller.return_frequency("[freq]")

	if(!frequency) return
	var/datum/signal/signal = new()
	signal.source = src
	signal.transmission_method = 1
	for(var/key in keyval)
		signal.data[key] = keyval[key]
		//world << "sent [key],[keyval[key]] on [freq]"
	frequency.post_signal(src, signal)

// signals bot status etc. to controller
/obj/machinery/bot/secbot/proc/send_status()
	var/list/kv = new()
	kv["type"] = "secbot"
	kv["name"] = name
	kv["loca"] = loc.loc	// area
	kv["mode"] = mode
	post_signal_multiple(control_freq, kv)



// look for a criminal in view of the bot
/obj/machinery/bot/secbot/proc/look_for_perp()
	src.anchored = 0
	for (var/mob/living/carbon/C in view(7,src)) //Let's find us a criminal
		if ((C.stat) || (C.handcuffed))
			continue

		if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100))
			continue

		if (istype(C, /mob/living/carbon/human))
			src.threatlevel = src.assess_perp(C)
		else if ((istype(C, /mob/living/carbon/monkey)) && (C.client) && (ticker.mode.name == "monkey"))
			src.threatlevel = 4

		if (!src.threatlevel)
			continue

		else if (src.threatlevel >= 4)
			src.target = C
			src.oldtarget_name = C.name

		// Beepsky now does not reveal he is after someone, to prevent escape
		//	src.speak("Level [src.threatlevel] infraction alert! Pursuing [C.name] near [src.loc.loc]!")
		//	playsound(src.loc, pick('bcriminal.ogg', 'bjustice.ogg', 'bfreeze.ogg'), 50, 0)
		//	src.visible_message("<b>[src]</b> points at [C.name]!")

			mode = SECBOT_HUNT
			if(src.threatlevel >= 10)
				secure_arrest = 1

			spawn(0)
				process()	// ensure bot quickly responds to a perp

			break

		else
			continue

//If the security records say to arrest them, arrest them
//Or if they have weapons and aren't security, arrest them.
/obj/machinery/bot/secbot/proc/assess_perp(mob/living/carbon/human/perp as mob)
	var/threatcount = 0

	if(src.emagged)
		arrestreasons += "BZZZT!"
		return 10 //Everyone is a criminal!

	if((src.idcheck) || (isnull(perp:wear_id)) && (!istype(perp:wear_id, /obj/item/weapon/card/id/syndicate))) //Syndicate IDs mess with electronics, beepsky won't suspect a thing


		for(var/obj/item/weapon/cloaking_device/S in perp)
			if(S.active)
				arrestreasons += "Carrying activated cloaking device"
				secure_arrest = 1
				return 10

		for(var/obj in contraband) //Syndicate contraband... Hidden programming by NT means that beepsky WILL arrest on sight
			if( istype(perp:belt,obj) || istype(perp.l_hand,obj) || istype(perp.r_hand,obj) /*|| istype(perp:wear_suit,obj)*/ )
				arrestreasons += "Carrying syndicate contraband"
				secure_arrest = 1
				return 10

		if(src.allowed(perp)) //Corrupt cops cannot exist beep boop // Except if they are carrying contraband
			arrestreasons = list()
			return 0

		if(istype(perp:belt, /obj/item/weapon/gun) || istype(perp.belt, /obj/item/weapon/baton))
			arrestreasons += "Unauthorized weapon on belt [perp.belt.name]"
			threatcount += 4


		if(istype(perp.l_hand, /obj/item/weapon/gun) || istype(perp.l_hand, /obj/item/weapon/baton))
			arrestreasons += "Unauthorized weapon in left hand: [perp.l_hand.name]"
			threatcount += 4

		if(istype(perp.r_hand, /obj/item/weapon/gun) || istype(perp.r_hand, /obj/item/weapon/baton))
			arrestreasons += "Unauthorized weapon in right hand [perp.r_hand.name]"
			threatcount += 4

		/*if(istype(perp:wear_suit, /obj/item/clothing/suit/wizrobe))
			threatcount += 2
			arrestreasons += "Illegal roleplaying equipment [perp.wear_suit.name]"*/

		/*if(perp.mutantrace)						// Being on a research ship, one might expect to see oddities around
			threatcount += 2
			arrestreasons += "Unknown Species"*/

	//Agent cards lower threatlevel when normal idchecking is off.
		if((istype(perp:wear_id, /obj/item/weapon/card/id/syndicate)) && src.idcheck)
			threatcount -= 2

	if (src.check_records)
		for (var/datum/data/record/E in data_core.general)
			var/perpname = perp.name
			if (perp:wear_id && perp:wear_id.registered)
				perpname = perp.wear_id.registered
			if (E.fields["name"] == perpname)
				for (var/datum/data/record/R in data_core.security)
					if ((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "*Arrest*"))
						threatcount += 4
						arrestreasons += "Set to arrest"
						break
				for (var/datum/data/record/R in data_core.medical)
					if ((R.fields["id"] == E.fields["id"]) && (R.fields["m_stat"] == "*Insane*"))
						threatcount += 4
						arrestreasons += "Declared insane"
						break


	return threatcount

/obj/machinery/bot/secbot/Bump(M as mob|obj) //Leave no door unopened!
	spawn(0)
		if ((istype(M, /obj/machinery/door)) && (!isnull(src.botcard)))
			var/obj/machinery/door/D = M
			if (D.check_access(src.botcard))
				D.open()
				spawn(0) CloseDoor(D, loc)
				src.frustration = 0
		else if ((istype(M, /mob/living/)) && (!src.anchored))
			src.loc = M:loc
			src.frustration = 0

		return
	return

/obj/machinery/bot/secbot/Bumped(M as mob|obj)
	spawn(0)
		var/turf/T = get_turf(src)
		M:loc = T

/obj/machinery/bot/secbot/bullet_act(flag, A as obj)
	if (flag == PROJECTILE_BULLET)
		src.health -= 20

	else if (flag == PROJECTILE_WEAKBULLET)
		src.health -= 2

	else if (flag == PROJECTILE_LASER)
		src.health -= 10

	if (src.health <= 0)
		src.explode()

/obj/machinery/bot/secbot/proc/speak(var/message)
	for(var/mob/O in hearers(src, null))
		O << "<span class='game say'><span class='name'>[src]</span> beeps, \"[message]\""
	radio.security_talk_into(src, message)
	return

//Generally we want to explode() instead of just deleting the securitron.
/obj/machinery/bot/secbot/ex_act(severity)
	switch(severity)
		if(1.0)
			src.explode()
			return
		if(2.0)
			src.health -= 15
			if (src.health <= 0)
				src.explode()
			return
	return

/obj/machinery/bot/secbot/meteorhit()
	src.explode()
	return

/obj/machinery/bot/secbot/blob_act()
	if(prob(25))
		src.explode()
	return

/obj/machinery/bot/secbot/proc/explode()

	walk_to(src,0) // Aborting any previous walking functions

	for(var/mob/O in hearers(src, null)) // BOOM!
		O.show_message("\red <B>[src] blows apart!</B>", 1)

	var/turf/Loc = get_turf(src)

	var/obj/item/weapon/secbot_assembly/Sa = new /obj/item/weapon/secbot_assembly(Loc) // Dropping a partial assembly
	Sa.build_step = 1
	Sa.overlays += image('aibots.dmi', "hs_hole")
	Sa.created_name = src.name

	new /obj/item/device/prox_sensor(Loc) // Dropping a prox sensor

	var/obj/item/weapon/baton/B = new /obj/item/weapon/baton(Loc) // Dropping a baton, no charges
	B.charges = 0

	if (prob(50)) // Dropping a robot left arm
		new /obj/item/robot_parts/l_arm(Loc)

	for(var/obj/item/A in src.contents) // Dropping the contraband
		if(A.captured_by_securitron == 1)
			A.loc = Loc
			A.captured_by_securitron = 0

	var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread // Sparks!
	s.set_up(3, 1, src)
	s.start()

	del(src) // And that was all for today, folks!


/obj/machinery/bot/secbot/proc/say_quote(var/text)
	return "beeps, \"[text]\"";


/obj/machinery/bot/secbot/shutdowns()
	src.on = !src.on
	src.target = null
	src.oldtarget_name = null
	src.anchored = 0
	src.mode = SECBOT_IDLE
	walk_to(src,0)
	src.icon_state = "secbot[src.on]"
	src.updateUsrDialog()
//Secbot Construction

/obj/item/weapon/secbot_assembly
	name = "helmet/signaler assembly"
	desc = "Some sort of bizarre assembly."
	icon = 'aibots.dmi'
	icon_state = "helmet_signaler"
	item_state = "helmet"
	var/build_step = 0
	var/created_name = "Securitron" //To preserve the name if it's a unique securitron I guess

/obj/item/clothing/head/helmet/attackby(var/obj/item/device/radio/signaler/S, mob/user as mob)
	if (!istype(S, /obj/item/device/radio/signaler))
		..()
		return

	if (src.type != /obj/item/clothing/head/helmet) //Eh, but we don't want people making secbots out of space helmets.
		return

	if (!S.b_stat)
		return
	else
		src.assemble(src, S, user, /obj/item/weapon/secbot_assembly)
		user << "You add the signaler to the helmet."

/obj/item/weapon/secbot_assembly/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if ((istype(W, /obj/item/weapon/weldingtool)) && (!src.build_step))
		if ((W:welding) && (W:get_fuel() >= 1))
			W:use_fuel(1)
			src.build_step++
			src.overlays += image('aibots.dmi', "hs_hole")
			user << "You weld a hole in [src]!"

	else if ((istype(W, /obj/item/device/prox_sensor)) && (src.build_step == 1))
		src.build_step++
		user << "You add the prox sensor to [src]!"
		src.overlays += image('aibots.dmi', "hs_eye")
		src.name = "helmet/signaler/prox sensor assembly"
		del(W)

	else if (((istype(W, /obj/item/robot_parts/l_arm)) || (istype(W, /obj/item/robot_parts/r_arm))) && (src.build_step == 2))
		src.build_step++
		user << "You add the robot arm to [src]!"
		src.name = "helmet/signaler/prox sensor/robot arm assembly"
		src.overlays += image('aibots.dmi', "hs_arm")
		del(W)

	else if ((istype(W, /obj/item/weapon/baton)) && (src.build_step >= 3))
		src.build_step++
		user << "You complete the Securitron! Beep boop."
		var/obj/machinery/bot/secbot/S = new /obj/machinery/bot/secbot
		S.loc = get_turf(src)
		S.name = src.created_name
		del(W)
		del(src)

	else if (istype(W, /obj/item/weapon/pen))
		var/t = input(user, "Enter new robot name", src.name, src.created_name) as text
		t = copytext(sanitize(t), 1, MAX_MESSAGE_LEN)
		if (!t)
			return
		if (!in_range(src, usr) && src.loc != usr)
			return

		src.created_name = t