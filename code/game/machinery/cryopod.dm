/*
 * Cryogenic refrigeration unit. Basically a despawner.
 * Stealing a lot of concepts/code from sleepers due to massive laziness.
 * The despawn tick will only fire if it's been more than time_till_despawned ticks
 * since time_entered, which is world.time when the occupant moves in.
 * ~ Zuhayr
 */


//Main cryopod console.
#define MAIN  1
#define LOG   2
#define ITEMS 3
/obj/machinery/computer/cryopod
	name = "cryogenic oversight console"
	desc = "An interface between crew and the cryogenic storage oversight systems."

	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "cellconsole"
	icon_screen = "cellconsole_on"
	icon_keyboard = "cellconsole_key"
	light_color = "#00FF25"
	light_max_bright_on = 1.0
	light_inner_range_on = 0.5
	light_outer_range_on = 3

	circuit = /obj/item/circuitboard/cryopodcontrol
	density = 0
	interact_offline = 1
	turf_height_offset = 0
	var/datum/browser/browser = null
	var/menu = MAIN

	//Used for logging people entering cryosleep and important items they are carrying.
	var/list/frozen_crew = list()
	var/list/frozen_items = list()
	var/list/_admin_logs = list() // _ so it shows first in VV

	var/storage_type = "crewmembers"
	var/storage_name = "Cryogenic Oversight Control"
	var/allow_items = 1

/obj/machinery/computer/cryopod/robot
	name = "robotic storage console"
	desc = "An interface between crew and the robotic storage systems."
	icon = 'icons/obj/robot_storage.dmi'
	icon_state = "console"
	icon_screen = "console_on"
	icon_keyboard = "console_key"
	light_color = "#0099FF"
	circuit = /obj/item/circuitboard/robotstoragecontrol

	storage_type = "cyborgs"
	storage_name = "Robotic Storage Control"
	allow_items = 0

/obj/machinery/computer/cryopod/attack_ai()
	src.attack_hand()

/obj/machinery/computer/cryopod/attack_hand(mob/user = usr)
	if(stat & (NOPOWER|BROKEN))
		return
	..()
	interact(user)


/obj/machinery/computer/cryopod/interact(mob/user)
	var/dat = ""
	switch(menu)
		if(MAIN)
			dat += "<meta charset=\"utf-8\">"
			dat += "<hr><br><b>[storage_name]</b><br>"
			dat += "<i>Welcome, [user.real_name].</i><br><br><hr>"
			dat += "<a href='?src=\ref[src];log=1'>View storage log</a><br>"
			if(allow_items)
				dat += "<a href='?src=\ref[src];view=1'>View objects</a><br>"
				dat += "<a href='?src=\ref[src];item=1'>Recover object</a><br>"
				dat += "<a href='?src=\ref[src];allitems=1'>Recover all objects</a><br>"
		if(LOG)
			dat += "<b>Recently stored [storage_type]</b><br><hr><br>"
			if(length(frozen_crew))
				for(var/person in frozen_crew)
					dat += "[person]<br>"
			else
				dat += "<i>Log is empty</i><br>"
			dat += "<hr>"
			dat += "<a href='?src=\ref[src];return=1'>Return to main menu</a><br>"
		if(ITEMS)
			dat += "<b>Recently stored objects</b><br><hr><br>"
			if(length(frozen_items))
				for(var/obj/item/I in frozen_items)
					dat += "[I.name]<br>"
			else
				dat += "<i>Log is empty</i><br>"
			dat += "<hr>"
			dat += "<a href='?src=\ref[src];return=1'>Return to main menu</a><br>"

	if(!browser || browser.user != user)
		browser = new(user, "cryopod_console", "[storage_name]", 400, 500)
		browser.set_content(dat)
	else
		browser.set_content(dat)
		browser.update()
	browser.open()

