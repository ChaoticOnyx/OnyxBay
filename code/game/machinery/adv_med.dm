// Pretty much everything here is stolen from the dna scanner FYI


/obj/machinery/bodyscanner
	var/mob/living/carbon/human/occupant
	var/locked
	var/obj/machinery/body_scanconsole/BSC
	name = "Body Scanner"
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "body_scanner_0"
	density = 1
	anchored = 1

	component_types = list(
		/obj/item/circuitboard/body_scanner,
		/obj/item/device/healthanalyzer,
		/obj/item/stock_parts/scanning_module = 3,
		/obj/item/stock_parts/manipulator = 4,
	)

	idle_power_usage = 60 WATTS
	active_power_usage = 10 KILO WATTS // It's a big all-body scanner.

/obj/machinery/bodyscanner/Destroy()
	go_out()
	if(BSC)
		BSC.connected = null
		BSC = null
	return ..()

/obj/machinery/bodyscanner/Initialize()
	. = ..()
	for(var/D in GLOB.cardinal)
		var/obj/machinery/body_scanconsole/console = locate() in get_step(src, D)
		if(!console || console?.connected)
			continue
		console.connected = src
		BSC = console
		break
	RefreshParts()
	register_context()
	update_icon()

/obj/machinery/bodyscanner/relaymove(mob/user)
	if(user.incapacitated())
		return

	go_out()
	return

/obj/machinery/bodyscanner/examine(mob/user, infix)
	. = ..()

	if(!user.Adjacent(src))
		return

	if(occupant)
		. += "It has [SPAN_NOTICE("[occupant]")] inside."

/obj/machinery/bodyscanner/verb/eject()
	set src in oview(1)
	set category = "Object"
	set name = "Eject Body Scanner"

	if(usr.incapacitated())
		return

	go_out()
	add_fingerprint(usr)
	return

/obj/machinery/bodyscanner/verb/move_inside()
	set src in oview(1)
	set category = "Object"
	set name = "Enter Body Scanner"

	if(usr.incapacitated())
		return

	if(occupant)
		to_chat(usr, SPAN("warning", "The scanner is already occupied!"))
		return

	if(usr.abiotic())
		to_chat(usr, SPAN("warning", "The subject cannot have abiotic items on."))
		return

	usr.client.perspective = EYE_PERSPECTIVE
	usr.client.eye = src
	usr.forceMove(src)
	occupant = usr
	update_use_power(POWER_USE_ACTIVE)
	icon_state = "body_scanner_1"
	for(var/obj/O in src)
		if(O in component_parts)
			continue

		O.forceMove(get_turf(src))
	add_fingerprint(usr)
	return

/obj/machinery/bodyscanner/proc/go_out()
	if(!occupant || src.locked)
		return

	if(occupant.client)
		occupant.client.eye = occupant.client.mob
		occupant.client.perspective = MOB_PERSPECTIVE
	if(occupant in src)
		occupant.dropInto(loc)
	occupant = null

	for(var/obj/O in src)
		if(O in component_parts)
			continue

		O.dropInto(loc)
	update_use_power(POWER_USE_IDLE)
	src.icon_state = "body_scanner_0"
	return

/obj/machinery/bodyscanner/attackby(obj/item/W, mob/user)
	if(default_deconstruction_screwdriver(user, W))
		return

	if(default_deconstruction_crowbar(user, W))
		return

	if(default_part_replacement(user, W))
		return

	var/obj/item/grab/G = W
	if(!istype(G))
		return ..()

	var/mob/M = G.get_affecting_mob()
	if(!check_compatibility(M, user))
		return

	user.visible_message(SPAN("notice", "\The [user] begins placing \the [M] into \the [src]."), SPAN("notice", "You start placing \the [M] into \the [src]."))
	if(do_after(user, 20, src))
		if(!check_compatibility(M, user))
			return

		M.forceMove(src)
		src.occupant = M
		update_use_power(POWER_USE_ACTIVE)
		src.icon_state = "body_scanner_1"
		for(var/obj/O in src)
			if(O in component_parts)
				continue

			O.forceMove(loc)
		src.add_fingerprint(user)
		qdel(G)
	else
		return

