/mob/living/bot/medbot
	name = "Medbot"
	desc = "A little medical robot. He looks somewhat underwhelmed."
	icon_state = "medibot0"
	req_one_access = list(access_medical, access_robotics)
	botcard_access = list(access_medical, access_morgue, access_surgery, access_chemistry, access_virology)

	var/skin = null // Set to "tox", "fire", "o2", "adv" or "bezerk" for different firstaid styles.

	//AI vars
	var/last_newpatient_speak = 0
	var/vocal = 1

	//Healing vars
	var/obj/item/weapon/reagent_containers/glass/reagent_glass = null // Can be set to draw from this for reagents.
	var/injection_amount = 15 // How much reagent do we inject at a time?
	var/heal_threshold = 10 // Start healing when they have this much damage in a category
	var/use_beaker = 0 // Use reagents in beaker instead of default treatment agents.
	var/treatment_brute = /datum/reagent/tricordrazine
	var/treatment_oxy = /datum/reagent/dexalin
	var/treatment_fire = /datum/reagent/tricordrazine
	var/treatment_tox = /datum/reagent/dylovene
	var/treatment_virus = /datum/reagent/spaceacillin
	var/treatment_emag = /datum/reagent/toxin
	var/declare_treatment = 0 // When attempting to treat a patient, should it notify everyone wearing medhuds?
	var/should_treat_brute = TRUE
	var/should_treat_oxy = TRUE
	var/should_treat_fire = TRUE
	var/should_treat_tox = TRUE

/mob/living/bot/medbot/handleIdle()
	if(vocal && prob(1))
		var/list/messagevoice = list("Radar, put a mask on!" = 'sound/voice/medbot/radar.ogg', "There's always a catch, and it's the best there is." = 'sound/voice/medbot/catch.ogg', "I knew it, I should've been a plastic surgeon." = 'sound/voice/medbot/surgeon.ogg', "What kind of infirmary is this? Everyone's dropping like dead flies." = 'sound/voice/medbot/flies.ogg', "Delicious!" = 'sound/voice/medbot/delicious.ogg')
		var/message = pick(messagevoice)
		say(message)
		playsound(src, messagevoice[message], 75, FALSE)

/mob/living/bot/medbot/handleAdjacentTarget()
	UnarmedAttack(target)

/mob/living/bot/medbot/lookForTargets()
	for(var/mob/living/carbon/human/H in view(7, src)) // Time to find a patient!
		if(confirmTarget(H))
			target = H
			if(last_newpatient_speak + 300 < world.time)
				var/list/messagevoice = list("Hey, [H.name]! Hold on, I'm coming." = 'sound/voice/medbot/coming.ogg', "Wait [H.name]! I want to help!" = 'sound/voice/medbot/help.ogg', "[H.name], you appear to be injured!" = 'sound/voice/medbot/injured.ogg')
				var/message = pick(messagevoice)
				say(message)
				playsound(src, messagevoice[message], 75, FALSE)
				custom_emote(1, "points at [H.name].")
				last_newpatient_speak = world.time
			break

