// Pretty much everything here is stolen from the dna scanner FYI


/obj/machinery/bodyscanner
	var/mob/living/carbon/human/occupant
	var/locked
	name = "Body Scanner"
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "body_scanner_0"
	density = 1
	anchored = 1

	idle_power_usage = 60
	active_power_usage = 10000	//10 kW. It's a big all-body scanner.

/obj/machinery/bodyscanner/relaymove(mob/user as mob)
	if (user.stat)
		return
	src.go_out()
	return

/obj/machinery/bodyscanner/examine(mob/user)
	. = ..()
	if (user.Adjacent(src))
		if(occupant)
			. += "\n[occupant.examine(user)]"

/obj/machinery/bodyscanner/verb/eject()
	set src in oview(1)
	set category = "Object"
	set name = "Eject Body Scanner"

	if (usr.stat != 0)
		return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/bodyscanner/verb/move_inside()
	set src in oview(1)
	set category = "Object"
	set name = "Enter Body Scanner"

	if (usr.stat != 0)
		return
	if (src.occupant)
		to_chat(usr, "<span class='warning'>The scanner is already occupied!</span>")
		return
	if (usr.abiotic())
		to_chat(usr, "<span class='warning'>The subject cannot have abiotic items on.</span>")
		return
	usr.pulling = null
	usr.client.perspective = EYE_PERSPECTIVE
	usr.client.eye = src
	usr.forceMove(src)
	src.occupant = usr
	update_use_power(POWER_USE_ACTIVE)
	src.icon_state = "body_scanner_1"
	for(var/obj/O in src)
		//O = null
		qdel(O)
		//Foreach goto(124)
	src.add_fingerprint(usr)
	return

/obj/machinery/bodyscanner/proc/go_out()
	if ((!( src.occupant ) || src.locked))
		return
	for(var/obj/O in src)
		O.dropInto(loc)
		//Foreach goto(30)
	if (src.occupant.client)
		src.occupant.client.eye = src.occupant.client.mob
		src.occupant.client.perspective = MOB_PERSPECTIVE
	if (src.occupant in src)
		src.occupant.dropInto(loc)
	src.occupant = null
	update_use_power(POWER_USE_IDLE)
	src.icon_state = "body_scanner_0"
	return

/obj/machinery/bodyscanner/attackby(obj/item/grab/normal/G, mob/user as mob)
	if(!istype(G))
		return ..()

	var/mob/M = G.affecting
	if(!check_compatibility(M, user))
		return
	user.visible_message("<span class='notice'>\The [user] begins placing \the [M] into \the [src].</span>", "<span class='notice'>You start placing \the [M] into \the [src].</span>")
	if(do_after(user, 20, src))
		if(!check_compatibility(M, user))
			return
		M.forceMove(src)
		src.occupant = M
		update_use_power(POWER_USE_ACTIVE)
		src.icon_state = "body_scanner_1"
		for(var/obj/O in src)
			O.forceMove(loc)
		src.add_fingerprint(user)
		qdel(G)
	else
		return

/obj/machinery/bodyscanner/proc/check_compatibility(mob/target, mob/user)
	if(!istype(user) || !istype(target))
		return FALSE

	if (!(occupant in src))
		go_out()

	if(!CanMouseDrop(target, user))
		return FALSE
	if(occupant)
		to_chat(user, "<span class='warning'>The scanner is already occupied!</span>")
		return FALSE
	if(target.abiotic())
		to_chat(user, "<span class='warning'>The subject cannot have abiotic items on.</span>")
		return FALSE
	if(target.buckled)
		to_chat(user, "<span class='warning'>Unbuckle the subject before attempting to move them.</span>")
		return FALSE
	for(var/mob/living/carbon/slime/M in range(1,target))
		if(M.Victim == target)
			to_chat(user, "[target.name] will not fit into the sleeper because they have a slime latched onto their head.")
			return FALSE
	return TRUE

/obj/machinery/bodyscanner/MouseDrop_T(mob/target, mob/user)
	if(!check_compatibility(target, user))
		return
	user.visible_message("<span class='notice'>\The [user] begins placing \the [target] into \the [src].</span>", "<span class='notice'>You start placing \the [target] into \the [src].</span>")
	if(!do_after(user, 20, src))
		return

	if(!check_compatibility(target, user))
		return

	var/mob/M = target
	M.forceMove(src)
	src.occupant = M
	update_use_power(POWER_USE_ACTIVE)
	src.icon_state = "body_scanner_1"
	for(var/obj/O in src)
		O.forceMove(loc)
	src.add_fingerprint(user)

