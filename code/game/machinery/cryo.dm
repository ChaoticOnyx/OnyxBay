#define HEAT_CAPACITY_HUMAN 100 //249840 J/K, for a 72 kg person.

/obj/machinery/atmospherics/unary/cryo_cell
	name = "cryo cell"
	icon = 'icons/obj/cryogenics.dmi' // map only
	icon_state = "pod_preview"
	density = 1
	anchored = 1.0
	interact_offline = 1
	layer = ABOVE_HUMAN_LAYER // this needs to be fairly high so it displays over most things, but it needs to be under lighting

	var/on = 0
	idle_power_usage = 20
	active_power_usage = 200
	clicksound = 'sound/machines/buttonbeep.ogg'
	clickvol = 30

	var/temperature_archived
	var/mob/living/carbon/human/occupant = null
	var/obj/item/weapon/reagent_containers/glass/beaker = null

	var/current_heat_capacity = 50

	var/occupant_icon_update_timer = 0
	var/ejecting = 0
	var/biochemical_stasis = 0

	beepsounds = list(
		'sound/effects/machinery/medical/beep1.ogg',
		'sound/effects/machinery/medical/beep2.ogg',
		'sound/effects/machinery/medical/beep3.ogg',
		'sound/effects/machinery/medical/beep4.ogg',
		'sound/effects/machinery/medical/beep5.ogg',
		'sound/effects/machinery/medical/beep6.ogg'
	)

/obj/machinery/atmospherics/unary/cryo_cell/New()
	..()
	icon = 'icons/obj/cryogenics_split.dmi'
	update_icon()
	initialize_directions = dir

/obj/machinery/atmospherics/unary/cryo_cell/Destroy()
	var/turf/T = loc
	T.contents += contents
	if(beaker)
		beaker.forceMove(get_step(loc, SOUTH)) //Beaker is carefully ejected from the wreckage of the cryotube
		beaker = null
	. = ..()

/obj/machinery/atmospherics/unary/cryo_cell/atmos_init()
	..()
	if(node)
		return
	var/node_connect = dir
	for(var/obj/machinery/atmospherics/target in get_step(src, node_connect))
		if(target.initialize_directions & get_dir(target, src))
			node = target
			break

/obj/machinery/atmospherics/unary/cryo_cell/examine(mob/user)
	. = ..()
	if(user.Adjacent(src))
		if(beaker)
			. += "\nIt is loaded with a beaker."
		if(emagged)
			. += "\nThe panel is loose and the circuitry is charred."

/obj/machinery/atmospherics/unary/cryo_cell/Process()
	if(stat & (BROKEN|NOPOWER))
		update_use_power(0)
		update_icon()
	..()
	if(!node)
		return
	if(!on)
		return

	play_beep()

	if(occupant)
		if(occupant.stat != DEAD)
			if(occupant_icon_update_timer < world.time)
				update_icon()
			process_occupant()

	if(air_contents)
		temperature_archived = air_contents.temperature
		heat_gas_contents()
		if(occupant && iscarbon(occupant) && occupant.stat != DEAD && !occupant.is_asystole() && !occupant.losebreath)
			expel_gas()

	if(abs(temperature_archived-air_contents.temperature) > 1)
		network.update = 1

	return 1

/obj/machinery/atmospherics/unary/cryo_cell/relaymove(mob/user) // note that relaymove will also be called for mobs outside the cell with UI open
	if(occupant == user && !user.stat)
		go_out()

/obj/machinery/atmospherics/unary/cryo_cell/attack_hand(mob/user)
	ui_interact(user)
	return 1

 /**
  * The ui_interact proc is used to open and update Nano UIs
  * If ui_interact is not used then the UI will not update correctly
  * ui_interact is currently defined for /atom/movable (which is inherited by /obj and /mob)
  *
  * @param user /mob The mob who is interacting with this ui
  * @param ui_key string A string key to use for this ui. Allows for multiple unique uis on one obj/mob (defaut value "main")
  * @param ui /datum/nanoui This parameter is passed by the nanoui process() proc when updating an open ui
  *
  * @return nothing
  */