/mob/living/bot/medbot/UnarmedAttack(mob/living/carbon/human/H, proximity)
	if(!..())
		return

	if(!on)
		return

	if(!istype(H))
		return

	if(busy)
		return

	// TODO: Fix bot ai so this check can actually be done somewhen
	if(H.stat == DEAD)
		var/list/death_messagevoice = list("No! NO!" = 'sound/voice/medbot/no.ogg', "Live, damnit! LIVE!" = 'sound/voice/medbot/live.ogg', "I... I've never lost a patient before. Not today, I mean." = 'sound/voice/medbot/lost.ogg')
		var/death_message = pick(death_messagevoice)
		say(death_message)
		playsound(src, death_messagevoice[death_message], 75, FALSE)
		target = null
		return

	var/t = confirmTarget(H)
	if(!t)
		target = null
		return

	icon_state = "medibots"
	visible_message("<span class='warning'>[src] is trying to inject [H]!</span>")
	if(declare_treatment)
		var/area/location = get_area(src)
		broadcast_medical_hud_message("[src] is treating <b>[H]</b> in <b>[location]</b>", src)
	busy = 1
	update_icons()
	if(do_mob(src, H, 30))
		if(t == 1)
			reagent_glass.reagents.trans_to_mob(H, injection_amount, CHEM_BLOOD)
		else
			H.reagents.add_reagent(t, injection_amount)
		visible_message("<span class='warning'>[src] injects [H] with the syringe!</span>")
	busy = 0
	update_icons()

	var/list/messagevoice = list("All patched up!" = 'sound/voice/medbot/patchedup.ogg', "An apple a day keeps me away." = 'sound/voice/medbot/apple.ogg', "Feel better soon!" = 'sound/voice/medbot/feelbetter.ogg')
	var/message = pick(messagevoice)
	say(message)
	playsound(src, messagevoice[message], 75, FALSE)

/mob/living/bot/medbot/update_icons()
	overlays.Cut()
	if(skin)
		overlays += image('icons/obj/aibots.dmi', "medskin_[skin]")
	if(busy)
		icon_state = "medibots"
	else
		icon_state = "medibot[on]"

/mob/living/bot/medbot/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/weapon/reagent_containers/glass))
		if(locked)
			to_chat(user, "<span class='notice'>You cannot insert a beaker because the panel is locked.</span>")
			return
		if(!isnull(reagent_glass))
			to_chat(user, "<span class='notice'>There is already a beaker loaded.</span>")
			return

		user.drop_item()
		O.loc = src
		reagent_glass = O
		to_chat(user, "<span class='notice'>You insert [O].</span>")
		return
	else
		..()

/mob/living/bot/medbot/GetInteractTitle()
	. = "<head><title>Medibot v1.0 controls</title></head>"
	. += "<b>Automatic Medical Unit v1.0</b>"

/mob/living/bot/medbot/GetInteractStatus()
	. = ..()
	. += "<br>Beaker: "
	if(reagent_glass)
		. += "<A href='?src=\ref[src];command=eject'>Loaded \[[reagent_glass.reagents.total_volume]/[reagent_glass.reagents.maximum_volume]\]</a>"
	else
		. += "None loaded"

/mob/living/bot/medbot/GetInteractPanel()
	. = "Healing threshold: "
	. += "<a href='?src=\ref[src];command=adj_threshold;amount=-10'>--</a> "
	. += "<a href='?src=\ref[src];command=adj_threshold;amount=-5'>-</a> "
	. += "[heal_threshold] "
	. += "<a href='?src=\ref[src];command=adj_threshold;amount=5'>+</a> "
	. += "<a href='?src=\ref[src];command=adj_threshold;amount=10'>++</a>"

	. += "<br>Injection level: "
	. += "<a href='?src=\ref[src];command=adj_inject;amount=-5'>-</a> "
	. += "[injection_amount] "
	. += "<a href='?src=\ref[src];command=adj_inject;amount=5'>+</a>"

	. += "<br><br>Treatment types: "
	. += "<br>Physical traumas: <a href='?src=\ref[src];command=toggle_brute'>[should_treat_brute ? "On" : "Off"]</a>"
	. += "<br>Burns: <a href='?src=\ref[src];command=toggle_fire'>[should_treat_fire ? "On" : "Off"]</a>"
	. += "<br>Oxygen deprivation: <a href='?src=\ref[src];command=toggle_oxy'>[should_treat_oxy ? "On" : "Off"]</a>"
	. += "<br>Intoxication: <a href='?src=\ref[src];command=toggle_tox'>[should_treat_tox ? "On" : "Off"]</a>"

	. += "<br><br>Reagent source: <a href='?src=\ref[src];command=use_beaker'>[use_beaker ? "Loaded Beaker (When available)" : "Internal Synthesizer"]</a>"
	. += "<br>Treatment report is [declare_treatment ? "on" : "off"]. <a href='?src=\ref[src];command=declaretreatment'>Toggle</a>"
	. += "<br>The speaker switch is [vocal ? "on" : "off"]. <a href='?src=\ref[src];command=togglevoice'>Toggle</a>"

