/*
Overview:
   Used to create objects that need a per step proc call.  Default definition of 'New()'
   stores a reference to src machine in global 'machines list'.  Default definition
   of 'Destroy' removes reference to src machine in global 'machines list'.

Class Variables:
   use_power (num)
	  current state of auto power use.
	  Possible Values:
		 0 -- no auto power use
		 1 -- machine is using power at its idle power level
		 2 -- machine is using power at its active power level

   active_power_usage (num)
	  Value for the amount of power to use when in active power mode

   idle_power_usage (num)
	  Value for the amount of power to use when in idle power mode

   power_channel (num)
	  What channel to draw from when drawing power for power mode
	  Possible Values:
		 STATIC_EQUIP:1 -- Equipment Channel
		 STATIC_LIGHT:2 -- Lighting Channel
		 STATIC_ENVIRON:3 -- Environment Channel

   component_parts (list)
	  A list of component parts of machine used by frame based machines.

   panel_open (num)
	  Whether the panel is open

   uid (num)
	  Unique id of machine across all machines.

   gl_uid (global num)
	  Next uid value in sequence

   stat (bitflag)
	  Machine status bit flags.
	  Possible bit flags:
		 BROKEN:1 -- Machine is broken
		 NOPOWER:2 -- No power is being supplied to machine.
		 POWEROFF:4 -- tbd
		 MAINT:8 -- machine is currently under going maintenance.
		 EMPED:16 -- temporary broken by EMP pulse

Class Procs:
   Initialize()					 'game/machinery/machinery.dm'

   Destroy()					 'game/machinery/machinery.dm'

   powered(chan = EQUIP)		 'modules/power/power_usage.dm'
	  Checks to see if area that contains the object has power available for power
	  channel given in 'chan'.

   use_power_oneoff(amount, chan=power_channel)   'modules/power/power_usage.dm'
	  Deducts 'amount' from the power channel 'chan' of the area that contains the object.
	  This is not a continuous draw, but rather will be cleared after one APC update.

   power_change()			   'modules/power/power_usage.dm'
	  Called by the area that contains the object when ever that area under goes a
	  power state change (area runs out of power, or area channel is turned off).

   RefreshParts()			   'game/machinery/machinery.dm'
	  Called to refresh the variables in the machine that are contributed to by parts
	  contained in the component_parts list. (example: glass and material amounts for
	  the autolathe)

	  Default definition does nothing.

   assign_uid()			   'game/machinery/machinery.dm'
	  Called by machine to assign a value to the uid variable.

   Process()				  'game/machinery/machinery.dm'
	  Called by the 'master_controller' once per game tick for each machine that is listed in the 'machines' list.
*/

#define POWER_USE_DELAY 2

/obj/machinery
	name = "machinery"
	icon = 'icons/obj/stationobjs.dmi'
	w_class = ITEM_SIZE_NO_CONTAINER
	pull_sound = SFX_PULL_MACHINE
	layer = BELOW_OBJ_LAYER

	var/stat = 0
	var/emagged = 0
	var/malf_upgraded = 0
	var/use_power = POWER_USE_IDLE
		//0 = dont run the auto
		//1 = run auto, use idle
		//2 = run auto, use active
	var/idle_power_usage = 0 WATTS
	var/active_power_usage = 0 WATTS
	var/power_channel = STATIC_EQUIP //STATIC_EQUIP, STATIC_ENVIRON or STATIC_LIGHT
	/* List of types that should be spawned as component_parts for this machine.
		Structure:
			type -> num_objects

		num_objects is optional, and will be treated as 1 if omitted.

		example:
		component_types = list(
			/obj/foo/bar,
			/obj/baz = 2
		)
	*/
	var/list/component_types
	var/power_init_complete = FALSE // Helps with bookkeeping when initializing atoms. Don't modify.
	var/list/component_parts = null //list of all the parts used to build it, if made from certain kinds of frames.
	var/uid
	var/panel_open = 0
	var/global/gl_uid = 1
	var/interact_offline = 0 // Can the machine be interacted with while de-powered.
	var/clicksound			// sound played on succesful interface use by a carbon lifeform
	var/clickvol = 40		// sound played on succesful interface use
	var/life_tick = 0		// O P T I M I Z A T I O N
	var/beep_last_played = 0
	var/list/beepsounds = null

	var/current_power_usage = 0 WATTS // How much power are we currently using, dont change by hand, change power_usage vars and then use set_power_use
	var/area/current_power_area // What area are we powering currently

	rad_resist_type = /datum/rad_resist/machinery

/datum/rad_resist/machinery
	alpha_particle_resist = 160 MEGA ELECTRONVOLT
	beta_particle_resist = 26.6 MEGA ELECTRONVOLT
	hawking_resist = 1 ELECTRONVOLT

