/mob/living/carbon/human/proc/monkeyize()
	if (monkeyizing)
		return
	for(var/obj/item/weapon/W in src)
		u_equip(W)
		if (client)
			client.screen -= W
		if (W)
			W.loc = loc
			W.dropped(src)
			W.layer = initial(W.layer)
	update_clothing()
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101
	for(var/t in organs)
		//organs[text("[]", t)] = null
		del(organs[text("[]", t)])
	var/atom/movable/overlay/animation = new /atom/movable/overlay( loc )
	animation.icon_state = "blank"
	animation.icon = 'mob.dmi'
	animation.master = src
	flick("h2monkey", animation)
	sleep(48 * tick_multiplier)
	//animation = null
	del(animation)
	var/mob/living/carbon/monkey/O = new /mob/living/carbon/monkey( loc )

	O.name = "monkey"
	O.dna = dna
	dna = null
	O.dna.uni_identity = "00600200A00E0110148FC01300B009"
	O.dna.struc_enzymes = "0983E840344C39F4B059D5145FC5785DC6406A4BB8"
	if (mind)
		mind.transfer_to(O)
	O.loc = loc
	O.a_intent = "hurt"
	O << "<B>You are now a monkey.</B>"
	/*
	if (ticker.mode.name == "monkey")
		O << "<B>Don't be angry at the source as now you are just like him so deal with it.</B>"
		O << "<B>Follow your objective.</B>"
	//SN src = null
	*/
	del(src)
	return

/mob/living/carbon/AIize()
	if (monkeyizing)
		return
	for(var/obj/item/weapon/W in src)
		u_equip(W)
		if (client)
			client.screen -= W
		if (W)
			W.loc = loc
			W.dropped(src)
			W.layer = initial(W.layer)
			del(W)
	update_clothing()
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101
	for(var/t in organs)
		del(organs[text("[]", t)])


	..()


/mob/proc/AIize()
	client.screen.len = null
	var/mob/living/silicon/ai/O = new /mob/living/silicon/ai( loc )

	O.invisibility = 0
	O.canmove = 0
	O.name = name
	O.real_name = real_name
	O.anchored = 1
	O.aiRestorePowerRoutine = 0
	O.lastKnownIP = client.address

	mind.transfer_to(O)

	var/obj/loc_landmark
	//if (ticker.mode.name  == "AI malfunction")
		//loc_landmark = locate("landmark*ai")
	//else
	loc_landmark = locate(text("start*AI"))

	O.loc = loc_landmark.loc

	O << "<B>You are playing the station's AI. The AI cannot move, but can interact with many objects while viewing them (through cameras).</B>"
	O << "<B>To look at other parts of the station, double-click yourself to get a camera menu.</B>"
	O << "<B>While observing through a camera, you can use most (networked) devices which you can see, such as computers, APCs, intercoms, doors, etc.</B>"
	O << "To use something, simply double-click it."
	O << "Currently right-click functions will not work for the AI (except examine), and will either be replaced with dialogs or won't be usable by the AI."

	if (ticker.mode.name != "AI malfunction")
		O.laws_object = new /datum/ai_laws/nanotrasen
		O.show_laws()
		O << "<b>These laws may be changed by other players, or by you being the traitor.</b>"
	else
		O.verbs += /mob/living/silicon/ai/proc/choose_modules
		O.laws_object = new /datum/ai_laws/malfunction
		O:malf_picker = new /datum/game_mode/malfunction/AI_Module/module_picker
		O.show_laws()
		O << "<b>Kill all.</b>"
	//O.verbs += /mob/living/silicon/ai/proc/ai_call_shuttle
	//O.verbs += /mob/living/silicon/ai/proc/show_laws_verb
//	O.verbs += /mob/living/silicon/ai/proc/ai_alerts
	O.verbs += /mob/living/silicon/ai/proc/lockdown
	O.verbs += /mob/living/silicon/ai/proc/disablelockdown
	//O.verbs += /mob/living/silicon/ai/proc/ai_statuschange