/mob/living/bot/medbot/GetInteractMaintenance()
	. = "Injection mode: "
	switch(emagged)
		if(0)
			. += "<a href='?src=\ref[src];command=emag'>Treatment</a>"
		if(1)
			. += "<a href='?src=\ref[src];command=emag'>Random (DANGER)</a>"
		if(2)
			. += "ERROROROROROR-----"

/mob/living/bot/medbot/ProcessCommand(mob/user, command, href_list)
	..()
	if(CanAccessPanel(user))
		switch(command)
			if("adj_threshold")
				if(!locked || issilicon(user))
					var/adjust_num = text2num(href_list["amount"])
					heal_threshold = Clamp(heal_threshold + adjust_num, 5, 75)
			if("adj_inject")
				if(!locked || issilicon(user))
					var/adjust_num = text2num(href_list["amount"])
					injection_amount = Clamp(injection_amount + adjust_num, 5, 15)
			if("use_beaker")
				if(!locked || issilicon(user))
					use_beaker = !use_beaker
			if("eject")
				if(reagent_glass)
					if(!locked)
						reagent_glass.dropInto(src.loc)
						reagent_glass = null
					else
						to_chat(user, "<span class='notice'>You cannot eject the beaker because the panel is locked.</span>")
			if("togglevoice")
				if(!locked || issilicon(user))
					vocal = !vocal
			if("declaretreatment")
				if(!locked || issilicon(user))
					declare_treatment = !declare_treatment
			if("toggle_brute")
				if(!locked || issilicon(user))
					should_treat_brute = !should_treat_brute
			if("toggle_oxy")
				if(!locked || issilicon(user))
					should_treat_oxy = !should_treat_oxy
			if("toggle_fire")
				if(!locked || issilicon(user))
					should_treat_fire = !should_treat_fire
			if("toggle_tox")
				if(!locked || issilicon(user))
					should_treat_tox = !should_treat_tox

	if(CanAccessMaintenance(user))
		switch(command)
			if("emag")
				if(emagged < 2)
					emagged = !emagged

/mob/living/bot/medbot/emag_act(remaining_uses, mob/user)
	. = ..()
	if(!emagged)
		if(user)
			to_chat(user, "<span class='warning'>You short out [src]'s reagent synthesis circuits.</span>")
			ignore_list |= user
		visible_message("<span class='warning'>[src] buzzes oddly!</span>")
		flick("medibot_spark", src)
		target = null
		busy = 0
		emagged = 1
		on = 1
		update_icons()
		. = 1

/mob/living/bot/medbot/explode()
	on = 0
	visible_message("<span class='danger'>[src] blows apart!</span>")
	var/turf/Tsec = get_turf(src)

	new /obj/item/weapon/storage/firstaid(Tsec)
	new /obj/item/device/assembly/prox_sensor(Tsec)
	new /obj/item/device/healthanalyzer(Tsec)
	if (prob(50))
		new /obj/item/robot_parts/l_arm(Tsec)

	if(reagent_glass)
		reagent_glass.loc = Tsec
		reagent_glass = null

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	qdel(src)
	return