/obj/machinery/Initialize(mapload, d=0, populate_components = TRUE)
	. = ..()
	if(d)
		set_dir(d)

	SSmachines.machinery.Add(src)

	if(populate_components && component_types)
		component_parts = list()
		for(var/type in component_types)
			var/count = component_types[type]
			if(count > 1)
				for(var/i in 1 to count)
					component_parts.Add(new type(src))
			else
				component_parts.Add(new type(src))

		if(length(component_parts))
			RefreshParts()

	if(!mapload)
		power_change()

	START_PROCESSING(SSmachines, src) // It's safe to remove machines from here.

/obj/machinery/Destroy()
	SSmachines.machinery.Remove(src)
	set_power_use(NO_POWER_USE)
	STOP_PROCESSING(SSmachines, src)
	if(component_parts)
		QDEL_NULL_LIST(component_parts)
	component_parts = null
	current_power_area = null
	return ..()


/obj/machinery/proc/play_beep()
	if (isnull(beepsounds))
		return

	if(!stat && world.time > beep_last_played + 60 SECONDS && prob(10))
		beep_last_played = world.time
		playsound(src.loc, pick(beepsounds), 30)

/obj/machinery/Process()
	return PROCESS_KILL // Only process if you need to.

/obj/machinery/emp_act(severity)
	if(use_power && stat == 0)
		use_power_oneoff(7500/severity)

		var/obj/effect/overlay/pulse2 = new /obj/effect/overlay(loc)
		pulse2.icon = 'icons/effects/effects.dmi'
		pulse2.icon_state = "empdisable"
		pulse2.SetName("emp sparks")
		pulse2.anchored = 1
		pulse2.set_dir(pick(GLOB.cardinal))

		spawn(10)
			qdel(pulse2)
	..()

/obj/machinery/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
		if(3.0)
			if (prob(25))
				qdel(src)
				return

/obj/machinery/blob_act()
	if(stat & BROKEN)
		qdel(src)
		return

	if(prob(10))
		set_broken(TRUE)

/obj/machinery/proc/set_broken(new_state)
	if(new_state && !(stat & BROKEN))
		stat |= BROKEN
		. = TRUE
	else if(!new_state && (stat & BROKEN))
		stat &= ~BROKEN
		. = TRUE
	if(.)
		queue_icon_update()

/proc/is_operable(obj/machinery/M, mob/user)
	return istype(M) && M.operable()

/obj/machinery/proc/operable(additional_flags = 0)
	return !inoperable(additional_flags)

/obj/machinery/proc/inoperable(additional_flags = 0)
	return (stat & (POWEROFF|NOPOWER|BROKEN|additional_flags))

/obj/machinery/CanUseTopic(mob/user)
	if(stat & BROKEN)
		return STATUS_CLOSE

	if(!interact_offline && (stat & NOPOWER))
		return STATUS_CLOSE

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.IsAdvancedToolUser(TRUE) == FALSE)
			return STATUS_CLOSE

	return ..()

/obj/machinery/tgui_state(mob/user)
	return GLOB.tgui_machinery_state

/obj/machinery/CouldUseTopic(mob/user)
	..()
	if(user)
		user.set_machine(src)

/obj/machinery/CouldNotUseTopic(mob/user)
	if(user)
		user.unset_machine()

////////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/attack_ai(mob/user)
	if(isrobot(user))
		// For some reason attack_robot doesn't work
		// This is to stop robots from using cameras to remotely control machines.
		if(user.client && user.client.eye == user)
			return src.attack_hand(user)
	else
		return src.attack_hand(user)

/obj/machinery/attack_hand(mob/user)
	if(inoperable(MAINT))
		return TRUE
	if(user.lying || user.stat)
		return TRUE
	if (!(istype(usr, /mob/living/carbon/human) || istype(usr, /mob/living/silicon)))
		to_chat(usr, FEEDBACK_YOU_LACK_DEXTERITY)
		return TRUE
/*
	//distance checks are made by atom/proc/DblClick
	if ((get_dist(src, user) > 1 || !istype(src.loc, /turf)) && !istype(user, /mob/living/silicon))
		return TRUE
*/
	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.IsAdvancedToolUser(TRUE) == FALSE)
			to_chat(user, SPAN("warning", "I'm not smart enough to do that!"))
			return TRUE
		if(H.getBrainLoss() >= 55)
			visible_message(SPAN("warning", "[H] stares cluelessly at \the [src]."))
			return TRUE
		else if(prob(H.getBrainLoss()))
			to_chat(user, SPAN("warning", "You momentarily forget how to use \the [src]."))
			return TRUE

	return ..()

/obj/machinery/proc/RefreshParts() //Placeholder proc for machines that are built using frames.
	return

/obj/machinery/proc/assign_uid()
	uid = gl_uid
	gl_uid++

/obj/machinery/proc/state(msg)
	for(var/mob/O in hearers(src, null))
		O.show_message("\icon[src] <span class = 'notice'>[msg]</span>", 2)

