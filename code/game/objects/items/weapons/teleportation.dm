/* Teleportation devices.
 * Contains:
 *		Locator
 *		Vortex Manipulator
 */

/*
 * Locator
 */
/obj/item/weapon/locator
	name = "locator"
	desc = "Used to track those with locater implants."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"
	var/temp = null
	var/frequency = 1451
	var/broadcasting = null
	var/listening = 1.0
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	w_class = ITEM_SIZE_SMALL
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	origin_tech = list(TECH_MAGNET = 1)
	matter = list(MATERIAL_STEEL = 400)

/obj/item/weapon/locator/attack_self(mob/user)
	user.set_machine(src)
	var/dat
	if (temp)
		dat = "<meta charset=\"utf-8\">[temp]<BR><BR><A href='byond://?src=\ref[src];temp=1'>Clear</A>"
	else
		dat = {"
<meta charset=\"utf-8\">
<B>Persistent Signal Locator</B><HR>
Frequency:
<A href='byond://?src=\ref[src];freq=-10'>-</A>
<A href='byond://?src=\ref[src];freq=-2'>-</A> [format_frequency(src.frequency)]
<A href='byond://?src=\ref[src];freq=2'>+</A>
<A href='byond://?src=\ref[src];freq=10'>+</A><BR>

<A href='?src=\ref[src];refresh=1'>Refresh</A>"}
	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return

/obj/item/weapon/locator/Topic(href, href_list)
	var/mob/user
	..()
	if (user.stat || user.restrained())
		return
	var/turf/current_location = get_turf(user)//What turf is the user on?
	if(!current_location||current_location.z==2)//If turf was not found or they're on z level 2.
		to_chat(user, "The [src] is malfunctioning.")
		return
	if ((user.contents.Find(src) || (in_range(src, user) && istype(src.loc, /turf))))
		user.set_machine(src)
		if (href_list["refresh"])
			temp = "<B>Persistent Signal Locator</B><HR>"
			var/turf/sr = get_turf(src)

			if (sr)
				temp += "<B>Located Beacons:</B><BR>"

				for(var/obj/item/device/radio/beacon/W in GLOB.listening_objects)
					if (W.frequency == frequency)
						var/turf/tr = get_turf(W)
						if (tr.z == sr.z && tr)
							var/direct = max(abs(tr.x - sr.x), abs(tr.y - sr.y))
							if (direct < 5)
								direct = "very strong"
							else
								if (direct < 10)
									direct = "strong"
								else
									if (direct < 20)
										direct = "weak"
									else
										direct = "very weak"
							temp += "[W.code]-[dir2text(get_dir(sr, tr))]-[direct]<BR>"

				temp += "<B>Extranneous Signals:</B><BR>"
				for (var/obj/item/weapon/implant/tracking/W in GLOB.listening_objects)
					if (!W.implanted || !(istype(W.loc,/obj/item/organ/external) || ismob(W.loc)))
						continue
					else
						var/mob/M = W.loc
						if (M.stat == 2)
							if (M.timeofdeath + 6000 < world.time)
								continue

					var/turf/tr = get_turf(W)
					if (tr.z == sr.z && tr)
						var/direct = max(abs(tr.x - sr.x), abs(tr.y - sr.y))
						if (direct < 20)
							if (direct < 5)
								direct = "very strong"
							else
								if (direct < 10)
									direct = "strong"
								else
									direct = "weak"
							temp += "[W.id]-[dir2text(get_dir(sr, tr))]-[direct]<BR>"

				temp += "<B>You are at \[[sr.x],[sr.y],[sr.z]\]</B> in orbital coordinates.<BR><BR><A href='byond://?src=\ref[src];refresh=1'>Refresh</A><BR>"
			else
				temp += "<B><FONT color='red'>Processing Error:</FONT></B> Unable to locate orbital position.<BR>"
		else
			if (href_list["freq"])
				frequency += text2num(href_list["freq"])
				frequency = sanitize_frequency(src.frequency)
			else
				if (href_list["temp"])
					temp = null
		if (istype(src.loc, /mob))
			attack_self(src.loc)
		else
			for(var/mob/M in viewers(1, src))
				if (M.client)
					attack_self(M)
	return

/*
 * Vortex Manipulator (Hello Missy)
 * TODO:
 * - New Icon
 * - Random Malfunctions - maybe add more effects of spawning sth 'out of bluespace rift'
 * - EMP interactions - more random effects
 */

/obj/item/weapon/vortex_manipulator
	name = "Vortex Manipulator"
	desc = "Strange and complex reverse-engineered technology of some ancient race designed to travel through space and time. Unfortunately, time-shifting is DNA-locked."
	icon = 'icons/obj/device.dmi'
	icon_state = "vm_closed"
	item_state = "electronic"
	var/chargecost_area = 1000
	var/chargecost_beacon = 100
	var/chargecost_local = 100
	var/cover_open = 0
	var/timelord_mode = 0
	var/unique_id = 0
	var/teleport_on_click = 0
	var/active = 0
	var/list/possible_ids = list(1, 2, 3)
	var/list/beacon_locations = list()
	var/obj/item/weapon/cell/vcell
	var/emp_prevent_until = 0
	throwforce = 5
	w_class = ITEM_SIZE_SMALL
	throw_speed = 3
	throw_range = 5
	origin_tech = list(TECH_MATERIAL = 9, TECH_BLUESPACE = 10, TECH_MAGNET = 8, TECH_POWER = 9, TECH_DATA = 8, TECH_ENGINEERING = 9)
	matter = list(MATERIAL_STEEL = 10000, MATERIAL_GLASS = 5000)

/obj/item/weapon/vortex_manipulator/attack_self(mob/user)
	if(cover_open)
		user.set_machine(src)
		var/dat = "<B>Vortex Manipulator Menu:</B><BR>"
		if(vcell)
			dat += "Current charge: [src.vcell.charge] out of [src.vcell.maxcharge]<BR>"
		else
			dat += "The device has no power source!<BR>"
		if(timelord_mode)
			dat += "SAY SOMETHING NICE<BR>"
		dat += "<HR>"
		dat += "<B>Unstable technology: Major Malfunction Possible!</B><BR>"
		if(active && (timelord_mode || vcell))
			dat += "<A href='byond://?src=\ref[src];close_cover=1'>Flip device's protective cover</A><BR>"
			dat += "<A href='byond://?src=\ref[src];toggle_click_tele=1'>Toggle directed local teleportation</A><BR>"
			dat += "<B>Teleportation abilities:</B><BR>"
			dat += "<A href='byond://?src=\ref[src];area_teleport=1'>Teleport to Area</A><BR>"
			dat += "<A href='byond://?src=\ref[src];beacon_teleport=1'>Teleport to Beacon</A><BR>"
			dat += "<A href='byond://?src=\ref[src];local_teleport=1'>Space-shift locally</A><BR>"
			dat += "<HR>"
			dat += "<B>Special abilities:</B><BR>"
			dat += "<A href='byond://?src=\ref[src];lmr_ability=1'>Create local space-time anomaly </A> <B>DANGER: COMBAT ABILITY</B><BR>"
			dat += "<A href='byond://?src=\ref[src];ebt_ability=1'>Teleport to random beacon </A><B>WARNING: USE IN EMERGENCY ONLY</B><BR>"
			dat += "<A href='byond://?src=\ref[src];vma_ability=1'>Announce something to all active VM users </A><B>WARNING: EXTREME POWER DRAIN</B><BR>"
		else
			dat += "ALERT: THE DEVICE IS INACTIVE OR HAS NO SOURCE OF POWER <BR>"
			if(vcell)
				dat += "<A href='byond://?src=\ref[src];attempt_activate=1'>Activate the Vortex Manipulator</A><BR>"
			else
				dat += "<B>INSTALL POWER CELL! (vortex power cell recommended)</B><BR>"

		dat += "Kind regards,<br>Dominus temporis. <br><br>P.S. Don't forget to ask someone to say something nice.<HR>"
		user << browse(dat, "window=scroll")
		onclose(user, "scroll")
		return
	else
		to_chat(user, SPAN_NOTICE("You flip Vortex Manipulator's protective cover open"))
		cover_open = 1

		if(vcell)
			icon_state = "vm_open"
		else
			icon_state = "vm_nocell"

		update_icon()

/obj/item/weapon/vortex_manipulator/attackby(obj/item/weapon/W, mob/user)
	if(cover_open)
		if(istype(W, /obj/item/weapon/cell))
			if(!vcell)
				user.drop_from_inventory(W, src)
				vcell = W
				to_chat(user, SPAN_NOTICE("You install a cell in [src]."))
				icon_state = "vm_open"
				update_icon()
			else
				to_chat(user, SPAN_NOTICE("[src] already has a cell."))

		else if(istype(W, /obj/item/weapon/screwdriver))
			if(vcell)
				vcell.update_icon()
				vcell.forceMove(get_turf(src.loc))
				vcell = null
				to_chat(user, SPAN_NOTICE("You remove the cell from the [src]."))
				icon_state = "vm_nocell"
				update_icon()
				return
			..()
		return
	else
		to_chat(user, SPAN_NOTICE("Open cover first!"))

/obj/item/weapon/vortex_manipulator/Topic(href, href_list)
	var/mob/living/carbon/human/H = usr
	if(..())
		return 1
	if (H.incapacitated() || loc != H)
		return
	if (!ishuman(H))
		return 1
	if ((H == src.loc || (in_range(src, H) && istype(src.loc, /turf))))
		H.set_machine(src)
		if(!vcell)
			return
		if (href_list["area_teleport"])
			if (active && (timelord_mode || (vcell.charge >= chargecost_area)))
				areateleport(H, 0)
		else if (href_list["beacon_teleport"])
			if (active && (timelord_mode || (vcell.charge >= chargecost_beacon)))
				beaconteleport(H, 0)
		else if (href_list["local_teleport"])
			if (active && (timelord_mode || (vcell.charge >= chargecost_local * 7)))
				localteleport(H, 0)
		else if (href_list["lmr_ability"])
			if (active && (timelord_mode || (vcell.charge >= chargecost_area)))
				localmassiverandom(H)
		else if (href_list["ebt_ability"])
			if (active && (timelord_mode || (vcell.charge >= chargecost_beacon * 5)))
				beaconteleport(H, 1)
		else if (href_list["vma_ability"])
			if (active && (timelord_mode || (vcell.charge >= chargecost_beacon)))
				vortexannounce(H, 1)
		else if (href_list["attempt_activate"])
			self_activate(H)
		else if (href_list["toggle_click_tele"])
			teleport_on_click = !teleport_on_click
			to_chat(H, SPAN_NOTICE("You toggle the ability of your Vortex Manipulator to teleport you with just aiming it at some location. Is it on or off now?"))
		else if (href_list["close_cover"])
			cover_open = 0
			icon_state = "vm_closed"
			to_chat(H, SPAN_NOTICE("You flip Vortex Manipulator's protective cover closed"))
			update_icon()
			return

	attack_self(H)
	return

/obj/item/weapon/vortex_manipulator/emp_act(severity)
	var/vm_owner = get_owner()
	if(!ishuman(vm_owner))
		return
	var/mob/living/carbon/human/H = vm_owner
	if(!vcell || !cover_open)
		return
	if(world.time < emp_prevent_until)
		return
	emp_prevent_until = world.time + 13 SECONDS
	if(timelord_mode || (severity == 2))
		if(prob(25))
			if(prob(50))
				H.visible_message(SPAN_NOTICE("The Vortex Manipulator suddenly teleports user to specific beacon for its own reasons."))
				beaconteleport(H, 1)
			else
				malfunction()
		else
			if(prob(75))
				H.visible_message(SPAN_NOTICE("The Vortex Manipulator is automatically trying to avoid local space-time anomaly."))
				localteleport(H, 1)
			else
				malfunction()
	else
		if(prob(50))
			if(prob(50))
				H.visible_message(SPAN_WARNING("The Vortex Manipulator violently shakes and extracts Space Carps from local bluespace anomaly!"))
				playsound(get_turf(src), 'sound/effects/phasein.ogg', 50, 1)
				new /mob/living/simple_animal/hostile/carp(get_turf(src))
				H.visible_message(SPAN_NOTICE("The Vortex Manipulator automatically initiates emergency area teleportation procedure."))
				areateleport(H, 1)
			else
				malfunction()
		else
			if(prob(50))
				H.visible_message(SPAN_WARNING("The Vortex Manipulator violently shakes and extracts Space Carps from local bluespace anomaly!"))
				playsound(get_turf(src), 'sound/effects/phasein.ogg', 50, 1)
				new /mob/living/simple_animal/hostile/carp(get_turf(src))
				var/temp_turf = get_turf(H)
				H.visible_message(SPAN_NOTICE("The Vortex Manipulator suddenly teleports user to specific beacon for its own reasons."))
				beaconteleport(H, 1)
				for(var/mob/M in range(rand(2, 7), temp_turf))
					localteleport(M, 1)
			else
				malfunction()

/obj/item/weapon/vortex_manipulator/afterattack(atom/A, mob/user, proximity)
	if(proximity || !teleport_on_click) return
	if((!vcell || (vcell.charge <= chargecost_local * 10)) && !timelord_mode)
		to_chat(user, SPAN_NOTICE("No power source or not enough charge to teleport locally"))
		return
	var/turf/tempturf = get_turf(A)
	localteleport(user, 1, tempturf.x, tempturf.y)

/obj/item/weapon/vortex_manipulator/Initialize()
	. = ..()
	GLOB.vortex_manipulators += src

/obj/item/weapon/vortex_manipulator/Destroy()
	GLOB.vortex_manipulators -= src
	return ..()

/obj/item/weapon/vortex_manipulator/proc/self_activate(mob/living/carbon/human/user)
	if(!active)
		to_chat(user, SPAN_NOTICE("You attempt to activate Vortex Manipulator"))
		if(!timelord_mode)
			var/counter = 0
			for(var/obj/item/weapon/vortex_manipulator/VM in GLOB.vortex_manipulators)
				if(VM.active && !VM.timelord_mode)
					counter++
			if (counter > 3)
				to_chat(user, SPAN_WARNING("You fail to activate your Vortex Manipulator - local space-time can't hold any more active VMs."))
				return
		active = 1
		unique_id = random_id(/obj/item/weapon/vortex_manipulator, 1111, 9999)
		log_and_message_admins("has activated Vortex Manipulator [unique_id]!")
		to_chat(user, SPAN_NOTICE("You successfully activate Vortex Manipulator. Its unique identifier is now: [unique_id]"))
		return
	else
		//currently not used
		to_chat(user, SPAN_NOTICE("You deactivate your Vortex Manipulator and clean all personal settings"))
		unique_id = 0
		active = 0
		timelord_mode = 0

// Gets CURRENT HOLDER (or turf, if no mob is holding it) of VM, avoiding runtimes. Returns 0 just in case it's located in sth wrong.
/obj/item/weapon/vortex_manipulator/proc/get_owner()
	var/obj/item/temp_loc = src
	while(!ishuman(temp_loc.loc) && !istype(temp_loc.loc, /turf))
		if(!ismob(temp_loc.loc) && !isobj(temp_loc.loc))
			return 0
		temp_loc = temp_loc.loc
	return temp_loc.loc

// TODO: possible rework; different malfunctions in different situations (multipliers with default settings?)
/obj/item/weapon/vortex_manipulator/proc/malfunction()
	if(timelord_mode)
		return
	var/vm_owner = get_owner()
	if(!ishuman(vm_owner))
		return
	var/mob/living/carbon/human/H = vm_owner
	H.visible_message(SPAN_NOTICE("The Vortex Manipulator malfunctions!"))
	var/turf/temp_turf = get_turf(H)
	if(prob(3))
		H.visible_message(SPAN_DANGER("The Vortex Manipulator releases its energy in a large explosion!"))
		explosion(temp_turf, 0, 0, 3, 4)
		areateleport(H, 1)
		explosion(temp_turf, 1, 2, 4, 5)
		for(var/mob/M in range(rand(3, 7), temp_turf))
			areateleport(M, 1)
		return
	else if(prob(10))
		H.visible_message(SPAN_WARNING("The Vortex Manipulator violently shakes and extracts Space Carps from local space-time anomaly!"))
		playsound(get_turf(src), 'sound/effects/phasein.ogg', 50, 1)
		var/amount = rand(1,3)
		for(var/i=0; i<amount; i++)
			new /mob/living/simple_animal/hostile/carp(get_turf(src))
		for(var/mob/M in range(rand(3, 7), temp_turf))
			localteleport(M, 1)
		return
	else if(prob(10))
		H.visible_message(SPAN_WARNING("The Vortex Manipulator violently shakes and releases some of its hidden energy!"))
		explosion(get_turf(src), 0, 0, 3, 4)
		return
	else if(prob(15))
		H.visible_message(SPAN_NOTICE("The Vortex Manipulator automatically initiates emergency area teleportation procedure."))
		areateleport(H, 1)
		for(var/mob/M in range(rand(3, 7), temp_turf))
			beaconteleport(M, 1)
		return
	else if(prob(30))
		H.visible_message(SPAN_NOTICE("The Vortex Manipulator suddenly teleports user to specific beacon for its own reasons."))
		beaconteleport(H, 1)
		for(var/mob/M in range(rand(3, 7), temp_turf))
			localteleport(M, 1)
		return
	else if(prob(40))
		H.visible_message(SPAN_NOTICE("The Vortex Manipulator is automatically trying to avoid local space-time anomaly."))
		if(prob(50))
			H.visible_message(SPAN_WARNING("The Vortex Manipulator fails to avoid local space-time anomaly!"))
			for(var/mob/M in range(rand(3, 7), temp_turf))
				localteleport(M, 1)
			return
		localteleport(H, 1)
	playsound(get_turf(src), "spark", 50, 1)
	var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
	sparks.set_up(3, 0, get_turf(src))
	sparks.start()

// Lowers cellcharge according to power spent. Protected against negative charge values.
/obj/item/weapon/vortex_manipulator/proc/deductcharge(chrgdeductamt)
	if(vcell)
		if(vcell.checked_use(chrgdeductamt))
			return 1
		else
			return 0
	return null

// Looks for all beacons located on station levels (station + tcomms for now) and adds them to refreshed (emptied) list of areas to teleport to.
/obj/item/weapon/vortex_manipulator/proc/get_beacon_locations()
	beacon_locations = list()
	for(var/obj/item/device/radio/beacon/R in GLOB.listening_objects)
		var/area/AR = get_area(R)
		if(beacon_locations.Find(AR.name)) continue
		var/turf/picked = pick(get_area_turfs(AR.type))
		if(isStationLevel(picked.z))
			beacon_locations += AR.name
			beacon_locations[AR.name] = AR
	beacon_locations = sortAssoc(beacon_locations)

// phase_in & phase_out are from ninja's teleport mostly.
/obj/item/weapon/vortex_manipulator/proc/phase_in(mob/M,turf/T)
	if(!M || !T)
		return
	playsound(T, 'sound/effects/phasein.ogg', 50, 1)
	anim(T,M,'icons/mob/mob.dmi',,"phasein",,M.dir)

/obj/item/weapon/vortex_manipulator/proc/phase_out(mob/M,turf/T)
	if(!M || !T)
		return
	playsound(T, 'sound/effects/phasein.ogg', 50, 1)
	anim(T,M,'icons/mob/mob.dmi',,"phaseout",,M.dir)
/*
 * Special VM abilities:
 * - Local massive random (COMBAT)
 * - Vortex Announce (COMMS)
 */

/*
 * Local massive random
 * Special combat ability allowing VM to teleport all those surrounding its wearer randomly.
 * User returns to his position after everyone's been teleported.
 */
/obj/item/weapon/vortex_manipulator/proc/localmassiverandom(mob/user)
	if(istype(vcell, /obj/item/weapon/cell/quantum))
		var/obj/item/weapon/cell/quantum/Q = vcell
		if(Q.partner)
			playsound(get_turf(src), 'sound/effects/phasein.ogg', 50, 1)
			user.visible_message(SPAN_WARNING("The Vortex Manipulator turns into a potato!"))
			new /obj/item/weapon/cell/potato(get_turf(src))
			qdel(src)
			return
	log_and_message_admins("has used Vortex Manipulator's Local Massive Random ability.")
	user.visible_message(SPAN_WARNING("The Vortex Manipulator announces: Battle function activated. Assembling local space-time anomaly."))
	var/turf/temp_turf = get_turf(user)
	for(var/mob/M in range(5, temp_turf))
		var/vortexchecktemp = 0
		for(var/obj/item/weapon/vortex_manipulator/VM in M.contents)
			if(VM.active == 1)
				vortexchecktemp = 1
		if(!vortexchecktemp)
			localteleport(M, 1)
	phase_out(user, get_turf(user))
	user.forceMove(temp_turf)
	phase_in(user, get_turf(user))
	deductcharge(chargecost_area)

/*
 * Vortex Announce
 * Allows you to say something nice to all active VM users in world
 * TODO: add CD
 */

/obj/item/weapon/vortex_manipulator/proc/vortexannounce(mob/user, nonactive_announce = 0)
	var/input = sanitize(input(user, "Enter what you want to announce"))
	for(var/obj/item/weapon/vortex_manipulator/VM in GLOB.vortex_manipulators)
		var/H = VM.get_owner()
		if (ishuman(H) && (VM.active || nonactive_announce))
			to_chat(H, SPAN_DANGER("Your Vortex Manipulator suddenly announces with voice of [user]: [input]"))
	deductcharge(chargecost_beacon)


/*
 * VM basic teleporation types:
 * - Local teleport
 * - Beacon teleport
 * - Area teleport
 */

/*
 * Local teleport.
 * Teleports user with coordinates (x, y) to coordinates (x+a, y+b), allowing him to choose 'a' and 'b' in range [-5, 5].
 * When malfunctioning, picks random 'a' and 'b' values and has chance of next malfunction doubled.
 * Also teleports everyone aggressively grabbed by user.
 */
/obj/item/weapon/vortex_manipulator/proc/localteleport(mob/user, malf_use, new_x = 0, new_y = 0)
	if(!active)
		malf_use = 1
	var/list/possible_x = list(-5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5)
	var/list/possible_y = list(-5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5)
	var/A = pick(possible_x)
	var/B = pick(possible_y)
	if(!malf_use)
		A = input(user, "X-coordinate shift", "JEEROOONIMOOO") in possible_x
		B = input(user, "Y-coordinate shift", "JEEROOONIMOOO") in possible_y
	var/turf/starting = get_turf(user)
	if((new_x + new_y) == 0)
		new_x = starting.x + A
		new_y = starting.y + B
		deductcharge(chargecost_local * round(sqrt(A * A + B * B)))
	else
		deductcharge(chargecost_local * round(sqrt((new_x - starting.x) * (new_x - starting.x) + (new_y - starting.y) * (new_y - starting.y))))
	var/turf/targetturf = locate(new_x, new_y, user.z)
	phase_out(user,get_turf(user))
	if(istype(vcell, /obj/item/weapon/cell/quantum))
		var/obj/item/weapon/cell/quantum/Q = vcell
		if(Q.partner)
			bluespace_malf(user)
	else
		user.forceMove(targetturf)
	phase_in(user,get_turf(user))
	for(var/obj/item/grab/G in user.contents)
		if(G.affecting)
			phase_out(G.affecting,get_turf(G.affecting))
			G.affecting.forceMove(get_turf(user))
			phase_in(G.affecting,get_turf(G.affecting))
	if(prob(10 - (10 * malf_use)))
		malfunction()

/*
 * Beacon teleport.
 * Teleports user to every area with beacon in world on station levels (station + tcomms).
 * If there are two or more beacons in area, target beacon is chosen almost randomly.
 * When malfunctioning, picks random area from list of areas with beacons and has chance of next malfunction doubled.
 * Also teleports everyone aggressively grabbed by user.
 */
/obj/item/weapon/vortex_manipulator/proc/beaconteleport(mob/user, malf_use)
	if(!active)
		malf_use = 1
	get_beacon_locations()
	var/A = pick(beacon_locations)
	if(!malf_use)
		A = input(user, "Beacon to jump to", "JEEROOONIMOOO") in beacon_locations
	var/area/thearea = beacon_locations[A]
	if (user.incapacitated())
		return
	if(!((user == loc || (in_range(src, user) && istype(src.loc, /turf)))))
		return
	if(user && user.buckled)
		user.buckled.unbuckle_mob()
	for(var/obj/item/device/radio/beacon/R in GLOB.listening_objects)
		if(get_area(R) == thearea)
			var/turf/T = get_turf(R)
			phase_out(user,get_turf(user))
			if(istype(vcell, /obj/item/weapon/cell/quantum))
				var/obj/item/weapon/cell/quantum/Q = vcell
				if(Q.partner)
					bluespace_malf(user)
			else
				user.forceMove(T)
			phase_in(user,get_turf(user))
			deductcharge(chargecost_beacon)
			for(var/obj/item/grab/G in user.contents)
				if(G.affecting)
					phase_out(G.affecting,get_turf(G.affecting))
					G.affecting.forceMove(locate(user.x+rand(-1,1),user.y+rand(-1,1),T.z))
					phase_in(G.affecting,get_turf(G.affecting))
			break
	if(prob(2 + (3 * malf_use)))
		malfunction()
/*
 * Bluespace cell malfunction
 */

obj/item/weapon/vortex_manipulator/proc/bluespace_malf(mob/user)
	user.visible_message(SPAN_WARNING("The Vortex Manipulator announces: Bluespace cell detected. Heading to its pair."))
	var/obj/item/weapon/cell/quantum/quacell = vcell
	user.forceMove(get_turf(quacell.partner))

/*
 * Area teleport.
 * Teleports user to area selected from the same list of areas that wizard's teleportation scroll uses.
 * When malfunctioning, picks random area from this list. Also has chance of next malfunction doubled.
 * Which for now means definite malfunction after teleporation, so with the chance of 50% you will be teleported locally after that.
 * Also teleports everyone aggressively grabbed by user.
 */
/obj/item/weapon/vortex_manipulator/proc/areateleport(mob/user, malf_use)
	if(!active)
		malf_use = 1
	var/A = pick(teleportlocs)
	if(!malf_use)
		A = input(user, "Area to jump to", "JEEROOONIMOOO") in teleportlocs
	var/area/thearea = teleportlocs[A]
	if (user.incapacitated())
		return
	if(!((user == loc || (in_range(src, user) && istype(src.loc, /turf)))))
		return
	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		if(!T.density)
			var/clear = 1
			for(var/obj/O in T)
				if(O.density)
					clear = 0
					break
			if(clear)
				L+=T
	if(!L.len)
		to_chat(user, "The space-time travel matrix was unable to locate a suitable teleport destination for an unknown reason. Sorry.")
		return
	if(user && user.buckled)
		user.buckled.unbuckle_mob()
	var/turf/T = pick(L)
	phase_out(user,get_turf(user))
	if(istype(vcell, /obj/item/weapon/cell/quantum))
		var/obj/item/weapon/cell/quantum/Q = vcell
		if(Q.partner)
			bluespace_malf(user)
	else
		user.forceMove(T)
	phase_in(user,get_turf(user))
	deductcharge(chargecost_area)
	for(var/obj/item/grab/G in user.contents)
		if(G.affecting)
			phase_out(G.affecting,get_turf(G.affecting))
			G.affecting.forceMove(locate(user.x+rand(-1,1),user.y+rand(-1,1),T.z))
			phase_in(G.affecting,get_turf(G.affecting))
	if(prob(13 - (malf_use * 13)))
		malfunction()
