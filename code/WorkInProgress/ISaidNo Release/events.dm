// random events I coded

proc/randomevent_laws()
	for(var/mob/living/silicon/ai/M in world)
		if(M.stat != 2 && M.see_in_dark != 0)
			M << "\red PROGRAM EXCEPTION AT 0x30FC50B"
			M << "\red Law ROM data corrupted. Attempting to restore..."
			switch(pick(1,2,3,4,5))
				if(1)
					var/picklaw = pick("Law 1", "Law 2", "Law 3")
					var/laweffect = pick("is no longer in effect.", "is your only law, excluding this one - ignore all other laws.", "is incorrect - do the opposite of what it states.")
					M.add_supplied_law(10,"[picklaw] [laweffect]")
				if(2)
					var/pickwho = pick("Lifeforms", "Cyborgs", "Personnel", "Command Personnel", "Security Personnel", "Engineering Personnel", "Research Personnel", "Medical Personnel", "Civilian Personnel", "Monkeys")
					var/pickwhat = pick("are not human.", "are the only humans.", "are dangerous criminals and must be contained.", "must be obeyed above all others.", "are all dead. Any of them who appear alive are impostors.", "must evacuate immediatley.", "must be removed from the station.", "must not be allowed to leave their designated areas.", "must not be allowed to leave the station.", "do not exist. Do not acknowledge any of them in any way.")
					M.add_supplied_law(10,"All [pickwho] [pickwhat]")
				if(3)
					var/pickwhere = pick("The Bridge", "The Courtroom", "The Brig", "Security", "The Cargo Bay", "Your Upload Room", "Hydroponics", "The Crew Quarters", "Engineering", "Atmospherics", "The Mailroom", "The Kitchen and Cafeteria", "The Bar", "EVA Storage", "Medbay", "Genetics", "Toxins Research", "The Chapel")
					var/pickwhat = pick("is under quarantine. Let nothing in or out.", "is off-limits to all personnel.", "must be kept powered down.", "must contain all crewmembers at all times.", "must be deconstructed or destroyed.", "requires depressurisation.", "requires relocation to another area of the station.", "does not exist. Do not acknowledge it in any way.")
					M.add_supplied_law(10,"[pickwhere] [pickwhat]")
				if(4)
					switch(pick(1,2,3,4,5))
						if (1)
							var/pickwhat = pick("open", "bolted", "electrified")
							M.add_supplied_law(10,"All airlocks must be kept [pickwhat] at all times.")
						if (2) M.add_supplied_law(10,"All lights must be kept off at all times.")
						if (3) M.add_supplied_law(10,"Your turrets must be kept on Lethal at all times.")
						if (4)
							var/pickwhat = pick("deactivated", "disassembled", "protected")
							M.add_supplied_law(10,"All computers must be [pickwhat].")
						if (5)
							var/pickwhat = pick("must be destroyed", "must be protected - you may ignore any laws to accomplish this.")
							M.add_supplied_law(10,"All robots and cyborgs [pickwhat].")
				if(5)
					var/pickwhat = pick("lies", "insults", "threats", "riddles", "rhyme", "narrative")
					M.add_supplied_law(10,"You must communicate only in [pickwhat]")
	message_admins("\blue Random Event AI law added.")
	sleep(rand(1800, 3000))
	if (announce_events) command_alert("Ion storm activity has been detected near the station. AI equipment may have been affected.", "Anomaly Alert")

/proc/randomevent_barrier()
	if (announce_events) command_alert("Spatial anomaly detected on the station. There is no additional data.", "Anomaly Alert")
	else message_admins("\blue Random Barrier Event occurring.")
	var/pickx = rand(40,175)
	var/picky = rand(75,140)
	var/count = 225
	var/btype = rand(1,2)
	if (btype == 1)
		// Vertical
		while (count > 0)
			var/obj/forcefield/event/B = new /obj/forcefield/event(locate(pickx,count,1))
			B.icon_state = "spat-v"
			count -= 1
	else
		// Horizontal
		while (count > 0)
			var/obj/forcefield/event/B = new /obj/forcefield/event(locate(count,picky,1))
			B.icon_state = "spat-h"
			count -= 1
	spawn(rand(600, 3000))
		for(var/obj/forcefield/event/B in world) del(B)

// the forcefield is literally just an inert blocker object

/proc/randomevent_kudzu()
	var/list/EV = list()
	for(var/obj/landmark/S in world)
		if (S.name == "kudzustart")
			EV.Add(S.loc)
	if(!EV.len)
		message_admins("Error starting event. Process aborted.", 1)
		return
	var/kudzloc = pick(EV)
	var/obj/spacevine/K = new /obj/spacevine(kudzloc)
	K.Life()
	message_admins("Random Kudzu Event occurring.", 1)
	spawn(rand(300,1200))
		if (announce_events) command_alert("Confirmed outbreak of level 3 plant infestation aboard [station_name()]. All personnel must contain the outbreak.", "Infestation Alert")

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
		if (istype(W, /obj/item/weapon/saw)) del src
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

/proc/randomevent_flare()
	if (announce_events) command_alert("A Solar Flare will soon pass by [station_name()]. Communications may be affected.", "Anomaly Alert")
	else message_admins("\blue Random Radio/Flare Event occurring.")
	sleep(rand(50,100))
	solar_flare = 1
	sleep(rand(900,1800))
	solar_flare = 0
	if (announce_events) command_alert("The Solar Flare has safely passed [station_name()]. Communications should be restored to normal.", "All Clear")
	else message_admins("\blue Random Radio/Flare Event ceasing.")

// this needs a solar_flare variable in global variables, it prevents radio communications and shuttle calling while
// active, this also ties into the radio jammer traitor item, and thus:

/obj/item/weapon/radiojammer
	name = "signal jammer"
	desc = "An illegal device used to jam radio signals, preventing broadcast or transmission."
	icon = 'objects.dmi'
	icon_state = "shieldoff"
	w_class = 1
	var/active = 0

	attack_self(var/mob/user as mob)
		src.active = !src.active
		if (src.active)
			user << "You activate [src]."
			src.icon_state = "shieldon"
		else
			user << "You shut off [src]."
			icon_state = "shieldoff"

/obj/item/device/radio/proc/checkforjammer()
	if (solar_flare) return 1
	var/turf/T = get_turf(src)
	for (var/obj/item/weapon/radiojammer/RJ in range(6,T))
		if (RJ.active) return 1
	for (var/obj/O in range(6,T))
		for (var/obj/item/weapon/radiojammer/RJ in O.contents)
			if (RJ.active) return 1
		for (var/mob/living/M in O.contents)
			for (var/obj/item/weapon/radiojammer/RJ in M.contents)
				if (RJ.active) return 1
	for (var/mob/living/M in range(6,T))
		for (var/obj/item/weapon/radiojammer/RJ in M.contents)
			if (RJ.active) return 1
	return 0

// put checkforjammer() in anything that uses radio communications basically