/obj/machinery/bodyscanner/add_context(list/context, obj/item/held_item, mob/user)
	. = NONE

	if(isnull(held_item))
		return

	if(isScrewdriver(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "[panel_open ? "Close" : "Open"] maintenance hatch"
		return CONTEXTUAL_SCREENTIP_SET

	if(isCrowbar(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Dismantle"
		return CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item, /obj/item/grab))
		context[SCREENTIP_CONTEXT_LMB] = "Place into"
		return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/bodyscanner/proc/check_compatibility(mob/target, mob/user)
	if(!istype(user) || !istype(target))
		return FALSE

	if(!(occupant in src))
		go_out()

	if(!CanMouseDrop(target, user))
		return FALSE

	if(occupant)
		to_chat(user, SPAN("warning", "The scanner is already occupied!"))
		return FALSE

	if(target.abiotic())
		to_chat(user, SPAN("warning", "The subject cannot have abiotic items on."))
		return FALSE

	if(target.buckled)
		to_chat(user, SPAN("warning", "Unbuckle the subject before attempting to move them."))
		return FALSE

	for(var/mob/living/carbon/metroid/M in range(1,target))
		if(M.Victim == target)
			to_chat(user, "[target.name] will not fit into the sleeper because they have a metroid latched onto their head.")
			return FALSE

	return TRUE

/obj/machinery/bodyscanner/MouseDrop_T(mob/target, mob/user)
	if(!check_compatibility(target, user))
		return

	user.visible_message(SPAN("notice", "\The [user] begins placing \the [target] into \the [src]."), SPAN("notice", "You start placing \the [target] into \the [src]."))
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
		if(O in component_parts)
			continue

		O.forceMove(loc)
	src.add_fingerprint(user)

/obj/machinery/bodyscanner/ex_act(severity)
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

	return

/obj/machinery/body_scanconsole/ex_act(severity)

	switch(severity)
		if(1.0)
			// SN src = null
			qdel(src)
			return

		if(2.0)
			if (prob(50))
				// SN src = null
				qdel(src)
				return

	return

/obj/machinery/body_scanconsole/on_update_icon()
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

	component_types = list(
		/obj/item/circuitboard/bodyscanner_console
	)

/obj/machinery/body_scanconsole/Destroy()
	if(connected)
		connected.BSC = null
		connected = null
	return ..()

/obj/machinery/body_scanconsole/Initialize()
	for(var/D in GLOB.cardinal)
		src.connected = locate(/obj/machinery/bodyscanner, get_step(src, D))
		if(src.connected)
			var/obj/machinery/bodyscanner/BS = src.connected
			if(BS?.BSC)
				continue

			BS.BSC = src
			break

	return ..()

/obj/machinery/body_scanconsole/attackby(obj/item/W, mob/user)
	if(default_deconstruction_screwdriver(user, W))
		return

	if(default_deconstruction_crowbar(user, W))
		return

	if(default_part_replacement(user, W))
		return

/obj/machinery/body_scanconsole/attack_ai(user as mob)
	return src.attack_hand(user)

/obj/machinery/body_scanconsole/tgui_act(action, params)
	. = ..()

	if(.)
		return TRUE

	if(!allowed(usr))
		to_chat(usr, SPAN("warning", "Access denied."))
		return TRUE

	switch (action)
		if ("print")
			if (!src.connected)
				to_chat(usr, SPAN("warning", "Error: No body scanner connected."))
				return TRUE

			var/mob/living/carbon/human/occupant = src.connected.occupant
			if (!src.connected.occupant)
				to_chat(usr, SPAN("warning", "The body scanner is empty."))
				return TRUE

			if (!istype(occupant, /mob/living/carbon/human))
				to_chat(usr, SPAN("warning", "The body scanner cannot scan that lifeform."))
				return TRUE

			var/obj/item/paper/P = new /obj/item/paper/(loc)
			P.set_content("<tt>[connected.occupant.get_medical_data()]</tt>", "Body scan report - [occupant]", TRUE)
			return TRUE

		if ("eject")
			if (connected)
				connected.eject()
				return TRUE

/obj/machinery/body_scanconsole/tgui_data(mob/user)
	var/list/data = list()

	data["connected"] = connected
	data["medical_data"] = null

	if (connected && connected.occupant)
		data["medical_data"] = connected.occupant.get_medical_data_ui()

	return data

/obj/machinery/body_scanconsole/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "BodyScanner", name)
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/body_scanconsole/attack_hand(mob/user)
	if(..())
		return

	if(stat & (NOPOWER|BROKEN))
		return

	if(!connected || (connected.stat & (NOPOWER|BROKEN)))
		to_chat(user, SPAN("warning", "This console is not connected to a functioning body scanner."))
		return

	if (!(connected.occupant in connected))
		connected.go_out()
	if(!ishuman(connected.occupant))
		to_chat(user, SPAN("warning", "This device can only scan compatible lifeforms."))
		return

	tgui_interact(user)

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
		var/obj/item/organ/internal/cerebrum/brain/brain = H.internal_organs_by_name[BP_BRAIN]
		if (!brain || H.is_ic_dead() || (H.status_flags & FAKEDEATH) || (isundead(H) && !isfakeliving(H)))
			data["brain_activity"] = 0
		else if (!H.is_ic_dead())
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
	data["blood_volume_abs"] = H.get_blood_volume_abs()
	data["blood_volume_max"] = H.species.blood_volume

	data["blood_type"] = null

	if(H.b_type)
		data["blood_type"] = H.b_type

	data["blood_pressure"] = H.get_blood_pressure()
	data["blood_oxygenation"] = H.get_blood_oxygenation()
	data["warnings"] = list()

	if (H.chem_effects[CE_BLOCKAGE])
		data["warnings"] += list("Warning: Blood clotting detected, blood transfusion recommended.")

	data["body_temperature_c"] = CONV_KELVIN_CELSIUS(H.get_body_temperature())
	data["body_temperature_f"] = H.get_body_temperature()*1.8-459.67

	if(H.nutrition < 150)
		data["warnings"] += list("Warning: Very low nutrition value detected")

	data["brute_severity"] = capitalize(get_severity(H.getBruteLoss()))
	data["burn_severity"] = capitalize(get_severity(H.getFireLoss()))
	data["tox_severity"] = capitalize(get_severity(H.getToxLoss()))
	data["oxy_severity"] = capitalize(get_severity(H.getOxyLoss()))
	data["clone_severity"] = capitalize(get_severity(H.getCloneLoss()))
	data["rad_dose"] = H.radiation

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
				organ_data["damage"] += list("[capitalize(get_wound_severity(E.brute_ratio, (E.organ_flags & ORGAN_FLAG_HEALS_OVERKILL)))] physical trauma")

			if (E.burn_dam)
				organ_data["damage"] += list("[capitalize(get_wound_severity(E.burn_ratio, (E.organ_flags & ORGAN_FLAG_HEALS_OVERKILL)))] burns")

			if (E.brute_dam + E.burn_dam == 0)
				organ_data["damage"] += list("None")

			organ_data["status"] += list("[english_list(E.get_scan_results(), nothing_text = "", and_text = ", ")]")

		data["external_organs"] += list(organ_data)

	data["internal_organs"] = list()

	for (var/obj/item/organ/internal/I in H.internal_organs)
		if (I.hidden)
			continue // we shouldn't be able to see that

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
		var/obj/item/organ/internal/cerebrum/brain/brain = H.internal_organs_by_name[BP_BRAIN]
		if(!brain || H.is_ic_dead() || (H.status_flags & FAKEDEATH) || (isundead(H) && !isfakeliving(H)))
			brain_result = SPAN("danger", "none, patient is braindead")
		else if(!H.is_ic_dead())
			brain_result = "[round(max(0, (1 - brain.damage/brain.max_damage) * 100))]%"
	else
		brain_result = SPAN("danger", "ERROR - Nonstandard biology")
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
		dat += SPAN("danger", "Severe blood loss detected.")
	if(H.b_type)
		dat += "<b>Blood type:</b> [H.b_type]"
	dat += "<b>Blood pressure:</b> [H.get_blood_pressure()] ([H.get_blood_oxygenation()]% blood oxygenation)"
	dat += "<b>Blood volume:</b> [H.get_blood_volume_abs()]/[H.species.blood_volume]u"
	if (H.chem_effects[CE_BLOCKAGE])
		dat += SPAN("warning", "Warning: Blood clotting detected, blood transfusion recommended.")
	// Body temperature.
	dat += "<b>Body temperature:</b> [CONV_KELVIN_CELSIUS(H.get_body_temperature())]&deg;C ([H.get_body_temperature()*1.8-459.67]&deg;F)"
	if(H.nutrition < 150)
		dat += SPAN("warning", "Warning: Very low nutrition value detected.")

	dat += "<b>Physical Trauma:</b>\t[get_severity(H.getBruteLoss())]"
	dat += "<b>Burn Severity:</b>\t[get_severity(H.getFireLoss())]"
	dat += "<b>Systematic Organ Failure:</b>\t[get_severity(H.getToxLoss())]"
	dat += "<b>Oxygen Deprivation:</b>\t[get_severity(H.getOxyLoss())]"

	dat += "<b>Radiation dose:</b>\t[fmt_siunit(H.radiation, "Sv", 3)]"
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
		dat += SPAN("warning", "Warning: Medicine overdose detected.")
	if (H.chem_effects[CE_ALCOHOL])
		dat += SPAN("notice", "Alcohol byproducts detected in subject's blood.")
	if (H.chem_effects[CE_ALCOHOL_TOXIC])
		dat += SPAN("warning", "Warning: Subject suffering from alcohol intoxication.")

	var/list/table = list()
	table += "<table border='1'><tr><th>Organ</th><th>Damage</th><th>Status</th></tr>"
	for(var/obj/item/organ/external/E in H.organs)
		table += "<tr><td>[E.name]</td>"
		if(E.is_stump())
			table += "<td>N/A</td><td>Missing</td>"
		else
			table += "<td>"
			if(E.brute_dam)
				table += "[capitalize(get_wound_severity(E.brute_ratio, (E.organ_flags & ORGAN_FLAG_HEALS_OVERKILL)))] physical trauma"
			if(E.burn_dam)
				table += " [capitalize(get_wound_severity(E.burn_ratio, (E.organ_flags & ORGAN_FLAG_HEALS_OVERKILL)))] burns"
			if(E.brute_dam + E.burn_dam == 0)
				table += "None"
			table += "</td><td>[english_list(E.get_scan_results(), nothing_text = "", and_text = ", ")]</td></tr>"

	table += "<tr><td>---</td><td><b>INTERNAL ORGANS</b></td><td>---</td></tr>"
	for(var/obj/item/organ/internal/I in H.internal_organs)
		if (I.hidden)
			continue // we shouldn't be able to see that

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
