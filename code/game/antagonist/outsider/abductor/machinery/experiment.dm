/obj/machinery/abductor/experiment
	name = "experimentation machine"
	desc = "A large man-sized tube sporting a complex array of surgical machinery."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "experiment-open"
	density = FALSE
	var/state_open = TRUE
	var/points = 0
	var/credits = 0
	var/list/history
	var/list/abductee_minds
	/// Machine feedback message
	var/flash = "Awaiting subject."
	var/obj/machinery/abductor/console/console
	var/message_cooldown = 0
	var/breakout_time = 45
	var/atom/movable/occupant = null

/obj/machinery/abductor/experiment/Destroy()
	if(console)
		console.experiment = null
		console = null
	return ..()

/obj/machinery/abductor/experiment/MouseDrop_T(mob/target, mob/user)
	if(user.stat != CONSCIOUS || !Adjacent(user) || !target.Adjacent(user) || !ishuman(target))
		return
	if(isabductor(target))
		return
	close_machine(target)

/obj/machinery/abductor/experiment/proc/open_machine()
	if(!state_open && !panel_open)
		state_open = TRUE
		set_density(FALSE)
		update_icon_state()
		updateUsrDialog()
		occupant.forceMove(get_turf(src))
		occupant = null

/obj/machinery/abductor/experiment/proc/close_machine(mob/target)
	for(var/A in loc)
		if(isabductor(A))
			return
	if(state_open && !panel_open)
		state_open = FALSE
		set_density(TRUE)
		if(!target)
			for(var/atom in loc)
				if (!(isliving(atom)))
					continue
				if(isliving(atom))
					var/mob/living/current_mob = atom
					if(current_mob.buckled || current_mob.mob_size >= MOB_LARGE)
						continue
				target = atom

		var/mob/living/mobtarget = target
		if(target && (!isliving(target) || !mobtarget.buckled))
			occupant = target
			target.forceMove(src)
		updateUsrDialog()
		update_icon_state()

/obj/machinery/abductor/experiment/relaymove(mob/living/user, direction)
	if(user.stat != CONSCIOUS)
		return
	if(message_cooldown <= world.time)
		message_cooldown = world.time + 50
		to_chat(user, SPAN_WARNING("[src]'s door won't budge!"))

/obj/machinery/abductor/experiment/proc/mob_breakout(mob/living/user)
	user.last_special = world.time + 100
	user.visible_message(SPAN_NOTICE("You see [user] kicking against the door of [src]!"), \
		SPAN_NOTICE("You lean on the back of [src] and start pushing the door open... (this will take about [breakout_time].)"), \
		SPAN_NOTICE("You hear a metallic creaking from [src]."))
	if(do_after(user,(breakout_time), target = src))
		if(!user || user.stat != CONSCIOUS || user.loc != src || state_open)
			return
		user.visible_message(SPAN_WARNING("[user] successfully broke out of [src]!"), \
			SPAN_NOTICE("You successfully break out of [src]!"))
		open_machine()

/obj/machinery/abductor/experiment/ui_status(mob/user)
	if(user == occupant)
		return UI_CLOSE
	return ..()

/obj/machinery/abductor/experiment/tgui_state(mob/user)
	return GLOB.physical_state

/obj/machinery/abductor/experiment/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ProbingConsole", name)
		ui.open()

/obj/machinery/abductor/experiment/tgui_data(mob/user)
	var/list/data = list()
	data["open"] = state_open
	data["feedback"] = flash
	data["occupant"] = occupant ? TRUE : FALSE
	data["OccupantName"] = null
	data["OccupantStatus"] = null
	if(occupant)
		var/mob/living/mob_occupant = occupant
		data["OccupantName"] = mob_occupant.name
		data["OccupantStatus"] = mob_occupant.stat
	return data

/obj/machinery/abductor/experiment/tgui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("door")
			if(state_open)
				close_machine()
				return TRUE
			else
				open_machine()
				return TRUE
		if("experiment")
			if(!occupant)
				return
			var/mob/living/mob_occupant = occupant
			if(mob_occupant.stat == DEAD)
				return
			flash = experiment(mob_occupant, params["experiment_type"], usr)
			return TRUE

/**
 * experiment: Performs selected experiment on occupant mob, resulting in a point reward on success
 *
 * Arguments:
 * * occupant The mob inside the machine
 * * type The type of experiment to be performed
 * * user The mob starting the experiment
 */
/obj/machinery/abductor/experiment/proc/experiment(mob/occupant, type, mob/user)
	LAZYINITLIST(history)
	var/mob/living/carbon/human/H = occupant
	var/datum/abductor/user_abductor = user.mind.abductor
	if(!user_abductor)
		return "Authorization failure. Contact mothership immediately."

	var/point_reward = 0
	if(!H)
		return "Invalid or missing specimen."
	if(H in history)
		return "Specimen already in database."
	if(H.stat == DEAD)
		state("Specimen deceased - please provide fresh sample.")
		return "Specimen deceased."
	var/obj/item/organ/internal/heart/gland/GlandTest = locate() in H.internal_organs
	if(!GlandTest)
		state("Experimental dissection not detected!")
		return "No glands detected!"
	if(H.mind != null && H.ckey != null)
		LAZYINITLIST(abductee_minds)
		LAZYADD(history, H)
		LAZYADD(abductee_minds, H.mind)
		state("Processing specimen...")
		sleep(5)
		switch(text2num(type))
			if(1)
				to_chat(H, SPAN_WARNING("You feel violated."))
			if(2)
				to_chat(H, SPAN_WARNING("You feel yourself being sliced apart and put back together."))
			if(3)
				to_chat(H, SPAN_WARNING("You feel intensely watched."))
		sleep(5)
		user_abductor.team.abductees += H.mind
		var/datum/antagonist/abductee/antag = new()
		antag.add_antagonist(H.mind)

		for(var/obj/item/organ/internal/heart/gland/G in H.internal_organs)
			G.Start()
			point_reward++
		if(point_reward > 0)
			open_machine()
			send_back(H)
			playsound(src.loc, 'sound/machines/ding.ogg', 50, TRUE)
			points += point_reward
			credits += point_reward
			return "Experiment successful! [point_reward] new data-points collected."
		else
			playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
			return "Experiment failed! No replacement organ detected."
	else
		state("Brain activity nonexistent - disposing sample...")
		open_machine()
		send_back(H)
		return "Specimen braindead - disposed."

/**
 * send_back: Sends a mob back to a selected teleport location if safe
 *
 * Arguments:
 * * H The human mob to be sent back
 */
/obj/machinery/abductor/experiment/proc/send_back(mob/living/carbon/human/H)
	H.Sleeping(10)
	H.unEquip(H.handcuffed)
	if(console && console.pad && console.pad.teleport_target)
		H.forceMove(console.pad.teleport_target)
		return
	//Area not chosen / It's not safe area - teleport to arrivals
	var/datum/spawnpoint/arrivals/spawnpoint = new()
	H.forceMove(pick(spawnpoint.turfs))
	return

/obj/machinery/abductor/experiment/proc/update_icon_state()
	icon_state = "experiment[state_open ? "-open" : null]"
	update_icon()