/obj/machinery/bodyscanner/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.dropInto(loc)
				ex_act(severity)
				//Foreach goto(35)
			//SN src = null
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.dropInto(loc)
					ex_act(severity)
					//Foreach goto(108)
				//SN src = null
				qdel(src)
				return
		if(3.0)
			if (prob(25))
				for(var/atom/movable/A as mob|obj in src)
					A.dropInto(loc)
					ex_act(severity)
					//Foreach goto(181)
				//SN src = null
				qdel(src)
				return
		else
	return

/obj/machinery/body_scanconsole/ex_act(severity)

	switch(severity)
		if(1.0)
			//SN src = null
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				//SN src = null
				qdel(src)
				return
		else
	return

/obj/machinery/body_scanconsole/update_icon()
	if(stat & BROKEN)
		icon_state = "body_scannerconsole-p"
	else if (stat & NOPOWER)
		spawn(rand(0, 15))
			src.icon_state = "body_scannerconsole-p"
	else
		icon_state = initial(icon_state)

/obj/machinery/body_scanconsole
	var/obj/machinery/bodyscanner/connected
	var/delete
	var/temphtml
	name = "Body Scanner Console"
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "body_scannerconsole"
	density = 0
	anchored = 1

	// UI variables
	var/hide_status = FALSE
	var/hide_organs = FALSE

/obj/machinery/body_scanconsole/Initialize()
	for(var/D in GLOB.cardinal)
		src.connected = locate(/obj/machinery/bodyscanner, get_step(src, D))
		if(src.connected)
			break
	return ..()

/*

/obj/machinery/body_scanconsole/process() //not really used right now
	if(stat & (NOPOWER|BROKEN))
		return
	//use_power(250) // power stuff

//	var/mob/M //occupant
//	if (!( src.status )) //remove this
//		return
//	if ((src.connected && src.connected.occupant)) //connected & occupant ok
//		M = src.connected.occupant
//	else
//		if (istype(M, /mob))
//		//do stuff
//		else
///			src.temphtml = "Process terminated due to lack of occupant in scanning chamber."
//			src.status = null
//	src.updateDialog()
//	return

*/

/obj/machinery/body_scanconsole/attack_ai(user as mob)
	return src.attack_hand(user)

/obj/machinery/body_scanconsole/ui_act(action, params)
	if(..())
		return TRUE

	if(!src.allowed(usr))
		return TRUE

	switch (action)
		if ("print")
			if (!src.connected)
				to_chat(usr, "\icon[src]<span class='warning'>Error: No body scanner connected.</span>")
				return TRUE

			var/mob/living/carbon/human/occupant = src.connected.occupant
			if (!src.connected.occupant)
				to_chat(usr, "\icon[src]<span class='warning'>The body scanner is empty.</span>")
				return TRUE

			if (!istype(occupant,/mob/living/carbon/human))
				to_chat(usr, "\icon[src]<span class='warning'>The body scanner cannot scan that lifeform.</span>")
				return TRUE

			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper/(loc)
			P.set_content("<tt>[connected.occupant.get_medical_data()]</tt>", "Body scan report - [occupant]", TRUE)
			return TRUE
		if ("eject")
			if (connected)
				connected.eject()
				return TRUE
		if ("toggle_status")
			hide_status = !hide_status
			return TRUE
		if ("toggle_organs")
			hide_organs = !hide_organs
			return TRUE

/obj/machinery/body_scanconsole/ui_data(mob/user)
	var/list/data = list()

	data["connected"] = connected
	data["medical_data"] = null
	data["hide_status"] = hide_status
	data["hide_organs"] = hide_organs

	if (connected && connected.occupant)
		data["medical_data"] = connected.occupant.get_medical_data_ui()

	return data

/obj/machinery/body_scanconsole/tg_ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "body_scanner", name , 500, 700, master_ui, state)
		ui.open()

/obj/machinery/body_scanconsole/attack_hand(mob/user)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return
	if(!connected || (connected.stat & (NOPOWER|BROKEN)))
		to_chat(user, "<span class='warning'>This console is not connected to a functioning body scanner.</span>")
		return
	if (!(connected.occupant in connected))
		connected.go_out()
	if(!ishuman(connected.occupant))
		to_chat(user, "<span class='warning'>This device can only scan compatible lifeforms.</span>")
		return

	tg_ui_interact(user)