/obj/machinery/computer/cryopod/OnTopic(user, href_list, state)
	if(href_list["log"])
		menu = LOG
		. = TOPIC_REFRESH

	else if(href_list["view"])
		if(!allow_items) return

		menu = ITEMS
		. = TOPIC_REFRESH

	else if(href_list["return"])
		menu = MAIN
		. = TOPIC_REFRESH

	else if(href_list["item"])
		if(!allow_items) return

		if(frozen_items.len == 0)
			to_chat(user, SPAN("notice", "There is nothing to recover from storage."))
			return TOPIC_HANDLED

		var/obj/item/I = input(user, "Please choose which object to retrieve.","Object recovery",null) as null|anything in frozen_items
		if(!I || !CanUseTopic(user, state))
			return TOPIC_HANDLED

		if(!(I in frozen_items))
			to_chat(user, SPAN("notice", "\The [I] is no longer in storage."))
			return TOPIC_HANDLED

		visible_message(SPAN("notice", "The console beeps happily as it disgorges \the [I]."))

		I.dropInto(loc)
		frozen_items -= I

		menu = MAIN
		. = TOPIC_REFRESH

	else if(href_list["allitems"])
		if(!allow_items)
			return TOPIC_HANDLED

		if(frozen_items.len == 0)
			to_chat(user, SPAN("notice", "There is nothing to recover from storage."))
			return TOPIC_HANDLED

		visible_message(SPAN("notice", "The console beeps happily as it disgorges the desired objects."))

		for(var/obj/item/I in frozen_items)
			I.dropInto(loc)
			frozen_items -= I

		menu = MAIN
		. = TOPIC_REFRESH

	if(. == TOPIC_REFRESH)
		interact(user)

#undef MAIN
#undef LOG
#undef ITEMS

/obj/item/circuitboard/cryopodcontrol
	name = "Circuit board (Cryogenic Oversight Console)"
	build_path = /obj/machinery/computer/cryopod
	origin_tech = list(TECH_DATA = 3)

/obj/item/circuitboard/robotstoragecontrol
	name = "Circuit board (Robotic Storage Console)"
	build_path = /obj/machinery/computer/cryopod/robot
	origin_tech = list(TECH_DATA = 3)

//Decorative structures to go alongside cryopods.
/obj/structure/cryofeed

	name = "cryogenic feed"
	desc = "A bewildering tangle of machinery and pipes."
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "cryo_rear"
	anchored = 1
	dir = WEST

//Cryopods themselves.
/obj/machinery/cryopod
	name = "cryogenic freezer"
	desc = "A man-sized pod for entering suspended animation."
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "body_scanner_0"
	density = 1
	anchored = 1
	dir = WEST
	req_one_access = list(access_security)

	base_icon_state = "body_scanner_0"
	var/occupied_icon_state = "body_scanner_1"
	var/on_store_message = "has entered long-term storage."
	var/on_store_name = "Cryogenic Oversight"
	var/on_enter_occupant_message = "You feel cool air surround you. You go numb as your senses turn inward."
	var/allow_occupant_types = list(/mob/living/carbon/human)
	var/disallow_occupant_types = list()

	var/mob/occupant = null       // Person waiting to be despawned.
	var/time_till_despawn = 9000  // Down to 15 minutes //30 minutes-ish is too long
	var/time_entered = 0          // Used to keep track of the safe period.
	var/obj/item/device/radio/intercom/announce //

	var/obj/machinery/computer/cryopod/control_computer
	var/last_no_computer_message = 0
	var/applies_stasis = 1
	var/despawning_now = FALSE

	// These items are preserved when the process() despawn proc occurs.
	var/list/preserve_items = list(
		/obj/item/integrated_circuit/manipulation/bluespace_rift,
		/obj/item/integrated_circuit/input/teleporter_locator,
		/obj/item/card/id/captains_spare,
		/obj/item/aicard,
		/obj/item/organ/internal/cerebrum/mmi,
		/obj/item/device/paicard,
		/obj/item/gun,
		/obj/item/pinpointer,
		/obj/item/clothing/suit,
		/obj/item/clothing/shoes/magboots,
		/obj/item/blueprints,
		/obj/item/clothing/head/helmet/space,
		/obj/item/storage/internal
	)

/obj/machinery/cryopod/robot
	name = "robotic storage unit"
	desc = "A storage unit for robots."
	icon = 'icons/obj/robot_storage.dmi'
	icon_state = "pod_0"
	base_icon_state = "pod_0"
	occupied_icon_state = "pod_1"
	on_store_message = "has entered robotic storage."
	on_store_name = "Robotic Storage Oversight"
	on_enter_occupant_message = "The storage unit broadcasts a sleep signal to you. Your systems start to shut down, and you enter low-power mode."
	allow_occupant_types = list(/mob/living/silicon/robot)
	disallow_occupant_types = list(/mob/living/silicon/robot/drone)
	applies_stasis = 0
	req_one_access = list(access_robotics, access_security)

/obj/machinery/cryopod/lifepod
	name = "life pod"
	desc = "A man-sized pod for entering suspended animation. Dubbed 'cryocoffin' by more cynical spacers, it is pretty barebone, counting on stasis system to keep the victim alive rather than packing extended supply of food or air. Can be ordered with symbols of common religious denominations to be used in space funerals too."
	on_store_name = "Life Pod Oversight"
	time_till_despawn = 20 MINUTES
	icon_state = "redpod0"
	base_icon_state = "redpod0"
	occupied_icon_state = "redpod1"
	var/launched = 0
	var/datum/gas_mixture/airtank