/obj/machinery/atmospherics/unary/cryo_cell/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	if(user == occupant || user.stat)
		return

	// this is the data which will be sent to the ui
	var/data[0]
	data["isOperating"] = on
	data["hasOccupant"] = occupant ? 1 : 0
	data["notFunctional"] = 0
	if(stat & (BROKEN|NOPOWER))
		data["notFunctional"] = 1
	if(occupant)
		var/cloneloss = "none"
		var/amount = occupant.getCloneLoss()
		if(amount > 50)
			cloneloss = "severe"
		else if(amount > 25)
			cloneloss = "significant"
		else if(amount > 10)
			cloneloss = "moderate"
		else if(amount && !emagged)
			cloneloss = "minor"
		var/scan = medical_scan_results(occupant)
		scan += "<br>Genetic degradation: [cloneloss]"
		scan = replacetext(scan,"'notice'","'white'")
		scan = replacetext(scan,"'warning'","'average'")
		scan = replacetext(scan,"'danger'","'bad'")
		if (occupant.bodytemperature >= 170)
			scan += "<br><span class='average'>Warning: Patient's body temperature is not suitable.</span>"
		scan += "<br>Cryostasis factor: [occupant.stasis_value]x"
		data["occupant"] = scan

	data["cellTemperature"] = round(air_contents.temperature)
	data["cellTemperatureStatus"] = "good"
	if(air_contents.temperature > T0C) // if greater than 273.15 kelvin (0 celcius)
		data["cellTemperatureStatus"] = "bad"
	else if(air_contents.temperature > 170)
		data["cellTemperatureStatus"] = "average"

	data["isBeakerLoaded"] = beaker ? 1 : 0

	data["beakerLabel"] = null
	data["beakerVolume"] = 0
	if(beaker)
		data["beakerLabel"] = beaker.name
		data["beakerVolume"] = beaker.reagents.total_volume

	data["biochemicalStasis"] = biochemical_stasis

	// update the ui if it exists, returns null if no ui is passed/found
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		// the ui does not exist, so we'll create a new() one
		// for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "cryo.tmpl", "Cryo Cell Control System", 520, 630)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/machinery/atmospherics/unary/cryo_cell/OnTopic(user, href_list)
	if(user == occupant)
		return STATUS_CLOSE

	if(href_list["switchOn"])
		on = 1
		update_icon()
		return TOPIC_REFRESH

	if(href_list["switchOff"])
		on = 0
		update_icon()
		return TOPIC_REFRESH

	if(href_list["ejectBeaker"])
		if(beaker)
			beaker.forceMove(get_step(loc, SOUTH))
			beaker = null
		return TOPIC_REFRESH

	if(href_list["ejectOccupant"])
		if(!occupant || isslime(user) || ispAI(user))
			return TOPIC_HANDLED // don't update UIs attached to this object
		go_out()
		return TOPIC_REFRESH

	if(href_list["biochemicalStasisOn"])
		biochemical_stasis = 1
		update_icon()
		return TOPIC_REFRESH

	if(href_list["biochemicalStasisOff"])
		biochemical_stasis = 0
		update_icon()
		return TOPIC_REFRESH

	. = ..()

/obj/machinery/atmospherics/unary/cryo_cell/attackby(obj/G, mob/user as mob)
	if(istype(G, /obj/item/weapon/reagent_containers/glass))
		if(beaker)
			to_chat(user, SPAN("warning", "A beaker is already loaded into the machine."))
			return

		beaker =  G
		user.drop_item()
		G.forceMove(src)
		user.visible_message("[user] adds \a [G] to \the [src]!", "You add \a [G] to \the [src]!")
	else if(istype(G, /obj/item/grab))
		if(!ismob(G:affecting))
			return
		for(var/mob/living/carbon/slime/M in range(1, G:affecting))
			if(M.Victim == G:affecting)
				to_chat(usr, "[G:affecting:name] will not fit into the cryo because they have a slime latched onto their head.")
				return
		user.visible_message(SPAN("notice", "\The [user] begins placing \the [G:affecting] into \the [src]."), SPAN("notice", "You start placing \the [G:affecting] into \the [src]."))
		if(!do_after(user, 30, src))
			return
		if(!ismob(G:affecting))
			return
		var/mob/M = G:affecting
		if(put_mob(M))
			qdel(G)
			user.visible_message(SPAN("notice", "\The [user] places \the [M] into \the [src]."), SPAN("notice", "You place \the [M] into \the [src]."))
	return