/obj/machinery/proc/ping(text=null)
	if (!text)
		text = "\The [src] pings."

	state(text, "blue")
	playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)

/obj/machinery/proc/shock(mob/user, prb)
	if(inoperable())
		return FALSE
	if(!prob(prb))
		return FALSE
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if(electrocute_mob(user, get_area(src), src, 0.7))
		var/area/temp_area = get_area(src)
		if(temp_area)
			var/obj/machinery/power/apc/temp_apc = temp_area.get_apc()

			if(temp_apc && temp_apc.terminal && temp_apc.terminal.powernet)
				temp_apc.terminal.powernet.trigger_warning()
		if(user.stunned)
			return 1
	return 0

/obj/machinery/proc/default_deconstruction_crowbar(mob/user, obj/item/C)
	if(!isCrowbar(C))
		return 0
	if(!panel_open)
		return 0
	. = dismantle()

/obj/machinery/proc/default_deconstruction_screwdriver(mob/user, obj/item/S, update_appearance = TRUE)
	if(!isScrewdriver(S))
		return 0
	playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
	panel_open = !panel_open
	to_chat(user, SPAN_NOTICE("You [panel_open ? "open" : "close"] the maintenance hatch of \the [src]."))
	if(update_appearance)
		update_icon()
	return 1

/obj/machinery/proc/default_part_replacement(mob/user, obj/item/storage/part_replacer/R)
	if(!istype(R))
		return FALSE

	if(!R.active)
		return FALSE

	if(!component_parts)
		return FALSE

	if(panel_open)
		var/obj/item/circuitboard/CB = locate(/obj/item/circuitboard) in component_parts
		var/P
		for(var/obj/item/stock_parts/A in component_parts)
			for(var/T in CB.req_components)
				if(ispath(A.type, T))
					P = T
					break
			for(var/obj/item/stock_parts/B in R.contents)
				if(istype(B, P) && istype(A, P))
					if(B.rating > A.rating)
						R.remove_from_storage(B, src)
						R.handle_item_insertion(A, 1)
						component_parts.Remove(A)
						component_parts.Add(B)
						B.forceMove(src)
						to_chat(user, SPAN("notice", "[A.name] has been replaced with [B.name]."))
						R.post_usage()
						break
			update_icon()
			RefreshParts()
	else
		to_chat(user, get_parts_infotext())

	return TRUE

/obj/machinery/proc/dismantle()
	playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
	var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(get_turf(src))
	M.set_dir(dir)
	M.state = 1
	M.update_icon()
	for(var/obj/I in component_parts)
		if(!QDELETED(I))
			I.forceMove(get_turf(src))
	LAZYCLEARLIST(component_parts)
	qdel(src)
	return 1

/obj/machinery/InsertedContents()
	return (contents - component_parts)

/datum/proc/apply_visual(mob/M)
	return

/datum/proc/remove_visual(mob/M)
	return

/obj/machinery/proc/malf_upgrade(mob/living/silicon/ai/user)
	return 0

/obj/machinery/tgui_act(action, params)
	. = ..()

	if(.)
		return TRUE

	if(clicksound && istype(usr, /mob/living/carbon))
		playsound(src, clicksound, clickvol)

/obj/machinery/CouldUseTopic(mob/user)
	..()
	if(clicksound && istype(user, /mob/living/carbon))
		playsound(src, clicksound, clickvol)

/obj/machinery/proc/get_parts_infotext()
	. = "<span class='notice'>Following parts detected in the machine:</span>"
	for(var/obj/item/C in component_parts)
		. += "\n<span class='notice'>	[C.name]</span>"

/obj/machinery/examine(mob/user, infix)
	. = ..()

	if(component_parts && hasHUD(user, HUD_SCIENCE))
		. += "[get_parts_infotext()]"

/obj/machinery/proc/update_power_use()
	set_power_use(use_power)

// The main proc that controls power usage of a machine, change use_power only with this proc
/obj/machinery/proc/set_power_use(new_use_power)
	if(current_power_usage && current_power_area) // We are tracking the area that is powering us so we can remove power from the right one if we got moved or something
		current_power_area.removeStaticPower(current_power_usage, power_channel)
		current_power_area = null

	current_power_usage = 0 WATTS
	use_power = new_use_power

	var/area/A = get_area(src)
	if(!A || !anchored || stat & NOPOWER) // Unwrenched machines aren't plugged in, unpowered machines don't use power
		return

	if(use_power == IDLE_POWER_USE && idle_power_usage)
		current_power_area = A
		current_power_usage = idle_power_usage
		current_power_area.addStaticPower(current_power_usage, power_channel)
	else if(use_power == ACTIVE_POWER_USE && active_power_usage)
		current_power_area = A
		current_power_usage = active_power_usage
		current_power_area.addStaticPower(current_power_usage, power_channel)


// Unwrenching = unpluging from a power source
/obj/machinery/wrenched_change()
	update_power_use()