/obj/machinery/cryopod/lifepod/Initialize()
	. = ..()
	airtank = new()
	airtank.temperature = 0 CELSIUS
	airtank.adjust_gas("oxygen", MOLES_O2STANDARD, 0)
	airtank.adjust_gas("nitrogen", MOLES_N2STANDARD)

/obj/machinery/cryopod/lifepod/return_air()
	return airtank

/obj/machinery/cryopod/lifepod/proc/launch()
	launched = 1
	for(var/d in GLOB.cardinal)
		var/turf/T = get_step(src,d)
		var/obj/machinery/door/blast/B = locate() in T
		if(B && B.density)
			B.force_open()
			break

	var/list/possible_locations = list()

	var/newz = GLOB.using_map.get_empty_zlevel()
	if(possible_locations.len && prob(10))
		newz = pick(possible_locations)
	var/turf/nloc = locate(rand(TRANSITION_EDGE, world.maxx-TRANSITION_EDGE), rand(TRANSITION_EDGE, world.maxy-TRANSITION_EDGE),newz)
	if(!istype(nloc, /turf/space))
		explosion(nloc, 1, 2, 3)
	playsound(loc,'sound/effects/rocket.ogg',100)
	forceMove(nloc)

//Don't use these for in-round leaving
/obj/machinery/cryopod/lifepod/Process()
	if(evacuation_controller && evacuation_controller.state >= EVAC_LAUNCHING)
		if(occupant && !launched)
			launch()
		..()

/obj/machinery/cryopod/Destroy()
	if(occupant)
		occupant.forceMove(loc)
		occupant.resting = 1
	. = ..()

/obj/machinery/cryopod/Initialize()
	. = ..()
	find_control_computer()
	announce = new /obj/item/device/radio/intercom(src)

/obj/machinery/cryopod/examine(mob/user, infix)
	. = ..()

	if(!user.Adjacent(src))
		return

	if(occupant)
		. += "It has [SPAN_NOTICE("[occupant]")] inside."

/obj/machinery/cryopod/emag_act(remaining_charges, mob/user)
	if(!emagged)
		playsound(src.loc, 'sound/effects/computer_emag.ogg', 25)
		to_chat(user, SPAN_NOTICE("The locking mechanism has been disabled."))
		emagged = TRUE
		return TRUE

/obj/machinery/cryopod/proc/find_control_computer(urgent=0)
	// Workaround for http://www.byond.com/forum/?post=2007448
	for(var/obj/machinery/computer/cryopod/C in src.loc.loc)
		control_computer = C
		break
	// control_computer = locate(/obj/machinery/computer/cryopod) in src.loc.loc

	// Don't send messages unless we *need* the computer, and less than five minutes have passed since last time we messaged
	if(!control_computer && urgent && last_no_computer_message + 5*60*10 < world.time)
		log_admin("Cryopod in [src.loc.loc] could not find control computer!")
		message_admins("Cryopod in [src.loc.loc] could not find control computer!")
		last_no_computer_message = world.time

	return control_computer != null

/obj/machinery/cryopod/proc/check_occupant_allowed(mob/M)
	var/correct_type = 0
	for(var/type in allow_occupant_types)
		if(istype(M, type))
			correct_type = 1
			break

	if(!correct_type) return 0

	for(var/type in disallow_occupant_types)
		if(istype(M, type))
			return 0

	return 1

//Lifted from Unity stasis.dm and refactored. ~Zuhayr
/obj/machinery/cryopod/Process()
	if(QDELETED(occupant))
		return
	if(applies_stasis && iscarbon(occupant))
		var/mob/living/carbon/C = occupant
		C.SetStasis(3)

	//Allow a ten minute gap between entering the pod and actually despawning.
	if(world.time - time_entered < time_till_despawn)
		return

	if(!occupant.client && occupant.stat<2) //Occupant is living and has no client.
		if(!control_computer)
			if(!find_control_computer(urgent=1))
				return
		if(!despawning_now)
			despawn_occupant()

// This function can not be undone; do not call this unless you are sure
// Also make sure there is a valid control computer
/obj/machinery/cryopod/robot/despawn_occupant()
	var/mob/living/silicon/robot/R = occupant
	if(!istype(R)) return ..()

	qdel(R.mmi)
	for(var/obj/item/I in R.module) // the tools the borg has; metal, glass, guns etc
		for(var/obj/item/O in I) // the things inside the tools, if anything; mainly for janiborg trash bags
			O.forceMove(R)
		qdel(I)
	qdel(R.module)

	return ..()