/proc/get_severity(amount)
	if(!amount)
		return "none"
	. = "minor"
	if(amount > 50)
		. = "severe"
	else if(amount > 25)
		. = "significant"
	else if(amount > 10)
		. = "moderate"

/mob/living/carbon/human/proc/get_medical_data_ui()
	var/list/data = list()
	var/mob/living/carbon/human/H = src

	data["object"] = H.name
	data["scan_date"] = stationtime2text()
	data["brain_activity"] = null
	data["pulse"] = null

	if(H.should_have_organ(BP_BRAIN))
		var/obj/item/organ/internal/brain/brain = H.internal_organs_by_name[BP_BRAIN]
		if (!brain || H.stat == DEAD || (H.status_flags & FAKEDEATH))
			data["brain_activity"] = 0
		else if (H.stat != DEAD)
			if (!brain.damage)
				data["brain_activity"] = 1
			else
				data["brain_activity"] = 1 - (brain.damage / brain.max_damage)
	else
		data["brain_activity"] = null

	if(H.should_have_organ(BP_HEART))
		if(H.status_flags & FAKEDEATH)
			data["pulse"] = 0
		else
			data["pulse"] = H.get_pulse(1)
	else
		data["pulse"] = null

	data["blood_volume"] = H.get_blood_volume()
	data["blood_volume_abs"] = H.vessel.get_reagent_amount(/datum/reagent/blood)
	data["blood_volume_max"] = H.species.blood_volume

	data["blood_type"] = null

	if(H.b_type)
		data["blood_type"] = H.b_type

	data["blood_pressure"] = H.get_blood_pressure()
	data["blood_oxygenation"] = H.get_blood_oxygenation()
	data["warnings"] = list()

	if (H.chem_effects[CE_BLOCKAGE])
		data["warnings"] += list("Warning: Blood clotting detected, blood transfusion recommended.")

	data["body_temperature_c"] = H.bodytemperature - T0C
	data["body_temperature_f"] = H.bodytemperature*1.8-459.67

	if(H.nutrition < 150)
		data["warnings"] += list("Warning: Very low nutrition value detected")

	data["brute_severity"] = capitalize(get_severity(H.getBruteLoss()))
	data["burn_severity"] = capitalize(get_severity(H.getFireLoss()))
	data["tox_severity"] = capitalize(get_severity(H.getToxLoss()))
	data["oxy_severity"] = capitalize(get_severity(H.getOxyLoss()))
	data["rad_severity"] = capitalize(get_severity(H.radiation/5))
	data["clone_severity"] = capitalize(get_severity(H.getCloneLoss()))

	if (H.paralysis)
		data["warnings"] += list("Paralysis Summary: approx. [H.paralysis/4] seconds left")

	data["immunity"] = H.virus_immunity()

	if (H.virus2.len)
		var/stage = 1
		for(var/ID in H.virus2)
			var/datum/disease2/disease/D = H.virus2[ID]
			if(D.stage > stage)
				stage = D.stage
		data["warnings"] += list("Viral pathogen on stage [stage] of its life cycle detected in blood stream.")

		if(H.antibodies.len)
			data["warnings"] += list("Antibodies detected: [antigens2string(H.antibodies)]")

	if(H.has_brain_worms())
		data["warnings"] += list("Large growth detected in frontal lobe, possibly cancerous. Surgical removal is recommended.")

	var/is_overdosed = 0
	if(H.reagents.total_volume)
		var/reagentdata[0]
		for(var/A in H.reagents.reagent_list)
			var/datum/reagent/R = A
			if(R.scannable)
				reagentdata[R.type] = "[round(H.reagents.get_reagent_amount(R.type), 1)]u [R.name]"
				if (R.volume >= R.overdose)
					is_overdosed = 1
		if(reagentdata.len)
			var/msg = "Beneficial reagents detected in subject's blood:"
			for(var/d in reagentdata)
				msg += reagentdata[d]

			data["warnings"] += list(msg)

	if (is_overdosed)
		data["warnings"] += list("Warning: Medicine overdose detected.")

	if (H.chem_effects[CE_ALCOHOL])
		data["warnings"] += list("Alcohol byproducts detected in subject's blood.")

	if (H.chem_effects[CE_ALCOHOL_TOXIC])
		data["warnings"] += list("Warning: Subject suffering from alcohol intoxication.")

	data["external_organs"] = list()

	for (var/obj/item/organ/external/E in H.organs)
		var/organ_data = list(
			"name" = capitalize(E.name), "status" = list(), "damage" = list()
			)

		if (E.is_stump())
			organ_data["status"] = list("Missing")
		else
			if (E.brute_dam)
				organ_data["damage"] += list("[capitalize(get_wound_severity(E.brute_ratio, (E.limb_flags & ORGAN_FLAG_HEALS_OVERKILL)))] physical trauma")

			if (E.burn_dam)
				organ_data["damage"] += list("[capitalize(get_wound_severity(E.burn_ratio, (E.limb_flags & ORGAN_FLAG_HEALS_OVERKILL)))] burns")

			if (E.brute_dam + E.burn_dam == 0)
				organ_data["damage"] += list("None")

			organ_data["status"] += list("[english_list(E.get_scan_results(), nothing_text = "", and_text = ", ")]")

		data["external_organs"] += list(organ_data)

	data["internal_organs"] = list()

	for (var/obj/item/organ/internal/I in H.internal_organs)
		var/organ_data = list(
			"name" = capitalize(I.name), "status" = list(), "damage" = list()
		)

		if (I.is_broken())
			organ_data["damage"] += list("Severe")
		else if (I.is_bruised())
			organ_data["damage"] += list("Moderate")
		else if (I.is_damaged())
			organ_data["damage"] += list("Minor")
		else
			organ_data["damage"] += list("None")

		organ_data["status"] += list("[english_list(I.get_scan_results(), nothing_text = "", and_text = ", ")]")
		data["internal_organs"] += list(organ_data)

	for (var/organ_name in H.species.has_organ)
		if(!locate(H.species.has_organ[organ_name]) in H.internal_organs)
			data["warnings"] += list("No [organ_name] detected.")

	if (H.sdisabilities & BLIND)
		data["warnings"] += list("Cataracts detected.")
	if (H.sdisabilities & NEARSIGHTED)
		data["warnings"] += list("Retinal misalignment detected.")

	return data

