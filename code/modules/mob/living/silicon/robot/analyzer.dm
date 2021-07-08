//
//Robotic Component Analyser, basically a health analyser for robots
//
/obj/item/device/robotanalyzer
	name = "robot analyzer"
	icon_state = "robotanalyzer"
	item_state = "analyzer"
	desc = "A hand-held scanner able to diagnose robotic injuries."
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = ITEM_SIZE_SMALL
	throw_speed = 5
	throw_range = 10
	origin_tech = list(TECH_MAGNET = 2, TECH_BIO = 1, TECH_ENGINEERING = 2)
	matter = list(MATERIAL_STEEL = 500, MATERIAL_GLASS = 200)
	var/mode = 1;

/obj/item/device/robotanalyzer/attack(mob/living/M as mob, mob/living/user as mob)
	if((MUTATION_CLUMSY in user.mutations) && prob(50))
		to_chat(user, text(SPAN("warning", "You try to analyze the floor's vitals!")))
		for(var/mob/O in viewers(M, null))
			O.show_message(text(SPAN("warning", "[user] has analyzed the floor's vitals!"), 1))
		user.show_message(text(SPAN("notice", "Analyzing Results for The floor:\n\t Overall Status: Healthy"), 1))
		user.show_message(text(SPAN("notice", "\t Damage Specifics: [0]-[0]-[0]-[0]"), 1))
		user.show_message(SPAN("notice", "Key: Suffocation/Toxin/Burns/Brute"), 1)
		user.show_message(SPAN("notice", "Body Temperature: ???"), 1)
		return

	var/scan_type
	if(istype(M, /mob/living/silicon/robot))
		scan_type = "robot"
	else if(istype(M, /mob/living/carbon/human))
		scan_type = "prosthetics"
	else
		to_chat(user, SPAN("warning", "You can't analyze non-robotic things!"))
		return

	user.visible_message(SPAN("notice", "\The [user] has analyzed [M]'s components."), SPAN("notice", "You have analyzed [M]'s components."))
	switch(scan_type)
		if("robot")
			var/BU = M.getFireLoss() > 50 	? 	"<b>[M.getFireLoss()]</b>" 		: M.getFireLoss()
			var/BR = M.getBruteLoss() > 50 	? 	"<b>[M.getBruteLoss()]</b>" 	: M.getBruteLoss()
			user.show_message(SPAN("notice", "Analyzing Results for [M]:\n\t Overall Status: [M.stat > 1 ? "fully disabled" : "[M.health - M.getHalLoss()]% functional"]"))
			user.show_message("\t Key: <font color='#ffa500'>Electronics</font>/<font color='red'>Brute</font>", 1)
			user.show_message("\t Damage Specifics: <font color='#ffa500'>[BU]</font> - <font color='red'>[BR]</font>")
			if(M.stat == DEAD)
				user.show_message(SPAN("notice", "Time of Failure: [time2text(worldtime2stationtime(M.timeofdeath))]"))
			var/mob/living/silicon/robot/H = M
			var/list/damaged = H.get_damaged_components(1,1,1)
			user.show_message(SPAN("notice", "Localized Damage:"),1)
			if(length(damaged)>0)
				for(var/datum/robot_component/org in damaged)
					user.show_message(text(SPAN("notice", "\t []: [][] - [] - [] - []"),	\
					capitalize(org.name),					\
					(org.installed == -1)	?	"<font color='red'><b>DESTROYED</b></font> "							:"",\
					(org.electronics_damage > 0)	?	"<font color='#ffa500'>[org.electronics_damage]</font>"	:0,	\
					(org.brute_damage > 0)	?	"<font color='red'>[org.brute_damage]</font>"							:0,		\
					(org.toggled)	?	"Toggled ON"	:	"<font color='red'>Toggled OFF</font>",\
					(org.powered)	?	"Power ON"		:	"<font color='red'>Power OFF</font>"),1)
			else
				user.show_message(SPAN("notice", "\t Components are OK."),1)
			if(H.emagged && prob(5))
				user.show_message(SPAN("warning", "\t ERROR: INTERNAL SYSTEMS COMPROMISED"),1)
			user.show_message(SPAN("notice", "Operating Temperature: [M.bodytemperature-T0C]&deg;C ([M.bodytemperature*1.8-459.67]&deg;F)"), 1)

		if("prosthetics")

			var/mob/living/carbon/human/H = M
			to_chat(user, SPAN("notice", "Analyzing Results for \the [H]:"))
			to_chat(user, "Key: <font color='#ffa500'>Electronics</font>/<font color='red'>Brute</font>")
			to_chat(user, SPAN("notice", "External prosthetics:"))
			var/organ_found
			for(var/obj/item/organ/external/E in H.organs)
				if(!BP_IS_ROBOTIC(E))
					continue
				organ_found = 1
				to_chat(user, "[E.name]: <font color='red'>[E.brute_dam]</font> <font color='#ffa500'>[E.burn_dam]</font>")
			if(!organ_found)
				to_chat(user, "No prosthetics located.")
			to_chat(user, "<hr>")
			to_chat(user, SPAN("notice", "Internal prosthetics:"))
			organ_found = null
			for(var/obj/item/organ/O in H.internal_organs)
				if(!BP_IS_ROBOTIC(O))
					continue
				organ_found = 1
				to_chat(user, "[O.name]: <font color='red'>[O.damage]</font>")
			if(!organ_found)
				to_chat(user, "No prosthetics located.")

	src.add_fingerprint(user)
	return