// This function can not be undone; do not call this unless you are sure
// Also make sure there is a valid control computer
/obj/machinery/cryopod/proc/despawn_occupant()
	set waitfor = 0

	if(QDELETED(occupant))
		log_and_message_admins("A mob was deleted while in a cryopod. This may cause errors!")
		return
	despawning_now = TRUE
	//Drop all items into the pod.
	for(var/obj/item/I in occupant.contents)
		if(QDELETED(I))
			continue
		if(I in occupant.contents) // Since things may actually be dropped upon removing other things (i.e. removing uniform first causes belts to drop)
			occupant.drop(I, src)
		else
			I.forceMove(src)
		if(length(I.contents)) // Make sure we catch anything not handled by qdel() on the items.
			for(var/obj/item/O in I.contents)
				if(istype(O, /obj/item/storage/internal)) // Stop eating pockets, you fuck!
					continue
				O.forceMove(src)

	//Delete all items not on the preservation list.
	var/list/items = contents.Copy()
	items -= occupant // Don't delete the occupant
	items -= announce // or the autosay radio.

	for(var/obj/item/I in items)

		var/preserve = null
		// Snowflaaaake.
		if(istype(I, /obj/item/organ/internal/cerebrum/mmi))
			var/obj/item/organ/internal/cerebrum/mmi/brain = I
			if(brain.brainmob && brain.brainmob.client && brain.brainmob.key)
				preserve = 1
			else
				continue
		else
			for(var/T in preserve_items)
				if(istype(I, T))
					preserve = 1
					break

		if(!preserve)
			qdel(I)
		else
			if(control_computer && control_computer.allow_items)
				control_computer.frozen_items += I
				I.forceMove(null)
			else
				I.dropInto(loc)

	//Update any existing objectives involving this mob.
	for(var/datum/antag_contract/AC in GLOB.all_contracts)
		AC.on_mob_despawned(occupant.mind)
	for(var/datum/objective/O in all_objectives)
		// We don't want revs to get objectives that aren't for heads of staff. Letting
		// them win or lose based on cryo is silly so we remove the objective.
		if(O.target == occupant.mind)
			if(O.owner && O.owner.current)
				to_chat(O.owner.current, "<span class='warning'>You get the feeling your target is no longer within your reach...</span>")
			qdel(O)

	//Handle job slot/tater cleanup.
	if(occupant.mind)
		var/job = occupant.mind.assigned_role
		job_master.FreeRole(job)

		if(occupant.mind.objectives.len)
			occupant.mind.objectives = null
			occupant.mind.special_role = null

	// Delete them from datacore.
	var/datum/computer_file/crew_record/R = get_crewmember_record(occupant.real_name)
	if(R)
		qdel(R)

	icon_state = base_icon_state

	//TODO: Check objectives/mode, update new targets if this mob is the target, spawn new antags?


	//Make an announcement and log the person entering storage.

	// Titles should really be fetched from data records
	//  and records should not be fetched by name as there is no guarantee names are unique
	var/role_alt_title = occupant.mind ? occupant.mind.role_alt_title : "Unknown"

	if(control_computer)
		control_computer.frozen_crew += "[occupant.real_name], [role_alt_title] - [stationtime2text()]"
		control_computer._admin_logs += "[key_name(occupant)] ([role_alt_title]) at [stationtime2text()]"
	log_and_message_admins("[key_name(occupant)] ([role_alt_title]) entered cryostorage.")

	announce.autosay("[occupant.real_name], [role_alt_title], [on_store_message]", "[on_store_name]")
	visible_message("<span class='notice'>\The [initial(name)] hums and hisses as it moves [occupant.real_name] into storage.</span>")

	//This should guarantee that ghosts don't spawn.
	occupant.ckey = null

	// Delete the mob.
	qdel(occupant)
	set_occupant(null)
	despawning_now = FALSE

/obj/machinery/cryopod/attackby(obj/item/G as obj, mob/user as mob)

	if(istype(G, /obj/item/grab))
		var/obj/item/grab/grab = G
		if(!check_compatibility(grab.affecting, user))
			return

		var/willing = null //We don't want to allow people to be forced into despawning.
		var/mob/M = G:affecting

		if(M.client)
			if(alert(M,"Would you like to enter long-term storage?",,"Yes","No") == "Yes")
				if(!M || !grab || !grab.affecting)
					return
				willing = 1
		else
			willing = 1

		if(willing && go_in(grab.affecting, user))
			if(!check_compatibility(grab.affecting, user))
				return
			log_and_message_admins("put [key_name_admin(grab.affecting)] into the cryopod.")
			add_fingerprint(M)
			qdel(grab)