/mob/living/carbon/human/proc/get_medical_data()
	var/mob/living/carbon/human/H = src
	var/dat = list("<meta charset=\"utf-8\">")
	dat +="<b>SCAN RESULTS FOR: [H]</b>"
	dat +="Scan performed at [stationtime2text()]<br>"

	var/brain_result = "normal"
	if(H.should_have_organ(BP_BRAIN))
		var/obj/item/organ/internal/brain/brain = H.internal_organs_by_name[BP_BRAIN]
		if(!brain || H.stat == DEAD || (H.status_flags & FAKEDEATH))
			brain_result = "<span class='danger'>none, patient is braindead</span>"
		else if(H.stat != DEAD)
			brain_result = "[round(max(0,(1 - brain.damage/brain.max_damage)*100))]%"
	else
		brain_result = "<span class='danger'>ERROR - Nonstandard biology</span>"
	dat += "<b>Brain activity:</b> [brain_result]"

	var/pulse_result = "normal"
	if(H.should_have_organ(BP_HEART))
		if(H.status_flags & FAKEDEATH)
			pulse_result = 0
		else
			pulse_result = H.get_pulse(1)
	else
		pulse_result = "ERROR - Nonstandard biology"
	dat += "<b>Pulse rate:</b> [pulse_result]bpm."

	// Blood pressure. Based on the idea of a normal blood pressure being 120 over 80.
	if(H.get_blood_volume() <= 70)
		dat += "<span class='danger'>Severe blood loss detected.</span>"
	if(H.b_type)
		dat += "<b>Blood type:</b> [H.b_type]"
	dat += "<b>Blood pressure:</b> [H.get_blood_pressure()] ([H.get_blood_oxygenation()]% blood oxygenation)"
	dat += "<b>Blood volume:</b> [H.vessel.get_reagent_amount(/datum/reagent/blood)]/[H.species.blood_volume]u"
	if (H.chem_effects[CE_BLOCKAGE])
		dat += "<span class='warning'>Warning: Blood clotting detected, blood transfusion recommended.</span>"
	// Body temperature.
	dat += "<b>Body temperature:</b> [H.bodytemperature-T0C]&deg;C ([H.bodytemperature*1.8-459.67]&deg;F)"
	if(H.nutrition < 150)
		dat += "<span class='warning'>Warning: Very low nutrition value detected.</span>"

	dat += "<b>Physical Trauma:</b>\t[get_severity(H.getBruteLoss())]"
	dat += "<b>Burn Severity:</b>\t[get_severity(H.getFireLoss())]"
	dat += "<b>Systematic Organ Failure:</b>\t[get_severity(H.getToxLoss())]"
	dat += "<b>Oxygen Deprivation:</b>\t[get_severity(H.getOxyLoss())]"

	dat += "<b>Radiation Level:</b>\t[get_severity(H.radiation/5)]"
	dat += "<b>Genetic Tissue Damage:</b>\t[get_severity(H.getCloneLoss())]"
	if(H.paralysis)
		dat += "Paralysis Summary: approx. [H.paralysis/4] seconds left"

	dat += "Antibody levels and immune system perfomance are at [round(H.virus_immunity()*100)]% of baseline."
	if (H.virus2.len)
		var/stage = 1
		for(var/ID in H.virus2)
			var/datum/disease2/disease/D = H.virus2[ID]
			if(D.stage > stage)
				stage = D.stage
		dat += "<font color='red'>Viral pathogen on stage [stage] of its life cycle detected in blood stream.</font>"
		if(H.antibodies.len)
			dat += "Antibodies detected: [antigens2string(H.antibodies)]"

	if(H.has_brain_worms())
		dat += "Large growth detected in frontal lobe, possibly cancerous. Surgical removal is recommended."
	var/is_overdosed = 0
	if(H.reagents.total_volume)
		var/reagentdata[0]
		for(var/A in H.reagents.reagent_list)
			var/datum/reagent/R = A
			if(R.scannable)
				reagentdata[R.type] = "[round(H.reagents.get_reagent_amount(R.type), 1)]u [R.name]"
				if (R.volume >= R.overdose)
					is_overdosed = 1
		if(reagentdata.len)
			dat += "Beneficial reagents detected in subject's blood:"
			for(var/d in reagentdata)
				dat += reagentdata[d]
	if (is_overdosed)
		dat += "<span class='warning'>Warning: Medicine overdose detected.</span>"
	if (H.chem_effects[CE_ALCOHOL])
		dat += "<span class='notice'>Alcohol byproducts detected in subject's blood.</span>"
	if (H.chem_effects[CE_ALCOHOL_TOXIC])
		dat += "<span class='warning'>Warning: Subject suffering from alcohol intoxication.</span>"

	var/list/table = list()
	table += "<table border='1'><tr><th>Organ</th><th>Damage</th><th>Status</th></tr>"
	for(var/obj/item/organ/external/E in H.organs)
		table += "<tr><td>[E.name]</td>"
		if(E.is_stump())
			table += "<td>N/A</td><td>Missing</td>"
		else
			table += "<td>"
			if(E.brute_dam)
				table += "[capitalize(get_wound_severity(E.brute_ratio, (E.limb_flags & ORGAN_FLAG_HEALS_OVERKILL)))] physical trauma"
			if(E.burn_dam)
				table += " [capitalize(get_wound_severity(E.burn_ratio, (E.limb_flags & ORGAN_FLAG_HEALS_OVERKILL)))] burns"
			if(E.brute_dam + E.burn_dam == 0)
				table += "None"
			table += "</td><td>[english_list(E.get_scan_results(), nothing_text = "", and_text = ", ")]</td></tr>"

	table += "<tr><td>---</td><td><b>INTERNAL ORGANS</b></td><td>---</td></tr>"
	for(var/obj/item/organ/internal/I in H.internal_organs)
		table += "<tr><td>[I.name]</td>"
		table += "<td>"
		if(I.is_broken())
			table += "Severe"
		else if(I.is_bruised())
			table += "Moderate"
		else if(I.is_damaged())
			table += "Minor"
		else
			table += "None"
		table += "</td><td>[english_list(I.get_scan_results(), nothing_text = "", and_text = ", ")]</td></tr>"
	table += "</table>"
	dat += jointext(table,null)
	table.Cut()
	for(var/organ_name in H.species.has_organ)
		if(!locate(H.species.has_organ[organ_name]) in H.internal_organs)
			dat += text("No [organ_name] detected.")

	if(H.sdisabilities & BLIND)
		dat += text("Cataracts detected.")
	if(H.sdisabilities & NEARSIGHTED)
		dat += text("Retinal misalignment detected.")

	. = jointext(dat,"<br>")