/obj/machinery/atmospherics/unary/cryo_cell/update_icon()
	overlays.Cut()
	var/overlays_state = 0
	if(stat & (BROKEN|NOPOWER))
		overlays_state = 0
	else
		overlays_state = !on ? 0 : biochemical_stasis ? 2 : 1

	icon_state = "pod[overlays_state]"
	var/image/I
	I = image(icon, "pod[overlays_state]_top")

	I.pixel_z = 32
	overlays += I

	if(occupant)
		occupant.UpdateDamageIcon()
		var/image/pickle = image(occupant.icon, occupant.icon_state)
		pickle.overlays = occupant.overlays
		pickle.pixel_z = 18
		overlays += pickle
		occupant_icon_update_timer = world.time + 30

	I = image(icon, "lid[overlays_state]")
	overlays += I

	I = image(icon, "lid[overlays_state]_top")
	I.pixel_z = 32
	overlays += I

/obj/machinery/atmospherics/unary/cryo_cell/proc/process_occupant()
	if(air_contents.total_moles < 10)
		return
	if(occupant)
		if(occupant.stat == DEAD)
			return

		// Just empty a cryo if occupant isn't here
		if(!(occupant in src))
			go_out(force_move=FALSE)
			return

		occupant.set_stat(UNCONSCIOUS)
		var/has_cryo_medicine = occupant.reagents.has_any_reagent(list(/datum/reagent/cryoxadone, /datum/reagent/clonexadone)) >= REM
		if(beaker && !has_cryo_medicine && !emagged)
			beaker.reagents.trans_to_mob(occupant, REM, CHEM_BLOOD)
		if(occupant.InStasis() && !biochemical_stasis)
			occupant.handle_chemicals_in_body(handle_ingested = FALSE)
		if(emagged)
			if(prob(5))
				to_chat(occupant, "<span class='notice'>You feel strange.</span>")
			else if(prob(3))
				to_chat(occupant, "<span class='notice'>Your skin is itching.</span>")

			if(beaker)
				if (beaker.reagents.has_reagent(/datum/reagent/cryoxadone))
					occupant.adjustCloneLoss(0.6)
					beaker.reagents.remove_reagent(/datum/reagent/cryoxadone,REM)
					occupant.add_chemical_effect(CE_CRYO, 1)
				else if (beaker.reagents.has_reagent(/datum/reagent/clonexadone))
					occupant.adjustCloneLoss(1)
					beaker.reagents.remove_reagent(/datum/reagent/clonexadone,REM)
					occupant.add_chemical_effect(CE_CRYO, 1)
				else
					occupant.adjustCloneLoss(0.3)
			else
				occupant.adjustCloneLoss(0.3)


/obj/machinery/atmospherics/unary/cryo_cell/proc/heat_gas_contents()
	if(air_contents.total_moles < 1)
		return
	var/air_heat_capacity = air_contents.heat_capacity()
	var/combined_heat_capacity = current_heat_capacity + air_heat_capacity
	if(combined_heat_capacity > 0)
		var/combined_energy = T20C*current_heat_capacity + air_heat_capacity*air_contents.temperature
		air_contents.temperature = combined_energy/combined_heat_capacity

/obj/machinery/atmospherics/unary/cryo_cell/proc/expel_gas()
	if(air_contents.total_moles < 1)
		return
	air_contents.remove(air_contents.total_moles/50)

/obj/machinery/atmospherics/unary/cryo_cell/proc/go_out(force_move=TRUE)
	if(!occupant)
		return
	//for(var/obj/O in src)
	//	O.loc = loc
	if(occupant.client)
		occupant.client.eye = occupant.client.mob
		occupant.client.perspective = MOB_PERSPECTIVE

	if(force_move)
		occupant.forceMove(get_step(loc, SOUTH))	//this doesn't account for walls or anything, but i don't forsee that being a problem.

	if(occupant.bodytemperature < 261 && occupant.bodytemperature >= 70) //Patch by Aranclanos to stop people from taking burn damage after being ejected
		occupant.bodytemperature = 261									  // Changed to 70 from 140 by Zuhayr due to reoccurance of bug.
	occupant = null
	current_heat_capacity = initial(current_heat_capacity)
	update_use_power(POWER_USE_IDLE)
	update_icon()
	return