//	O.verbs += /mob/living/silicon/ai/proc/ai_cancel_call
	O.job = "AI"

	spawn(0)
		var/randomname = pick(ai_names)
		var/newname = input(O,"You are the AI. Would you like to change your name to something else?", "Name change",randomname)

		if (length(newname) == 0)
			newname = randomname

		if (newname)
			if (length(newname) >= 26)
				newname = copytext(newname, 1, 26)
			newname = dd_replacetext(newname, ">", "'")
			O.real_name = newname
			O.name = newname
		var/aisprite = input(O,"What do you want to look like?", "AI image", "Cancel") in list("Blue Face","Text") //Let's player change AI sprite. Will add more sprites later. -CN
		if (aisprite == "Blue Face")
			O.icon_state = "ai"
		if (aisprite == "Text")
			O.icon_state = "ai_2"
		world << text("<b>[O.real_name] is the AI!</b>")
		del(src)

	return O


//human -> robot

/mob/living/carbon/human/proc/Robotize()
	if (monkeyizing)
		return
	for(var/obj/item/weapon/W in src)
		u_equip(W)
		if (client)
			client.screen -= W
		if (W)
			W.loc = loc
			W.dropped(src)
			W.layer = initial(W.layer)
			del(W)
	update_clothing()
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101
	for(var/t in organs)
		del(organs[text("[t]")])
	//client.screen -= main_hud1.contents
	client.screen -= hud_used.contents
	client.screen -= hud_used.adding
	client.screen -= hud_used.mon_blo
	client.screen -= list( oxygen, throw_icon, i_select, m_select, toxin, internals, fire, hands, healths, pullin, blind, flash, rest, sleep, mach )
	client.screen -= list( zone_sel, oxygen, throw_icon, i_select, m_select, toxin, internals, fire, hands, healths, pullin, blind, flash, rest, sleep, mach )
	var/mob/living/silicon/robot/O = new /mob/living/silicon/robot( loc )

	// cyborgs produced by Robotize get an automatic power cell
	O.cell = new(O)
	O.cell.maxcharge = 7500
	O.cell.charge = 1500


	O.gender = gender
	O.invisibility = 0
	O.name = "Cyborg"
	O.real_name = "Cyborg"
	O.lastKnownIP = client.address
	if (client)
		client.mob = O
	mind.transfer_to(O)		//Added to fix robot gibbing disconnecting the player. - Strumpetplaya
	O.loc = loc
	O << "<B>You are playing a Robot. A Robot can interact with most electronic objects in its view point.</B>"
	O << "<B>You must follow the laws that the AI has. You are the AI's assistant to the station basically.</B>"
	O << "To use something, simply double-click it."
	O << {"Use say ":s to speak to fellow cyborgs and the AI through binary."}

	O.job = "Cyborg"



	del(src)
	return O

//human -> alien
/mob/living/carbon/human/proc/Alienize()
	if (monkeyizing)
		return
	for(var/obj/item/weapon/W in src)
		u_equip(W)
		if (client)
			client.screen -= W
		if (W)
			W.loc = loc
			W.dropped(src)
			W.layer = initial(W.layer)
	update_clothing()
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101
	for(var/t in organs)
		del(organs[t])
//	var/atom/movable/overlay/animation = new /atom/movable/overlay( loc )
//	animation.icon_state = "blank"
//	animation.icon = 'mob.dmi'
//	animation.master = src
//	flick("h2alien", animation)
//	sleep(48 * tick_multiplier)
//	del(animation)
	var/mob/living/carbon/alien/humanoid/O = new /mob/living/carbon/alien/humanoid( loc )
	O.name = "alien"
	O.dna = dna
	dna = null
	O.dna.uni_identity = "00600200A00E0110148FC01300B009"
	O.dna.struc_enzymes = "0983E840344C39F4B059D5145FC5785DC6406A4BB8"
	if (client)
		client.mob = O
	O.loc = loc
	O.a_intent = "hurt"
	O << "<B>You are now an alien.</B>"
	del(src)
	return