/obj/machinery/cryopod/verb/eject()
	set name = "Eject Pod"
	set category = "Object"
	set src in oview(1)

	if(usr.stat != 0)
		return

	if(usr != occupant && !allowed(usr) && !emagged)
		to_chat(usr, "<span class='warning'>Access Denied.</span>")
		return

	icon_state = base_icon_state

	//Eject any items that aren't meant to be in the pod.
	var/list/items = src.contents
	if(occupant) items -= occupant
	if(announce) items -= announce

	for(var/obj/item/I in items)
		I.forceMove(get_turf(src))

	go_out()
	add_fingerprint(usr)

	SetName(initial(name))

/obj/machinery/cryopod/proc/go_out()
	if(!occupant)
		return

	if(occupant.client)
		occupant.client.eye = src.occupant.client.mob
		occupant.client.perspective = MOB_PERSPECTIVE

	occupant.forceMove(get_turf(src))
	set_occupant(null)

	icon_state = base_icon_state

/obj/machinery/cryopod/proc/go_in(mob/M, mob/user)
	if(!M)
		return
	if(stat & (BROKEN|NOPOWER))
		return
	if(occupant)
		to_chat(user, "<span class='warning'>\The [src] is already occupied.</span>")
		return
	if(name == "cryogenic freezer" && M.is_ic_dead())
		to_chat(user, "<span class='warning'>\The [src]s are not designed to store bodies. Contact the medical unit.</span>")
		var/area/t = get_area(M)
		var/location = t.name
		for(var/channel in list("Security", "Medical"))
			GLOB.global_headset.autosay("Someone is trying to store a dead body in [name] at [location]!", ("[name] warning"), channel)
		return
	if(M == user)
		visible_message("\The [user] starts climbing into \the [src].")
	else
		visible_message("\The [user] starts putting [M] into \the [src].")

	var/turf/old_loc = get_turf(M)
	if(do_after(user, 20, src))
		if(old_loc != get_turf(M))
			return
		if(occupant)
			to_chat(user, "<span class='warning'>\The [src] is already occupied.</span>")
			return
		if(M.buckled)
			to_chat(user, "<span class='warning'>Unbuckle [M == user ? "yourself" : M] first.</span>")
			return FALSE

		M.stop_pulling()
		if(M.client)
			M.client.perspective = EYE_PERSPECTIVE
			M.client.eye = src
		set_occupant(M)
		return TRUE

/obj/machinery/cryopod/proc/set_occupant(mob/living/carbon/occupant)
	src.occupant = occupant
	if(!occupant)
		SetName(initial(name))
		return

	occupant.stop_pulling()
	if(occupant.client)
		to_chat(occupant, "<span class='notice'>[on_enter_occupant_message]</span>")
		to_chat(occupant, "<span class='notice'><b>If you ghost, log out or close your client now, your character will shortly be permanently removed from the round.</b></span>")
		occupant.client.perspective = EYE_PERSPECTIVE
		occupant.client.eye = src
	occupant.forceMove(src)
	time_entered = world.time

	SetName("[name] ([occupant])")
	icon_state = occupied_icon_state

/obj/machinery/cryopod/MouseDrop_T(mob/target, mob/user)
	if(!CanMouseDrop(target, user))
		return
	if(!check_compatibility(target, user))
		return

	if(go_in(target, user))
		if(target == user)
			log_and_message_admins("entered a cryopod.")
		else
			log_and_message_admins("put [key_name_admin(target)] into the cryopod.")

/obj/machinery/cryopod/proc/check_compatibility(mob/target, mob/user)
	if(!istype(user) || !istype(target))
		return
	if(!check_occupant_allowed(target))
		to_chat(user, "<span class='warning'>[target] will not fit into the [src].</span>")
		return
	if(occupant)
		to_chat(user, "<span class='warning'>The [src] is already occupied!</span>")
		return
	if(target.buckled)
		to_chat(user, "<span class='warning'>Unbuckle [target == user ? "yourself" : target] first.</span>")
		return
	for(var/mob/living/carbon/metroid/M in range(1,target))
		if(M.Victim == target)
			to_chat(user, "[target.name] will not fit into the [src] because they have a metroid latched onto their head.")
			return
	return TRUE

/obj/machinery/cryopod/relaymove(mob/user)
	if(user.stat != 0)
		return

	go_out()
	. = ..()