/obj/machinery/atmospherics/unary/cryo_cell/proc/put_mob(mob/living/carbon/M as mob)
	if (stat & (NOPOWER|BROKEN))
		to_chat(usr, "<span class='warning'>The cryo cell is not functioning.</span>")
		return
	if (!istype(M))
		to_chat(usr, "<span class='danger'>The cryo cell cannot handle such a lifeform!</span>")
		return
	if (occupant)
		to_chat(usr, "<span class='danger'>The cryo cell is already occupied!</span>")
		return
	if (M.abiotic())
		to_chat(usr, "<span class='warning'>Subject may not have abiotic items on.</span>")
		return
	if(!node)
		to_chat(usr, "<span class='warning'>The cell is not correctly connected to its pipe network!</span>")
		return
	if (M.client)
		M.client.perspective = EYE_PERSPECTIVE
		M.client.eye = src
	M.stop_pulling()
	M.forceMove(src)
	M.ExtinguishMob()
	if(M.stat != DEAD)
		to_chat(M, "<span class='notice'><b>You feel a cold liquid surround you. Your skin starts to freeze up.</b></span>")
	occupant = M
	current_heat_capacity = HEAT_CAPACITY_HUMAN
	update_use_power(POWER_USE_ACTIVE)

	for(var/obj/item/clothing/mask/smokable/cig in M.contents)
		cig.die(nomessage = TRUE, nodestroy = TRUE)

	add_fingerprint(usr)
	occupant.update_icon()
	update_icon()
	return 1

/obj/machinery/atmospherics/unary/cryo_cell/proc/check_compatibility(mob/target, mob/user)
	if(!CanMouseDrop(target, user))
		return 0
	if (!istype(target))
		return 0
	if (target.buckled)
		to_chat(user, "<span class='warning'>Unbuckle the subject before attempting to move them.</span>")
		return 0
	return 1

	//Like grab-putting, but for mouse-dropping.
/obj/machinery/atmospherics/unary/cryo_cell/MouseDrop_T(mob/target, mob/user)
	if(!check_compatibility(target, user))
		return
	user.visible_message("<span class='notice'>\The [user] begins placing \the [target] into \the [src].</span>", "<span class='notice'>You start placing \the [target] into \the [src].</span>")
	if(!do_after(user, 30, src))
		return
	if(!check_compatibility(target, user))
		return
	put_mob(target)


/obj/machinery/atmospherics/unary/cryo_cell/verb/move_eject()
	set name = "Eject occupant"
	set category = "Object"
	set src in oview(1)
	if(usr == occupant)//If the user is inside the tube...
		if(usr.stat == 2 || ejecting)//and he's not dead or not trying already....
			return
		to_chat(usr, "<span class='notice'>Release sequence activated. This will take two minutes.</span>")
		ejecting = 1
		if(do_after(occupant, 1200, src, needhand = 0, incapacitation_flags = 0) && (src || usr || occupant || (occupant == usr))) //Check if someone's released/replaced/bombed him already
			ejecting = 0
			go_out()//and release him from the eternal prison.
		ejecting = 0
	else
		if(usr.stat != 0)
			return
		go_out()
	add_fingerprint(usr)
	return

/obj/machinery/atmospherics/unary/cryo_cell/verb/move_inside()
	set name = "Move Inside"
	set category = "Object"
	set src in oview(1)
	for(var/mob/living/carbon/slime/M in range(1,usr))
		if(M.Victim == usr)
			to_chat(usr, "You're too busy getting your life sucked out of you.")
			return
	if (usr.stat != 0)
		return
	put_mob(usr)
	return

/obj/machinery/atmospherics/unary/cryo_cell/return_air()
	if(on)
		return air_contents
	..()

//This proc literally only exists for cryo cells.
/atom/proc/return_air_for_internal_lifeform()
	return return_air()

/obj/machinery/atmospherics/unary/cryo_cell/return_air_for_internal_lifeform()
	//assume that the cryo cell has some kind of breath mask or something that
	//draws from the cryo tube's environment, instead of the cold internal air.
	if(loc)
		return loc.return_air()
	else
		return null

/datum/data/function/proc/reset()
	return

/datum/data/function/proc/r_input(href, href_list, mob/user as mob)
	return

/datum/data/function/proc/display()
	return

/obj/machinery/atmospherics/unary/cryo_cell/emag_act(remaining_charges, mob/user)
	if(emagged)
		return
	playsound(src.loc, 'sound/effects/computer_emag.ogg', 25)
	emagged = 1
	to_chat(user, "<span class='danger'>You short out \the [src]'s circuits.</span>")
	var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
	spark_system.set_up(5, 0, src.loc)
	spark_system.start()
	return 1