/mob/living/bot/medbot/confirmTarget(mob/living/carbon/human/H)
	if(!..())
		return 0

	if(H.stat == DEAD) // He's dead, Jim
		return 0

	if(emagged)
		return treatment_emag

	// If they're injured, we're using a beaker, and they don't have on of the chems in the beaker
	if(reagent_glass && use_beaker && ((should_treat_brute && (H.getBruteLoss() >= heal_threshold)) || (should_treat_fire && (H.getFireLoss() >= heal_threshold)) || (should_treat_tox && (H.getToxLoss() >= heal_threshold)) || (should_treat_oxy && (H.getOxyLoss() >= (heal_threshold + 15)))))
		for(var/datum/reagent/R in reagent_glass.reagents.reagent_list)
			if(!H.reagents.has_reagent(R))
				return 1
			continue

	if(should_treat_brute && (H.getBruteLoss() >= heal_threshold) && (!H.reagents.has_reagent(treatment_brute)))
		return treatment_brute //If they're already medicated don't bother!

	if(should_treat_oxy && (H.getOxyLoss() >= (15 + heal_threshold)) && (!H.reagents.has_reagent(treatment_oxy)))
		return treatment_oxy

	if(should_treat_fire && (H.getFireLoss() >= heal_threshold) && (!H.reagents.has_reagent(treatment_fire)))
		return treatment_fire

	if(should_treat_tox && (H.getToxLoss() >= heal_threshold) && (!H.reagents.has_reagent(treatment_tox)))
		return treatment_tox

/* Construction */

/obj/item/weapon/storage/firstaid/attackby(obj/item/robot_parts/S, mob/user as mob)
	if ((!istype(S, /obj/item/robot_parts/l_arm)) && (!istype(S, /obj/item/robot_parts/r_arm)))
		..()
		return

	if(contents.len >= 1)
		to_chat(user, "<span class='notice'>You need to empty [src] out first.</span>")
		return

	var/obj/item/weapon/firstaid_arm_assembly/A = new /obj/item/weapon/firstaid_arm_assembly
	if(istype(src, /obj/item/weapon/storage/firstaid/fire))
		A.skin = "fire"
	else if(istype(src, /obj/item/weapon/storage/firstaid/toxin))
		A.skin = "tox"
	else if(istype(src, /obj/item/weapon/storage/firstaid/o2))
		A.skin = "o2"
	else if(istype(src, /obj/item/weapon/storage/firstaid/adv))
		A.skin = "adv"
	else if(istype(src, /obj/item/weapon/storage/firstaid/combat))
		A.skin = "bezerk"

	qdel(S)
	user.put_in_hands(A)
	to_chat(user, "<span class='notice'>You add the robot arm to the first aid kit.</span>")
	user.drop_from_inventory(src)
	qdel(src)

/obj/item/weapon/firstaid_arm_assembly
	name = "first aid/robot arm assembly"
	desc = "A first aid kit with a robot arm permanently grafted to it."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "firstaid_arm"
	var/build_step = 0
	var/created_name = "Medibot" //To preserve the name if it's a unique medbot I guess
	var/skin = null //Same as medbot, set to tox or ointment for the respective kits.
	w_class = ITEM_SIZE_NORMAL

/obj/item/weapon/firstaid_arm_assembly/New()
	..()
	spawn(5) // Terrible. TODO: fix
		if(skin)
			overlays += image('icons/obj/aibots.dmi', "kit_skin_[src.skin]")

/obj/item/weapon/firstaid_arm_assembly/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/weapon/pen))
		var/t = sanitizeSafe(input(user, "Enter new robot name", name, created_name), MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, usr) && loc != usr)
			return
		created_name = t
	else
		switch(build_step)
			if(0)
				if(istype(W, /obj/item/device/healthanalyzer))
					user.drop_item()
					qdel(W)
					build_step++
					to_chat(user, "<span class='notice'>You add the health sensor to [src].</span>")
					SetName("First aid/robot arm/health analyzer assembly")
					overlays += image('icons/obj/aibots.dmi', "na_scanner")

			if(1)
				if(isprox(W))
					user.drop_item()
					qdel(W)
					to_chat(user, "<span class='notice'>You complete the Medibot! Beep boop.</span>")
					var/turf/T = get_turf(src)
					var/mob/living/bot/medbot/S = new /mob/living/bot/medbot(T)
					S.skin = skin
					S.SetName(created_name)
					S.update_icons() // apply the skin
					user.drop_from_inventory(src)
					qdel(src)
